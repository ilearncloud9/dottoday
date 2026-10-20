-- 0001_init.sql — Dottoday core schema with row-level security.
-- See docs/05-data-model.md and docs/06-security.md. Never edit; add new migrations.

create extension if not exists "pgcrypto";

-- ---------- helpers ----------
create or replace function public.set_updated_at()
returns trigger language plpgsql as $$
begin
  new.updated_at := now();
  return new;
end $$;

-- Validation of profile settings (mirrors client validator; keep in sync).
create or replace function public.validate_settings(s jsonb)
returns boolean language sql immutable as $$
  select s ? 'dayBoundaries'
     and coalesce((s->>'snapMinutes')::int, 5) in (1,5,10,15)
     and coalesce(s->>'shiftFollowers','ask') in ('ask','always','never')
     and coalesce(jsonb_array_length(s->'defaultAlerts'),0) <= 5
$$;

-- ---------- profiles ----------
create table public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  display_name text check (char_length(display_name) <= 80),
  tz_id text not null default 'UTC' check (char_length(tz_id) <= 64),
  locale text not null default 'en' check (char_length(locale) <= 16),
  settings jsonb not null default '{"dayBoundaries":{}}'::jsonb check (public.validate_settings(settings)),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
alter table public.profiles enable row level security;
create policy "profiles: own row" on public.profiles
  for all using (id = auth.uid()) with check (id = auth.uid());
create trigger profiles_updated_at before update on public.profiles
  for each row execute function public.set_updated_at();

-- Auto-create profile on signup.
create or replace function public.handle_new_user()
returns trigger language plpgsql security definer set search_path = public as $$
begin
  insert into public.profiles (id) values (new.id) on conflict do nothing;
  return new;
end $$;
create trigger on_auth_user_created after insert on auth.users
  for each row execute function public.handle_new_user();

-- ---------- enums ----------
create type public.occurrence_status as enum ('planned','done','skipped');
create type public.occurrence_source as enum ('user','calendar');
create type public.calendar_provider as enum ('apple_device','android_device','google','microsoft','caldav');

-- ---------- series (recurring templates) ----------
create table public.series (
  id uuid primary key,
  user_id uuid not null references public.profiles(id) on delete cascade,
  title text not null check (char_length(btrim(title)) between 1 and 200),
  notes text check (char_length(notes) <= 10000),
  color_key text not null default 'indigo' check (char_length(color_key) <= 24),
  icon_key text not null default 'circle' check (char_length(icon_key) <= 48),
  duration_min int not null check (duration_min between 5 and 1440),
  rrule text not null check (rrule like 'FREQ=%' and char_length(rrule) <= 512),
  dtstart_local text not null,                 -- ISO-8601 wall-clock, no offset
  tz_id text not null check (char_length(tz_id) <= 64),
  until_utc timestamptz,
  count int check (count is null or count between 1 and 10000),
  pinned boolean not null default false,
  travel_buffer_min int not null default 0 check (travel_buffer_min between 0 and 180),
  energy smallint check (energy is null or energy between 1 and 3),
  alerts jsonb not null default '[]'::jsonb check (jsonb_array_length(alerts) <= 5),
  subtask_template jsonb not null default '[]'::jsonb check (jsonb_array_length(subtask_template) <= 50),
  materialised_through_utc timestamptz,
  archived_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  deleted_at timestamptz
);
create index series_user_updated on public.series (user_id, updated_at);
alter table public.series enable row level security;
create policy "series: own rows" on public.series
  for all using (user_id = auth.uid()) with check (user_id = auth.uid());
create trigger series_updated_at before update on public.series
  for each row execute function public.set_updated_at();

-- ---------- calendar accounts & links ----------
create table public.calendar_accounts (
  id uuid primary key,
  user_id uuid not null references public.profiles(id) on delete cascade,
  provider public.calendar_provider not null,
  label text not null check (char_length(label) <= 80),
  external_account_id text check (char_length(external_account_id) <= 256),
  write_back boolean not null default false,
  enabled boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
-- OAuth refresh tokens live in vault.secrets keyed by calendar_accounts.id (Edge Functions only).
alter table public.calendar_accounts enable row level security;
create policy "calendar_accounts: own rows" on public.calendar_accounts
  for all using (user_id = auth.uid()) with check (user_id = auth.uid());
create trigger calendar_accounts_updated_at before update on public.calendar_accounts
  for each row execute function public.set_updated_at();

create table public.calendar_links (
  id uuid primary key,
  user_id uuid not null references public.profiles(id) on delete cascade,
  account_id uuid not null references public.calendar_accounts(id) on delete cascade,
  external_calendar_id text not null check (char_length(external_calendar_id) <= 256),
  external_event_id text not null check (char_length(external_event_id) <= 512),
  etag text,
  last_synced_utc timestamptz,
  read_only boolean not null default true,
  unique (user_id, account_id, external_event_id)
);
alter table public.calendar_links enable row level security;
create policy "calendar_links: own rows" on public.calendar_links
  for all using (user_id = auth.uid()) with check (user_id = auth.uid());

-- ---------- occurrences (timeline blocks + inbox) ----------
create table public.occurrences (
  id uuid primary key,
  user_id uuid not null references public.profiles(id) on delete cascade,
  series_id uuid references public.series(id) on delete set null,
  original_start_utc timestamptz,              -- set for series-generated rows
  title text not null check (char_length(btrim(title)) between 1 and 200),
  notes text check (char_length(notes) <= 10000),
  color_key text not null default 'indigo' check (char_length(color_key) <= 24),
  icon_key text not null default 'circle' check (char_length(icon_key) <= 48),
  start_utc timestamptz,                       -- null = inbox
  tz_id text not null check (char_length(tz_id) <= 64),
  duration_min int not null check (duration_min between 5 and 1440),
  pinned boolean not null default false,
  travel_buffer_min int not null default 0 check (travel_buffer_min between 0 and 180),
  energy smallint check (energy is null or energy between 1 and 3),
  alerts jsonb check (alerts is null or jsonb_array_length(alerts) <= 5),
  status public.occurrence_status not null default 'planned',
  completed_at_utc timestamptz,
  sort_order double precision not null default 0,
  source public.occurrence_source not null default 'user',
  calendar_link_id uuid references public.calendar_links(id) on delete set null,
  snoozed_until_utc timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  deleted_at timestamptz,
  constraint occurrences_series_original_unique unique (series_id, original_start_utc)
);
create index occurrences_user_start on public.occurrences (user_id, start_utc);
create index occurrences_user_updated on public.occurrences (user_id, updated_at);
create index occurrences_user_deleted on public.occurrences (user_id, deleted_at) where deleted_at is not null;
alter table public.occurrences enable row level security;
create policy "occurrences: own rows" on public.occurrences
  for all using (user_id = auth.uid()) with check (user_id = auth.uid());
create trigger occurrences_updated_at before update on public.occurrences
  for each row execute function public.set_updated_at();

-- ---------- subtasks (per occurrence, never shared — R-09) ----------
create table public.subtasks (
  id uuid primary key,
  user_id uuid not null references public.profiles(id) on delete cascade,
  occurrence_id uuid not null references public.occurrences(id) on delete cascade,
  title text not null check (char_length(btrim(title)) between 1 and 200),
  done boolean not null default false,
  sort_order double precision not null default 0,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  deleted_at timestamptz
);
create index subtasks_occurrence on public.subtasks (occurrence_id);
create index subtasks_user_updated on public.subtasks (user_id, updated_at);
alter table public.subtasks enable row level security;
create policy "subtasks: own rows" on public.subtasks
  for all using (user_id = auth.uid()) with check (user_id = auth.uid());
create trigger subtasks_updated_at before update on public.subtasks
  for each row execute function public.set_updated_at();

-- ---------- conflicts ----------
create table public.conflicts (
  id uuid primary key,
  user_id uuid not null references public.profiles(id) on delete cascade,
  entity text not null check (entity in ('series','occurrences','subtasks','profiles')),
  entity_id uuid not null,
  field text not null check (char_length(field) <= 64),
  mine jsonb,
  theirs jsonb,
  created_at timestamptz not null default now(),
  resolved_at timestamptz
);
alter table public.conflicts enable row level security;
create policy "conflicts: own rows" on public.conflicts
  for all using (user_id = auth.uid()) with check (user_id = auth.uid());

-- ---------- sync RPC: per-field last-writer-wins with HLC ----------
-- payload: [{"entity":"occurrences","id":"…","hlc":"…","fields":{"title":"x","start_utc":"…"}}, …]
-- Ignores any user_id in payload (always auth.uid()). Max 500 changes per call.
create table public.field_versions (
  user_id uuid not null references public.profiles(id) on delete cascade,
  entity text not null,
  entity_id uuid not null,
  field text not null,
  hlc text not null,
  primary key (user_id, entity, entity_id, field)
);
alter table public.field_versions enable row level security;
create policy "field_versions: own rows" on public.field_versions
  for all using (user_id = auth.uid()) with check (user_id = auth.uid());

create or replace function public.sync_push(changes jsonb)
returns jsonb language plpgsql security invoker as $$
declare
  c jsonb;
  f record;
  applied int := 0;
  skipped int := 0;
  allowed_entities text[] := array['series','occurrences','subtasks','profiles'];
  tbl text;
  existing_hlc text;
  eid uuid;
  row_count int;
begin
  if jsonb_typeof(changes) <> 'array' or jsonb_array_length(changes) > 500 then
    raise exception 'sync_push: payload must be an array of <= 500 changes';
  end if;

  for c in select * from jsonb_array_elements(changes) loop
    tbl := c->>'entity';
    if not (tbl = any(allowed_entities)) then
      raise exception 'sync_push: unknown entity %', tbl;
    end if;
    eid := (c->>'id')::uuid;

    -- Ensure the row exists and belongs to the caller (RLS enforces user_id on insert).
    if tbl = 'profiles' then
      if eid <> auth.uid() then raise exception 'sync_push: profile id mismatch'; end if;
    else
      execute format(
        'insert into public.%I (id, user_id, title, tz_id, duration_min %s) values ($1, $2, %L, %L, 30 %s) on conflict (id) do nothing',
        tbl,
        case when tbl = 'series' then ', rrule, dtstart_local' else '' end,
        'untitled', 'UTC',
        case when tbl = 'series' then ', ''FREQ=DAILY'', ''1970-01-01T00:00:00''' else '' end
      ) using eid, auth.uid();
    end if;

    for f in select key, value from jsonb_each(c->'fields') loop
      if f.key in ('id','user_id','created_at','updated_at') then continue; end if;

      select hlc into existing_hlc from public.field_versions
        where user_id = auth.uid() and entity = tbl and entity_id = eid and field = f.key;

      if existing_hlc is not null and existing_hlc >= (c->>'hlc') then
        skipped := skipped + 1;
        continue;  -- server already has a newer value for this field
      end if;

      -- jsonb_populate_record-style single-field update; column names come from an allow-list
      -- enforced by the CHECK on field names below (regex) to avoid injection via format(%I).
      if f.key !~ '^[a-z_]{1,64}$' then raise exception 'sync_push: bad field %', f.key; end if;
      execute format('update public.%I set %I = ($1->>%L)::text::%s where id = $2',
                     tbl, f.key, f.key,
                     (select format_type(a.atttypid, a.atttypmod)
                        from pg_attribute a
                       where a.attrelid = ('public.'||tbl)::regclass and a.attname = f.key and not a.attisdropped))
        using c->'fields', eid;
      get diagnostics row_count = row_count;
      if row_count = 0 then
        -- RLS hid the row: it belongs to another user. Fail loudly rather than record a version.
        raise exception 'sync_push: row % of % not accessible', eid, tbl using errcode = '42501';
      end if;

      insert into public.field_versions (user_id, entity, entity_id, field, hlc)
        values (auth.uid(), tbl, eid, f.key, c->>'hlc')
        on conflict (user_id, entity, entity_id, field) do update set hlc = excluded.hlc;
      applied := applied + 1;
    end loop;
  end loop;

  return jsonb_build_object('applied', applied, 'skipped', skipped);
end $$;
revoke all on function public.sync_push(jsonb) from public;
grant execute on function public.sync_push(jsonb) to authenticated;

-- ---------- trash view & purge ----------
create view public.trash as
  select 'occurrences' as entity, id, user_id, title, deleted_at from public.occurrences
   where deleted_at is not null and deleted_at > now() - interval '30 days'
  union all
  select 'series', id, user_id, title, deleted_at from public.series
   where deleted_at is not null and deleted_at > now() - interval '30 days';
-- Views inherit RLS from base tables (security_invoker).
alter view public.trash set (security_invoker = on);

create or replace function public.purge_old_tombstones()
returns void language sql security definer set search_path = public as $$
  delete from public.subtasks where deleted_at < now() - interval '30 days';
  delete from public.occurrences where deleted_at < now() - interval '30 days';
  delete from public.series where deleted_at < now() - interval '30 days';
$$;
-- Schedule with pg_cron in a later migration: select cron.schedule('purge', '0 3 * * *', $$select public.purge_old_tombstones()$$);

-- ---------- realtime ----------
alter publication supabase_realtime add table public.series, public.occurrences, public.subtasks, public.profiles;
