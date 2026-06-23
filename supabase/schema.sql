-- Travel App — Supabase schema
-- Run this once in the Supabase SQL editor (Project → SQL → New query).
-- Safe to re-run: uses IF NOT EXISTS / ON CONFLICT where possible.

create extension if not exists "pgcrypto";

----------------------------------------------------------------------
-- Tables
----------------------------------------------------------------------

create table if not exists public.users (
  id               uuid primary key references auth.users(id) on delete cascade,
  email            text,
  name             text,
  image            text,
  location         text,
  address          text,
  phone_number     bigint,
  date_of_register text,
  interests        text[] default '{}',
  travel_style     text,
  preferred_budget text,
  onboarding_done  bool default false,
  created_at       timestamptz default now(),
  updated_at       timestamptz default now()
);

-- Older deployments may pre-date the personalization columns; backfill if missing.
alter table public.users add column if not exists interests        text[] default '{}';
alter table public.users add column if not exists travel_style     text;
alter table public.users add column if not exists preferred_budget text;
alter table public.users add column if not exists onboarding_done  bool default false;

create table if not exists public.plans (
  id               uuid primary key default gen_random_uuid(),
  user_id          uuid not null references public.users(id) on delete cascade,
  name             text,
  destination      text,
  start_date       text,
  end_date         text,
  travel_method    text,
  accommodation    text,
  budget           numeric,
  number_of_people int,
  extra_notes      text,
  created_at       timestamptz default now()
);
create index if not exists plans_user_id_idx on public.plans(user_id);

create table if not exists public.plan_checklist_items (
  id         uuid primary key default gen_random_uuid(),
  plan_id    uuid not null references public.plans(id) on delete cascade,
  item       text not null,
  done       bool default false,
  created_at timestamptz default now()
);
create index if not exists plan_checklist_items_plan_id_idx
  on public.plan_checklist_items(plan_id);

create table if not exists public.cards (
  id               uuid primary key default gen_random_uuid(),
  user_id          uuid not null references public.users(id) on delete cascade,
  card_number      bigint,
  card_holder_name text,
  cvc              text,
  is_default_card  bool default false,
  expiration_date  date,
  created_at       timestamptz default now()
);
create index if not exists cards_user_id_idx on public.cards(user_id);

create table if not exists public.saved_places (
  id         uuid primary key default gen_random_uuid(),
  user_id    uuid not null references public.users(id) on delete cascade,
  tour_key   text not null,
  tour_data  jsonb not null,
  created_at timestamptz default now(),
  unique(user_id, tour_key)
);
create index if not exists saved_places_user_id_idx on public.saved_places(user_id);

create table if not exists public.trip_collection (
  id         uuid primary key default gen_random_uuid(),
  plan_id    uuid not null references public.plans(id) on delete cascade,
  tour_key   text not null,
  tour_data  jsonb not null,
  created_at timestamptz default now(),
  unique(plan_id, tour_key)
);
create index if not exists trip_collection_plan_id_idx on public.trip_collection(plan_id);

create table if not exists public.trip_day_plan (
  id         uuid primary key default gen_random_uuid(),
  plan_id    uuid not null references public.plans(id) on delete cascade,
  day        int not null,
  time       text not null,
  title      text not null,
  location   text,
  note       text,
  created_at timestamptz default now()
);
create index if not exists trip_day_plan_plan_id_idx on public.trip_day_plan(plan_id);

create table if not exists public.trip_expenses (
  id         uuid primary key default gen_random_uuid(),
  plan_id    uuid not null references public.plans(id) on delete cascade,
  label      text not null,
  amount     numeric not null,
  category   text not null,
  spent_at   timestamptz default now(),
  created_at timestamptz default now()
);
create index if not exists trip_expenses_plan_id_idx on public.trip_expenses(plan_id);

create table if not exists public.trip_memories (
  id         uuid primary key default gen_random_uuid(),
  plan_id    uuid not null references public.plans(id) on delete cascade,
  image_url  text not null,
  caption    text,
  created_at timestamptz default now()
);
create index if not exists trip_memories_plan_id_idx on public.trip_memories(plan_id);

create table if not exists public.trip_invites (
  id         uuid primary key default gen_random_uuid(),
  plan_id    uuid not null references public.plans(id) on delete cascade,
  email      text not null,
  invited_at timestamptz default now(),
  unique(plan_id, email)
);
create index if not exists trip_invites_plan_id_idx on public.trip_invites(plan_id);

create table if not exists public.continents (
  id         uuid primary key default gen_random_uuid(),
  lang       text not null check (lang in ('en','ar')),
  name       text not null,
  sort_order int default 0,
  unique(lang, name)
);

create table if not exists public.categories (
  id         uuid primary key default gen_random_uuid(),
  lang       text not null check (lang in ('en','ar')),
  name       text not null,
  image      text,
  sort_order int default 0
);

create table if not exists public.tours (
  id                 uuid primary key default gen_random_uuid(),
  lang               text not null check (lang in ('en','ar')),
  title              text,
  continent          text,
  image              text,
  images             text[] default '{}',
  overview           text,
  distance           int,
  weather_condition  text,
  rating             numeric,
  number_of_reviews  int,
  started_price      int,
  temperature        int,
  duration_day       int,
  category           text,
  extra_price        int,
  details            text,
  reviews            text,
  costs              text,
  created_at         timestamptz default now()
);
create index if not exists tours_lang_continent_idx on public.tours(lang, continent);

----------------------------------------------------------------------
-- Row Level Security
----------------------------------------------------------------------

alter table public.users                enable row level security;
alter table public.plans                enable row level security;
alter table public.plan_checklist_items enable row level security;
alter table public.cards                enable row level security;
alter table public.continents           enable row level security;
alter table public.categories           enable row level security;
alter table public.tours                enable row level security;
alter table public.saved_places         enable row level security;
alter table public.trip_collection      enable row level security;
alter table public.trip_day_plan        enable row level security;
alter table public.trip_expenses        enable row level security;
alter table public.trip_memories        enable row level security;
alter table public.trip_invites         enable row level security;

-- users
drop policy if exists "users_select_own"  on public.users;
drop policy if exists "users_insert_own"  on public.users;
drop policy if exists "users_update_own"  on public.users;
create policy "users_select_own"  on public.users for select using (auth.uid() = id);
create policy "users_insert_own"  on public.users for insert with check (auth.uid() = id);
create policy "users_update_own"  on public.users for update using (auth.uid() = id) with check (auth.uid() = id);

-- plans
drop policy if exists "plans_select_own" on public.plans;
drop policy if exists "plans_insert_own" on public.plans;
drop policy if exists "plans_update_own" on public.plans;
drop policy if exists "plans_delete_own" on public.plans;
create policy "plans_select_own" on public.plans for select using (auth.uid() = user_id);
create policy "plans_insert_own" on public.plans for insert with check (auth.uid() = user_id);
create policy "plans_update_own" on public.plans for update using (auth.uid() = user_id) with check (auth.uid() = user_id);
create policy "plans_delete_own" on public.plans for delete using (auth.uid() = user_id);

-- plan_checklist_items (gated through plan ownership)
drop policy if exists "checklist_select_own" on public.plan_checklist_items;
drop policy if exists "checklist_insert_own" on public.plan_checklist_items;
drop policy if exists "checklist_update_own" on public.plan_checklist_items;
drop policy if exists "checklist_delete_own" on public.plan_checklist_items;
create policy "checklist_select_own" on public.plan_checklist_items for select using (
  exists (select 1 from public.plans p where p.id = plan_id and p.user_id = auth.uid())
);
create policy "checklist_insert_own" on public.plan_checklist_items for insert with check (
  exists (select 1 from public.plans p where p.id = plan_id and p.user_id = auth.uid())
);
create policy "checklist_update_own" on public.plan_checklist_items for update using (
  exists (select 1 from public.plans p where p.id = plan_id and p.user_id = auth.uid())
) with check (
  exists (select 1 from public.plans p where p.id = plan_id and p.user_id = auth.uid())
);
create policy "checklist_delete_own" on public.plan_checklist_items for delete using (
  exists (select 1 from public.plans p where p.id = plan_id and p.user_id = auth.uid())
);

-- cards
drop policy if exists "cards_select_own" on public.cards;
drop policy if exists "cards_insert_own" on public.cards;
drop policy if exists "cards_update_own" on public.cards;
drop policy if exists "cards_delete_own" on public.cards;
create policy "cards_select_own" on public.cards for select using (auth.uid() = user_id);
create policy "cards_insert_own" on public.cards for insert with check (auth.uid() = user_id);
create policy "cards_update_own" on public.cards for update using (auth.uid() = user_id) with check (auth.uid() = user_id);
create policy "cards_delete_own" on public.cards for delete using (auth.uid() = user_id);

-- saved_places (per user)
drop policy if exists "saved_places_select_own" on public.saved_places;
drop policy if exists "saved_places_insert_own" on public.saved_places;
drop policy if exists "saved_places_delete_own" on public.saved_places;
create policy "saved_places_select_own" on public.saved_places for select using (auth.uid() = user_id);
create policy "saved_places_insert_own" on public.saved_places for insert with check (auth.uid() = user_id);
create policy "saved_places_delete_own" on public.saved_places for delete using (auth.uid() = user_id);

-- trip-scoped tables (gated through plan ownership)
do $$
declare
  t text;
begin
  foreach t in array array[
    'trip_collection',
    'trip_day_plan',
    'trip_expenses',
    'trip_memories',
    'trip_invites'
  ] loop
    execute format('drop policy if exists "%1$s_select_own" on public.%1$s;', t);
    execute format('drop policy if exists "%1$s_insert_own" on public.%1$s;', t);
    execute format('drop policy if exists "%1$s_update_own" on public.%1$s;', t);
    execute format('drop policy if exists "%1$s_delete_own" on public.%1$s;', t);

    execute format(
      'create policy "%1$s_select_own" on public.%1$s for select using (exists (select 1 from public.plans p where p.id = plan_id and p.user_id = auth.uid()));',
      t);
    execute format(
      'create policy "%1$s_insert_own" on public.%1$s for insert with check (exists (select 1 from public.plans p where p.id = plan_id and p.user_id = auth.uid()));',
      t);
    execute format(
      'create policy "%1$s_update_own" on public.%1$s for update using (exists (select 1 from public.plans p where p.id = plan_id and p.user_id = auth.uid())) with check (exists (select 1 from public.plans p where p.id = plan_id and p.user_id = auth.uid()));',
      t);
    execute format(
      'create policy "%1$s_delete_own" on public.%1$s for delete using (exists (select 1 from public.plans p where p.id = plan_id and p.user_id = auth.uid()));',
      t);
  end loop;
end$$;

-- catalog (read-only for any authenticated user)
drop policy if exists "continents_read" on public.continents;
drop policy if exists "categories_read" on public.categories;
drop policy if exists "tours_read"      on public.tours;
create policy "continents_read" on public.continents for select using (auth.role() = 'authenticated');
create policy "categories_read" on public.categories for select using (auth.role() = 'authenticated');
create policy "tours_read"      on public.tours      for select using (auth.role() = 'authenticated');

----------------------------------------------------------------------
-- Auto-provision public.users row when an auth.users row is created
----------------------------------------------------------------------

create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer set search_path = public
as $$
begin
  insert into public.users (id, email, date_of_register)
  values (new.id, new.email, to_char(now(), 'YYYY/MM/DD ,HH24:MI:SS'))
  on conflict (id) do nothing;
  return new;
end;
$$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute procedure public.handle_new_user();

----------------------------------------------------------------------
-- Storage: avatars bucket (public read, owner write)
----------------------------------------------------------------------

insert into storage.buckets (id, name, public)
values ('avatars', 'avatars', true)
on conflict (id) do nothing;

insert into storage.buckets (id, name, public)
values ('memories', 'memories', true)
on conflict (id) do nothing;

drop policy if exists "memories_public_read"   on storage.objects;
drop policy if exists "memories_owner_insert"  on storage.objects;
drop policy if exists "memories_owner_update"  on storage.objects;
drop policy if exists "memories_owner_delete"  on storage.objects;

create policy "memories_public_read" on storage.objects
  for select using (bucket_id = 'memories');

create policy "memories_owner_insert" on storage.objects
  for insert with check (
    bucket_id = 'memories'
    and auth.uid()::text = (storage.foldername(name))[1]
  );

create policy "memories_owner_update" on storage.objects
  for update using (
    bucket_id = 'memories'
    and auth.uid()::text = (storage.foldername(name))[1]
  );

create policy "memories_owner_delete" on storage.objects
  for delete using (
    bucket_id = 'memories'
    and auth.uid()::text = (storage.foldername(name))[1]
  );

drop policy if exists "avatars_public_read"    on storage.objects;
drop policy if exists "avatars_owner_insert"   on storage.objects;
drop policy if exists "avatars_owner_update"   on storage.objects;
drop policy if exists "avatars_owner_delete"   on storage.objects;

create policy "avatars_public_read" on storage.objects
  for select using (bucket_id = 'avatars');

create policy "avatars_owner_insert" on storage.objects
  for insert with check (
    bucket_id = 'avatars'
    and auth.uid()::text = (storage.foldername(name))[1]
  );

create policy "avatars_owner_update" on storage.objects
  for update using (
    bucket_id = 'avatars'
    and auth.uid()::text = (storage.foldername(name))[1]
  );

create policy "avatars_owner_delete" on storage.objects
  for delete using (
    bucket_id = 'avatars'
    and auth.uid()::text = (storage.foldername(name))[1]
  );
