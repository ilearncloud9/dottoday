-- pgTAP tests for 0002_sync_push_fixes (docs/09 M0.9, ADR-0002, docs/06 §1). Run: supabase test db
begin;
select plan(16);

insert into auth.users (id, email) values
  ('00000000-0000-0000-0000-0000000000a1', 'a@example.com'),
  ('00000000-0000-0000-0000-0000000000b1', 'b@example.com');

-- helper: a valid HLC at now() + offset (ADR-0002 fixed-width format)
create function pg_temp.hlc(offset_ms bigint, node text default '00000000000000a1')
returns text language sql as $$
  select lpad(((extract(epoch from now()) * 1000)::bigint + offset_ms)::text, 13, '0')
         || '-0001-' || node;
$$;

set local role authenticated;

-- B owns an occurrence
set local request.jwt.claims = '{"sub":"00000000-0000-0000-0000-0000000000b1","role":"authenticated"}';
select lives_ok(
  format($$select public.sync_push('[{"entity":"occurrences","id":"20000000-0000-0000-0000-0000000000b1","hlc":"%s","fields":{"title":"B task"}}]'::jsonb)$$,
         pg_temp.hlc(-60000, '00000000000000b1')),
  'B creates an occurrence');

-- A owns an occurrence
set local request.jwt.claims = '{"sub":"00000000-0000-0000-0000-0000000000a1","role":"authenticated"}';
select lives_ok(
  format($$select public.sync_push('[{"entity":"occurrences","id":"20000000-0000-0000-0000-0000000000a1","hlc":"%s","fields":{"title":"A task"}}]'::jsonb)$$,
         pg_temp.hlc(-60000)),
  'A creates an occurrence');

-- (1) subtask round-trip now works
select lives_ok(
  format($$select public.sync_push('[{"entity":"subtasks","id":"30000000-0000-0000-0000-0000000000a1","hlc":"%s","fields":{"occurrence_id":"20000000-0000-0000-0000-0000000000a1","title":"Step one","done":"true"}}]'::jsonb)$$,
         pg_temp.hlc(-50000)),
  'A pushes a new subtask');
select results_eq(
  $$select title, done, occurrence_id from public.subtasks where id = '30000000-0000-0000-0000-0000000000a1'$$,
  $$values ('Step one'::text, true, '20000000-0000-0000-0000-0000000000a1'::uuid)$$,
  'subtask fields applied');

select throws_ok(
  format($$select public.sync_push('[{"entity":"subtasks","id":"30000000-0000-0000-0000-0000000000a2","hlc":"%s","fields":{"title":"orphan"}}]'::jsonb)$$,
         pg_temp.hlc(-50000)),
  '23502', null, 'new subtask without occurrence_id is rejected');

-- (2) subtasks cannot reference another user's occurrence
select throws_ok(
  format($$select public.sync_push('[{"entity":"subtasks","id":"30000000-0000-0000-0000-0000000000a3","hlc":"%s","fields":{"occurrence_id":"20000000-0000-0000-0000-0000000000b1","title":"x"}}]'::jsonb)$$,
         pg_temp.hlc(-50000)),
  '42501', null, 'new subtask on B''s occurrence is rejected');
select throws_ok(
  format($$select public.sync_push('[{"entity":"subtasks","id":"30000000-0000-0000-0000-0000000000a1","hlc":"%s","fields":{"occurrence_id":"20000000-0000-0000-0000-0000000000b1"}}]'::jsonb)$$,
         pg_temp.hlc(-40000)),
  '42501', null, 'moving a subtask onto B''s occurrence is rejected');
select throws_ok(
  $$insert into public.subtasks (id, user_id, occurrence_id, title) values
    ('30000000-0000-0000-0000-0000000000a4', '00000000-0000-0000-0000-0000000000a1', '20000000-0000-0000-0000-0000000000b1', 'x')$$,
  '42501', null, 'direct insert on B''s occurrence violates RLS');

-- (3) unknown field fails clearly
select throws_ok(
  format($$select public.sync_push('[{"entity":"occurrences","id":"20000000-0000-0000-0000-0000000000a1","hlc":"%s","fields":{"no_such_col":"1"}}]'::jsonb)$$,
         pg_temp.hlc(-30000)),
  '42703', null, 'unknown field is rejected');

-- (4) HLC validation
select throws_ok(
  $$select public.sync_push('[{"entity":"occurrences","id":"20000000-0000-0000-0000-0000000000a1","fields":{"title":"t"}}]'::jsonb)$$,
  '22023', null, 'missing hlc is rejected');
select throws_ok(
  $$select public.sync_push('[{"entity":"occurrences","id":"20000000-0000-0000-0000-0000000000a1","hlc":"0000000001-0001-dev","fields":{"title":"t"}}]'::jsonb)$$,
  '22023', null, 'legacy/malformed hlc is rejected');
select throws_ok(
  $$select public.sync_push('[{"entity":"occurrences","id":"20000000-0000-0000-0000-0000000000a1","hlc":"1760000000000-0001-00000000000000AA","fields":{"title":"t"}}]'::jsonb)$$,
  '22023', null, 'uppercase node id is rejected');
select throws_ok(
  format($$select public.sync_push('[{"entity":"occurrences","id":"20000000-0000-0000-0000-0000000000a1","hlc":"%s","fields":{"title":"future"}}]'::jsonb)$$,
         pg_temp.hlc(10 * 60 * 1000)),
  '22023', null, 'hlc > 5 min in the future is rejected');
select is(
  public.sync_push(format('[{"entity":"occurrences","id":"20000000-0000-0000-0000-0000000000a1","hlc":"%s","fields":{"title":"soon"}}]',
                          pg_temp.hlc(4 * 60 * 1000))::jsonb),
  '{"applied": 1, "skipped": 0}'::jsonb,
  'hlc within 5 min skew is accepted');

-- LWW: an older HLC for the same field is skipped (lexicographic compare)
select is(
  public.sync_push(format('[{"entity":"occurrences","id":"20000000-0000-0000-0000-0000000000a1","hlc":"%s","fields":{"title":"stale"}}]',
                          pg_temp.hlc(-20000))::jsonb),
  '{"applied": 0, "skipped": 1}'::jsonb,
  'older hlc is skipped');

-- B still sees none of A's subtasks
set local request.jwt.claims = '{"sub":"00000000-0000-0000-0000-0000000000b1","role":"authenticated"}';
select is((select count(*) from public.subtasks), 0::bigint, 'B sees no subtasks of A');

select * from finish();
rollback;
