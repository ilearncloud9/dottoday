-- 0009 (docs/12-sounds.md §3): a task's reminder sound, and "system" for
-- every profile whose reminder sound is null.
--
-- sound_id is null (inherit), 'none' (silent) or a sound id. The CHECK
-- pins only the shape: an id this server has never heard of must still be
-- accepted, because the catalogue ships in the app and a newer device may
-- know more sounds. Mirrors `soundIdCheck` in app/lib/data/db/tables/
-- columns.dart. The existing RLS policies on series and occurrences cover
-- the new columns; sync_push resolves column types dynamically (0002), so
-- no function change.

alter table public.series
  add column sound_id text
    check (sound_id is null or sound_id ~ '^[a-z0-9._]{1,64}$');

alter table public.occurrences
  add column sound_id text
    check (sound_id is null or sound_id ~ '^[a-z0-9._]{1,64}$');

-- Until now a null reminderSound meant the OS sound; from here null means
-- the Dot tone. Write "system" once so no existing user's reminders change
-- (the app's v8 migration does the same to the device copy). New profiles
-- keep the column default, without the key, so they start at Dot.
update public.profiles
   set settings = jsonb_set(settings, '{reminderSound}', '"system"')
 where settings->>'reminderSound' is null;
