-- pgTAP RLS tests. Run with: supabase test db
begin;
select plan(7);

-- two fake users
insert into auth.users (id, email) values
  ('00000000-0000-0000-0000-00000000000a', 'a@example.com'),
  ('00000000-0000-0000-0000-00000000000b', 'b@example.com');

-- act as A, create an occurrence
set local role authenticated;
set local request.jwt.claims = '{"sub":"00000000-0000-0000-0000-00000000000a","role":"authenticated"}';
insert into public.occurrences (id, user_id, title, tz_id, duration_min)
  values ('10000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-00000000000a', 'A task', 'UTC', 30);
select is((select count(*) from public.occurrences), 1::bigint, 'A sees own occurrence');

-- A cannot insert a row for B
select throws_ok(
  $$insert into public.occurrences (id, user_id, title, tz_id, duration_min)
    values ('10000000-0000-0000-0000-000000000002', '00000000-0000-0000-0000-00000000000b', 'spoof', 'UTC', 30)$$,
  '42501', null, 'A cannot insert as B');

-- act as B
set local request.jwt.claims = '{"sub":"00000000-0000-0000-0000-00000000000b","role":"authenticated"}';
select is((select count(*) from public.occurrences), 0::bigint, 'B sees nothing of A');
select is((select count(*) from public.series), 0::bigint, 'B sees no series of A');

-- B cannot update A's row (0 rows affected)
update public.occurrences set title = 'hacked' where id = '10000000-0000-0000-0000-000000000001';
set local request.jwt.claims = '{"sub":"00000000-0000-0000-0000-00000000000a","role":"authenticated"}';
select is((select title from public.occurrences where id = '10000000-0000-0000-0000-000000000001'), 'A task', 'B could not modify A');

-- sync_push ignores spoofed user_id
select lives_ok(
  $$select public.sync_push('[{"entity":"occurrences","id":"10000000-0000-0000-0000-000000000001","hlc":"0000000001-0001-dev","fields":{"title":"renamed","user_id":"00000000-0000-0000-0000-00000000000b"}}]'::jsonb)$$,
  'sync_push runs');

-- B pushing to A's row must fail loudly (RLS hides the row)
set local request.jwt.claims = '{"sub":"00000000-0000-0000-0000-00000000000b","role":"authenticated"}';
select throws_ok(
  $$select public.sync_push('[{"entity":"occurrences","id":"10000000-0000-0000-0000-000000000001","hlc":"0000000009-0001","fields":{"title":"B hack"}}]'::jsonb)$$,
  '42501', null, 'B cannot sync_push into A row');

select * from finish();
rollback;
