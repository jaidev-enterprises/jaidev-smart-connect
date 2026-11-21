-- JAIDEV SMART CONNECT database schema
-- Run this entire file in Supabase Dashboard > SQL Editor.
-- Uses Supabase Auth. Never put the service_role key in the website.

create extension if not exists pgcrypto;

create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  email text,
  role text not null default 'customer' check (role in ('admin','staff','customer')),
  created_at timestamptz not null default now()
);

create table if not exists public.customers (
  id uuid primary key default gen_random_uuid(),
  business_name text not null,
  slug text not null unique,
  phone text,
  category text,
  logo_url text,
  background_color text not null default '#ffffff',
  welcome_text text,
  active boolean not null default true,
  created_at timestamptz not null default now()
);

create table if not exists public.business_links (
  id uuid primary key default gen_random_uuid(),
  customer_id uuid not null references public.customers(id) on delete cascade,
  label text not null,
  url text not null,
  link_type text not null default 'Other',
  position integer not null default 0,
  active boolean not null default true,
  created_at timestamptz not null default now()
);

create table if not exists public.nfc_tags (
  id uuid primary key default gen_random_uuid(),
  customer_id uuid not null references public.customers(id) on delete cascade,
  tag_uid text,
  programmed_url text not null,
  notes text,
  created_at timestamptz not null default now()
);

create table if not exists public.scan_events (
  id uuid primary key default gen_random_uuid(),
  customer_id uuid not null references public.customers(id) on delete cascade,
  link_id uuid references public.business_links(id) on delete set null,
  event_type text not null check (event_type in ('page_view','button_click')),
  session_id text,
  created_at timestamptz not null default now()
);

create index if not exists customers_slug_idx on public.customers(slug);
create index if not exists links_customer_position_idx on public.business_links(customer_id,position);
create index if not exists events_customer_created_idx on public.scan_events(customer_id,created_at desc);

-- Create a profile automatically for each newly registered auth user.
create or replace function public.handle_new_user()
returns trigger language plpgsql security definer set search_path = ''
as $$
begin
  insert into public.profiles (id,email,role)
  values (new.id,new.email,'customer')
  on conflict (id) do update set email=excluded.email;
  return new;
end;
$$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
after insert on auth.users
for each row execute procedure public.handle_new_user();

create or replace function public.is_jaidev_staff()
returns boolean language sql stable security definer set search_path = ''
as $$
  select exists (
    select 1 from public.profiles p
    where p.id = auth.uid() and p.role in ('admin','staff')
  );
$$;

create or replace function public.is_jaidev_admin()
returns boolean language sql stable security definer set search_path = ''
as $$
  select exists (
    select 1 from public.profiles p
    where p.id = auth.uid() and p.role = 'admin'
  );
$$;

alter table public.profiles enable row level security;
alter table public.customers enable row level security;
alter table public.business_links enable row level security;
alter table public.nfc_tags enable row level security;
alter table public.scan_events enable row level security;

-- Profiles: users can see their own record; admins can see/manage all.
drop policy if exists "profile self read" on public.profiles;
create policy "profile self read" on public.profiles for select to authenticated
using (id = auth.uid() or public.is_jaidev_admin());
drop policy if exists "admin manage profiles" on public.profiles;
create policy "admin manage profiles" on public.profiles for all to authenticated
using (public.is_jaidev_admin()) with check (public.is_jaidev_admin());

-- Public visitor can read active business pages and active links.
drop policy if exists "public read active customers" on public.customers;
create policy "public read active customers" on public.customers for select to anon, authenticated
using (active = true or public.is_jaidev_staff());
drop policy if exists "staff manage customers" on public.customers;
create policy "staff manage customers" on public.customers for all to authenticated
using (public.is_jaidev_staff()) with check (public.is_jaidev_staff());

drop policy if exists "public read active links" on public.business_links;
create policy "public read active links" on public.business_links for select to anon, authenticated
using (
  active = true and exists (select 1 from public.customers c where c.id=customer_id and c.active=true)
  or public.is_jaidev_staff()
);
drop policy if exists "staff manage links" on public.business_links;
create policy "staff manage links" on public.business_links for all to authenticated
using (public.is_jaidev_staff()) with check (public.is_jaidev_staff());

drop policy if exists "staff manage nfc tags" on public.nfc_tags;
create policy "staff manage nfc tags" on public.nfc_tags for all to authenticated
using (public.is_jaidev_staff()) with check (public.is_jaidev_staff());

-- Anonymous visitors can submit only event records. Staff can read/manage analytics.
drop policy if exists "public insert analytics events" on public.scan_events;
create policy "public insert analytics events" on public.scan_events for insert to anon, authenticated
with check (
  event_type in ('page_view','button_click')
  and exists (select 1 from public.customers c where c.id=customer_id and c.active=true)
  and (link_id is null or exists (select 1 from public.business_links l where l.id=link_id and l.customer_id=customer_id and l.active=true))
);
drop policy if exists "staff read analytics" on public.scan_events;
create policy "staff read analytics" on public.scan_events for select to authenticated
using (public.is_jaidev_staff());
drop policy if exists "staff manage analytics" on public.scan_events;
create policy "staff manage analytics" on public.scan_events for delete to authenticated
using (public.is_jaidev_staff());

-- IMPORTANT FIRST ADMIN SETUP:
-- 1) Create your own user in Supabase Authentication > Users > Add user.
-- 2) Copy that user's UUID.
-- 3) Run the following command, replacing YOUR_AUTH_USER_UUID:
-- update public.profiles set role='admin' where id='YOUR_AUTH_USER_UUID';
-- For each staff user, create/invite the Auth user, then:
-- update public.profiles set role='staff' where id='STAFF_AUTH_USER_UUID';
