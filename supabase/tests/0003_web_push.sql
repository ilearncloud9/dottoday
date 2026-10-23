-- pgTAP: web push tables (docs/09 M5.3b). Run with: supabase test db
begin;
select plan(9);

insert into auth.users (id, email) values
  ('00000000-0000-0000-0000-00000000000a', 'a@example.com'),
  ('00000000-0000-0000-0000-00000000000b', 'b@example.com');

set local role authenticated;
set local request.jwt.claims = '{"sub":"00000000-0000-0000-0000-00000000000a","role":"authenticated"}';

insert into public.push_subscriptions (id, endpoint)
  values ('20000000-0000-0000-0000-000000000001', 'https://push.example.com/a');
select is((select user_id from public.push_subscriptions), '00000000-0000-0000-0000-00000000000a'::uuid,
  'user_id defaults to the caller');

select throws_ok(
  $$insert into public.push_subscriptions (endpoint) values ('http://insecure.example.com/x')$$,
  '23514', null, 'endpoints must be https');

insert into public.scheduled_pushes (subscription_id, notification_id, fire_at, plan, ciphertext)
  values ('20000000-0000-0000-0000-000000000001', 7, now() + interval '1 hour', '{"v":1}', '\x01'::bytea);
select is((select count(*) from public.scheduled_pushes), 1::bigint, 'A schedules on own subscription');

select throws_ok(
  $$insert into public.scheduled_pushes (subscription_id, notification_id, fire_at, plan, ciphertext)
    values ('20000000-0000-0000-0000-000000000001', 8, now(), '{"v":1}', ''::bytea)$$,
  '23514', null, 'empty ciphertext is refused');

-- B: sees nothing, can't use A's subscription, can't spoof user_id.
set local request.jwt.claims = '{"sub":"00000000-0000-0000-0000-00000000000b","role":"authenticated"}';
select is((select count(*) from public.push_subscriptions), 0::bigint, 'B sees no subscriptions of A');
select is((select count(*) from public.scheduled_pushes), 0::bigint, 'B sees no pushes of A');
select throws_ok(
  $$insert into public.scheduled_pushes (subscription_id, notification_id, fire_at, plan, ciphertext)
    values ('20000000-0000-0000-0000-000000000001', 9, now(), '{"v":1}', '\x01'::bytea)$$,
  '42501', null, 'B cannot schedule on A''s subscription');
select throws_ok(
  $$insert into public.push_subscriptions (user_id, endpoint)
    values ('00000000-0000-0000-0000-00000000000a', 'https://push.example.com/spoof')$$,
  '42501', null, 'B cannot create a subscription as A');

-- The per-subscription cap.
set local request.jwt.claims = '{"sub":"00000000-0000-0000-0000-00000000000a","role":"authenticated"}';
insert into public.scheduled_pushes (subscription_id, notification_id, fire_at, plan, ciphertext)
  select '20000000-0000-0000-0000-000000000001', g, now() + interval '1 day', '{"v":1}', '\x01'::bytea
  from generate_series(100, 598) g;
select throws_ok(
  $$insert into public.scheduled_pushes (subscription_id, notification_id, fire_at, plan, ciphertext)
    values ('20000000-0000-0000-0000-000000000001', 999, now(), '{"v":1}', '\x01'::bytea)$$,
  '54000', null, 'at most 500 pending per subscription');

select * from finish();
rollback;
