// Run with: deno test supabase/functions/_shared/paymob_test.ts
import { assertEquals } from 'jsr:@std/assert@1';
import {
  buildHmacString,
  classifyTransaction,
  computeHmac,
  normalizeEgyptPhone,
  orderIdFromReference,
  splitName,
  timingSafeEqualHex,
} from './paymob.ts';

// Sample "Transaction Processed" callback `obj` from Paymob's documentation.
const sampleObj = {
  id: 192036465,
  pending: false,
  amount_cents: 100000,
  success: true,
  is_auth: false,
  is_capture: false,
  is_standalone_payment: true,
  is_voided: false,
  is_refunded: false,
  is_3d_secure: true,
  integration_id: 4097558,
  has_parent_transaction: false,
  order: { id: 217503754 },
  created_at: '2024-06-13T11:33:44.592345',
  currency: 'EGP',
  source_data: { pan: '2346', type: 'card', sub_type: 'MasterCard' },
  error_occured: false,
  owner: 302852,
};

// Concatenated string published in the same documentation page.
const documentedString =
  '1000002024-06-13T11:33:44.592345EGPfalsefalse1920364654097558truefalsefalsefalsetruefalse217503754302852false2346MasterCardcardtrue';

Deno.test('buildHmacString matches the documented concatenation', () => {
  assertEquals(buildHmacString(sampleObj), documentedString);
});

Deno.test('computeHmac returns a 128-char hex SHA-512 digest', async () => {
  const hmac = await computeHmac('secret', documentedString);
  assertEquals(hmac.length, 128);
  assertEquals(/^[0-9a-f]+$/.test(hmac), true);
});

Deno.test('timingSafeEqualHex', () => {
  assertEquals(timingSafeEqualHex('abc', 'abc'), true);
  assertEquals(timingSafeEqualHex('abc', 'abd'), false);
  assertEquals(timingSafeEqualHex('abc', 'abcd'), false);
});

Deno.test('classifyTransaction', () => {
  assertEquals(classifyTransaction(sampleObj), 'paid');
  assertEquals(classifyTransaction({ ...sampleObj, success: false }), 'failed');
  assertEquals(classifyTransaction({ ...sampleObj, pending: true }), 'pending');
  assertEquals(classifyTransaction({ ...sampleObj, is_refunded: true }), 'refunded');
  assertEquals(classifyTransaction({ ...sampleObj, is_voided: true }), 'refunded');
  // Authorized but not captured yet is NOT money received.
  assertEquals(classifyTransaction({ ...sampleObj, is_auth: true, is_capture: false }), 'failed');
  assertEquals(classifyTransaction({ ...sampleObj, is_auth: true, is_capture: true }), 'paid');
});

Deno.test('orderIdFromReference', () => {
  const id = '0b9a5c3e-1f7d-4a3b-9c1e-2d4f6a8b0c1d';
  assertEquals(orderIdFromReference(`${id}_1767000000000`), id);
  assertEquals(orderIdFromReference(id.toUpperCase()), id);
  assertEquals(orderIdFromReference('not-a-uuid'), null);
  assertEquals(orderIdFromReference(null), null);
});

Deno.test('normalizeEgyptPhone', () => {
  assertEquals(normalizeEgyptPhone('01012345678'), '+201012345678');
  assertEquals(normalizeEgyptPhone('010 1234 5678'), '+201012345678');
  assertEquals(normalizeEgyptPhone('201012345678'), '+201012345678');
  assertEquals(normalizeEgyptPhone('+201012345678'), '+201012345678');
});

Deno.test('splitName', () => {
  assertEquals(splitName('Abdallah Ahmed Ali'), { firstName: 'Abdallah', lastName: 'Ahmed Ali' });
  assertEquals(splitName('Abdallah'), { firstName: 'Abdallah', lastName: 'NA' });
  assertEquals(splitName('  '), { firstName: 'NA', lastName: 'NA' });
});
