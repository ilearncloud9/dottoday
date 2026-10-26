-- 0008 (docs/09 M13.2, ADR-0012, docs/13 §5): one additive column.
-- When a step was ticked done, so step lengths are learned from real ticks
-- (never inferred, B1). Set with done = true, cleared with done = false, in
-- the same change. No CHECK tying it to `done`: sync merges field by field,
-- so an older client that only writes `done` must never have its push
-- refused; learning reads `done and done_at is not null`.
-- The existing RLS policies on subtasks cover it; sync_push resolves column
-- types dynamically (0002), so no function change.

alter table public.subtasks
  add column done_at timestamptz;
