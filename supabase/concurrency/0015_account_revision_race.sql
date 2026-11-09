-- Two-session races for 0015 (CR-160 W2). Real concurrent backends through
-- dblink: one session writes, another freezes, and the order in which they
-- reach the revision row's lock is forced and checked in pg_stat_activity.
-- Local stack only. Run with: supabase/concurrency/run.sh
\set ON_ERROR_STOP 1
set client_min_messages = notice;
create extension if not exists dblink with schema extensions;
set search_path = public, extensions;

create temp table results (n serial, ok boolean, name text);
create function pg_temp.check(cond boolean, name text) returns void language plpgsql as $$
begin
  insert into results (ok, name) values (coalesce(cond, false), name);
  raise notice '% - %', case when coalesce(cond, false) then 'ok' else 'NOT OK' end, name;
end $$;

-- A connection named [c] acting as [role] with [sub] (null: no user).
create function pg_temp.open(c text, role text, sub uuid) returns int language plpgsql as $$
declare pid int;
begin
  perform dblink_connect(c, 'dbname=postgres user=postgres password=postgres host=supabase_db_dottoday port=5432');
  perform dblink_exec(c, format('set role %I', role));
  perform dblink_exec(c, format('set request.jwt.claims = %L',
    case when sub is null then json_build_object('role', role)::text
         else json_build_object('sub', sub, 'role', role)::text end));
  select p into pid from dblink(c, 'select pg_backend_pid()') as t(p int);
  return pid;
end $$;

-- Whether backend [pid] is waiting on a lock, within 5 s.
create function pg_temp.waiting(pid int) returns boolean language plpgsql as $$
begin
  for i in 1..100 loop
    if exists (select 1 from pg_stat_activity a where a.pid = waiting.pid and a.wait_event_type = 'Lock') then
      return true;
    end if;
    perform pg_sleep(0.05);
  end loop;
  return false;
end $$;

-- The text result of an async query on [c], or 'ERROR: <message>'.
create function pg_temp.result(c text) returns text language plpgsql as $$
declare v text;
begin
  while dblink_is_busy(c) = 1 loop perform pg_sleep(0.02); end loop;
  begin
    select r into v from dblink_get_result(c) as t(r text);
  exception when others then
    v := 'ERROR: ' || sqlerrm;
  end;
  -- Drain the trailing empty result so the connection is reusable.
  begin perform * from dblink_get_result(c) as t(r text); exception when others then null; end;
  return v;
end $$;

create function pg_temp.rev(o uuid) returns bigint language sql as $$
  select revision from public.account_revisions where user_id = o;
$$;
create function pg_temp.frozen(o uuid) returns boolean language sql as $$
  select deletion_attempt is not null from public.account_revisions where user_id = o;
$$;
create function pg_temp.attempt(o uuid) returns uuid language sql as $$
  select deletion_attempt from public.account_revisions where user_id = o;
$$;
-- Ends the live freeze of [o] through its own attempt (these tests make no
-- Auth Admin calls, so none is unresolved).
create function pg_temp.unfreeze(o uuid) returns text language sql as $$
  select public.release_account_deletion(o, pg_temp.attempt(o));
$$;

-- Leftovers of an interrupted run first.
delete from auth.users where email like '%@race.test';

-- Fresh accounts for this run, one task each (committed: other sessions see them).
create temp table ids as select gen_random_uuid() as a, gen_random_uuid() as b,
  gen_random_uuid() as ta, gen_random_uuid() as ta2, gen_random_uuid() as tb, gen_random_uuid() as sa;
insert into auth.users (id, email) select a, a::text || '@race.test' from ids;
insert into auth.users (id, email) select b, b::text || '@race.test' from ids;
insert into public.occurrences (id, user_id, title, tz_id, duration_min)
  select ta, a, 'A task', 'UTC', 30 from ids
  union all select ta2, a, 'A task 2', 'UTC', 30 from ids
  union all select tb, b, 'B task', 'UTC', 30 from ids;
insert into public.subtasks (id, user_id, occurrence_id, title) select sa, a, ta, 'A step' from ids;
select set_config('race.a', a::text, false), set_config('race.b', b::text, false),
       set_config('race.ta', ta::text, false), set_config('race.ta2', ta2::text, false),
       set_config('race.tb', tb::text, false) from ids;

\set A '(select a from ids)'
\set B '(select b from ids)'

-- ---------- 1. client writer first, freeze waits, then sees the change ----------
do $$
declare
  a uuid := current_setting('race.a'); r0 bigint := pg_temp.rev(a); wpid int; dpid int; v text;
begin
  wpid := pg_temp.open('w', 'authenticated', a);
  dpid := pg_temp.open('d', 'service_role', null);
  perform dblink_exec('w', 'begin');
  perform dblink_exec('w', format('update public.occurrences set title = %L where id = %L', 'w1', current_setting('race.ta')));
  perform dblink_send_query('d', format('select outcome from public.begin_account_deletion(%L, %s)', a, r0));
  perform pg_temp.check(pg_temp.waiting(dpid), '1: the freeze waits for an open client write');
  perform dblink_exec('w', 'commit');
  v := pg_temp.result('d');
  perform pg_temp.check(v = 'changed', '1: once it commits, the freeze sees the change (' || v || ')');
  perform pg_temp.check(not pg_temp.frozen(a), '1: nothing frozen');
  perform dblink_disconnect('w'); perform dblink_disconnect('d');
end $$;

-- ---------- 2. freeze first, client writer waits, then is refused ----------
do $$
declare
  a uuid := current_setting('race.a'); r0 bigint := pg_temp.rev(a); wpid int; dpid int; v text;
begin
  wpid := pg_temp.open('w', 'authenticated', a);
  dpid := pg_temp.open('d', 'service_role', null);
  perform dblink_exec('d', 'begin');
  select r into v from dblink('d', format('select outcome from public.begin_account_deletion(%L, %s)', a, r0)) as t(r text);
  perform pg_temp.check(v = 'frozen', '2: the freeze is taken (not yet committed)');
  perform dblink_send_query('w', format('update public.occurrences set title = %L where id = %L returning 1::text', 'late', current_setting('race.ta')));
  perform pg_temp.check(pg_temp.waiting(wpid), '2: a client write waits for the freeze');
  perform dblink_exec('d', 'commit');
  v := pg_temp.result('w');
  perform pg_temp.check(v like 'ERROR:%being deleted%', '2: and is refused once it commits (' || v || ')');
  perform pg_temp.check(pg_temp.rev(a) = r0, '2: the revision did not move');
  perform pg_temp.check((select title from public.occurrences where id = current_setting('race.ta')::uuid) = 'w1',
    '2: the row is unchanged');
  perform dblink_disconnect('w'); perform dblink_disconnect('d');
end $$;

-- ---------- 3. service-role write (data row first, revision lock last) after the freeze ----------
-- Still frozen from 2: end it so this one starts clean. Its own statement:
-- inside the block below it would hold A's revision row until the block
-- ended, and the freeze under test would wait for this session.
select pg_temp.unfreeze(current_setting('race.a')::uuid);
do $$
declare
  a uuid := current_setting('race.a'); r0 bigint := pg_temp.rev(a); wpid int; dpid int; v text;
begin
  wpid := pg_temp.open('w', 'service_role', null);
  dpid := pg_temp.open('d', 'service_role', null);
  perform dblink_exec('d', 'begin');
  perform * from dblink('d', format('select outcome from public.begin_account_deletion(%L, %s)', a, r0)) as t(r text);
  perform dblink_send_query('w', format(
    'update public.occurrences set title = title || %L where id in (%L, %L) returning 1::text',
    '!', current_setting('race.ta'), current_setting('race.tb')));
  perform pg_temp.check(pg_temp.waiting(wpid), '3: a service-role write over A and B waits at A''s revision row');
  perform dblink_exec('d', 'commit');
  v := pg_temp.result('w');
  perform pg_temp.check(v like 'ERROR:%being deleted%', '3: and is refused as a whole (' || v || ')');
  perform pg_temp.check((select title from public.occurrences where id = current_setting('race.tb')::uuid) = 'B task',
    '3: B''s row in that statement was not changed either');
  perform pg_temp.unfreeze(a);
  perform dblink_disconnect('w'); perform dblink_disconnect('d');
end $$;

-- ---------- 4. writer that rolls back: the freeze goes through ----------
do $$
declare
  a uuid := current_setting('race.a'); r0 bigint := pg_temp.rev(a); wpid int; dpid int; v text;
begin
  wpid := pg_temp.open('w', 'authenticated', a);
  dpid := pg_temp.open('d', 'service_role', null);
  perform dblink_exec('w', 'begin');
  perform dblink_exec('w', format('delete from public.occurrences where id = %L', current_setting('race.ta')));
  perform dblink_send_query('d', format('select outcome from public.begin_account_deletion(%L, %s)', a, r0));
  perform pg_temp.check(pg_temp.waiting(dpid), '4: the freeze waits for an open hard delete (with its cascade)');
  perform dblink_exec('w', 'rollback');
  v := pg_temp.result('d');
  perform pg_temp.check(v = 'frozen', '4: rolled back, nothing changed, so the freeze is taken (' || v || ')');
  perform pg_temp.check(pg_temp.rev(a) = r0, '4: the rollback did not move the revision');
  perform pg_temp.check(exists (select 1 from public.subtasks where occurrence_id = current_setting('race.ta')::uuid),
    '4: the task and its step are still there');
  perform pg_temp.unfreeze(a);
  perform dblink_disconnect('w'); perform dblink_disconnect('d');
end $$;

-- ---------- 5. committed multi-statement client transaction (sync_push shape) ----------
do $$
declare
  a uuid := current_setting('race.a'); r0 bigint := pg_temp.rev(a); wpid int; dpid int; v text;
begin
  wpid := pg_temp.open('w', 'authenticated', a);
  dpid := pg_temp.open('d', 'service_role', null);
  perform dblink_exec('w', 'begin');
  perform dblink_exec('w', format('insert into public.routines (id, user_id, title) values (gen_random_uuid(), %L, %L)', a, 'Evening'));
  perform dblink_send_query('d', format('select outcome from public.begin_account_deletion(%L, %s)', a, r0));
  perform pg_temp.check(pg_temp.waiting(dpid), '5: the freeze waits after the first statement');
  perform dblink_exec('w', format('update public.occurrences set deleted_at = now() where id = %L', current_setting('race.ta2')));
  perform dblink_exec('w', 'commit');
  v := pg_temp.result('d');
  perform pg_temp.check(v = 'changed', '5: insert + soft delete committed → changed (' || v || ')');
  perform dblink_disconnect('w'); perform dblink_disconnect('d');
end $$;

-- ---------- 6. two writers of one account serialise; each commit moves it ----------
do $$
declare
  a uuid := current_setting('race.a'); r0 bigint := pg_temp.rev(a); p1 int; p2 int;
begin
  p1 := pg_temp.open('w', 'authenticated', a);
  p2 := pg_temp.open('w2', 'authenticated', a);
  perform dblink_exec('w', 'begin');
  perform dblink_exec('w', format('update public.occurrences set title = %L where id = %L', 'one', current_setting('race.ta')));
  perform dblink_send_query('w2', format('update public.occurrences set title = %L where id = %L returning 1::text', 'two', current_setting('race.ta2')));
  perform pg_temp.check(pg_temp.waiting(p2), '6: a second writer of the same account waits (one lock order)');
  perform dblink_exec('w', 'commit');
  perform pg_temp.result('w2');
  perform pg_temp.check(pg_temp.rev(a) = r0 + 2, '6: both commits moved the revision');
  perform dblink_disconnect('w'); perform dblink_disconnect('w2');
end $$;

-- ---------- 7. lock timeout: a long writer holds the row, the freeze gives up ----------
do $$
declare
  a uuid := current_setting('race.a'); r0 bigint := pg_temp.rev(a); wpid int; dpid int; v text; t0 timestamptz;
begin
  wpid := pg_temp.open('w', 'authenticated', a);
  dpid := pg_temp.open('d', 'service_role', null);
  perform dblink_exec('w', 'begin');
  perform dblink_exec('w', format('update public.occurrences set title = %L where id = %L', 'slow', current_setting('race.ta')));
  t0 := clock_timestamp();
  perform dblink_send_query('d', format('select outcome from public.begin_account_deletion(%L, %s)', a, r0));
  v := pg_temp.result('d');
  perform pg_temp.check(v like 'ERROR:%lock timeout%', '7: the freeze stops after its lock timeout (' || v || ')');
  perform pg_temp.check(clock_timestamp() - t0 between interval '4 seconds' and interval '8 seconds',
    '7: after about 5 s');
  perform dblink_exec('w', 'commit');
  perform pg_temp.check(not pg_temp.frozen(a), '7: nothing frozen');
  perform pg_temp.check(pg_temp.rev(a) = r0 + 1, '7: the writer committed normally');
  perform dblink_disconnect('w'); perform dblink_disconnect('d');
end $$;

-- ---------- 8. deadlock: client (revision first) against service role (row first) ----------
do $$
declare
  a uuid := current_setting('race.a'); r0 bigint := pg_temp.rev(a); cpid int; spid int; vc text; vs text; dead int;
begin
  cpid := pg_temp.open('c', 'authenticated', a);
  spid := pg_temp.open('s', 'service_role', null);
  perform dblink_exec('c', 'begin');
  perform dblink_exec('s', 'begin');
  -- c: A's revision row, then task 2.
  perform dblink_exec('c', format('update public.occurrences set title = %L where id = %L', 'c', current_setting('race.ta2')));
  -- s: task 1's row, then waits for A's revision row (held by c).
  perform dblink_send_query('s', format('update public.occurrences set title = %L where id = %L returning 1::text', 's', current_setting('race.ta')));
  perform pg_temp.check(pg_temp.waiting(spid), '8: the service-role writer holds task 1 and waits for A''s revision');
  -- c now wants task 1: a cycle.
  perform dblink_send_query('c', format('update public.occurrences set title = %L where id = %L returning 1::text', 'c2', current_setting('race.ta')));
  vc := pg_temp.result('c');
  vs := pg_temp.result('s');
  dead := (vc like 'ERROR:%deadlock%')::int + (vs like 'ERROR:%deadlock%')::int;
  perform pg_temp.check(dead = 1, '8: Postgres breaks the cycle, aborting exactly one (c: ' || coalesce(vc, 'null') || ' / s: ' || coalesce(vs, 'null') || ')');
  perform dblink_exec('c', case when vc like 'ERROR:%' then 'rollback' else 'commit' end);
  perform dblink_exec('s', case when vs like 'ERROR:%' then 'rollback' else 'commit' end);
  perform pg_temp.check(pg_temp.rev(a) > r0, '8: the survivor''s commit moved the revision');
  perform dblink_disconnect('c'); perform dblink_disconnect('s');
end $$;

-- ---------- 9. concurrent upserts of one new row ----------
do $$
declare
  a uuid := current_setting('race.a'); r0 bigint := pg_temp.rev(a); p1 int; p2 int; id uuid := gen_random_uuid(); q text;
begin
  p1 := pg_temp.open('w', 'authenticated', a);
  p2 := pg_temp.open('w2', 'authenticated', a);
  q := format('insert into public.occurrences (id, user_id, title, tz_id, duration_min) values (%L, %L, %%L, %L, 10) on conflict (id) do update set title = excluded.title returning 1::text', id, a, 'UTC');
  perform dblink_exec('w', 'begin');
  perform * from dblink('w', format(q, 'first')) as t(r text);
  perform dblink_send_query('w2', format(q, 'second'));
  perform pg_temp.check(pg_temp.waiting(p2), '9: the second upsert waits');
  perform dblink_exec('w', 'commit');
  perform pg_temp.result('w2');
  perform pg_temp.check(pg_temp.rev(a) = r0 + 2, '9: insert then conflict-update, both counted');
  perform dblink_disconnect('w'); perform dblink_disconnect('w2');
end $$;


-- ---------- 10. two freezes at once, same revision: one attempt, joined ----------
do $$
declare
  a uuid := current_setting('race.a'); r0 bigint := pg_temp.rev(a); p1 int; p2 int; v1 text; v2 text; att uuid;
begin
  p1 := pg_temp.open('d', 'service_role', null);
  p2 := pg_temp.open('d2', 'service_role', null);
  perform dblink_exec('d', 'begin');
  select r into v1 from dblink('d', format('select attempt::text from public.begin_account_deletion(%L, %s)', a, r0)) as t(r text);
  perform dblink_send_query('d2', format('select attempt::text from public.begin_account_deletion(%L, %s)', a, r0));
  perform pg_temp.check(pg_temp.waiting(p2), '10: a second freeze at the same revision waits for the first');
  perform dblink_exec('d', 'commit');
  v2 := pg_temp.result('d2');
  perform pg_temp.check(v1 is not null and v1 = v2, '10: and joins the same attempt, nothing overwritten');
  perform pg_temp.check(pg_temp.attempt(a)::text = v1, '10: one freeze, the first attempt');
  perform dblink_disconnect('d'); perform dblink_disconnect('d2');
end $$;

-- ---------- 11. a freeze at another revision while one is unresolved ----------
do $$
declare
  a uuid := current_setting('race.a'); att uuid := pg_temp.attempt(a); v text; pid int;
begin
  pid := pg_temp.open('d', 'service_role', null);
  select r into v from dblink('d', format('select outcome from public.begin_account_deletion(%L, %s)', a, pg_temp.rev(a) + 1)) as t(r text);
  perform pg_temp.check(v = 'pending', '11: another revision is told an unresolved deletion exists (' || v || ')');
  perform pg_temp.check(pg_temp.attempt(a) = att, '11: and can''t take it over');
  perform dblink_disconnect('d');
end $$;

-- ---------- 12. a release racing an Auth Admin call being recorded ----------
do $$
declare
  a uuid := current_setting('race.a'); att uuid := pg_temp.attempt(a); p1 int; p2 int; v text;
begin
  p1 := pg_temp.open('e', 'service_role', null);
  p2 := pg_temp.open('r', 'service_role', null);
  perform dblink_exec('e', 'begin');
  perform * from dblink('e', format('select public.note_account_deletion_call(%L, %L)::text', a, att)) as t(r text);
  perform dblink_send_query('r', format('select public.release_account_deletion(%L, %L)', a, att));
  perform pg_temp.check(pg_temp.waiting(p2), '12: the release waits while a call is being recorded');
  perform dblink_exec('e', 'commit');
  v := pg_temp.result('r');
  perform pg_temp.check(v = 'unresolved', '12: and then refuses: that call''s outcome is unknown (' || v || ')');
  perform pg_temp.check(pg_temp.frozen(a), '12: still frozen');
  -- That call was (say) refused for certain: now the attempt may end it.
  perform * from dblink('e', format('select public.note_account_deletion_refused(%L, %L)::text', a, att)) as t(r text);
  perform dblink_disconnect('e'); perform dblink_disconnect('r');
end $$;
select pg_temp.check(pg_temp.unfreeze(current_setting('race.a')::uuid) = 'released',
  '12: once the call is known refused, the same attempt ends the freeze');

-- ---------- 13. lost connections ----------
do $$
declare
  a uuid := current_setting('race.a'); r0 bigint := pg_temp.rev(a); pid int;
begin
  pid := pg_temp.open('d', 'service_role', null);
  perform dblink_exec('d', 'begin');
  perform * from dblink('d', format('select outcome from public.begin_account_deletion(%L, %s)', a, r0)) as t(r text);
  perform pg_terminate_backend(pid);
  perform pg_sleep(0.3);
  perform pg_temp.check(not pg_temp.frozen(a), '13: a freeze whose connection drops before commit never happened');
  begin perform dblink_disconnect('d'); exception when others then null; end;
  pid := pg_temp.open('d', 'service_role', null);
  perform * from dblink('d', format('select outcome from public.begin_account_deletion(%L, %s)', a, r0)) as t(r text);
  perform pg_terminate_backend(pid);
  perform pg_sleep(0.3);
  perform pg_temp.check(pg_temp.frozen(a), '13: a committed freeze survives its connection dropping');
  begin perform dblink_disconnect('d'); exception when others then null; end;
end $$;
do $$
declare
  a uuid := current_setting('race.a'); pid int; v text;
begin
  pid := pg_temp.open('w', 'authenticated', a);
  select r into v from dblink('w', format('select count(*)::text from public.occurrences where id = %L', current_setting('race.ta'))) as t(r text);
  perform dblink_send_query('w', format('update public.occurrences set title = %L where id = %L returning 1::text', 'after drop', current_setting('race.ta')));
  v := pg_temp.result('w');
  perform pg_temp.check(v like 'ERROR:%being deleted%', '13: and still refuses writes from a new connection');
  perform dblink_disconnect('w');
end $$;

-- ---------- clean up and summarise ----------
-- A is still frozen (13): removing its auth user is the deletion path, allowed.
delete from auth.users where id in ((select a from ids), (select b from ids));
select count(*) filter (where ok) as passed, count(*) filter (where not ok) as failed from results;
do $$ begin
  if exists (select 1 from results where not ok) then raise exception 'race checks failed'; end if;
end $$;
