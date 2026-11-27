# Edge Functions

| Function | Called by | JWT |
|---|---|---|
| `create-payment` | The Flutter app (logged-in customer) | required |
| `paymob-webhook` | Paymob servers | **none** (authenticated by HMAC) |

## Secrets (one time, test keys first)

```bash
supabase secrets set \
  PAYMOB_SECRET_KEY=egy_sk_test_... \
  PAYMOB_PUBLIC_KEY=egy_pk_test_... \
  PAYMOB_HMAC_SECRET=... \
  PAYMOB_CARD_INTEGRATION_ID=1234567 \
  PAYMOB_WALLET_INTEGRATION_ID=7654321
# optional
supabase secrets set PAYMOB_RETURN_URL=https://sooq.app/payment-return
```

The secret key, public key and the integration ids must all be from the same
mode (test or live). Never put them in the Flutter app.

## Deploy

```bash
supabase functions deploy create-payment
supabase functions deploy paymob-webhook --no-verify-jwt
```

## Paymob dashboard

Developers -> Payment Integrations -> each integration (card + wallet): set
**Transaction processed callback** to

```
https://<project-ref>.supabase.co/functions/v1/paymob-webhook
```

(The same URL is also sent with every intention. Receiving the callback twice
is safe: `apply_payment_result` is idempotent.)

## Tests

```bash
deno test supabase/functions/_shared/paymob_test.ts
```

## Go-live checklist

1. Replace the four keys / ids with the **live** ones and set `PAYMOB_HMAC_SECRET` from the live account.
2. Set the live callback URL on the live integrations.
3. Schedule `expire_unpaid_online_orders` (see `004_payments.sql`).
