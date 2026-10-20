# ADR-0002: Local-first with Supabase, per-field LWW over HLC

**Status**: accepted · **Date**: 2026-10-20

## Context
Sync loss and slowness are a top complaint (R-08). Users must be able to work offline for days and merge without surprises. Full CRDT libraries add weight; our data is row-oriented with few concurrent editors (one person, several devices).

## Decision
Encrypted local SQLite is the source of truth. Changes are logged per field with a hybrid logical clock and pushed via a `sync_push` RPC that applies per-field last-writer-wins. Deletes are tombstones with 30-day trash. Realtime pushes server changes; periodic pull is the safety net. Same-field edits within 60 s are surfaced as conflicts.

### HLC format (amended 2026-10-20, M0.9)
An HLC is the fixed-width string `<ms>-<counter>-<node>`:
- `ms`: wall-clock milliseconds since the Unix epoch, exactly 13 decimal digits (zero-padded);
- `counter`: logical counter, exactly 4 decimal digits (`0000`–`9999`);
- `node`: device id, exactly 16 lowercase hex characters (`[0-9a-f]{16}`), stable per install.

Regex: `^[0-9]{13}-[0-9]{4}-[0-9a-f]{16}$`. Because every component is fixed-width with a fixed
charset, **HLCs compare lexicographically** (plain string `<`/`>`, in Dart and in SQL with `C`
collation) in the same order as `(ms, counter, node)`; the node id is the deterministic tie-break.
`sync_push` rejects malformed HLCs and any HLC whose `ms` is more than 5 minutes ahead of server
time (docs/06 §1 "Sync tampering").

## Alternatives
Firestore (weaker relational model, lock-in), PowerSync/ElectricSQL (extra service to run; revisit if conflict volume is high), full CRDT (overkill for single-user data).

## Consequences
+ Simple mental model, testable, no data loss on server errors.
− Occasional conflict prompts; subtasks reorder uses fractional sort_order to avoid conflicts.
