-- ============================================================
-- 002_addresses.sql
-- Customer delivery addresses (map location + details)
-- Depends on: 001_foundation.sql (set_updated_at, is_admin)
-- Run in: Supabase Dashboard -> SQL Editor
-- ============================================================

-- 1) Table -----------------------------------------------------
create table if not exists public.addresses (
  id           uuid primary key default gen_random_uuid(),
  user_id      uuid not null default auth.uid()
               references auth.users (id) on delete cascade,
  label        text not null default 'Home'
               check (char_length(label) between 1 and 30),
  full_address text not null
               check (char_length(btrim(full_address)) between 1 and 500),
  latitude     double precision not null check (latitude  between -90  and 90),
  longitude    double precision not null check (longitude between -180 and 180),
  building     text check (char_length(building)  <= 100),
  floor        text check (char_length(floor)     <= 50),
  apartment    text check (char_length(apartment) <= 50),
  phone        text check (char_length(phone)     <= 20),
  notes        text check (char_length(notes)     <= 300),
  is_default   boolean not null default false,
  created_at   timestamptz not null default now(),
  updated_at   timestamptz not null default now()
);

create index if not exists addresses_user_id_idx on public.addresses (user_id);

-- At most one default address per user (enforced by the DB, not the app)
create unique index if not exists addresses_one_default_per_user
  on public.addresses (user_id) where is_default;

-- 2) updated_at ------------------------------------------------
drop trigger if exists addresses_set_updated_at on public.addresses;
create trigger addresses_set_updated_at
  before update on public.addresses
  for each row execute function public.set_updated_at();

-- 3) Default-address rules -------------------------------------
-- a) the user's first address is always the default
-- b) marking an address as default un-marks the previous one
create or replace function public.addresses_enforce_default()
returns trigger
language plpgsql
as $$
begin
  if tg_op = 'INSERT'
     and not exists (select 1 from public.addresses where user_id = new.user_id) then
    new.is_default := true;
  end if;

  if new.is_default then
    update public.addresses
       set is_default = false
     where user_id = new.user_id
       and id <> new.id
       and is_default;
  end if;

  return new;
end;
$$;

drop trigger if exists addresses_enforce_default on public.addresses;
create trigger addresses_enforce_default
  before insert or update of is_default on public.addresses
  for each row execute function public.addresses_enforce_default();

-- c) deleting the default promotes the most recent remaining address
create or replace function public.addresses_promote_default_after_delete()
returns trigger
language plpgsql
as $$
begin
  if old.is_default then
    update public.addresses
       set is_default = true
     where id = (
       select id from public.addresses
        where user_id = old.user_id
        order by created_at desc
        limit 1
     );
  end if;
  return null;
end;
$$;

drop trigger if exists addresses_promote_default on public.addresses;
create trigger addresses_promote_default
  after delete on public.addresses
  for each row execute function public.addresses_promote_default_after_delete();

-- 4) Row Level Security ----------------------------------------
alter table public.addresses enable row level security;

drop policy if exists "addresses_select_own_or_admin" on public.addresses;
create policy "addresses_select_own_or_admin"
  on public.addresses for select
  to authenticated
  using (user_id = auth.uid() or public.is_admin());

drop policy if exists "addresses_insert_own" on public.addresses;
create policy "addresses_insert_own"
  on public.addresses for insert
  to authenticated
  with check (user_id = auth.uid());

drop policy if exists "addresses_update_own" on public.addresses;
create policy "addresses_update_own"
  on public.addresses for update
  to authenticated
  using (user_id = auth.uid())
  with check (user_id = auth.uid());

drop policy if exists "addresses_delete_own" on public.addresses;
create policy "addresses_delete_own"
  on public.addresses for delete
  to authenticated
  using (user_id = auth.uid());
