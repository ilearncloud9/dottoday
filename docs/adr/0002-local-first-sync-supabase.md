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

### Client clock rules (amended 2026-10-21, M1.7)
`domain/sync/hlc.dart`: `now()` for local writes, `receive()` for every pulled HLC (standard HLC
merge). If the counter would pass `9999` within one millisecond, the clock borrows the next
millisecond (keeps the fixed width; at most 1 ms drift). A remote HLC more than 5 min ahead of the
device clock is still compared for LWW but does not advance the local clock, mirroring the server's
5-min bound. `domain/sync/conflict_resolver.dart`: same field, different values, HLC `ms` less than
60 s apart → `Conflict` (server value applied, conflict row recorded); otherwise higher HLC wins; equal
values never conflict.

### Engine rules (amended 2026-10-23, M6.2)
- **Pull, then push.** A run pulls every entity since its cursor (rows with `updated_at` ≥ cursor,
  oldest first, pages of 500), merges, then pushes the outbox. Pushing first would let `sync_push`'s
  last-writer-wins overwrite a same-field edit before it could be seen as a conflict.
- **Merge per field.** A field with no pending local write takes the server value. A pending one is
  compared with the server's field HLC (`field_versions`): if that is the version the device last
  pulled (local `field_seen`), the edit was made on top of it and simply goes up; otherwise the
  resolver decides. One device's own edits never conflict (same HLC node: later wins), because a
  device re-pulls its own last rows.
- **Repeats** materialise with deterministic ids (`instanceId(series, originalStart)`), so two devices
  extending one repeat write one row instead of colliding on `(series_id, original_start_utc)`.
- **One clock**: the write path and the engine share the device HLC; every pulled HLC is received.
- **Account adoption**: on sign-in the device profile is re-keyed to the account id (FKs cascade),
  outbox profile rows follow, cursors reset; the whole local history then goes up.
- **First sync** for an account: local wins (re-stamped past a newer server clock); the device
  profile's first-launch defaults yield to an existing account profile (M6.4, 04 §4).
- Pulled rows are written without outbox rows; device-only columns (`calendar_link_id` until M7) keep
  their local value; instants cross as ISO on the server and epoch ms locally.

## Alternatives
Firestore (weaker relational model, lock-in), PowerSync/ElectricSQL (extra service to run; revisit if conflict volume is high), full CRDT (overkill for single-user data).

## Consequences
+ Simple mental model, testable, no data loss on server errors.
− Occasional conflict prompts; subtasks reorder uses fractional sort_order to avoid conflicts.
