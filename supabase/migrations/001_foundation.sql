-- ============================================================
-- 001_foundation.sql
-- Profiles + role-based access (customer / admin)
-- Run in: Supabase Dashboard -> SQL Editor
-- ============================================================

-- 1) Role enum -------------------------------------------------
do $$
begin
  if not exists (select 1 from pg_type where typname = 'user_role') then
    create type public.user_role as enum ('customer', 'admin');
  end if;
end$$;

-- 2) Profiles table (1:1 with auth.users) ----------------------
create table if not exists public.profiles (
  id          uuid primary key references auth.users (id) on delete cascade,
  full_name   text        not null default '',
  phone       text,
  avatar_url  text,
  role        public.user_role not null default 'customer',
  created_at  timestamptz not null default now(),
  updated_at  timestamptz not null default now()
);

-- 3) Keep updated_at fresh -------------------------------------
create or replace function public.set_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

drop trigger if exists profiles_set_updated_at on public.profiles;
create trigger profiles_set_updated_at
  before update on public.profiles
  for each row execute function public.set_updated_at();

-- 4) Auto-create a profile on signup ---------------------------
-- The app passes the name as user metadata: data: {'full_name': name}
create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  insert into public.profiles (id, full_name)
  values (
    new.id,
    coalesce(new.raw_user_meta_data ->> 'full_name', '')
  )
  on conflict (id) do nothing;
  return new;
end;
$$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_user();

-- Backfill: profiles for users who signed up before this migration
insert into public.profiles (id, full_name)
select u.id, coalesce(u.raw_user_meta_data ->> 'full_name', '')
from auth.users u
on conflict (id) do nothing;

-- 5) is_admin() helper (used by RLS policies in later phases) ---
create or replace function public.is_admin()
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select exists (
    select 1 from public.profiles
    where id = auth.uid() and role = 'admin'
  );
$$;

-- 6) Row Level Security ----------------------------------------
alter table public.profiles enable row level security;

drop policy if exists "profiles_select_own_or_admin" on public.profiles;
create policy "profiles_select_own_or_admin"
  on public.profiles for select
  to authenticated
  using (id = auth.uid() or public.is_admin());

drop policy if exists "profiles_update_own" on public.profiles;
create policy "profiles_update_own"
  on public.profiles for update
  to authenticated
  using (id = auth.uid())
  with check (
    id = auth.uid()
    -- a user can never promote themselves: role must stay unchanged
    and role = (select p.role from public.profiles p where p.id = auth.uid())
  );

-- No insert/delete policies on purpose:
--   insert -> only the signup trigger (security definer)
--   delete -> cascades from auth.users

-- 7) Make yourself the first admin (run manually, once) --------
-- update public.profiles set role = 'admin'
-- where id = (select id from auth.users where email = 'YOUR_EMAIL_HERE');
