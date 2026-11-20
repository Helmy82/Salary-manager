-- نفّذ هذا الملف مرة واحدة في Supabase > SQL Editor > New query
create table if not exists public.salary_transactions (
  id text primary key,
  user_id uuid not null references auth.users(id) on delete cascade,
  type text not null check (type in ('income','expense','saving')),
  amount numeric(12,2) not null check (amount > 0),
  category text not null,
  date date not null,
  note text default '',
  created_at timestamptz not null default now()
);

alter table public.salary_transactions enable row level security;

drop policy if exists "Users can view own salary transactions" on public.salary_transactions;
create policy "Users can view own salary transactions"
on public.salary_transactions for select to authenticated
using (auth.uid() = user_id);

drop policy if exists "Users can insert own salary transactions" on public.salary_transactions;
create policy "Users can insert own salary transactions"
on public.salary_transactions for insert to authenticated
with check (auth.uid() = user_id);

drop policy if exists "Users can update own salary transactions" on public.salary_transactions;
create policy "Users can update own salary transactions"
on public.salary_transactions for update to authenticated
using (auth.uid() = user_id)
with check (auth.uid() = user_id);

drop policy if exists "Users can delete own salary transactions" on public.salary_transactions;
create policy "Users can delete own salary transactions"
on public.salary_transactions for delete to authenticated
using (auth.uid() = user_id);

grant select, insert, update, delete on public.salary_transactions to authenticated;

do $$
begin
  if not exists (
    select 1 from pg_publication_tables
    where pubname = 'supabase_realtime'
      and schemaname = 'public'
      and tablename = 'salary_transactions'
  ) then
    alter publication supabase_realtime add table public.salary_transactions;
  end if;
end $$;
