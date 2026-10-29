-- Rooftop Beat: shared charts ("みんなの譜面")
-- Paste this whole file into Supabase → SQL Editor → Run. Safe to run again.
--
-- Anyone can browse, play and publish without an account. A chart can only be
-- deleted with the secret token the publishing browser kept (stored here as a hash).

create extension if not exists pgcrypto with schema extensions;

create table if not exists public.charts (
  id          uuid primary key default gen_random_uuid(),
  created_at  timestamptz not null default now(),
  title       text not null check (char_length(title) between 1 and 60),
  author      text not null check (char_length(author) between 1 and 24),
  bpm         real not null check (bpm between 40 and 300),
  phase       real not null check (phase between -2 and 5),          -- first beat, seconds
  duration    real not null check (duration between 5 and 900),      -- song length, seconds
  seed        integer not null default 1,                            -- rooftop heights
  notes       jsonb not null check (jsonb_typeof(notes) = 'array' and jsonb_array_length(notes) between 1 and 5000),
  note_count  integer generated always as (jsonb_array_length(notes)) stored,
  audio_path  text not null unique check (audio_path ~ '^[0-9a-f-]{36}\.(mp3|m4a|mp4|aac|ogg|oga|wav|flac|webm)$'),
  plays       integer not null default 0,
  owner_hash  text not null check (owner_hash ~ '^[0-9a-f]{64}$')    -- sha256 of the publisher's token
);
create index if not exists charts_created_idx on public.charts (created_at desc);
create index if not exists charts_plays_idx on public.charts (plays desc);

alter table public.charts enable row level security;
drop policy if exists "charts are public" on public.charts;
create policy "charts are public" on public.charts for select using (true);
drop policy if exists "anyone can publish" on public.charts;
create policy "anyone can publish" on public.charts for insert with check (plays = 0);
-- no update/delete policies: those go through the two functions below

create or replace function public.count_play(chart_id uuid) returns void
language sql security definer set search_path = public as $$
  update charts set plays = plays + 1 where id = chart_id;
$$;

create or replace function public.delete_chart(chart_id uuid, owner_token text) returns text
language plpgsql security definer set search_path = public, extensions as $$
declare p text;
begin
  delete from charts
   where id = chart_id and owner_hash = encode(digest(owner_token, 'sha256'), 'hex')
  returning audio_path into p;
  return p;   -- the song file to remove, or null if the token did not match
end $$;

revoke all on function public.count_play(uuid) from public;
revoke all on function public.delete_chart(uuid, text) from public;
grant execute on function public.count_play(uuid) to anon, authenticated;
grant execute on function public.delete_chart(uuid, text) to anon, authenticated;

-- song files: public to read, 15 MB max, audio only
insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values ('songs', 'songs', true, 15728640,
        array['audio/mpeg','audio/mp4','audio/x-m4a','audio/aac','audio/ogg','audio/wav','audio/x-wav','audio/wave','audio/flac','audio/webm'])
on conflict (id) do update
  set public = excluded.public, file_size_limit = excluded.file_size_limit, allowed_mime_types = excluded.allowed_mime_types;

drop policy if exists "songs: read" on storage.objects;
create policy "songs: read" on storage.objects for select to anon, authenticated using (bucket_id = 'songs');
drop policy if exists "songs: upload" on storage.objects;
create policy "songs: upload" on storage.objects for insert to anon, authenticated with check (bucket_id = 'songs');
-- a song file can be removed only once no chart points at it (i.e. after delete_chart)
drop policy if exists "songs: remove orphans" on storage.objects;
create policy "songs: remove orphans" on storage.objects for delete to anon, authenticated
  using (bucket_id = 'songs' and not exists (select 1 from public.charts c where c.audio_path = storage.objects.name));
