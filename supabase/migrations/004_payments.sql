-- ============================================================
-- 004_payments.sql
-- Online payments (Paymob): payment columns, transaction log,
-- idempotent payment result handler, online checkout in place_order.
-- Depends on: 001, 002, 003
-- Run in: Supabase Dashboard -> SQL Editor
-- ============================================================

-- 0) BEFORE YOU RUN: Paymob only charges in EGP --------------------
-- Run this once (pick your own fee / threshold) so online payment works:
--
--   update public.app_settings
--      set currency_code = 'EGP',
--          delivery_fee = 30,
--          free_delivery_threshold = 500;
--
-- While currency_code <> 'EGP', place_order rejects card / wallet orders
-- (CURRENCY_UNSUPPORTED) and the app hides those methods.

-- 1) Payment columns on orders ----------------------------------
alter table public.orders
  add column if not exists paymob_intention_id text,
  add column if not exists paymob_order_id     bigint,
  add column if not exists paid_at             timestamptz;

create index if not exists orders_paymob_order_idx on public.orders (paymob_order_id);

-- 2) payment_transactions: audit log + idempotency ---------------
-- One row per (Paymob transaction, outcome). Written only by
-- apply_payment_result (called from the webhook Edge Function).
create table if not exists public.payment_transactions (
  transaction_id bigint  not null,
  status         text    not null check (status in ('paid','failed','refunded')),
  order_id       uuid    not null references public.orders (id) on delete cascade,
  amount_cents   integer not null,
  currency       text,
  method         text,
  accepted       boolean not null,   -- false when amount / currency did not match the order
  raw            jsonb   not null default '{}'::jsonb,
  created_at     timestamptz not null default now(),
  primary key (transaction_id, status)
);

create index if not exists payment_transactions_order_idx
  on public.payment_transactions (order_id);

alter table public.payment_transactions enable row level security;

drop policy if exists "payment_transactions_select_admin" on public.payment_transactions;
create policy "payment_transactions_select_admin"
  on public.payment_transactions for select
  to authenticated
  using (public.is_admin());
-- No other policies: customers never read or write this table.

-- 3) apply_payment_result: the ONLY place that changes payment_status
-- Called by the paymob-webhook Edge Function with the service role.
-- Returns: paid | paid_on_cancelled | failed | refunded | duplicate |
--          amount_mismatch | order_not_found
create or replace function public.apply_payment_result(
  p_order_id       uuid,
  p_transaction_id bigint,
  p_status         text,
  p_amount_cents   integer,
  p_currency       text,
  p_method         text,
  p_raw            jsonb
)
returns text
language plpgsql
security definer
set search_path = public
as $$
declare
  v_order    public.orders%rowtype;
  v_accepted boolean;
  v_rows     integer;
begin
  if p_status not in ('paid', 'failed', 'refunded') then
    raise exception 'INVALID_STATUS';
  end if;

  -- Lock the order: two callbacks for the same order are processed one by one.
  select * into v_order from public.orders where id = p_order_id for update;
  if not found then
    return 'order_not_found';
  end if;

  -- Never trust a "paid" callback whose amount / currency differs from the order.
  v_accepted := (p_status <> 'paid')
    or (p_amount_cents = round(v_order.total * 100)::integer
        and upper(coalesce(p_currency, '')) = upper(v_order.currency_code));

  insert into public.payment_transactions
    (transaction_id, status, order_id, amount_cents, currency, method, accepted, raw)
  values
    (p_transaction_id, p_status, p_order_id, p_amount_cents, p_currency, p_method,
     v_accepted, coalesce(p_raw, '{}'::jsonb))
  on conflict (transaction_id, status) do nothing;

  get diagnostics v_rows = row_count;
  if v_rows = 0 then
    return 'duplicate';   -- Paymob retried / sent the callback twice
  end if;

  if not v_accepted then
    return 'amount_mismatch';
  end if;

  if p_status = 'paid' then
    update public.orders
       set payment_status = 'paid',
           paid_at = coalesce(paid_at, now())
     where id = p_order_id
       and payment_status in ('unpaid', 'failed');

    -- Paid after the order was cancelled / expired: needs a manual refund.
    return case when v_order.status = 'cancelled' then 'paid_on_cancelled' else 'paid' end;

  elsif p_status = 'failed' then
    -- A late "failed" must never undo a successful payment.
    update public.orders
       set payment_status = 'failed'
     where id = p_order_id
       and payment_status = 'unpaid';
    return 'failed';

  else
    update public.orders
       set payment_status = 'refunded'
     where id = p_order_id
       and payment_status = 'paid';
    return 'refunded';
  end if;
end;
$$;

revoke all on function public.apply_payment_result(uuid, bigint, text, integer, text, text, jsonb)
  from public, anon, authenticated;
grant execute on function public.apply_payment_result(uuid, bigint, text, integer, text, text, jsonb)
  to service_role;

-- 4) place_order: now accepts card / wallet ----------------------
-- Same function as 003 with two changes:
--   * payment method may be cod | card | wallet (else INVALID_PAYMENT_METHOD)
--   * online methods require the order currency to be EGP (CURRENCY_UNSUPPORTED)
-- Online orders are created unpaid; the app then asks the create-payment
-- Edge Function for a checkout session.
create or replace function public.place_order(
  p_items          jsonb,
  p_address_id     uuid,
  p_payment_method text,
  p_expected_total numeric default null,
  p_promo_code     text    default null
)
returns public.orders
language plpgsql
security definer
set search_path = public
as $$
declare
  v_uid   uuid := auth.uid();
  v_addr  public.addresses%rowtype;
  v_calc  jsonb;
  v_order public.orders%rowtype;
  v_name  text;
begin
  if v_uid is null then
    raise exception 'NOT_AUTHENTICATED';
  end if;

  if p_payment_method is null or p_payment_method not in ('cod', 'card', 'wallet') then
    raise exception 'INVALID_PAYMENT_METHOD';
  end if;

  select * into v_addr
  from public.addresses
  where id = p_address_id and user_id = v_uid;

  if not found then
    raise exception 'ADDRESS_NOT_FOUND';
  end if;

  if v_addr.phone is null or btrim(v_addr.phone) = '' then
    raise exception 'ADDRESS_PHONE_REQUIRED';
  end if;

  v_calc := public.calculate_order(p_items, p_promo_code, true);

  if p_payment_method <> 'cod' and upper(v_calc ->> 'currency_code') <> 'EGP' then
    raise exception 'CURRENCY_UNSUPPORTED';
  end if;

  if p_expected_total is not null
     and abs((v_calc ->> 'total')::numeric - p_expected_total) > 0.01 then
    raise exception 'PRICE_CHANGED';
  end if;

  select coalesce(full_name, '') into v_name
  from public.profiles
  where id = v_uid;

  insert into public.orders (
    user_id, payment_method,
    subtotal, discount_percent, discount_amount, promo_code,
    delivery_fee, total, currency_code,
    address_id, customer_name, contact_phone,
    address_label, address_full, address_lat, address_lng,
    address_building, address_floor, address_apartment, delivery_notes
  )
  values (
    v_uid, p_payment_method,
    (v_calc ->> 'subtotal')::numeric,
    (v_calc ->> 'discount_percent')::numeric,
    (v_calc ->> 'discount_amount')::numeric,
    v_calc ->> 'promo_code',
    (v_calc ->> 'delivery_fee')::numeric,
    (v_calc ->> 'total')::numeric,
    v_calc ->> 'currency_code',
    v_addr.id, coalesce(v_name, ''), btrim(v_addr.phone),
    v_addr.label, v_addr.full_address, v_addr.latitude, v_addr.longitude,
    v_addr.building, v_addr.floor, v_addr.apartment, v_addr.notes
  )
  returning * into v_order;

  insert into public.order_items (
    order_id, product_id, product_name, unit, image_url,
    unit_price, quantity, line_total
  )
  select
    v_order.id,
    (l ->> 'product_id')::uuid,
    l ->> 'name',
    l ->> 'unit',
    l ->> 'image_url',
    (l ->> 'unit_price')::numeric,
    (l ->> 'quantity')::int,
    (l ->> 'line_total')::numeric
  from jsonb_array_elements(v_calc -> 'items') as l;

  if v_calc ->> 'promo_code' is not null then
    update public.promo_codes
       set used_count = used_count + 1
     where code = v_calc ->> 'promo_code';
  end if;

  return v_order;
end;
$$;

revoke all on function public.place_order(jsonb, uuid, text, numeric, text) from public, anon;
grant execute on function public.place_order(jsonb, uuid, text, numeric, text) to authenticated;

-- 5) cancel_order: a failed online payment can be cancelled too ---
create or replace function public.cancel_order(p_order_id uuid)
returns public.orders
language plpgsql
security definer
set search_path = public
as $$
declare
  v_order public.orders%rowtype;
begin
  if auth.uid() is null then
    raise exception 'NOT_AUTHENTICATED';
  end if;

  update public.orders
     set status = 'cancelled'
   where id = p_order_id
     and user_id = auth.uid()
     and status = 'pending'
     and payment_status in ('unpaid', 'failed')
  returning * into v_order;

  if not found then
    if exists (select 1 from public.orders
               where id = p_order_id and user_id = auth.uid()) then
      raise exception 'ORDER_NOT_CANCELLABLE';
    end if;
    raise exception 'ORDER_NOT_FOUND';
  end if;

  return v_order;
end;
$$;

revoke all on function public.cancel_order(uuid) from public, anon;
grant execute on function public.cancel_order(uuid) to authenticated;

-- 6) Expire abandoned online orders ------------------------------
-- Cancels card / wallet orders that were never paid.
create or replace function public.expire_unpaid_online_orders(p_minutes integer default 60)
returns integer
language plpgsql
security definer
set search_path = public
as $$
declare
  v_count integer;
begin
  update public.orders
     set status = 'cancelled'
   where status = 'pending'
     and payment_method in ('card', 'wallet')
     and payment_status in ('unpaid', 'failed')
     and created_at < now() - make_interval(mins => p_minutes);

  get diagnostics v_count = row_count;
  return v_count;
end;
$$;

revoke all on function public.expire_unpaid_online_orders(integer) from public, anon, authenticated;
grant execute on function public.expire_unpaid_online_orders(integer) to service_role;

-- Schedule it every 15 minutes (enable the pg_cron extension first:
-- Dashboard -> Database -> Extensions), then run once:
--
--   select cron.schedule(
--     'expire-unpaid-online-orders',
--     '*/15 * * * *',
--     $$ select public.expire_unpaid_online_orders(60) $$
--   );
// تقدر تراجع المهام المسجلة باستخدام:
-- select *
-- from cron.job;
//وتراجع سجل التشغيل باستخدام:
-- select *
-- from cron.job_run_details
-- order by start_time desc
-- limit 10;
