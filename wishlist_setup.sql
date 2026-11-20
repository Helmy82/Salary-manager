-- نفّذ هذا الملف مرة واحدة في Supabase > SQL Editor > New query
-- جدول الحركات المالية الموجود بالفعل لا يحتاج إلى إعادة إنشائه.
create table if not exists public.salary_wishlist (
  id text primary key,
  user_id uuid not null references auth.users(id) on delete cascade,
  title text not null check (char_length(title) between 1 and 100),
  note text not null default '',
  created_at timestamptz not null default now()
);

alter table public.salary_wishlist enable row level security;

drop policy if exists "Users can view own wishlist" on public.salary_wishlist;
create policy "Users can view own wishlist" on public.salary_wishlist
for select to authenticated using (auth.uid() = user_id);

drop policy if exists "Users can insert own wishlist" on public.salary_wishlist;
create policy "Users can insert own wishlist" on public.salary_wishlist
for insert to authenticated with check (auth.uid() = user_id);

drop policy if exists "Users can update own wishlist" on public.salary_wishlist;
create policy "Users can update own wishlist" on public.salary_wishlist
for update to authenticated using (auth.uid() = user_id) with check (auth.uid() = user_id);

drop policy if exists "Users can delete own wishlist" on public.salary_wishlist;
create policy "Users can delete own wishlist" on public.salary_wishlist
for delete to authenticated using (auth.uid() = user_id);

grant select, insert, update, delete on public.salary_wishlist to authenticated;

do $$
begin
  if not exists (select 1 from pg_publication_tables where pubname='supabase_realtime' and schemaname='public' and tablename='salary_wishlist') then
    alter publication supabase_realtime add table public.salary_wishlist;
  end if;
end $$;
