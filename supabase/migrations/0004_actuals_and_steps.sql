-- 0004 (docs/09 M6.5.1, 11-standout-roadmap B1/B2): additive columns only.
-- Existing RLS policies on occurrences/series/subtasks cover the new
-- columns; sync_push resolves column types dynamically, so no function
-- change is needed (0002).

-- B1: when the user really started / finished (set by an explicit action,
-- never inferred).
alter table public.occurrences
  add column actual_start_utc timestamptz,
  add column actual_end_utc timestamptz,
  add column duration_from_steps boolean not null default false;

-- B2: a task's length may follow the sum of its steps.
alter table public.series
  add column duration_from_steps boolean not null default false;

-- B2: optional step length; shorter than a task (1 min) but at most a day.
alter table public.subtasks
  add column duration_min int check (duration_min is null or duration_min between 1 and 1440);
