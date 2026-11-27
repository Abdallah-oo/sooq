// POST /functions/v1/create-payment   body: { order_id }
//
// Creates a Paymob payment intention for one of the caller's own orders and
// returns the hosted checkout URL. The amount ALWAYS comes from the database
// (orders.total), never from the request.
//
// Secrets (supabase secrets set ...):
//   PAYMOB_SECRET_KEY, PAYMOB_PUBLIC_KEY,
//   PAYMOB_CARD_INTEGRATION_ID, PAYMOB_WALLET_INTEGRATION_ID
// Optional: PAYMOB_BASE_URL (default https://accept.paymob.com),
//           PAYMOB_RETURN_URL (default https://sooq.app/payment-return)
// Provided by Supabase automatically: SUPABASE_URL, SUPABASE_ANON_KEY, SUPABASE_SERVICE_ROLE_KEY

import { createClient } from 'npm:@supabase/supabase-js@2';
import { corsHeaders, json } from '../_shared/cors.ts';
import {
  buildCheckoutUrl,
  createIntention,
  makeSpecialReference,
  normalizeEgyptPhone,
  splitName,
} from '../_shared/paymob.ts';

const UUID = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i;
const DEFAULT_RETURN_URL = 'https://sooq.app/payment-return';

function readEnv() {
  const supabaseUrl = Deno.env.get('SUPABASE_URL');
  const anonKey = Deno.env.get('SUPABASE_ANON_KEY');
  const serviceKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY');
  const secretKey = Deno.env.get('PAYMOB_SECRET_KEY');
  const publicKey = Deno.env.get('PAYMOB_PUBLIC_KEY');
  const cardIntegrationId = Deno.env.get('PAYMOB_CARD_INTEGRATION_ID');
  const walletIntegrationId = Deno.env.get('PAYMOB_WALLET_INTEGRATION_ID');

  if (
    !supabaseUrl || !anonKey || !serviceKey || !secretKey ||
    !publicKey || !cardIntegrationId || !walletIntegrationId
  ) {
    return null;
  }

  return {
    supabaseUrl,
    anonKey,
    serviceKey,
    secretKey,
    publicKey,
    cardIntegrationId,
    walletIntegrationId,
    baseUrl: Deno.env.get('PAYMOB_BASE_URL') ?? undefined,
    returnUrl: Deno.env.get('PAYMOB_RETURN_URL') ?? DEFAULT_RETURN_URL,
  };
}

Deno.serve(async (req: Request) => {
  if (req.method === 'OPTIONS') return new Response('ok', { headers: corsHeaders });
  if (req.method !== 'POST') return json({ error: 'METHOD_NOT_ALLOWED' }, 405);

  const env = readEnv();
  if (!env) {
    console.error('create-payment: missing environment variables');
    return json({ error: 'SERVER_MISCONFIGURED' }, 500);
  }

  // 1) Who is calling? (the JWT is verified by the platform, we also resolve the user)
  const authHeader = req.headers.get('Authorization');
  if (!authHeader) return json({ error: 'NOT_AUTHENTICATED' }, 401);

  const userClient = createClient(env.supabaseUrl, env.anonKey, {
    global: { headers: { Authorization: authHeader } },
    auth: { persistSession: false },
  });
  const { data: userData, error: userError } = await userClient.auth.getUser();
  if (userError || !userData.user) return json({ error: 'NOT_AUTHENTICATED' }, 401);
  const user = userData.user;

  // 2) Input
  let orderId = '';
  try {
    const body = await req.json();
    orderId = String(body?.order_id ?? '');
  } catch {
    return json({ error: 'INVALID_REQUEST' }, 400);
  }
  if (!UUID.test(orderId)) return json({ error: 'INVALID_REQUEST' }, 400);

  // 3) Load the order with the USER's client: RLS guarantees it is their own.
  const { data: order, error: orderError } = await userClient
    .from('orders')
    .select(
      'id, order_number, status, payment_method, payment_status, total, currency_code, customer_name, contact_phone',
    )
    .eq('id', orderId)
    .maybeSingle();

  if (orderError) {
    console.error('create-payment: order query failed', orderError);
    return json({ error: 'SERVER_ERROR' }, 500);
  }
  if (!order) return json({ error: 'ORDER_NOT_FOUND' }, 404);

  const isOnline = order.payment_method === 'card' || order.payment_method === 'wallet';
  const isPayable =
    order.status === 'pending' && ['unpaid', 'failed'].includes(order.payment_status);
  if (!isOnline || !isPayable) return json({ error: 'ORDER_NOT_PAYABLE' }, 409);
  if (String(order.currency_code).toUpperCase() !== 'EGP') {
    return json({ error: 'CURRENCY_UNSUPPORTED' }, 409);
  }

  const integrationId = Number(
    order.payment_method === 'card' ? env.cardIntegrationId : env.walletIntegrationId,
  );
  if (!Number.isInteger(integrationId)) {
    console.error('create-payment: integration id is not a number');
    return json({ error: 'SERVER_MISCONFIGURED' }, 500);
  }

  // 4) Create the intention (amount in piasters, from the database)
  const amountCents = Math.round(Number(order.total) * 100);
  const { firstName, lastName } = splitName(order.customer_name ?? '');

  let intention;
  try {
    intention = await createIntention(
      env.secretKey,
      {
        amount: amountCents,
        currency: 'EGP',
        paymentMethods: [integrationId],
        // One line item: its amount must equal the total, so no rounding drift.
        items: [
          {
            name: `Sooq order #${order.order_number}`,
            amount: amountCents,
            description: `Order #${order.order_number}`,
            quantity: 1,
          },
        ],
        billingData: {
          first_name: firstName,
          last_name: lastName,
          email: user.email ?? 'customer@sooq.app',
          phone_number: normalizeEgyptPhone(order.contact_phone),
          country: 'EG',
          city: 'NA',
          street: 'NA',
          building: 'NA',
          floor: 'NA',
          apartment: 'NA',
          state: 'NA',
        },
        specialReference: makeSpecialReference(order.id),
        notificationUrl: `${env.supabaseUrl}/functions/v1/paymob-webhook`,
        redirectionUrl: env.returnUrl,
        extras: { order_id: order.id },
      },
      env.baseUrl,
    );
  } catch (error) {
    console.error('create-payment: Paymob error', error);
    return json({ error: 'PAYMENT_PROVIDER_ERROR' }, 502);
  }

  // 5) Remember the Paymob ids (orders has no client write policy -> service role)
  const admin = createClient(env.supabaseUrl, env.serviceKey, { auth: { persistSession: false } });
  const { error: updateError } = await admin
    .from('orders')
    .update({
      paymob_intention_id: intention.id,
      paymob_order_id: intention.intention_order_id,
    })
    .eq('id', order.id);
  if (updateError) console.error('create-payment: could not store Paymob ids', updateError);

  return json({
    checkout_url: buildCheckoutUrl(env.publicKey, intention.client_secret, env.baseUrl),
    return_url: env.returnUrl,
  });
});
