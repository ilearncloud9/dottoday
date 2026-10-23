-- pgTAP: actual timestamps and step durations (docs/09 M6.5.1). Run with: supabase test db
begin;
select plan(7);

insert into auth.users (id, email) values
  ('00000000-0000-0000-0000-0000000000a4', 'a4@example.com'),
  ('00000000-0000-0000-0000-0000000000b4', 'b4@example.com');

create function pg_temp.hlc(offset_ms bigint, node text default '00000000000000a4')
returns text language sql as $$
  select lpad(((extract(epoch from now()) * 1000)::bigint + offset_ms)::text, 13, '0')
         || '-0001-' || node;
$$;

set local role authenticated;
set local request.jwt.claims = '{"sub":"00000000-0000-0000-0000-0000000000a4","role":"authenticated"}';

select lives_ok(
  format($$select public.sync_push('[{"entity":"occurrences","id":"20000000-0000-0000-0000-0000000004a1","hlc":"%s","fields":{"title":"Run","actual_start_utc":"2026-10-21T07:42:00Z","actual_end_utc":"2026-10-21T08:16:00Z","duration_from_steps":"true"}}]'::jsonb)$$,
         pg_temp.hlc(-60000)),
  'A pushes actual start/end and duration_from_steps');
select results_eq(
  $$select actual_start_utc, actual_end_utc, duration_from_steps from public.occurrences where id = '20000000-0000-0000-0000-0000000004a1'$$,
  $$values ('2026-10-21T07:42:00Z'::timestamptz, '2026-10-21T08:16:00Z'::timestamptz, true)$$,
  'actual timestamps applied');

select lives_ok(
  format($$select public.sync_push('[{"entity":"subtasks","id":"30000000-0000-0000-0000-0000000004a1","hlc":"%s","fields":{"occurrence_id":"20000000-0000-0000-0000-0000000004a1","title":"Stretch","duration_min":"2"}}]'::jsonb)$$,
         pg_temp.hlc(-50000)),
  'A pushes a step with a 2 min duration');
select is((select duration_min from public.subtasks where id = '30000000-0000-0000-0000-0000000004a1'), 2,
  'step duration applied');

select throws_ok(
  format($$select public.sync_push('[{"entity":"subtasks","id":"30000000-0000-0000-0000-0000000004a1","hlc":"%s","fields":{"duration_min":"0"}}]'::jsonb)$$,
         pg_temp.hlc(-40000)),
  '23514', null, 'a 0 min step is refused');
select throws_ok(
  $$update public.subtasks set duration_min = 1441 where id = '30000000-0000-0000-0000-0000000004a1'$$,
  '23514', null, 'a step over a day is refused');

-- B can't see A's actuals.
set local request.jwt.claims = '{"sub":"00000000-0000-0000-0000-0000000000b4","role":"authenticated"}';
select is((select count(*) from public.occurrences where actual_start_utc is not null), 0::bigint,
  'B sees none of A''s actual timestamps');

select * from finish();
rollback;
