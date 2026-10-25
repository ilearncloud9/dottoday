-- 0006 (docs/09 M10.7, 11-standout-roadmap B3 Unstick): one additive column.
-- How many times a task was moved (drag, Running late, Rebalance — never an
-- edit), so a task with no steps moved three times can ask for its very
-- first step. Counted on the occurrence (a repeat's instances each count
-- their own moves). The existing RLS policies on occurrences cover it;
-- sync_push resolves column types dynamically (0002), so no function change.

alter table public.occurrences
  add column move_count int not null default 0 check (move_count between 0 and 1000);
