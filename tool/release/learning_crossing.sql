-- Release gate for learning features (docs/13 §10): how many active users
-- have crossed each feature's threshold. Announcements (release notes,
-- store text, posts) for a data feature wait until its share is >= 50 %.
-- The in-app reveal does not depend on this.
--
-- Output: ONE row of counts. No user ids, no titles, no per-user rows ever
-- leave the query; titles are only hashed inside it to group runs.
-- Read-only (a single SELECT). Running it touches the hosted project, so it
-- is the owner's call each time (CLAUDE.md §10). Run from the SQL editor or:
--   supabase db query --linked --file tool/release/learning_crossing.sql
--
-- Thresholds mirror LearningThresholds.standard (app/lib/domain/scheduling/
-- learning_thresholds.dart); keep them in step. Approximations, all on the
-- low side: the 90-day window ignores a device's remembered reveal, and a
-- step counts a tick with a time (not the span the app measures).

with params as (
  select
    now() - interval '30 days' as active_since,   -- "active" (docs/13 §10)
    now() - interval '90 days' as history_since,  -- historyDays
    10 as reality_min_runs,                        -- realityMinRuns
    4  as task_min_samples,                        -- taskMinSamples
    3  as step_min_samples,                        -- stepMinSamples
    20 as energy_min_completions                   -- energyMinCompletions
),
runs as (  -- finished tasks with a real start and end, 1-1440 min (B1)
  select o.user_id, o.id, o.energy,
         md5(lower(regexp_replace(btrim(o.title), '\s+', ' ', 'g'))) as title_key
  from public.occurrences o, params p
  where o.deleted_at is null
    and o.status = 'done'
    and o.actual_start_utc >= p.history_since
    and o.actual_end_utc > o.actual_start_utc
    and o.actual_end_utc - o.actual_start_utc between interval '1 minute' and interval '1440 minutes'
),
active as (
  select distinct o.user_id
  from public.occurrences o, params p
  where o.deleted_at is null and o.actual_start_utc >= p.active_since
),
reality as (
  select r.user_id from runs r, params p
  group by r.user_id, p.reality_min_runs
  having count(*) >= p.reality_min_runs
),
lengths as (
  select distinct r.user_id from runs r, params p
  group by r.user_id, r.title_key, p.task_min_samples
  having count(*) >= p.task_min_samples
),
steps as (
  select distinct s.user_id
  from public.subtasks s
  join runs r on r.id = s.occurrence_id, params p
  where s.deleted_at is null and s.done and s.done_at is not null
  group by s.user_id, r.title_key,
           md5(lower(regexp_replace(btrim(s.title), '\s+', ' ', 'g'))),
           p.step_min_samples
  having count(*) >= p.step_min_samples
),
energy as (
  select r.user_id from runs r, params p
  where r.energy = 3  -- Energy.high
  group by r.user_id, p.energy_min_completions
  having count(*) >= p.energy_min_completions
)
select
  (select count(*) from active) as active_users,
  (select count(*) from active a join reality  x using (user_id)) as reality_thread,
  (select count(*) from active a join lengths  x using (user_id)) as task_lengths,
  (select count(*) from active a join steps    x using (user_id)) as step_lengths,
  (select count(*) from active a join energy   x using (user_id)) as energy_suggestions;
