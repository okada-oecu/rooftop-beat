-- Rooftop Beat: admin mode for "みんなの譜面"
-- 1. Supabase → Authentication → Users → "Add user" → "Create new user" で管理者のメールとパスワードを作る（Auto Confirm にチェック）。
-- 2. 下の 'あなたのメールアドレス' を 1 で作ったメールに書き換えてから、このファイル全体を SQL Editor で Run。
--    管理者を増やすときは、最後の insert 文だけメールを変えてもう一度 Run。
-- Safe to run again.

create table if not exists public.admins (
  user_id uuid primary key references auth.users(id) on delete cascade
);
alter table public.admins enable row level security;   -- no policies: not readable or writable through the API

create or replace function public.is_admin() returns boolean
language sql stable security definer set search_path = public as $$
  select exists (select 1 from admins where user_id = auth.uid());
$$;
revoke all on function public.is_admin() from public;
grant execute on function public.is_admin() to anon, authenticated;

-- hidden charts disappear from everyone's list but stay visible to admins
alter table public.charts add column if not exists hidden boolean not null default false;

drop policy if exists "charts are public" on public.charts;
create policy "charts are public" on public.charts for select using (not hidden or public.is_admin());
drop policy if exists "anyone can publish" on public.charts;
create policy "anyone can publish" on public.charts for insert with check (plays = 0 and hidden = false);
drop policy if exists "admins can edit" on public.charts;
create policy "admins can edit" on public.charts for update to authenticated using (public.is_admin()) with check (public.is_admin());
drop policy if exists "admins can delete" on public.charts;
create policy "admins can delete" on public.charts for delete to authenticated using (public.is_admin());

drop policy if exists "songs: admin remove" on storage.objects;
create policy "songs: admin remove" on storage.objects for delete to authenticated
  using (bucket_id = 'songs' and public.is_admin());

-- make the account from step 1 an admin
insert into public.admins (user_id)
select id from auth.users where email = 'あなたのメールアドレス'
on conflict do nothing;

-- check: shows the admin emails
select u.email as admin from public.admins a join auth.users u on u.id = a.user_id;
