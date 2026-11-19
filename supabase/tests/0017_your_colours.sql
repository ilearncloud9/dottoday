-- pgTAP: custom colours (ED-219, ED-220; M19.4 part 4c-1). Run with: supabase test db
begin;
select plan(13);

insert into auth.users (id, email) values
  ('00000000-0000-0000-0000-0000000017a0', 'a17@example.com'),
  ('00000000-0000-0000-0000-0000000017b0', 'b17@example.com');

create function pg_temp.hlc(offset_ms bigint, node text default '000000000000017a')
returns text language sql as $$
  select lpad(((extract(epoch from now()) * 1000)::bigint + offset_ms)::text, 13, '0')
         || '-0001-' || node;
$$;

select has_column('public', 'profiles', 'your_colours', 'profiles.your_colours exists');
select has_column('public', 'profiles', 'accent_hex', 'profiles.accent_hex exists');
select is((select your_colours from public.profiles
            where id = '00000000-0000-0000-0000-0000000017a0'),
  '[]'::jsonb, 'a new profile has no colours of its own');

set local role authenticated;
set local request.jwt.claims = '{"sub":"00000000-0000-0000-0000-0000000017a0","role":"authenticated"}';

select lives_ok(
  format($$select public.sync_push('[{"owner":"00000000-0000-0000-0000-0000000017a0","entity":"profiles","id":"00000000-0000-0000-0000-0000000017a0","hlc":"%s","fields":{"your_colours":["#8C6A4F","#1a2b3c"],"accent_hex":"#9E4F8F"}}]'::jsonb)$$,
         pg_temp.hlc(-60000)),
  'A pushes their colours and a custom accent');
select is((select your_colours from public.profiles where id = '00000000-0000-0000-0000-0000000017a0'),
  '["#8C6A4F","#1a2b3c"]'::jsonb, 'the colours are kept in order');

select throws_ok(
  $$update public.profiles set your_colours = '["teal"]'::jsonb
    where id = '00000000-0000-0000-0000-0000000017a0'$$,
  '23514', null, 'a name is not a custom colour');
select throws_ok(
  $$update public.profiles set your_colours =
      (select jsonb_agg('#000000'::text) from generate_series(1, 25))
    where id = '00000000-0000-0000-0000-0000000017a0'$$,
  '23514', null, 'at most 24 colours');
select throws_ok(
  $$update public.profiles set accent_hex = 'gold'
    where id = '00000000-0000-0000-0000-0000000017a0'$$,
  '23514', null, 'a custom accent is a #RRGGBB');

select lives_ok(
  format($$select public.sync_push('[{"owner":"00000000-0000-0000-0000-0000000017a0","entity":"occurrences","id":"20000000-0000-0000-0000-0000000017a1","hlc":"%s","fields":{"title":"Paint","color_key":"#8C6A4F"}}]'::jsonb)$$,
         pg_temp.hlc(-50000)),
  'a task can carry a custom colour');
select lives_ok(
  format($$select public.sync_push('[{"owner":"00000000-0000-0000-0000-0000000017a0","entity":"occurrences","id":"20000000-0000-0000-0000-0000000017a1","hlc":"%s","fields":{"color_key":"chartreuse"}}]'::jsonb)$$,
         pg_temp.hlc(-40000)),
  'a newer palette''s name is accepted');
select throws_ok(
  $$update public.occurrences set color_key = 'Neon!'
    where id = '20000000-0000-0000-0000-0000000017a1'$$,
  '23514', null, 'a malformed colour key is refused');

-- B can't see or change A's colours.
set local request.jwt.claims = '{"sub":"00000000-0000-0000-0000-0000000017b0","role":"authenticated"}';
select is((select count(*) from public.profiles
            where id = '00000000-0000-0000-0000-0000000017a0'), 0::bigint,
  'B cannot read A''s profile');
update public.profiles set your_colours = '[]'::jsonb
  where id = '00000000-0000-0000-0000-0000000017a0';
reset role;
select is((select jsonb_array_length(your_colours) from public.profiles
            where id = '00000000-0000-0000-0000-0000000017a0'), 2,
  'B''s update reached no row');

select * from finish();
rollback;
