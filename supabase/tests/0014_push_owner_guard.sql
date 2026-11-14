-- pgTAP: the cross-account upload guard (CR-160, ED-193, docs/06 §9).
-- Run with: supabase test db
begin;
select plan(11);

insert into auth.users (id, email) values
  ('00000000-0000-0000-0000-0000000014a0', 'a14@example.com'),
  ('00000000-0000-0000-0000-0000000014b0', 'b14@example.com');

create function pg_temp.hlc(offset_ms bigint, node text default '00000000000014a0')
returns text language sql as $$
  select lpad(((extract(epoch from now()) * 1000)::bigint + offset_ms)::text, 13, '0')
         || '-0001-' || node;
$$;

select is((select prosecdef from pg_proc where oid = 'public.sync_push(jsonb)'::regprocedure),
  false, 'sync_push still runs as the caller (RLS applies)');

set local role authenticated;
set local request.jwt.claims = '{"sub":"00000000-0000-0000-0000-0000000014a0","role":"authenticated"}';

select lives_ok(
  format($$select public.sync_push('[{"owner":"00000000-0000-0000-0000-0000000014a0","entity":"occurrences","id":"20000000-0000-0000-0000-0000000014a1","hlc":"%s","fields":{"title":"A task"}}]'::jsonb)$$,
         pg_temp.hlc(-60000)),
  'A pushes a change A owns');

-- The leak CR-160 describes: the device signed in as A uploads rows that
-- belong to B (or the other way round). Refused, nothing written.
select throws_ok(
  format($$select public.sync_push('[{"owner":"00000000-0000-0000-0000-0000000014b0","entity":"occurrences","id":"20000000-0000-0000-0000-0000000014b9","hlc":"%s","fields":{"title":"B task"}}]'::jsonb)$$,
         pg_temp.hlc(-50000)),
  '42501', null, 'a change owned by another account is refused');
select is((select count(*) from public.occurrences where id = '20000000-0000-0000-0000-0000000014b9'),
  0::bigint, 'and nothing of it was written');

select throws_ok(
  format($$select public.sync_push('[{"entity":"occurrences","id":"20000000-0000-0000-0000-0000000014a2","hlc":"%s","fields":{"title":"no owner"}}]'::jsonb)$$,
         pg_temp.hlc(-40000)),
  '42501', null, 'a change that names no owner is refused (an old client)');

select throws_ok(
  format($$select public.sync_push('[{"owner":"00000000-0000-0000-0000-0000000014a0","entity":"occurrences","id":"20000000-0000-0000-0000-0000000014a3","hlc":"%s","fields":{"title":"mine"}},{"owner":"00000000-0000-0000-0000-0000000014b0","entity":"occurrences","id":"20000000-0000-0000-0000-0000000014a4","hlc":"%s","fields":{"title":"theirs"}}]'::jsonb)$$,
         pg_temp.hlc(-30000), pg_temp.hlc(-30000)),
  '42501', null, 'one foreign change refuses the whole call');
select is((select count(*) from public.occurrences
            where id in ('20000000-0000-0000-0000-0000000014a3', '20000000-0000-0000-0000-0000000014a4')),
  0::bigint, 'not even the caller''s own change of that call is applied');

select throws_ok(
  format($$select public.sync_push('[{"owner":"00000000-0000-0000-0000-0000000014b0","entity":"profiles","id":"00000000-0000-0000-0000-0000000014a0","hlc":"%s","fields":{"tz_id":"Asia/Tokyo"}}]'::jsonb)$$,
         pg_temp.hlc(-20000)),
  '42501', null, 'another account''s settings can''t be pushed onto A''s profile');

-- B, signed in, sees none of A's rows and can't claim them.
set local request.jwt.claims = '{"sub":"00000000-0000-0000-0000-0000000014b0","role":"authenticated"}';
select is((select count(*) from public.occurrences), 0::bigint, 'B''s account holds none of A''s rows');
select throws_ok(
  format($$select public.sync_push('[{"owner":"00000000-0000-0000-0000-0000000014a0","entity":"occurrences","id":"20000000-0000-0000-0000-0000000014a5","hlc":"%s","fields":{"title":"pretend A"}}]'::jsonb)$$,
         pg_temp.hlc(-10000, '00000000000014b0')),
  '42501', null, 'B can''t push a change in A''s name');
select lives_ok(
  format($$select public.sync_push('[{"owner":"00000000-0000-0000-0000-0000000014b0","entity":"occurrences","id":"20000000-0000-0000-0000-0000000014b1","hlc":"%s","fields":{"title":"B task"}}]'::jsonb)$$,
         pg_temp.hlc(-10000, '00000000000014b0')),
  'B pushes a change B owns');

select * from finish();
rollback;
