-- pgTAP: Google/Microsoft calendar connections and their Vault tokens (docs/09 M7.4).
-- Run with: supabase test db
begin;
select plan(14);

insert into auth.users (id, email) values
  ('00000000-0000-0000-0000-00000000000a', 'a@example.com'),
  ('00000000-0000-0000-0000-00000000000b', 'b@example.com');

-- The service role (the Edge Functions) connects A's Google account.
set local role service_role;
select lives_ok(
  $$select public.calendar_account_connect('00000000-0000-0000-0000-00000000000a', 'google',
      'sub-a', 'a@example.com', '{"refresh_token":"r1"}')$$,
  'the service role connects an account');
select is(
  (select public.calendar_token_get(id) from public.calendar_accounts where external_account_id = 'sub-a'),
  '{"refresh_token":"r1"}', 'its token is in Vault');
select public.calendar_account_connect('00000000-0000-0000-0000-00000000000a', 'google',
  'sub-a', 'a@example.com', '{"refresh_token":"r2"}');
select is((select count(*) from public.calendar_accounts where external_account_id = 'sub-a'), 1::bigint,
  'reconnecting keeps one row');
select is(
  (select public.calendar_token_get(id) from public.calendar_accounts where external_account_id = 'sub-a'),
  '{"refresh_token":"r2"}', 'reconnecting replaces the token');
select throws_ok(
  $$select public.calendar_account_connect('00000000-0000-0000-0000-00000000000a', 'apple_device',
      'x', 'x', '{}')$$,
  '22023', null, 'device providers have no OAuth');
insert into public.calendar_oauth_states (state, user_id, provider, code_verifier, return_to)
  values (repeat('s', 40), '00000000-0000-0000-0000-00000000000a', 'google', repeat('v', 43),
    'dottoday://settings/calendars');
select is((select count(*) from public.calendar_oauth_take_state(repeat('s', 40))), 1::bigint,
  'a state is taken once');
select is((select count(*) from public.calendar_oauth_take_state(repeat('s', 40))), 0::bigint,
  'and never twice');

-- A client: reads its own connection, never a token, a state, or another user's row.
set local role authenticated;
set local request.jwt.claims = '{"sub":"00000000-0000-0000-0000-00000000000a","role":"authenticated"}';
select is((select count(*) from public.calendar_accounts), 1::bigint, 'A sees its connection');
select throws_ok(
  $$select public.calendar_token_get(id) from public.calendar_accounts$$,
  '42501', null, 'A cannot read a token');
select throws_ok(
  $$select public.calendar_account_connect('00000000-0000-0000-0000-00000000000a', 'google',
      'sub-z', 'z', '{}')$$,
  '42501', null, 'A cannot connect an account itself');
select throws_ok(
  $$insert into public.calendar_accounts (id, user_id, provider, label)
    values (gen_random_uuid(), '00000000-0000-0000-0000-00000000000a', 'google', 'mine')$$,
  '42501', null, 'A cannot insert a connection');
select throws_ok(
  $$select * from public.calendar_oauth_states$$, '42501', null, 'A cannot read states');

set local request.jwt.claims = '{"sub":"00000000-0000-0000-0000-00000000000b","role":"authenticated"}';
select is((select count(*) from public.calendar_accounts), 0::bigint, 'B sees none of A''s');

-- Disconnecting removes the token with the row.
set local request.jwt.claims = '{"sub":"00000000-0000-0000-0000-00000000000a","role":"authenticated"}';
delete from public.calendar_accounts;
set local role postgres;
select is((select count(*) from vault.secrets where name like 'calendar_account:%'), 0::bigint,
  'disconnecting deletes the token');

select * from finish();
rollback;
