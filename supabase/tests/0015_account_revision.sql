-- pgTAP: the per-account revision and deletion freeze (CR-160 W2, 0015).
-- One session: what each route moves, what a freeze refuses, who may do
-- what. The races between sessions are in supabase/concurrency/.
-- Run with: supabase test db
begin;
select plan(90);

insert into auth.users (id, email) values
  ('00000000-0000-0000-0000-0000000015a0', 'a15@example.com'),
  ('00000000-0000-0000-0000-0000000015b0', 'b15@example.com');

-- Revisions read as the table owner, whoever the test is acting as.
create table pg_temp.marks (owner uuid primary key, rev bigint);
create function pg_temp.rev(o uuid) returns bigint language sql security definer as $$
  select coalesce((select revision from public.account_revisions where user_id = o), -1);
$$;
create function pg_temp.mark(o uuid) returns void language sql security definer as $$
  insert into pg_temp.marks values (o, pg_temp.rev(o))
  on conflict (owner) do update set rev = excluded.rev;
$$;
create function pg_temp.moved(o uuid) returns boolean language sql security definer as $$
  select pg_temp.rev(o) > (select rev from pg_temp.marks where owner = o);
$$;
create function pg_temp.same(o uuid) returns boolean language sql security definer as $$
  select pg_temp.rev(o) = (select rev from pg_temp.marks where owner = o);
$$;
create function pg_temp.hlc(offset_ms bigint) returns text language sql as $$
  select lpad(((extract(epoch from now()) * 1000)::bigint + offset_ms)::text, 13, '0')
         || '-0001-00000000000015a0';
$$;
grant all on table pg_temp.marks to authenticated, service_role;

-- ---------- structure and privileges ----------
select ok(pg_temp.rev('00000000-0000-0000-0000-0000000015a0') >= 1,
  'a new account has a revision (its profile insert moved it)');
select is((select relrowsecurity from pg_class where oid = 'public.account_revisions'::regclass),
  true, 'account_revisions has RLS');
select is((select count(*) from pg_proc
            where proname in ('account_revision_bump','account_revision_row','account_revision_statement',
                              'begin_account_deletion','abort_account_deletion')
              and prosecdef and proconfig @> array['search_path=""']),
  5::bigint, 'every definer function runs with an empty search_path');
select is((select prosecdef from pg_proc where oid = 'public.account_revision()'::regprocedure),
  false, 'account_revision() runs as the caller (RLS applies)');
select ok(not has_function_privilege('authenticated', 'public.begin_account_deletion(uuid,bigint)', 'EXECUTE'),
  'a signed-in user can''t freeze any account');
select ok(not has_function_privilege('authenticated', 'public.abort_account_deletion(uuid)', 'EXECUTE'),
  'a signed-in user can''t end a freeze');
select ok(not has_function_privilege('authenticated', 'public.account_revision_bump(uuid)', 'EXECUTE'),
  'a signed-in user can''t call the bump');
select ok(not has_function_privilege('service_role', 'public.account_revision_bump(uuid)', 'EXECUTE'),
  'nor can the service role');
select ok(not has_function_privilege('anon', 'public.account_revision()', 'EXECUTE'),
  'anon can''t read revisions');
select ok(has_function_privilege('service_role', 'public.begin_account_deletion(uuid,bigint)', 'EXECUTE'),
  'the service role (delete-account) can freeze');
select ok(not has_table_privilege('authenticated', 'public.account_revisions', 'UPDATE')
          and not has_table_privilege('authenticated', 'public.account_revisions', 'INSERT')
          and not has_table_privilege('authenticated', 'public.account_revisions', 'DELETE'),
  'signed-in users can''t write revisions');
select ok(not has_table_privilege('service_role', 'public.account_revisions', 'UPDATE'),
  'the service role can''t write revisions directly either');
select ok(not has_table_privilege('authenticated', 'public.occurrences', 'TRUNCATE')
          and not has_table_privilege('service_role', 'public.occurrences', 'TRUNCATE'),
  'TRUNCATE (no row triggers) is not granted on exported data');

-- ---------- as A: every write type on every exported table ----------
set local role authenticated;
set local request.jwt.claims = '{"sub":"00000000-0000-0000-0000-0000000015a0","role":"authenticated"}';

select is((select revision from public.account_revision()),
  pg_temp.rev('00000000-0000-0000-0000-0000000015a0'), 'A reads A''s revision');
select is((select count(*) from public.account_revisions), 1::bigint, 'A sees only A''s revision row');
select throws_ok($$update public.account_revisions set revision = 0$$, '42501', null,
  'A can''t forge a revision');
select throws_ok($$update public.account_revisions set deleting_until = null$$, '42501', null,
  'A can''t lift a freeze by hand');
select throws_ok($$select public.begin_account_deletion('00000000-0000-0000-0000-0000000015b0', 0)$$,
  '42501', null, 'A can''t freeze B');
select throws_ok($$select public.account_revision_bump('00000000-0000-0000-0000-0000000015a0')$$,
  '42501', null, 'A can''t call the bump');

select pg_temp.mark('00000000-0000-0000-0000-0000000015a0');
update public.profiles set tz_id = 'Europe/Berlin';
select ok(pg_temp.moved('00000000-0000-0000-0000-0000000015a0'), 'profiles: update moves it');

select pg_temp.mark('00000000-0000-0000-0000-0000000015a0');
insert into public.series (id, user_id, title, tz_id, duration_min, rrule, dtstart_local)
  values ('15000000-0000-0000-0000-0000000015a1', '00000000-0000-0000-0000-0000000015a0',
          'Run', 'UTC', 30, 'FREQ=DAILY', '2026-11-01T07:00:00');
select ok(pg_temp.moved('00000000-0000-0000-0000-0000000015a0'), 'series: insert moves it');
select pg_temp.mark('00000000-0000-0000-0000-0000000015a0');
update public.series set title = 'Run far' where id = '15000000-0000-0000-0000-0000000015a1';
select ok(pg_temp.moved('00000000-0000-0000-0000-0000000015a0'), 'series: update moves it');

select pg_temp.mark('00000000-0000-0000-0000-0000000015a0');
insert into public.occurrences (id, user_id, title, tz_id, duration_min, series_id)
  values ('15000000-0000-0000-0000-0000000015a2', '00000000-0000-0000-0000-0000000015a0',
          'Gym', 'UTC', 45, '15000000-0000-0000-0000-0000000015a1');
select ok(pg_temp.moved('00000000-0000-0000-0000-0000000015a0'), 'occurrences: insert moves it');
select pg_temp.mark('00000000-0000-0000-0000-0000000015a0');
update public.occurrences set title = 'Gym, legs' where id = '15000000-0000-0000-0000-0000000015a2';
select ok(pg_temp.moved('00000000-0000-0000-0000-0000000015a0'), 'occurrences: update moves it');
select pg_temp.mark('00000000-0000-0000-0000-0000000015a0');
insert into public.occurrences (id, user_id, title, tz_id, duration_min)
  values ('15000000-0000-0000-0000-0000000015a2', '00000000-0000-0000-0000-0000000015a0', 'Gym, arms', 'UTC', 45)
  on conflict (id) do update set title = excluded.title;
select ok(pg_temp.moved('00000000-0000-0000-0000-0000000015a0'), 'occurrences: upsert (conflict → update) moves it');
select pg_temp.mark('00000000-0000-0000-0000-0000000015a0');
insert into public.occurrences (id, user_id, title, tz_id, duration_min)
  values ('15000000-0000-0000-0000-0000000015a2', '00000000-0000-0000-0000-0000000015a0', 'ignored', 'UTC', 45)
  on conflict (id) do nothing;
select ok(pg_temp.same('00000000-0000-0000-0000-0000000015a0'), 'an upsert that changes nothing moves nothing');

select pg_temp.mark('00000000-0000-0000-0000-0000000015a0');
insert into public.subtasks (id, user_id, occurrence_id, title)
  values ('15000000-0000-0000-0000-0000000015a3', '00000000-0000-0000-0000-0000000015a0',
          '15000000-0000-0000-0000-0000000015a2', 'Warm up');
select ok(pg_temp.moved('00000000-0000-0000-0000-0000000015a0'), 'subtasks: insert moves it');
select pg_temp.mark('00000000-0000-0000-0000-0000000015a0');
update public.subtasks set done = true where id = '15000000-0000-0000-0000-0000000015a3';
select ok(pg_temp.moved('00000000-0000-0000-0000-0000000015a0'), 'subtasks: update moves it');
select pg_temp.mark('00000000-0000-0000-0000-0000000015a0');
update public.subtasks set deleted_at = now() where id = '15000000-0000-0000-0000-0000000015a3';
select ok(pg_temp.moved('00000000-0000-0000-0000-0000000015a0'), 'subtasks: soft delete moves it');

select pg_temp.mark('00000000-0000-0000-0000-0000000015a0');
insert into public.routines (id, user_id, title)
  values ('15000000-0000-0000-0000-0000000015a4', '00000000-0000-0000-0000-0000000015a0', 'Morning');
select ok(pg_temp.moved('00000000-0000-0000-0000-0000000015a0'), 'routines: insert moves it');
select pg_temp.mark('00000000-0000-0000-0000-0000000015a0');
update public.routines set deleted_at = now() where id = '15000000-0000-0000-0000-0000000015a4';
select ok(pg_temp.moved('00000000-0000-0000-0000-0000000015a0'), 'routines: soft delete moves it');
select pg_temp.mark('00000000-0000-0000-0000-0000000015a0');
delete from public.routines where id = '15000000-0000-0000-0000-0000000015a4';
select ok(pg_temp.moved('00000000-0000-0000-0000-0000000015a0'), 'routines: hard delete moves it');

select pg_temp.mark('00000000-0000-0000-0000-0000000015a0');
insert into public.reveal_hints (id, user_id, hint_id)
  values ('15000000-0000-0000-0000-0000000015a5', '00000000-0000-0000-0000-0000000015a0', 'unstick');
select ok(pg_temp.moved('00000000-0000-0000-0000-0000000015a0'), 'reveal_hints: insert moves it');
select pg_temp.mark('00000000-0000-0000-0000-0000000015a0');
update public.reveal_hints set shown_count = 1 where id = '15000000-0000-0000-0000-0000000015a5';
select ok(pg_temp.moved('00000000-0000-0000-0000-0000000015a0'), 'reveal_hints: update moves it');
select pg_temp.mark('00000000-0000-0000-0000-0000000015a0');
delete from public.reveal_hints where id = '15000000-0000-0000-0000-0000000015a5';
select ok(pg_temp.moved('00000000-0000-0000-0000-0000000015a0'), 'reveal_hints: hard delete moves it');

select pg_temp.mark('00000000-0000-0000-0000-0000000015a0');
select lives_ok(
  format($$select public.sync_push('[{"owner":"00000000-0000-0000-0000-0000000015a0","entity":"occurrences","id":"15000000-0000-0000-0000-0000000015a6","hlc":"%s","fields":{"title":"Pushed"}}]'::jsonb)$$,
         pg_temp.hlc(-60000)),
  'A pushes through sync_push');
select ok(pg_temp.moved('00000000-0000-0000-0000-0000000015a0'), 'sync_push moves it');

-- Cascades: a series delete sets occurrences.series_id null (an UPDATE),
-- an occurrence delete takes its subtasks (DELETEs).
select pg_temp.mark('00000000-0000-0000-0000-0000000015a0');
delete from public.series where id = '15000000-0000-0000-0000-0000000015a1';
select ok(pg_temp.moved('00000000-0000-0000-0000-0000000015a0'), 'series: hard delete (with its SET NULL cascade) moves it');
select is((select series_id from public.occurrences where id = '15000000-0000-0000-0000-0000000015a2'),
  null::uuid, 'the cascade ran');
select pg_temp.mark('00000000-0000-0000-0000-0000000015a0');
update public.occurrences set deleted_at = now() where id = '15000000-0000-0000-0000-0000000015a2';
select ok(pg_temp.moved('00000000-0000-0000-0000-0000000015a0'), 'occurrences: soft delete moves it');
select pg_temp.mark('00000000-0000-0000-0000-0000000015a0');
delete from public.occurrences where id = '15000000-0000-0000-0000-0000000015a2';
select ok(pg_temp.rev('00000000-0000-0000-0000-0000000015a0')
          >= (select rev from pg_temp.marks where owner = '00000000-0000-0000-0000-0000000015a0') + 2,
  'occurrences: hard delete moves it once for itself and once for its cascaded subtask');
select is((select count(*) from public.subtasks where id = '15000000-0000-0000-0000-0000000015a3'),
  0::bigint, 'the subtask went with it');

-- A change rolled back moves nothing.
select pg_temp.mark('00000000-0000-0000-0000-0000000015a0');
savepoint before_rollback;
insert into public.occurrences (id, user_id, title, tz_id, duration_min)
  values ('15000000-0000-0000-0000-0000000015a7', '00000000-0000-0000-0000-0000000015a0', 'Undone', 'UTC', 10);
rollback to savepoint before_rollback;
select ok(pg_temp.same('00000000-0000-0000-0000-0000000015a0'), 'a rolled-back insert leaves the revision as it was');
select pg_temp.mark('00000000-0000-0000-0000-0000000015a0');
update public.occurrences set title = 'nothing' where id = '15000000-0000-0000-0000-00000000ffff';
select ok(pg_temp.same('00000000-0000-0000-0000-0000000015a0'), 'an update that matches no row moves nothing');

-- ---------- as B ----------
set local request.jwt.claims = '{"sub":"00000000-0000-0000-0000-0000000015b0","role":"authenticated"}';
insert into public.occurrences (id, user_id, title, tz_id, duration_min)
  values ('15000000-0000-0000-0000-0000000015b1', '00000000-0000-0000-0000-0000000015b0', 'B task', 'UTC', 20);
select is((select count(*) from public.account_revisions), 1::bigint, 'B sees only B''s revision row');
select pg_temp.mark('00000000-0000-0000-0000-0000000015a0');
update public.occurrences set title = 'B was here' where user_id = '00000000-0000-0000-0000-0000000015a0';
select ok(pg_temp.same('00000000-0000-0000-0000-0000000015a0'), 'B can''t touch A''s rows (RLS), so A''s revision stays');

-- ---------- the service role: several owners, owner changes ----------
reset role;
set local role service_role;
set local request.jwt.claims = '{"role":"service_role"}';
insert into public.occurrences (id, user_id, title, tz_id, duration_min)
  values ('15000000-0000-0000-0000-0000000015a8', '00000000-0000-0000-0000-0000000015a0', 'A again', 'UTC', 20);
select pg_temp.mark('00000000-0000-0000-0000-0000000015a0');
select pg_temp.mark('00000000-0000-0000-0000-0000000015b0');
update public.occurrences set title = title || '.'
 where id in ('15000000-0000-0000-0000-0000000015a8', '15000000-0000-0000-0000-0000000015b1');
select ok(pg_temp.moved('00000000-0000-0000-0000-0000000015a0') and pg_temp.moved('00000000-0000-0000-0000-0000000015b0'),
  'one service-role statement over two owners moves both (auth.uid() is null)');
select pg_temp.mark('00000000-0000-0000-0000-0000000015a0');
select pg_temp.mark('00000000-0000-0000-0000-0000000015b0');
update public.occurrences set user_id = '00000000-0000-0000-0000-0000000015b0'
 where id = '15000000-0000-0000-0000-0000000015a8';
select ok(pg_temp.moved('00000000-0000-0000-0000-0000000015a0') and pg_temp.moved('00000000-0000-0000-0000-0000000015b0'),
  'moving a row to another owner moves both owners');
update public.occurrences set user_id = '00000000-0000-0000-0000-0000000015a0'
 where id = '15000000-0000-0000-0000-0000000015a8';

-- ---------- freeze ----------
select is(public.begin_account_deletion('00000000-0000-0000-0000-0000000015a0',
            pg_temp.rev('00000000-0000-0000-0000-0000000015a0') - 1),
  'changed', 'a stale expected revision refuses the deletion');
select is((select deleting_until from public.account_revisions where user_id = '00000000-0000-0000-0000-0000000015a0'),
  null::timestamptz, 'and freezes nothing');
select throws_ok($$select public.begin_account_deletion(null, 1)$$, '22004', null,
  'no user: refused');
select is(public.begin_account_deletion('00000000-0000-0000-0000-00000000dead', 0), 'gone',
  'an unknown user is reported gone');
select pg_temp.mark('00000000-0000-0000-0000-0000000015a0');
select is(public.begin_account_deletion('00000000-0000-0000-0000-0000000015a0',
            pg_temp.rev('00000000-0000-0000-0000-0000000015a0')),
  'frozen', 'the export''s revision freezes the account');
select ok(pg_temp.same('00000000-0000-0000-0000-0000000015a0'), 'freezing doesn''t move the revision');
select is(public.begin_account_deletion('00000000-0000-0000-0000-0000000015a0',
            pg_temp.rev('00000000-0000-0000-0000-0000000015a0')),
  'frozen', 'a retry at the same revision is still frozen');
select is(public.begin_account_deletion('00000000-0000-0000-0000-0000000015a0',
            pg_temp.rev('00000000-0000-0000-0000-0000000015a0') - 1),
  'changed', 'a retry at another revision is refused, the freeze stays');
select throws_ok($$update public.occurrences set title = 'svc' where id = '15000000-0000-0000-0000-0000000015a8'$$,
  'DT409', null, 'the service role can''t change a frozen account''s rows');
select throws_ok($$update public.occurrences set title = title
                    where id in ('15000000-0000-0000-0000-0000000015a8', '15000000-0000-0000-0000-0000000015b1')$$,
  'DT409', null, 'nor slip them into a statement over several owners');
select lives_ok($$update public.occurrences set title = 'B ok' where id = '15000000-0000-0000-0000-0000000015b1'$$,
  'another account is not affected');

reset role;
set local role authenticated;
set local request.jwt.claims = '{"sub":"00000000-0000-0000-0000-0000000015a0","role":"authenticated"}';
select is((select frozen from public.account_revision()), true, 'A can see the freeze');
select throws_ok($$insert into public.occurrences (id, user_id, title, tz_id, duration_min)
                    values ('15000000-0000-0000-0000-0000000015a9', '00000000-0000-0000-0000-0000000015a0', 'late', 'UTC', 5)$$,
  'DT409', null, 'frozen: insert refused');
select throws_ok($$update public.occurrences set title = 'late' where id = '15000000-0000-0000-0000-0000000015a8'$$,
  'DT409', null, 'frozen: update refused');
select throws_ok($$update public.occurrences set deleted_at = now() where id = '15000000-0000-0000-0000-0000000015a8'$$,
  'DT409', null, 'frozen: soft delete refused');
select throws_ok($$delete from public.occurrences where id = '15000000-0000-0000-0000-0000000015a8'$$,
  'DT409', null, 'frozen: hard delete refused');
select throws_ok($$delete from public.occurrences where id = '15000000-0000-0000-0000-00000000ffff'$$,
  'DT409', null, 'frozen: even a statement that would touch nothing is refused');
select throws_ok($$update public.profiles set tz_id = 'UTC'$$, 'DT409', null, 'frozen: settings refused');
select throws_ok($$delete from public.profiles$$, 'DT409', null, 'frozen: deleting the profile (and its cascade) refused');
select throws_ok($$insert into public.routines (id, user_id, title) values ('15000000-0000-0000-0000-0000000015aa', '00000000-0000-0000-0000-0000000015a0', 'x')$$,
  'DT409', null, 'frozen: routines refused');
select throws_ok($$insert into public.reveal_hints (id, user_id, hint_id) values ('15000000-0000-0000-0000-0000000015ab', '00000000-0000-0000-0000-0000000015a0', 'routines')$$,
  'DT409', null, 'frozen: reveal_hints refused');
select throws_ok($$insert into public.series (id, user_id, title, tz_id, duration_min, rrule, dtstart_local) values ('15000000-0000-0000-0000-0000000015ac', '00000000-0000-0000-0000-0000000015a0', 'x', 'UTC', 5, 'FREQ=DAILY', '2026-11-01T07:00:00')$$,
  'DT409', null, 'frozen: series refused');
select throws_ok($$insert into public.subtasks (id, user_id, occurrence_id, title) values ('15000000-0000-0000-0000-0000000015ad', '00000000-0000-0000-0000-0000000015a0', '15000000-0000-0000-0000-0000000015a8', 'x')$$,
  'DT409', null, 'frozen: subtasks refused');
select throws_ok(
  format($$select public.sync_push('[{"owner":"00000000-0000-0000-0000-0000000015a0","entity":"occurrences","id":"15000000-0000-0000-0000-0000000015ae","hlc":"%s","fields":{"title":"late push"}}]'::jsonb)$$,
         pg_temp.hlc(-30000)),
  'DT409', null, 'frozen: sync_push refused');
select ok(pg_temp.same('00000000-0000-0000-0000-0000000015a0'), 'nothing refused moved the revision');

-- ---------- purge skips the frozen account ----------
reset role;
set local request.jwt.claims = '{}';
update public.occurrences set deleted_at = now() - interval '40 days'
 where id = '15000000-0000-0000-0000-0000000015b1';
select lives_ok($$select public.purge_old_tombstones()$$, 'the purge runs while an account is frozen');
select is((select count(*) from public.occurrences where id = '15000000-0000-0000-0000-0000000015b1'),
  0::bigint, 'and still purges the other accounts');

-- ---------- abort and expiry ----------
set local role service_role;
select pg_temp.mark('00000000-0000-0000-0000-0000000015a0');
select is(public.abort_account_deletion('00000000-0000-0000-0000-0000000015a0'), true, 'abort ends the freeze');
select ok(pg_temp.moved('00000000-0000-0000-0000-0000000015a0'), 'and moves the revision, so the old review is void');
select is(public.begin_account_deletion('00000000-0000-0000-0000-0000000015a0',
            (select rev from pg_temp.marks where owner = '00000000-0000-0000-0000-0000000015a0')),
  'changed', 'the revision from before the abort no longer deletes');
select is(public.abort_account_deletion('00000000-0000-0000-0000-0000000015a0'), false, 'a second abort does nothing');
select is(public.begin_account_deletion('00000000-0000-0000-0000-0000000015a0',
            pg_temp.rev('00000000-0000-0000-0000-0000000015a0')),
  'frozen', 'frozen again at the current revision');
reset role;
update public.account_revisions set deleting_until = clock_timestamp() - interval '1 second'
 where user_id = '00000000-0000-0000-0000-0000000015a0';
set local role authenticated;
set local request.jwt.claims = '{"sub":"00000000-0000-0000-0000-0000000015a0","role":"authenticated"}';
select pg_temp.mark('00000000-0000-0000-0000-0000000015a0');
select lives_ok($$update public.occurrences set title = 'after expiry' where id = '15000000-0000-0000-0000-0000000015a8'$$,
  'an expired freeze no longer refuses');
select ok(pg_temp.moved('00000000-0000-0000-0000-0000000015a0'), 'the write moves the revision');
select is((select frozen from public.account_revision()), false, 'and the freeze is cleared');
reset role;
set local role service_role;
select is(public.begin_account_deletion('00000000-0000-0000-0000-0000000015a0',
            (select rev from pg_temp.marks where owner = '00000000-0000-0000-0000-0000000015a0')),
  'changed', 'a retry after expiry with the old revision is refused');

-- ---------- removing the auth user while frozen (SQL path) ----------
-- The Auth Admin API path is checked against the running stack in
-- supabase/concurrency/auth_admin_delete.sh.
select is(public.begin_account_deletion('00000000-0000-0000-0000-0000000015a0',
            pg_temp.rev('00000000-0000-0000-0000-0000000015a0')),
  'frozen', 'frozen before the user is removed');
reset role;
select lives_ok($$delete from auth.users where id = '00000000-0000-0000-0000-0000000015a0'$$,
  'deleting the frozen auth user succeeds (the cascade is allowed)');
select is((select count(*) from public.occurrences where user_id = '00000000-0000-0000-0000-0000000015a0')
        + (select count(*) from public.profiles where id = '00000000-0000-0000-0000-0000000015a0')
        + (select count(*) from public.account_revisions where user_id = '00000000-0000-0000-0000-0000000015a0'),
  0::bigint, 'its rows, profile and revision are gone');
select ok(pg_temp.rev('00000000-0000-0000-0000-0000000015b0') > 0
          and (select count(*) from public.profiles where id = '00000000-0000-0000-0000-0000000015b0') = 1,
  'B is untouched');

-- A stale session of the deleted user can't write anything back.
set local role authenticated;
set local request.jwt.claims = '{"sub":"00000000-0000-0000-0000-0000000015a0","role":"authenticated"}';
select throws_ok($$insert into public.occurrences (id, user_id, title, tz_id, duration_min)
                    values ('15000000-0000-0000-0000-0000000015af', '00000000-0000-0000-0000-0000000015a0', 'ghost', 'UTC', 5)$$,
  '23503', null, 'a deleted user''s leftover token can''t re-create rows');
select is((select count(*) from public.account_revisions), 0::bigint, 'nor a revision row');

select * from finish();
rollback;
