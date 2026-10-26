# ADR-0012 · A step records when it was ticked (`subtasks.done_at`)

Status: Accepted · Date: 2026-10-26 · Task: M13.2 · Amends docs/05 `subtasks`, docs/11 §B1

## Context
11 §B1 promises learned step lengths ("my usual breakdown" with real timings), and
`13-learning-reveal.md` §5 sets their threshold. The M13 audit found nothing to learn from: a
subtask has `done` but no time, and Focus times the current step from the previous step's
`updatedAt`. Any edit (a rename, a reorder, a sync merge) moves that value, so it is not a tick
time, and B1's rule is that actual times are recorded, never inferred.

## Decision
- `subtasks` gains `done_at`: nullable, a ms epoch on the client (Drift schema 7) and `timestamptz`
  on the server (migration `0008_subtask_done_at.sql`). It is additive. **No CHECK tying it to
  `done`** (amended in M13.2): sync merges field by field, so an older client that unticks by
  writing only `done` would have its push refused and its sync stalled; learning reads
  `done and done_at is not null` instead. The pair is held in code: every write goes through
  `tick(step, done:, nowUtc:)` (a domain test proves `done_at` is non-null iff `done` after any tick
  or untick), and every read through `tickedAt(step)`, where **`done` wins**: a `done_at` left on
  an unticked step (an older client's untick) is ignored, and a done step without one (ticked
  before 0008) is done with no time. Rejected: reading a stray `done_at` as done, which would
  re-tick a step the user unticked. The existing RLS policies on `subtasks` cover
  it, and `sync_push` resolves column types dynamically (0002), so no function changes.
- It is set to now when a step is ticked done and cleared when it is unticked, wherever that happens
  (Focus, task sheet, editor). It is synced, exported and restored like `duration_min`. There is no
  backfill: steps ticked before 0008 keep `null` and never count.
- Focus stops reading `Subtask.updatedAt`. The current step starts at the latest `done_at` before it,
  else the task's `actual_start_utc`, else its planned start.
- Learned step lengths are derived on read from these columns (`LearningIndex.forStep`) and are
  never stored or uploaded. Resets and reveal state for learning live in `local_meta` (local only),
  per `13-learning-reveal.md` §8.

## Alternatives
- **A local-only log of Focus ticks in `local_meta`.** It needs no migration, but a step ticked on
  the Mac would teach nothing to the phone, and the Focus stand-in would stay. Rejected: learning
  reads synced occurrences everywhere else (C3, C4), and steps should behave the same.
- **Keep `updatedAt` as the tick time.** Rejected. It moves on any edit or merge, which breaks B1's
  "never inferred" rule, and it makes Focus timers jump after a rename.
- **A `subtask_runs` table, one row per tick.** It would keep every tick, including re-ticks.
  Rejected: it adds a second synced entity and policy, and a step is ticked once per occurrence
  (R-09), so a single column holds the same information.

## Consequences
- One more synced column. The export bundle stays `ExportBundle.version` 1: `done_at` is an
  optional field of `Subtask.toJson`, so a bundle from before 0008 imports with `null`.
- Clock skew between devices can shift a step span. Spans outside 1–1440 min are dropped, as for
  task runs.
- Owner gate: the hosted `supabase db push` of 0008 is a must-ask (CLAUDE.md §10).
