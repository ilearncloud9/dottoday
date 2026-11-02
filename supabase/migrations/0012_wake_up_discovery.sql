-- 0012 (docs/09 M17.6, docs/15 §11): Wake Up's discovery hints join minimal
-- mode's reveal hints and share their budget (owner: one a day, twice
-- ever). The hint_id CHECK widens to name them; nothing is dropped or
-- retyped, existing rows are untouched, RLS and its policy are unchanged
-- (the app's schema 15 rebuilds its copy with the same list).
alter table public.reveal_hints drop constraint reveal_hints_hint_id_check;
alter table public.reveal_hints add constraint reveal_hints_hint_id_check
  check (hint_id in
    ('unstick','routines','breakDown','nextUpWidget','weekReview','learnedDefaults',
     'wakeUpPromise','wakeUpStartDay','wakeUpShift','wakeUpCheckPing','missionOffer'));
