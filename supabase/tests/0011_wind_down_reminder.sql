-- pgTAP: the Wind Down reminder's settings key (0011). Run with: supabase test db
begin;
select plan(3);

insert into auth.users (id, email) values
  ('00000000-0000-0000-0000-0000000000a1', 'a11@example.com');

-- A profile written by an older build still carries the old key: the same
-- statement as 0011 moves its value, false included.
update public.profiles
   set settings = settings || '{"bedtimeReminder": false}'::jsonb
 where id = '00000000-0000-0000-0000-0000000000a1';
update public.profiles
   set settings = (settings - 'bedtimeReminder')
                  || jsonb_build_object('windDownReminder', settings->'bedtimeReminder')
 where settings ? 'bedtimeReminder';

select is((select settings->'windDownReminder' from public.profiles
            where id = '00000000-0000-0000-0000-0000000000a1'),
  'false'::jsonb, 'the value moves to windDownReminder');
select ok(not exists (select 1 from public.profiles where settings ? 'bedtimeReminder'),
  'no profile keeps bedtimeReminder');
select ok((select public.validate_settings(settings) from public.profiles
            where id = '00000000-0000-0000-0000-0000000000a1'),
  'the moved settings stay valid');

select * from finish();
rollback;
