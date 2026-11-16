-- pgTAP: the account's device list for "Alarm sounds on" (0016, ED-084).
-- Run with: supabase test db
begin;
select plan(15);

select has_table('public', 'devices', 'devices exists');
select is((select relrowsecurity from pg_class where oid = 'public.devices'::regclass), true,
  'RLS is on for devices');

insert into auth.users (id, email) values
  ('00000000-0000-0000-0000-0000000000a6', 'a16@example.com'),
  ('00000000-0000-0000-0000-0000000000b6', 'b16@example.com');

set local role authenticated;
set local request.jwt.claims = '{"sub":"00000000-0000-0000-0000-0000000000a6","role":"authenticated"}';

select lives_ok(
  $$insert into public.devices (id, platform, form, can_ring, alarm_on) values
    ('60000000-0000-0000-0000-0000000016a1', 'ios', 'phone', true, true),
    ('60000000-0000-0000-0000-0000000016a2', 'macos', 'desktop', false, false)$$,
  'A registers a phone and a Mac');
select is((select user_id from public.devices where id = '60000000-0000-0000-0000-0000000016a1'),
  '00000000-0000-0000-0000-0000000000a6'::uuid, 'user_id defaults to the signed-in account');
select lives_ok(
  $$insert into public.devices (id, platform, form) values
    ('60000000-0000-0000-0000-0000000016a1', 'ios', 'phone')
    on conflict (id) do update set armed_wake_utc = '2026-11-16 05:30Z', last_seen_utc = now()$$,
  'A upserts its own row');
select is((select armed_wake_utc from public.devices where id = '60000000-0000-0000-0000-0000000016a1'),
  '2026-11-16 05:30Z'::timestamptz, 'the armed Wake Up is stored');
select throws_ok(
  $$update public.devices set can_ring = true where id = '60000000-0000-0000-0000-0000000016a2'$$,
  '23514', null, 'a Mac never rings');
select throws_ok(
  $$insert into public.devices (id, platform, form) values
    ('60000000-0000-0000-0000-0000000016a3', 'web', 'phone')$$,
  '23514', null, 'web is a desktop');
select throws_ok(
  $$insert into public.devices (id, platform, form) values
    ('60000000-0000-0000-0000-0000000016a4', 'watchos', 'phone')$$,
  '23514', null, 'an unknown platform is refused');
select throws_ok(
  $$insert into public.devices (id, user_id, platform, form) values
    ('60000000-0000-0000-0000-0000000016a5', '00000000-0000-0000-0000-0000000000b6', 'android', 'phone')$$,
  '42501', null, 'A cannot add a device to B');

-- B can neither see, change nor take over A's devices.
set local request.jwt.claims = '{"sub":"00000000-0000-0000-0000-0000000000b6","role":"authenticated"}';
select is((select count(*) from public.devices), 0::bigint, 'B sees none of A''s devices');
update public.devices set alarm_on = false where id = '60000000-0000-0000-0000-0000000016a1';
select throws_ok(
  $$insert into public.devices (id, platform, form) values
    ('60000000-0000-0000-0000-0000000016a1', 'android', 'phone')$$,
  '23505', null, 'B cannot claim A''s device id');

set local request.jwt.claims = '{"sub":"00000000-0000-0000-0000-0000000000a6","role":"authenticated"}';
select is((select alarm_on from public.devices where id = '60000000-0000-0000-0000-0000000016a1'),
  true, 'B''s update reached nothing');

-- The 50-device cap (A has 2 live; a forgotten one does not count).
update public.devices set deleted_at = now() where id = '60000000-0000-0000-0000-0000000016a2';
insert into public.devices (id, platform, form)
  select ('60000000-0000-0000-0000-' || lpad(n::text, 12, '0'))::uuid, 'android', 'phone'
    from generate_series(1, 49) n;
select throws_ok(
  $$insert into public.devices (id, platform, form) values
    ('60000000-0000-0000-0000-0000000016ff', 'android', 'tablet')$$,
  '54000', null, 'at most 50 live devices per account');

reset role;
select is((select count(*) from public.devices where deleted_at is null), 50::bigint,
  'A has exactly 50 live devices');

select * from finish();
rollback;
