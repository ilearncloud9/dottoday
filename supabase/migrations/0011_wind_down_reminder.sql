-- 0011 (docs/09 M17.5, owner 2026-11-01: "Wind Down everywhere"): the Wind
-- Down reminder's settings key is windDownReminder, renamed from
-- bedtimeReminder. The value moves; nothing is dropped or retyped, and no
-- table or policy changes (the app's schema 11 does the same to its copy).
update public.profiles
   set settings = (settings - 'bedtimeReminder')
                  || jsonb_build_object('windDownReminder', settings->'bedtimeReminder')
 where settings ? 'bedtimeReminder';
