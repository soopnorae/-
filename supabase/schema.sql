-- 데이트 스크랩북 · Supabase 초기 설정
-- Supabase 대시보드 → SQL Editor → New query → 이 파일 전체를 붙여넣고 Run 한 번이면 끝납니다.
-- 두 번 실행해도 안전하게 만들어 두었습니다 (if not exists / drop policy if exists).

-- 1) 기록 테이블
create table if not exists public.entries (
  id          uuid primary key default gen_random_uuid(),
  date        date not null,
  cat         text not null,                 -- movie / show / food / cafe / travel / walk / etc
  title       text not null,
  place       text not null default '',
  memo        text not null default '',
  rating      int  not null default 0 check (rating between 0 and 5),
  photos      text[] not null default '{}',  -- storage 경로 목록 (photos 버킷 안)
  extra       jsonb not null default '{}',   -- seat / to / menu 등 카테고리별 추가 정보
  created_by  uuid references auth.users (id) on delete set null,
  created_at  timestamptz not null default now(),
  updated_at  timestamptz not null default now()
);
create index if not exists entries_date_idx on public.entries (date desc, created_at desc);

-- 2) 설정 (스크랩북 이름, 처음 만난 날) - 행 하나만 씁니다
create table if not exists public.settings (
  id          text primary key default 'main',
  title       text not null default '',
  since       date,
  updated_at  timestamptz not null default now()
);
insert into public.settings (id) values ('main') on conflict (id) do nothing;

-- 3) 접근 권한: 로그인한 사용자(= 두 사람)만 읽고 쓸 수 있음
alter table public.entries  enable row level security;
alter table public.settings enable row level security;

drop policy if exists "members read entries"   on public.entries;
drop policy if exists "members write entries"  on public.entries;
drop policy if exists "members update entries" on public.entries;
drop policy if exists "members delete entries" on public.entries;
create policy "members read entries"   on public.entries for select to authenticated using (true);
create policy "members write entries"  on public.entries for insert to authenticated with check (true);
create policy "members update entries" on public.entries for update to authenticated using (true) with check (true);
create policy "members delete entries" on public.entries for delete to authenticated using (true);

drop policy if exists "members read settings"   on public.settings;
drop policy if exists "members write settings"  on public.settings;
drop policy if exists "members update settings" on public.settings;
create policy "members read settings"   on public.settings for select to authenticated using (true);
create policy "members write settings"  on public.settings for insert to authenticated with check (true);
create policy "members update settings" on public.settings for update to authenticated using (true) with check (true);

-- 4) 사진 저장소 (비공개 버킷: 로그인한 사람만 서명 URL로 봅니다)
insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values ('photos', 'photos', false, 10485760, array['image/jpeg','image/png','image/webp','image/gif'])
on conflict (id) do update set public = false;

drop policy if exists "members read photos"   on storage.objects;
drop policy if exists "members upload photos" on storage.objects;
drop policy if exists "members update photos" on storage.objects;
drop policy if exists "members delete photos" on storage.objects;
create policy "members read photos"   on storage.objects for select to authenticated using (bucket_id = 'photos');
create policy "members upload photos" on storage.objects for insert to authenticated with check (bucket_id = 'photos');
create policy "members update photos" on storage.objects for update to authenticated using (bucket_id = 'photos');
create policy "members delete photos" on storage.objects for delete to authenticated using (bucket_id = 'photos');

-- 5) 실시간 반영: 한 사람이 올리면 상대 화면에도 바로 뜨도록
do $$
begin
  if not exists (select 1 from pg_publication_tables where pubname = 'supabase_realtime' and tablename = 'entries') then
    alter publication supabase_realtime add table public.entries;
  end if;
  if not exists (select 1 from pg_publication_tables where pubname = 'supabase_realtime' and tablename = 'settings') then
    alter publication supabase_realtime add table public.settings;
  end if;
end $$;
