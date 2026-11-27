// Paymob helpers shared by create-payment and paymob-webhook.
// Pure functions + one fetch call, so they can be unit-tested (see paymob_test.ts).

const DEFAULT_BASE_URL = 'https://accept.paymob.com';

// ---------------------------------------------------------------------------
// Intention API (https://accept.paymob.com/v1/intention/)
// ---------------------------------------------------------------------------

export interface IntentionRequest {
  /** Total in cents (piasters). Must equal the sum of the items' amounts. */
  amount: number;
  currency: string;
  paymentMethods: number[];
  items: { name: string; amount: number; description: string; quantity: number }[];
  billingData: Record<string, string>;
  /** Returned by Paymob in callbacks as `order.merchant_order_id`. */
  specialReference: string;
  notificationUrl: string;
  redirectionUrl: string;
  extras?: Record<string, unknown>;
}

export interface IntentionResponse {
  id: string;
  client_secret: string;
  intention_order_id: number;
}

export async function createIntention(
  secretKey: string,
  request: IntentionRequest,
  baseUrl: string = DEFAULT_BASE_URL,
): Promise<IntentionResponse> {
  const response = await fetch(`${baseUrl}/v1/intention/`, {
    method: 'POST',
    headers: {
      Authorization: `Token ${secretKey}`,
      'Content-Type': 'application/json',
    },
    body: JSON.stringify({
      amount: request.amount,
      currency: request.currency,
      payment_methods: request.paymentMethods,
      items: request.items,
      billing_data: request.billingData,
      special_reference: request.specialReference,
      notification_url: request.notificationUrl,
      redirection_url: request.redirectionUrl,
      extras: request.extras ?? {},
    }),
    signal: AbortSignal.timeout(15_000),
  });

  if (!response.ok) {
    // Log the provider's answer for debugging, never forward it to the app.
    const detail = await response.text().catch(() => '');
    throw new Error(`Paymob intention failed (${response.status}): ${detail}`);
  }

  const data = await response.json();
  if (!data?.client_secret) {
    throw new Error('Paymob intention response has no client_secret');
  }
  return data as IntentionResponse;
}

/** Hosted Unified Checkout page: the card / wallet details are typed on Paymob's page, never in our app. */
export function buildCheckoutUrl(
  publicKey: string,
  clientSecret: string,
  baseUrl: string = DEFAULT_BASE_URL,
): string {
  const params = new URLSearchParams({ publicKey, clientSecret });
  return `${baseUrl}/unifiedcheckout/?${params.toString()}`;
}

// ---------------------------------------------------------------------------
// Transaction callback HMAC (SHA-512)
// Fields and order: developers.paymob.com -> Webhook callbacks & HMAC ->
// "HMAC Transaction Callback" (Transaction Processed, POST).
// ---------------------------------------------------------------------------

const HMAC_FIELDS: readonly string[] = [
  'amount_cents',
  'created_at',
  'currency',
  'error_occured',
  'has_parent_transaction',
  'id',
  'integration_id',
  'is_3d_secure',
  'is_auth',
  'is_capture',
  'is_refunded',
  'is_standalone_payment',
  'is_voided',
  'order.id',
  'owner',
  'pending',
  'source_data.pan',
  'source_data.sub_type',
  'source_data.type',
  'success',
];

function getPath(source: unknown, path: string): unknown {
  return path.split('.').reduce<unknown>((current, key) => {
    if (current !== null && typeof current === 'object') {
      return (current as Record<string, unknown>)[key];
    }
    return undefined;
  }, source);
}

/** Concatenation (no separator) of the 20 fields of `obj`, booleans as "true" / "false". */
export function buildHmacString(obj: Record<string, unknown>): string {
  return HMAC_FIELDS.map((path) => {
    const value = getPath(obj, path);
    return value === null || value === undefined ? '' : String(value);
  }).join('');
}

export async function computeHmac(secret: string, message: string): Promise<string> {
  const encoder = new TextEncoder();
  const key = await crypto.subtle.importKey(
    'raw',
    encoder.encode(secret),
    { name: 'HMAC', hash: 'SHA-512' },
    false,
    ['sign'],
  );
  const signature = await crypto.subtle.sign('HMAC', key, encoder.encode(message));
  return Array.from(new Uint8Array(signature))
    .map((byte) => byte.toString(16).padStart(2, '0'))
    .join('');
}

/** Constant-time comparison so the signature can't be guessed byte by byte. */
export function timingSafeEqualHex(a: string, b: string): boolean {
  if (a.length !== b.length) return false;
  let diff = 0;
  for (let i = 0; i < a.length; i++) {
    diff |= a.charCodeAt(i) ^ b.charCodeAt(i);
  }
  return diff === 0;
}

// ---------------------------------------------------------------------------
// Transaction interpretation
// ---------------------------------------------------------------------------

export type TransactionOutcome = 'paid' | 'failed' | 'refunded' | 'pending';

/** Paymob has no event names: the outcome is read from boolean fields. */
export function classifyTransaction(obj: Record<string, unknown>): TransactionOutcome {
  if (obj.is_refunded === true || obj.is_voided === true) return 'refunded';
  if (obj.pending === true) return 'pending';
  const capturedIfAuth = obj.is_auth !== true || obj.is_capture === true;
  if (obj.success === true && capturedIfAuth) return 'paid';
  return 'failed';
}

const UUID_PREFIX = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}/i;

/** special_reference is `<order uuid>_<timestamp>`: returns the order uuid (or null). */
export function orderIdFromReference(reference: unknown): string | null {
  if (typeof reference !== 'string') return null;
  const match = reference.match(UUID_PREFIX);
  return match ? match[0].toLowerCase() : null;
}

export function makeSpecialReference(orderId: string): string {
  return `${orderId}_${Date.now()}`;
}

// ---------------------------------------------------------------------------
// Billing data helpers
// ---------------------------------------------------------------------------

/** "01012345678" -> "+201012345678"; keeps numbers that already have a country code. */
export function normalizeEgyptPhone(raw: string): string {
  const cleaned = raw.replace(/[\s()-]/g, '');
  if (cleaned.startsWith('+')) return cleaned;
  if (/^01\d{9}$/.test(cleaned)) return `+2${cleaned}`;
  if (/^201\d{9}$/.test(cleaned)) return `+${cleaned}`;
  return cleaned;
}

export function splitName(fullName: string): { firstName: string; lastName: string } {
  const parts = fullName.trim().split(/\s+/).filter(Boolean);
  if (parts.length === 0) return { firstName: 'NA', lastName: 'NA' };
  if (parts.length === 1) return { firstName: parts[0], lastName: 'NA' };
  return { firstName: parts[0], lastName: parts.slice(1).join(' ') };
}
