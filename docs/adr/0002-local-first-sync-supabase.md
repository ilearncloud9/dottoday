# ADR-0002: Local-first with Supabase, per-field LWW over HLC

**Status**: accepted · **Date**: 2026-10-20

## Context
Sync loss and slowness are a top complaint (R-08). Users must be able to work offline for days and merge without surprises. Full CRDT libraries add weight; our data is row-oriented with few concurrent editors (one person, several devices).

## Decision
Encrypted local SQLite is the source of truth. Changes are logged per field with a hybrid logical clock and pushed via a `sync_push` RPC that applies per-field last-writer-wins. Deletes are tombstones with 30-day trash. Realtime pushes server changes; periodic pull is the safety net. Same-field edits within 60 s are surfaced as conflicts.

## Alternatives
Firestore (weaker relational model, lock-in), PowerSync/ElectricSQL (extra service to run; revisit if conflict volume is high), full CRDT (overkill for single-user data).

## Consequences
+ Simple mental model, testable, no data loss on server errors.
− Occasional conflict prompts; subtasks reorder uses fractional sort_order to avoid conflicts.
