// POST /functions/v1/paymob-webhook?hmac=...   (called by Paymob, no user JWT)
//
// DEPLOY WITH:  supabase functions deploy paymob-webhook --no-verify-jwt
//
// Security: the request is accepted only if its HMAC-SHA512 (computed with
// PAYMOB_HMAC_SECRET over the documented fields) matches the `hmac` query
// parameter. Everything else is ignored with a 4xx.
//
// The database function apply_payment_result is idempotent, so Paymob
// retries and duplicate callbacks are safe.
//
// Secrets: PAYMOB_HMAC_SECRET
// Provided by Supabase: SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY

import { createClient } from 'npm:@supabase/supabase-js@2';
import { json } from '../_shared/cors.ts';
import {
  buildHmacString,
  classifyTransaction,
  computeHmac,
  orderIdFromReference,
  timingSafeEqualHex,
} from '../_shared/paymob.ts';

Deno.serve(async (req: Request) => {
  if (req.method !== 'POST') return json({ error: 'METHOD_NOT_ALLOWED' }, 405);

  const hmacSecret = Deno.env.get('PAYMOB_HMAC_SECRET');
  const supabaseUrl = Deno.env.get('SUPABASE_URL');
  const serviceKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY');
  if (!hmacSecret || !supabaseUrl || !serviceKey) {
    console.error('paymob-webhook: missing environment variables');
    return json({ error: 'SERVER_MISCONFIGURED' }, 500);
  }

  let payload: Record<string, unknown>;
  try {
    payload = await req.json();
  } catch {
    return json({ error: 'INVALID_JSON' }, 400);
  }

  // Paymob also posts card-token callbacks to the same URL: nothing to do.
  const obj = payload.obj;
  if (payload.type !== 'TRANSACTION' || obj === null || typeof obj !== 'object') {
    return json({ ignored: 'not_a_transaction' });
  }
  const transaction = obj as Record<string, unknown>;

  // 1) Authenticate the callback
  const received = (new URL(req.url).searchParams.get('hmac') ?? '').toLowerCase();
  const expected = await computeHmac(hmacSecret, buildHmacString(transaction));
  if (!received || !timingSafeEqualHex(expected, received)) {
    console.warn('paymob-webhook: invalid HMAC');
    return json({ error: 'INVALID_SIGNATURE' }, 401);
  }

  // 2) Interpret it
  const outcome = classifyTransaction(transaction);
  if (outcome === 'pending') return json({ ignored: 'pending' });

  const order = transaction.order as Record<string, unknown> | undefined;
  const orderId = orderIdFromReference(order?.merchant_order_id);
  if (!orderId) {
    console.warn('paymob-webhook: no order reference', { transactionId: transaction.id });
    return json({ ignored: 'no_order_reference' });
  }

  const sourceData = (transaction.source_data ?? {}) as Record<string, unknown>;
  const data = (transaction.data ?? {}) as Record<string, unknown>;

  // 3) Apply it (idempotent, amount-checked, inside one DB transaction)
  const supabase = createClient(supabaseUrl, serviceKey, { auth: { persistSession: false } });
  const { data: result, error } = await supabase.rpc('apply_payment_result', {
    p_order_id: orderId,
    p_transaction_id: transaction.id,
    p_status: outcome,
    p_amount_cents: transaction.amount_cents,
    p_currency: transaction.currency,
    p_method: sourceData.type ?? null,
    // Audit trail without card numbers / customer data.
    p_raw: {
      id: transaction.id,
      success: transaction.success,
      pending: transaction.pending,
      is_refunded: transaction.is_refunded,
      is_voided: transaction.is_voided,
      is_auth: transaction.is_auth,
      is_capture: transaction.is_capture,
      integration_id: transaction.integration_id,
      created_at: transaction.created_at,
      source_type: sourceData.type,
      source_sub_type: sourceData.sub_type,
      response_code: data.txn_response_code ?? null,
      message: data.message ?? null,
    },
  });

  if (error) {
    console.error('paymob-webhook: apply_payment_result failed', error);
    return json({ error: 'DB_ERROR' }, 500); // let Paymob retry
  }

  console.log('paymob-webhook', { orderId, transactionId: transaction.id, outcome, result });
  if (result === 'amount_mismatch' || result === 'paid_on_cancelled') {
    console.warn('paymob-webhook: needs manual review', { orderId, result });
  }
  return json({ ok: true, result });
});
