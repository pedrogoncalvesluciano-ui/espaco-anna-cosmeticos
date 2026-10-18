-- Espaço Anna Cosméticos — esquema inicial para Supabase
-- Execute no SQL Editor do seu projeto Supabase.
-- Segurança: mantenha RLS ativo. Nunca exponha a service_role key no site.
create extension if not exists pgcrypto;

create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  role text not null default 'customer' check (role in ('customer','admin')),
  created_at timestamptz not null default now()
);

create table if not exists public.products (
  id uuid primary key default gen_random_uuid(),
  name text not null check (char_length(name) between 1 and 120),
  category text not null,
  price numeric(10,2) not null check (price > 0),
  stock integer not null default 0 check (stock >= 0),
  description text not null default '',
  image_url text,
  supplier text not null default '',
  active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.orders (
  id uuid primary key default gen_random_uuid(),
  customer_name text not null,
  customer_phone text not null,
  customer_cep text not null default '',
  notes text not null default '',
  status text not null default 'received' check (status in ('received','confirmed','paid','separating','shipped','completed','cancelled')),
  subtotal numeric(10,2) not null default 0 check (subtotal >= 0),
  shipping_cost numeric(10,2),
  payment_method text,
  payment_reference text,
  created_at timestamptz not null default now()
);

create table if not exists public.order_items (
  id uuid primary key default gen_random_uuid(),
  order_id uuid not null references public.orders(id) on delete cascade,
  product_id uuid references public.products(id) on delete set null,
  product_name text not null,
  quantity integer not null check (quantity > 0),
  unit_price numeric(10,2) not null check (unit_price >= 0),
  created_at timestamptz not null default now()
);

alter table public.profiles enable row level security;
alter table public.products enable row level security;
alter table public.orders enable row level security;
alter table public.order_items enable row level security;

-- Helper: só usuários explicitamente cadastrados como admin em profiles são admins.
create or replace function public.is_admin()
returns boolean language sql stable security definer set search_path = public
as $$
  select exists(select 1 from public.profiles where id = auth.uid() and role = 'admin');
$$;

-- Catálogo público: clientes só leem produtos ativos; admin pode gerenciar todos.
drop policy if exists "Public can read active products" on public.products;
create policy "Public can read active products" on public.products
for select to anon, authenticated using (active = true or public.is_admin());

drop policy if exists "Admins manage products" on public.products;
create policy "Admins manage products" on public.products
for all to authenticated using (public.is_admin()) with check (public.is_admin());

-- Dados pessoais e pedidos só são acessíveis por administradores nesta versão inicial.
-- Checkout via WhatsApp não grava dados pessoais no banco.
drop policy if exists "Admins read orders" on public.orders;
create policy "Admins read orders" on public.orders
for select to authenticated using (public.is_admin());

drop policy if exists "Admins manage orders" on public.orders;
create policy "Admins manage orders" on public.orders
for all to authenticated using (public.is_admin()) with check (public.is_admin());

drop policy if exists "Admins read order items" on public.order_items;
create policy "Admins read order items" on public.order_items
for select to authenticated using (public.is_admin());

drop policy if exists "Admins manage order items" on public.order_items;
create policy "Admins manage order items" on public.order_items
for all to authenticated using (public.is_admin()) with check (public.is_admin());

drop policy if exists "Users read own profile" on public.profiles;
create policy "Users read own profile" on public.profiles
for select to authenticated using (id = auth.uid() or public.is_admin());

-- IMPORTANTE: criar o usuário pelo Supabase Auth e promover manualmente o primeiro admin:
-- insert into public.profiles (id, role)
-- select id, 'admin' from auth.users where email = 'SEU_EMAIL_DE_ADMIN';
-- Não deixe essa instrução com um e-mail de exemplo; substitua pelo seu e-mail real.
