-- 0002: sync_push fixes found in M0.9 (docs/09). 0001 is never edited (CLAUDE.md §7).
--  1. subtasks placeholder insert used columns subtasks lacks (tz_id, duration_min) and never set
--     the required occurrence_id -> every subtask push failed (R-09).
--  2. a subtask could reference another user's occurrence (FKs bypass RLS).
--  3. unknown field names produced a broken cast instead of a clear error.
--  4. hlc was unvalidated: missing hlc hit a NOT NULL error, and future-dated HLCs could win LWW
--     forever. Format + 5-minute future bound per ADR-0002 / docs/06 §1.
-- Kept: entity allow-list, field-name regex, security invoker + RLS, auth.uid() ownership.

-- (2) subtasks may only hang off the caller's own occurrences.
drop policy "subtasks: own rows" on public.subtasks;
create policy "subtasks: own rows" on public.subtasks
  for all
  using (user_id = auth.uid())
  with check (
    user_id = auth.uid()
    and exists (
      select 1 from public.occurrences o
       where o.id = occurrence_id and o.user_id = auth.uid()
    )
  );

-- Fixed-width HLC (ADR-0002): <13-digit ms>-<4-digit counter>-<16 lowercase hex node>.
create or replace function public.hlc_is_valid(hlc text)
returns boolean language sql immutable as $$
  select hlc is not null and hlc ~ '^[0-9]{13}-[0-9]{4}-[0-9a-f]{16}$';
$$;

-- Ensures the row exists for the caller, creating a minimal placeholder that the per-field
-- updates then fill. Inserts run under RLS, so with-check rejects foreign ownership (42501).
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
  allowed_entities text[] := array['series','occurrences','subtasks','profiles'];
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
