-- 0007 (docs/09 M11.4, 11-standout-roadmap C2 Routines).
-- 1. routines: a saved slice of thread — ordered steps with lengths and gaps
--    (items jsonb, camelCase inside like series.subtask_template), placed on a
--    day by its anchor (Wake Up, Bedtime or a local minute). One table, not
--    routines + routine_items: a routine is edited as a whole, rarely, and the
--    items column mirrors series.subtask_template (one sync entity, one RLS
--    policy, one export list).
-- 2. occurrences.routine_start: the first step of a dropped routine rings loud
--    like an alarm (A0, M6.5.3). Additive.
-- 3. sync_push / sync_push_ensure_row learn the 'routines' entity; conflicts
--    accept it; purge and realtime include it. Nothing dropped or retyped.

create table public.routines (
  id uuid primary key,
  user_id uuid not null references public.profiles(id) on delete cascade,
  title text not null check (char_length(btrim(title)) between 1 and 200),
  anchor text not null default 'wake' check (anchor in ('wake','bed','time')),
  anchor_minute int check (anchor_minute is null or anchor_minute between 0 and 1439),
  items jsonb not null default '[]'::jsonb
    check (jsonb_typeof(items) = 'array' and jsonb_array_length(items) <= 30),
  sort_order double precision not null default 0,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  deleted_at timestamptz
);
create index routines_user_updated on public.routines (user_id, updated_at);
alter table public.routines enable row level security;
create policy "routines: own rows" on public.routines
  for all using (user_id = auth.uid()) with check (user_id = auth.uid());
create trigger routines_updated_at before update on public.routines
  for each row execute function public.set_updated_at();

alter table public.occurrences
  add column routine_start boolean not null default false;

alter table public.conflicts drop constraint conflicts_entity_check;
alter table public.conflicts add constraint conflicts_entity_check
  check (entity in ('series','occurrences','subtasks','profiles','routines'));

create or replace function public.sync_push_ensure_row(tbl text, eid uuid, fields jsonb)
returns void language plpgsql security invoker set search_path = public as $$
declare
  occ uuid;
begin
  if tbl = 'profiles' then
    if eid <> auth.uid() then raise exception 'sync_push: profile id mismatch'; end if;
  elsif tbl = 'series' then
    insert into public.series (id, user_id, title, tz_id, duration_min, rrule, dtstart_local)
      values (eid, auth.uid(), 'untitled', 'UTC', 30, 'FREQ=DAILY', '1970-01-01T00:00:00')
      on conflict (id) do nothing;
  elsif tbl = 'occurrences' then
    insert into public.occurrences (id, user_id, title, tz_id, duration_min)
      values (eid, auth.uid(), 'untitled', 'UTC', 30)
      on conflict (id) do nothing;
  elsif tbl = 'routines' then
    insert into public.routines (id, user_id, title)
      values (eid, auth.uid(), 'untitled')
      on conflict (id) do nothing;
  elsif tbl = 'subtasks' then
    if exists (select 1 from public.subtasks where id = eid) then return; end if;
    occ := (fields->>'occurrence_id')::uuid;
    if occ is null then
      raise exception 'sync_push: new subtask % needs occurrence_id', eid using errcode = '23502';
    end if;
    insert into public.subtasks (id, user_id, occurrence_id, title)
      values (eid, auth.uid(), occ, 'untitled')
      on conflict (id) do nothing;
  end if;
end $$;

create or replace function public.sync_push(changes jsonb)
returns jsonb language plpgsql security invoker set search_path = public as $$
declare
  c jsonb;
  f record;
  applied int := 0;
  skipped int := 0;
  allowed_entities text[] := array['series','occurrences','subtasks','profiles','routines'];
  tbl text;
  hlc text;
  existing_hlc text;
  col_type text;
  eid uuid;
  row_count int;
  max_ms bigint := (extract(epoch from now()) * 1000)::bigint + 5 * 60 * 1000;
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

    -- (4) validate before touching any row.
    hlc := c->>'hlc';
    if not public.hlc_is_valid(hlc) then
      raise exception 'sync_push: malformed hlc for % %', tbl, eid using errcode = '22023';
    end if;
    if left(hlc, 13)::bigint > max_ms then
      raise exception 'sync_push: hlc more than 5 min in the future for % %', tbl, eid
        using errcode = '22023';
    end if;

    perform public.sync_push_ensure_row(tbl, eid, c->'fields');

    for f in select key, value from jsonb_each(c->'fields') loop
      if f.key in ('id','user_id','created_at','updated_at') then continue; end if;
      if f.key !~ '^[a-z_]{1,64}$' then raise exception 'sync_push: bad field %', f.key; end if;

      -- (3) resolve the column type up front; unknown columns fail clearly.
      select format_type(a.atttypid, a.atttypmod) into col_type
        from pg_attribute a
       where a.attrelid = ('public.' || tbl)::regclass
         and a.attname = f.key and a.attnum > 0 and not a.attisdropped;
      if col_type is null then
        raise exception 'sync_push: unknown field % on %', f.key, tbl using errcode = '42703';
      end if;

      select v.hlc into existing_hlc from public.field_versions v
        where v.user_id = auth.uid() and v.entity = tbl and v.entity_id = eid and v.field = f.key;

      -- Fixed-width HLCs compare lexicographically; force C collation (ADR-0002).
      if existing_hlc is not null and existing_hlc collate "C" >= hlc collate "C" then
        skipped := skipped + 1;
        continue;  -- server already has a newer value for this field
      end if;

      execute format('update public.%I set %I = ($1->>%L)::text::%s where id = $2',
                     tbl, f.key, f.key, col_type)
        using c->'fields', eid;
      get diagnostics row_count = row_count;
      if row_count = 0 then
        -- RLS hid the row: it belongs to another user. Fail loudly rather than record a version.
        raise exception 'sync_push: row % of % not accessible', eid, tbl using errcode = '42501';
      end if;

      insert into public.field_versions (user_id, entity, entity_id, field, hlc)
        values (auth.uid(), tbl, eid, f.key, hlc)
        on conflict (user_id, entity, entity_id, field) do update set hlc = excluded.hlc;
      applied := applied + 1;
    end loop;
  end loop;

  return jsonb_build_object('applied', applied, 'skipped', skipped);
end $$;

revoke all on function public.sync_push(jsonb) from public;
grant execute on function public.sync_push(jsonb) to authenticated;
revoke all on function public.sync_push_ensure_row(text, uuid, jsonb) from public;
grant execute on function public.sync_push_ensure_row(text, uuid, jsonb) to authenticated;

create or replace function public.purge_old_tombstones()
returns void language sql security definer set search_path = public as $$
  delete from public.subtasks where deleted_at < now() - interval '30 days';
  delete from public.occurrences where deleted_at < now() - interval '30 days';
  delete from public.series where deleted_at < now() - interval '30 days';
  delete from public.routines where deleted_at < now() - interval '30 days';
$$;

alter publication supabase_realtime add table public.routines;
