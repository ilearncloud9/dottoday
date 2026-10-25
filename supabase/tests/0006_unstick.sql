-- pgTAP: the move counter for Unstick (docs/09 M10.7). Run with: supabase test db
begin;
select plan(6);

insert into auth.users (id, email) values
  ('00000000-0000-0000-0000-0000000000a6', 'a6@example.com'),
  ('00000000-0000-0000-0000-0000000000b6', 'b6@example.com');

create function pg_temp.hlc(offset_ms bigint, node text default '00000000000000a6')
returns text language sql as $$
  select lpad(((extract(epoch from now()) * 1000)::bigint + offset_ms)::text, 13, '0')
         || '-0001-' || node;
$$;

set local role authenticated;
set local request.jwt.claims = '{"sub":"00000000-0000-0000-0000-0000000000a6","role":"authenticated"}';

select lives_ok(
  format($$select public.sync_push('[{"entity":"occurrences","id":"20000000-0000-0000-0000-0000000006a1","hlc":"%s","fields":{"title":"Do taxes"}}]'::jsonb)$$,
         pg_temp.hlc(-60000)),
  'A pushes a task without a move count');
select is((select move_count from public.occurrences where id = '20000000-0000-0000-0000-0000000006a1'), 0,
  'a new task starts at 0 moves');

select lives_ok(
  format($$select public.sync_push('[{"entity":"occurrences","id":"20000000-0000-0000-0000-0000000006a1","hlc":"%s","fields":{"move_count":"3"}}]'::jsonb)$$,
         pg_temp.hlc(-50000)),
  'A pushes three moves');
select is((select move_count from public.occurrences where id = '20000000-0000-0000-0000-0000000006a1'), 3,
  'move count applied');

select throws_ok(
  $$update public.occurrences set move_count = -1 where id = '20000000-0000-0000-0000-0000000006a1'$$,
  '23514', null, 'a negative move count is refused');

-- B can't see A's counter.
set local request.jwt.claims = '{"sub":"00000000-0000-0000-0000-0000000000b6","role":"authenticated"}';
select is((select count(*) from public.occurrences where move_count > 0), 0::bigint,
  'B sees none of A''s moved tasks');

select * from finish();
rollback;
