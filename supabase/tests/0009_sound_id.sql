-- pgTAP: a task's reminder sound (docs/12-sounds.md §3). Run with: supabase test db
begin;
select plan(9);

insert into auth.users (id, email) values
  ('00000000-0000-0000-0000-0000000000a9', 'a9@example.com'),
  ('00000000-0000-0000-0000-0000000000b9', 'b9@example.com');

create function pg_temp.hlc(offset_ms bigint, node text default '00000000000000a9')
returns text language sql as $$
  select lpad(((extract(epoch from now()) * 1000)::bigint + offset_ms)::text, 13, '0')
         || '-0001-' || node;
$$;

select has_column('public', 'series', 'sound_id', 'series.sound_id exists');
select has_column('public', 'occurrences', 'sound_id', 'occurrences.sound_id exists');

-- A profile made after 0009 has no reminderSound: it starts at the Dot tone.
select is((select settings->>'reminderSound' from public.profiles
            where id = '00000000-0000-0000-0000-0000000000a9'),
  null, 'a new profile keeps reminderSound unset');

set local role authenticated;
set local request.jwt.claims = '{"sub":"00000000-0000-0000-0000-0000000000a9","role":"authenticated"}';

select lives_ok(
  format($$select public.sync_push('[{"entity":"occurrences","id":"20000000-0000-0000-0000-0000000009a1","hlc":"%s","fields":{"title":"Stretch","sound_id":"clear.lift"}}]'::jsonb)$$,
         pg_temp.hlc(-60000)),
  'A pushes a task with a sound');
select is((select sound_id from public.occurrences where id = '20000000-0000-0000-0000-0000000009a1'),
  'clear.lift', 'the sound is kept');

select lives_ok(
  format($$select public.sync_push('[{"entity":"occurrences","id":"20000000-0000-0000-0000-0000000009a1","hlc":"%s","fields":{"sound_id":"none"}}]'::jsonb)$$,
         pg_temp.hlc(-50000)),
  '"none" (silent) is accepted');

-- A newer device's catalogue: an id this server never heard of is fine.
select lives_ok(
  format($$select public.sync_push('[{"entity":"occurrences","id":"20000000-0000-0000-0000-0000000009a1","hlc":"%s","fields":{"sound_id":"quiet.from_the_future"}}]'::jsonb)$$,
         pg_temp.hlc(-40000)),
  'an unknown but well-formed id is accepted');

select throws_ok(
  $$insert into public.occurrences (id, user_id, title, tz_id, duration_min, sound_id) values
    ('20000000-0000-0000-0000-0000000009a2', '00000000-0000-0000-0000-0000000000a9',
     'x', 'UTC', 30, 'Free text!')$$,
  '23514', null, 'a malformed sound id is refused');

-- B can't see A's sounds.
set local request.jwt.claims = '{"sub":"00000000-0000-0000-0000-0000000000b9","role":"authenticated"}';
select is((select count(*) from public.occurrences where sound_id is not null), 0::bigint,
  'B sees none of A''s tasks');

select * from finish();
rollback;
