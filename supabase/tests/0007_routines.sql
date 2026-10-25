-- pgTAP: routines and routine-start dots (docs/09 M11.4). Run with: supabase test db
begin;
select plan(12);

select has_table('public', 'routines', 'routines exists');
select is((select relrowsecurity from pg_class where oid = 'public.routines'::regclass), true,
  'RLS is on for routines');

insert into auth.users (id, email) values
  ('00000000-0000-0000-0000-0000000000a7', 'a7@example.com'),
  ('00000000-0000-0000-0000-0000000000b7', 'b7@example.com');

create function pg_temp.hlc(offset_ms bigint, node text default '00000000000000a7')
returns text language sql as $$
  select lpad(((extract(epoch from now()) * 1000)::bigint + offset_ms)::text, 13, '0')
         || '-0001-' || node;
$$;

set local role authenticated;
set local request.jwt.claims = '{"sub":"00000000-0000-0000-0000-0000000000a7","role":"authenticated"}';

select lives_ok(
  format($$select public.sync_push('[{"entity":"routines","id":"30000000-0000-0000-0000-0000000007a1","hlc":"%s","fields":{"title":"Morning","anchor":"wake","items":"[{\"id\":\"i1\",\"title\":\"Run\",\"offsetMin\":0,\"durationMin\":30}]"}}]'::jsonb)$$,
         pg_temp.hlc(-60000)),
  'A pushes a new routine');
select is((select title from public.routines where id = '30000000-0000-0000-0000-0000000007a1'), 'Morning',
  'the routine is stored');
select is((select jsonb_array_length(items) from public.routines where id = '30000000-0000-0000-0000-0000000007a1'), 1,
  'its steps are stored');

select throws_ok(
  $$update public.routines set anchor = 'noon' where id = '30000000-0000-0000-0000-0000000007a1'$$,
  '23514', null, 'an unknown anchor is refused');
select throws_ok(
  $$update public.routines set items = '{}'::jsonb where id = '30000000-0000-0000-0000-0000000007a1'$$,
  '23514', null, 'items must be an array');
select throws_ok(
  $$update public.routines set anchor_minute = 1440 where id = '30000000-0000-0000-0000-0000000007a1'$$,
  '23514', null, 'anchor minute stays within the day');

select lives_ok(
  format($$select public.sync_push('[{"entity":"occurrences","id":"20000000-0000-0000-0000-0000000007a2","hlc":"%s","fields":{"title":"Run","routine_start":"true"}}]'::jsonb)$$,
         pg_temp.hlc(-50000)),
  'A pushes a routine-start task');
select is((select routine_start from public.occurrences where id = '20000000-0000-0000-0000-0000000007a2'), true,
  'routine_start applied');

-- B can neither see nor take over A's routine.
set local request.jwt.claims = '{"sub":"00000000-0000-0000-0000-0000000000b7","role":"authenticated"}';
select is((select count(*) from public.routines), 0::bigint, 'B sees none of A''s routines');
select throws_ok(
  format($$select public.sync_push('[{"entity":"routines","id":"30000000-0000-0000-0000-0000000007a1","hlc":"%s","fields":{"title":"Mine"}}]'::jsonb)$$,
         pg_temp.hlc(-40000, '00000000000000b7')),
  null, null, 'B cannot write A''s routine');

select * from finish();
rollback;
