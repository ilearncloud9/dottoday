-- 0014 (CR-160, ED-193; docs/06-security.md §9): the server-side guard
-- against cross-account uploads. A device can hold several owners' rows
-- (a guest, account A, account B); each pushed change now names the
-- local owner it belongs to (`owner`), and sync_push refuses the whole
-- call (42501) when any change names no owner or another account than
-- auth.uid(). RLS (`user_id = auth.uid()`) already stops writes to another
-- user's existing rows; this also stops a client defect from inserting
-- one account's new rows into another account. Nothing is dropped or
-- retyped; the function keeps its signature and every 0010 check.

create or replace function public.sync_push(changes jsonb)
returns jsonb language plpgsql security invoker set search_path = public as $$
declare
  c jsonb;
  f record;
  applied int := 0;
  skipped int := 0;
  allowed_entities text[] := array['series','occurrences','subtasks','profiles','routines','reveal_hints'];
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

    -- (CR-160) every change names its local owner; only the signed-in
    -- account's own changes are applied. A device holding another
    -- account's rows can't upload them here, whatever the client does.
    if c->>'owner' is null then
      raise exception 'sync_push: change % of % names no owner', eid, tbl
        using errcode = '42501';
    end if;
    if (c->>'owner') is distinct from auth.uid()::text then
      raise exception 'sync_push: change % of % belongs to another account', eid, tbl
        using errcode = '42501';
    end if;

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
