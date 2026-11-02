-- pgTAP: Wake Up discovery's hint ids (docs/09 M17.6). Run with: supabase test db
begin;
select plan(5);

insert into auth.users (id, email) values
  ('00000000-0000-0000-0000-0000000000a2', 'a12@example.com');

set local role authenticated;
set local request.jwt.claims = '{"sub":"00000000-0000-0000-0000-0000000000a2","role":"authenticated"}';

select lives_ok(
  $$insert into public.reveal_hints (id, user_id, hint_id) values
    ('40000000-0000-0000-0000-0000000012a1', '00000000-0000-0000-0000-0000000000a2', 'wakeUpPromise'),
    ('40000000-0000-0000-0000-0000000012a2', '00000000-0000-0000-0000-0000000000a2', 'wakeUpStartDay'),
    ('40000000-0000-0000-0000-0000000012a3', '00000000-0000-0000-0000-0000000000a2', 'wakeUpShift'),
    ('40000000-0000-0000-0000-0000000012a4', '00000000-0000-0000-0000-0000000000a2', 'wakeUpCheckPing'),
    ('40000000-0000-0000-0000-0000000012a5', '00000000-0000-0000-0000-0000000000a2', 'missionOffer')$$,
  'every discovery hint is a hint');
select lives_ok(
  $$insert into public.reveal_hints (id, user_id, hint_id) values
    ('40000000-0000-0000-0000-0000000012a6', '00000000-0000-0000-0000-0000000000a2', 'unstick')$$,
  'minimal mode''s hints still are');
select throws_ok(
  $$insert into public.reveal_hints (id, user_id, hint_id) values
    ('40000000-0000-0000-0000-0000000012a7', '00000000-0000-0000-0000-0000000000a2', 'streaks')$$,
  '23514', null, 'an unknown hint is still refused');
select throws_ok(
  $$update public.reveal_hints set shown_count = 3 where id = '40000000-0000-0000-0000-0000000012a1'$$,
  '23514', null, 'a discovery hint shows at most twice');
select is((select relrowsecurity from pg_class where oid = 'public.reveal_hints'::regclass), true,
  'RLS is still on');

select * from finish();
rollback;
