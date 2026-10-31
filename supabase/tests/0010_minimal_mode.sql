-- pgTAP: minimal mode's layout flag and reveal hints (docs/09 M16). Run with: supabase test db
begin;
select plan(11);

select has_table('public', 'reveal_hints', 'reveal_hints exists');
select is((select relrowsecurity from pg_class where oid = 'public.reveal_hints'::regclass), true,
  'RLS is on for reveal_hints');

insert into auth.users (id, email) values
  ('00000000-0000-0000-0000-0000000000a0', 'a10@example.com'),
  ('00000000-0000-0000-0000-0000000000b0', 'b10@example.com');

create function pg_temp.hlc(offset_ms bigint, node text default '00000000000000a0')
returns text language sql as $$
  select lpad(((extract(epoch from now()) * 1000)::bigint + offset_ms)::text, 13, '0')
         || '-0001-' || node;
$$;

select ok(public.validate_settings('{"dayBoundaries":{},"uiLayout":"minimal"}'), 'minimal is a layout');
select ok(not public.validate_settings('{"dayBoundaries":{},"uiLayout":"tiny"}'), 'an unknown layout is refused');

set local role authenticated;
set local request.jwt.claims = '{"sub":"00000000-0000-0000-0000-0000000000a0","role":"authenticated"}';

select lives_ok(
  format($$select public.sync_push('[{"entity":"reveal_hints","id":"40000000-0000-0000-0000-0000000010a1","hlc":"%s","fields":{"hint_id":"unstick","shown_count":"1"}}]'::jsonb)$$,
         pg_temp.hlc(-60000)),
  'A pushes a hint record');
select is((select shown_count from public.reveal_hints where id = '40000000-0000-0000-0000-0000000010a1'), 1,
  'the count is stored');
select throws_ok(
  $$update public.reveal_hints set shown_count = 3 where id = '40000000-0000-0000-0000-0000000010a1'$$,
  '23514', null, 'a hint shows at most twice');
select throws_ok(
  $$insert into public.reveal_hints (id, user_id, hint_id) values
    ('40000000-0000-0000-0000-0000000010a2', '00000000-0000-0000-0000-0000000000a0', 'unstick')$$,
  '23505', null, 'one row per user and hint');
select throws_ok(
  $$insert into public.reveal_hints (id, user_id, hint_id) values
    ('40000000-0000-0000-0000-0000000010a3', '00000000-0000-0000-0000-0000000000a0', 'streaks')$$,
  '23514', null, 'an unknown hint is refused');

-- B can neither see nor take over A's hints.
set local request.jwt.claims = '{"sub":"00000000-0000-0000-0000-0000000000b0","role":"authenticated"}';
select is((select count(*) from public.reveal_hints), 0::bigint, 'B sees none of A''s hints');
select throws_ok(
  format($$select public.sync_push('[{"entity":"reveal_hints","id":"40000000-0000-0000-0000-0000000010a1","hlc":"%s","fields":{"shown_count":"2"}}]'::jsonb)$$,
         pg_temp.hlc(-40000, '00000000000000b0')),
  null, null, 'B cannot write A''s hint');

select * from finish();
rollback;
