-- pgTAP: the alarm-tier soft reveal's hint id (docs/15 §11). Run with: supabase test db
begin;
select plan(3);

insert into auth.users (id, email) values
  ('00000000-0000-0000-0000-0000000000a3', 'a13@example.com');

set local role authenticated;
set local request.jwt.claims = '{"sub":"00000000-0000-0000-0000-0000000000a3","role":"authenticated"}';

select lives_ok(
  $$insert into public.reveal_hints (id, user_id, hint_id) values
    ('40000000-0000-0000-0000-0000000013a1', '00000000-0000-0000-0000-0000000000a3', 'wakeUpTierGained'),
    ('40000000-0000-0000-0000-0000000013a2', '00000000-0000-0000-0000-0000000000a3', 'missionOffer')$$,
  'the alarm-tier reveal is a hint, and the earlier ones still are');
select throws_ok(
  $$insert into public.reveal_hints (id, user_id, hint_id) values
    ('40000000-0000-0000-0000-0000000013a3', '00000000-0000-0000-0000-0000000000a3', 'streaks')$$,
  '23514', null, 'an unknown hint is still refused');
select is((select relrowsecurity from pg_class where oid = 'public.reveal_hints'::regclass), true,
  'RLS is still on');

select * from finish();
rollback;
