-- ============================================================
-- 003_orders.sql
-- App settings, promo codes, orders, order items and the RPCs
-- that price and place orders on the server.
-- Depends on: 001_foundation.sql (set_updated_at, is_admin)
--             002_addresses.sql  (addresses)
-- Run in: Supabase Dashboard -> SQL Editor
-- ============================================================

-- 1) app_settings (single row) ---------------------------------
-- Change delivery rules without shipping a new app version:
--   update public.app_settings set delivery_fee = 30, free_delivery_threshold = 500;
create table if not exists public.app_settings (
  id                      boolean primary key default true check (id),
  delivery_fee            numeric(10,2) not null default 2.99 check (delivery_fee >= 0),
  free_delivery_threshold numeric(10,2) not null default 50   check (free_delivery_threshold >= 0),
  currency_code           text not null default 'USD',
  updated_at              timestamptz not null default now()
);

insert into public.app_settings (id) values (true) on conflict (id) do nothing;

drop trigger if exists app_settings_set_updated_at on public.app_settings;
create trigger app_settings_set_updated_at
  before update on public.app_settings
  for each row execute function public.set_updated_at();

alter table public.app_settings enable row level security;

drop policy if exists "app_settings_select_all" on public.app_settings;
create policy "app_settings_select_all"
  on public.app_settings for select
  to anon, authenticated
  using (true);

drop policy if exists "app_settings_update_admin" on public.app_settings;
create policy "app_settings_update_admin"
  on public.app_settings for update
  to authenticated
  using (public.is_admin())
  with check (public.is_admin());

-- 2) promo_codes -----------------------------------------------
-- Customers can NOT read this table (no code enumeration): they validate
-- codes only through quote_order / place_order.
create table if not exists public.promo_codes (
  code             text primary key
                   check (code = upper(btrim(code)) and char_length(code) between 3 and 30),
  discount_percent numeric(5,2) not null
                   check (discount_percent > 0 and discount_percent <= 100),
  min_order_amount numeric(10,2) not null default 0 check (min_order_amount >= 0),
  max_uses         integer check (max_uses is null or max_uses > 0),
  used_count       integer not null default 0 check (used_count >= 0),
  starts_at        timestamptz not null default now(),
  expires_at       timestamptz,
  is_active        boolean not null default true,
  created_at       timestamptz not null default now()
);

alter table public.promo_codes enable row level security;

drop policy if exists "promo_codes_admin_all" on public.promo_codes;
create policy "promo_codes_admin_all"
  on public.promo_codes for all
  to authenticated
  using (public.is_admin())
  with check (public.is_admin());

-- Codes that used to be hard-coded in the app
insert into public.promo_codes (code, discount_percent) values
  ('TABANJA1', 10),
  ('TABANJA2', 20),
  ('TABANJA3', 15)
on conflict (code) do nothing;

-- 3) orders ----------------------------------------------------
create sequence if not exists public.order_number_seq start 1001;

create table if not exists public.orders (
  id               uuid primary key default gen_random_uuid(),
  order_number     bigint not null unique default nextval('public.order_number_seq'),
  user_id          uuid not null references auth.users (id) on delete restrict,

  status           text not null default 'pending'
                   check (status in ('pending','confirmed','preparing',
                                     'out_for_delivery','delivered','cancelled')),
  payment_method   text not null check (payment_method in ('cod','card','wallet')),
  payment_status   text not null default 'unpaid'
                   check (payment_status in ('unpaid','paid','failed','refunded')),

  subtotal         numeric(12,2) not null check (subtotal >= 0),
  discount_percent numeric(5,2)  not null default 0 check (discount_percent between 0 and 100),
  discount_amount  numeric(12,2) not null default 0 check (discount_amount >= 0),
  promo_code       text,
  delivery_fee     numeric(10,2) not null default 0 check (delivery_fee >= 0),
  total            numeric(12,2) not null check (total >= 0),
  currency_code    text not null default 'USD',

  -- Snapshots: an order must never change when the user edits/deletes an address
  address_id       uuid references public.addresses (id) on delete set null,
  customer_name    text not null default '',
  contact_phone    text not null,
  address_label    text not null,
  address_full     text not null,
  address_lat      double precision not null,
  address_lng      double precision not null,
  address_building text,
  address_floor    text,
  address_apartment text,
  delivery_notes   text,

  created_at       timestamptz not null default now(),
  updated_at       timestamptz not null default now()
);

create index if not exists orders_user_created_idx   on public.orders (user_id, created_at desc);
create index if not exists orders_status_created_idx on public.orders (status, created_at desc);

drop trigger if exists orders_set_updated_at on public.orders;
create trigger orders_set_updated_at
  before update on public.orders
  for each row execute function public.set_updated_at();

-- 4) order_items (price / name snapshots) ----------------------
create table if not exists public.order_items (
  id           uuid primary key default gen_random_uuid(),
  order_id     uuid not null references public.orders (id) on delete cascade,
  product_id   uuid references public.products (id) on delete set null,
  product_name text not null,
  unit         text,
  image_url    text,
  unit_price   numeric(10,2) not null check (unit_price >= 0),
  quantity     integer not null check (quantity between 1 and 99),
  line_total   numeric(12,2) not null check (line_total >= 0)
);

create index if not exists order_items_order_id_idx on public.order_items (order_id);

-- 5) RLS: customers read their own orders, nobody writes directly -
alter table public.orders      enable row level security;
alter table public.order_items enable row level security;

drop policy if exists "orders_select_own_or_admin" on public.orders;
create policy "orders_select_own_or_admin"
  on public.orders for select
  to authenticated
  using (user_id = auth.uid() or public.is_admin());

drop policy if exists "order_items_select_own_or_admin" on public.order_items;
create policy "order_items_select_own_or_admin"
  on public.order_items for select
  to authenticated
  using (
    exists (
      select 1 from public.orders o
      where o.id = order_items.order_id
        and (o.user_id = auth.uid() or public.is_admin())
    )
  );
-- No insert/update/delete policies: writes happen only inside the
-- security-definer functions below (place_order / cancel_order).
-- Admin status changes get their own policy in the dashboard phase.

-- 6) calculate_order: the single source of truth for pricing ----
-- Internal helper (not callable by clients). Raises business errors as
-- plain codes that the app maps to friendly messages:
--   EMPTY_CART, INVALID_ITEMS, PRODUCT_UNAVAILABLE, PROMO_INVALID, PROMO_MIN_ORDER
create or replace function public.calculate_order(
  p_items      jsonb,
  p_promo_code text    default null,
  p_lock_promo boolean default false
)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  v_requested int;
  v_found     int;
  v_max_qty   int;
  v_lines     jsonb;
  v_subtotal  numeric(12,2);
  v_code      text := nullif(upper(btrim(coalesce(p_promo_code, ''))), '');
  v_promo     public.promo_codes%rowtype;
  v_pct       numeric(5,2) := 0;
  v_discount  numeric(12,2) := 0;
  v_settings  public.app_settings%rowtype;
  v_fee       numeric(10,2);
begin
  if p_items is null
     or jsonb_typeof(p_items) <> 'array'
     or jsonb_array_length(p_items) = 0 then
    raise exception 'EMPTY_CART';
  end if;

  if jsonb_array_length(p_items) > 100 then
    raise exception 'INVALID_ITEMS';
  end if;

  begin
    if exists (
      select 1 from jsonb_array_elements(p_items) e
      where coalesce((e ->> 'quantity')::int, 0) not between 1 and 99
    ) then
      raise exception 'INVALID_ITEMS';
    end if;

    -- Prices ALWAYS come from the products table, never from the client.
    with parsed as (
      select (e ->> 'product_id')::uuid as product_id,
             (e ->> 'quantity')::int    as quantity
      from jsonb_array_elements(p_items) as e
    ),
    agg as (
      select product_id, sum(quantity)::int as quantity
      from parsed
      group by product_id
    )
    select
      (select count(*) from agg),
      count(p.id),
      max(a.quantity),
      jsonb_agg(
        jsonb_build_object(
          'product_id', p.id,
          'name',       p.name,
          'unit',       p.unit,
          'image_url',  p.image_url,
          'unit_price', round(p.price::numeric, 2),
          'quantity',   a.quantity,
          'line_total', round(p.price::numeric, 2) * a.quantity
        )
        order by p.name
      ),
      coalesce(sum(round(p.price::numeric, 2) * a.quantity), 0)
    into v_requested, v_found, v_max_qty, v_lines, v_subtotal
    from agg a
    join public.products p on p.id = a.product_id;
  exception
    when invalid_text_representation
      or numeric_value_out_of_range
      or invalid_parameter_value then
      raise exception 'INVALID_ITEMS';
  end;

  if v_requested is null or v_found <> v_requested or v_lines is null then
    raise exception 'PRODUCT_UNAVAILABLE';
  end if;

  if v_max_qty > 99 then
    raise exception 'INVALID_ITEMS';
  end if;

  if v_code is not null then
    if p_lock_promo then
      select * into v_promo from public.promo_codes where code = v_code for update;
    else
      select * into v_promo from public.promo_codes where code = v_code;
    end if;

    if not found
       or not v_promo.is_active
       or v_promo.starts_at > now()
       or (v_promo.expires_at is not null and v_promo.expires_at <= now())
       or (v_promo.max_uses is not null and v_promo.used_count >= v_promo.max_uses) then
      raise exception 'PROMO_INVALID';
    end if;

    if v_subtotal < v_promo.min_order_amount then
      raise exception 'PROMO_MIN_ORDER';
    end if;

    v_pct      := v_promo.discount_percent;
    v_discount := round(v_subtotal * v_pct / 100, 2);
  end if;

  select * into v_settings from public.app_settings where id;

  v_fee := case
             when (v_subtotal - v_discount) >= v_settings.free_delivery_threshold then 0
             else v_settings.delivery_fee
           end;

  return jsonb_build_object(
    'items',                   v_lines,
    'subtotal',                v_subtotal,
    'discount_percent',        v_pct,
    'discount_amount',         v_discount,
    'promo_code',              v_code,
    'delivery_fee',            v_fee,
    'total',                   v_subtotal - v_discount + v_fee,
    'free_delivery_threshold', v_settings.free_delivery_threshold,
    'currency_code',           v_settings.currency_code
  );
end;
$$;

-- 7) quote_order: authoritative totals for the checkout screen --
create or replace function public.quote_order(
  p_items      jsonb,
  p_promo_code text default null
)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
begin
  if auth.uid() is null then
    raise exception 'NOT_AUTHENTICATED';
  end if;

  return public.calculate_order(p_items, p_promo_code, false);
end;
$$;

-- 8) place_order ------------------------------------------------
-- p_expected_total: the total the customer saw. If the server total
-- differs (price changed meanwhile) the order is rejected with
-- PRICE_CHANGED so the customer re-confirms instead of being surprised.
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

  -- Only cash on delivery until the Paymob phase.
  if p_payment_method is distinct from 'cod' then
    raise exception 'PAYMENT_METHOD_UNSUPPORTED';
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

-- 9) cancel_order (customer, only while pending and unpaid) -----
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
     and payment_status = 'unpaid'
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

-- 10) Function permissions --------------------------------------
revoke all on function public.calculate_order(jsonb, text, boolean) from public, anon, authenticated;

revoke all on function public.quote_order(jsonb, text) from public, anon;
grant execute on function public.quote_order(jsonb, text) to authenticated;

revoke all on function public.place_order(jsonb, uuid, text, numeric, text) from public, anon;
grant execute on function public.place_order(jsonb, uuid, text, numeric, text) to authenticated;

revoke all on function public.cancel_order(uuid) from public, anon;
grant execute on function public.cancel_order(uuid) to authenticated;
