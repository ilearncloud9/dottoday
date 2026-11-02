-- 0013 (docs/15 §11): the alarm-tier soft reveal ("Your phone can now ring
-- Dottoday's wake-up like an alarm") joins the reveal hints and their
-- budget. The hint_id CHECK widens to name it; nothing is dropped or
-- retyped, rows and RLS are unchanged (the app's schema 16 does the same).
alter table public.reveal_hints drop constraint reveal_hints_hint_id_check;
alter table public.reveal_hints add constraint reveal_hints_hint_id_check
  check (hint_id in
    ('unstick','routines','breakDown','nextUpWidget','weekReview','learnedDefaults',
     'wakeUpPromise','wakeUpStartDay','wakeUpShift','wakeUpCheckPing','missionOffer',
     'wakeUpTierGained'));
