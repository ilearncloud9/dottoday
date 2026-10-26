-- pgTAP: a step's tick time (docs/09 M13.2, ADR-0012). Run with: supabase test db
begin;
select plan(6);

insert into auth.users (id, email) values
  ('00000000-0000-0000-0000-0000000000a8', 'a8@example.com'),
  ('00000000-0000-0000-0000-0000000000b8', 'b8@example.com');

create function pg_temp.hlc(offset_ms bigint, node text default '00000000000000a8')
returns text language sql as $$
  select lpad(((extract(epoch from now()) * 1000)::bigint + offset_ms)::text, 13, '0')
         || '-0001-' || node;
$$;

select has_column('public', 'subtasks', 'done_at', 'subtasks.done_at exists');

set local role authenticated;
set local request.jwt.claims = '{"sub":"00000000-0000-0000-0000-0000000000a8","role":"authenticated"}';

select lives_ok(
  format($$select public.sync_push('[
    {"entity":"occurrences","id":"20000000-0000-0000-0000-0000000008a1","hlc":"%1$s","fields":{"title":"Clean"}},
    {"entity":"subtasks","id":"30000000-0000-0000-0000-0000000008a1","hlc":"%1$s","fields":{"occurrence_id":"20000000-0000-0000-0000-0000000008a1","title":"Dishes"}}
  ]'::jsonb)$$, pg_temp.hlc(-60000)),
  'A pushes a task with a step and no tick time');

select lives_ok(
  format($$select public.sync_push('[{"entity":"subtasks","id":"30000000-0000-0000-0000-0000000008a1","hlc":"%s","fields":{"done":true,"done_at":"2026-10-26T09:15:00.000Z"}}]'::jsonb)$$,
         pg_temp.hlc(-50000)),
  'A ticks the step');
select is((select done_at from public.subtasks where id = '30000000-0000-0000-0000-0000000008a1'),
  '2026-10-26T09:15:00Z'::timestamptz, 'the tick time is kept');

-- An older client unticks without knowing the column: never refused.
select lives_ok(
  format($$select public.sync_push('[{"entity":"subtasks","id":"30000000-0000-0000-0000-0000000008a1","hlc":"%s","fields":{"done":false}}]'::jsonb)$$,
         pg_temp.hlc(-40000)),
  'an untick that leaves done_at is accepted');

-- B can't see A's tick times.
set local request.jwt.claims = '{"sub":"00000000-0000-0000-0000-0000000000b8","role":"authenticated"}';
select is((select count(*) from public.subtasks where done_at is not null), 0::bigint,
  'B sees none of A''s steps');

select * from finish();
rollback;
