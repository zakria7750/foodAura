-- ══════════════════════════════════════════
-- جدول الطلبات (orders)
-- شغّل هذا الكود في Supabase SQL Editor
-- ══════════════════════════════════════════

create table if not exists public.orders (
  id          bigint generated always as identity primary key,
  user_id     uuid references auth.users(id) on delete set null,
  items       jsonb    not null,
  total       numeric  not null,
  status      text     not null default 'pending',
  created_at  timestamptz not null default now()
);

-- تفعيل Row Level Security
alter table public.orders enable row level security;

-- السماح للمستخدم برؤية طلباته فقط
drop policy if exists "Users see own orders" on public.orders;
create policy "Users see own orders"
  on public.orders for select
  using (auth.uid() = user_id);

-- السماح للمستخدم بإنشاء طلب باسمه
drop policy if exists "Users insert own orders" on public.orders;
create policy "Users insert own orders"
  on public.orders for insert
  with check (auth.uid() = user_id);
