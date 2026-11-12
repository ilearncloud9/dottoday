# CR-160 Stage B · Multipart export and staged import (specification)

Status: **specification**, built in stages. Built so far (uncommitted unless noted): B0 (§10, the
Settings export size refusal); B1 (format, splitter, part checks, file kinds; committed `017677d`);
B2 (staging tables, schema 21, inactive; §6 results in "B2 verification" below; committed
`7a99f0e`); B3 (the staged pipeline, reachable from tests only; "B3 verification" below). Decision record: ADR-0019. Owner of the approval: the
product owner, per stage gate in §9. Release status: CR-160 stays CRITICAL · OPEN · RELEASE BLOCKER.

## 1. Problem
An account whose JSON v1 export is over 25 MB (`maxImportBytes`) has no restorable copy today:
- D1's export reports "too large" (Stage C) and can only be waived.
- Settings › Export used to hand over a file its own import refuses (fixed in B0, §10).
- Automatic backups (daily, pre-import, pre-restore) are written at any size, but restoring one
  decodes it with the same 25 MB limit, so an oversized backup can never be restored (§8).
- Every import holds the file, its decoded objects, the current account and one `WriteBatch` in
  memory at once, which does not scale past the current limit.

## 2. File types and identification
Three file types, all UTF-8 JSON with the `.json` extension (so every platform picker's filter
keeps working). Files are identified by **content, never by name**.

| Type | Identifying keys | Notes |
|---|---|---|
| Legacy single file | `version: 1` | Today's format, unchanged. Stage A's optional `calendarSeries` key is part of it. Written whenever the whole export fits the part target (§4). |
| Manifest | `format: "dottoday-multipart"`, `formatVersion: 1`, **no `version` key** | Describes one multipart export. |
| Part | `format: "dottoday-part"`, `formatVersion: 1`, **no `version` key** | One slice of the rows. |

Manifest fields: `exportId` (UUID v7, new per export), `exportedAt` (UTC ms), `appVersion`,
`schemaVersion`, `purpose` (`account-deletion` · `export` · `backup`), `totals` (rows per table:
`series`, `occurrences`, `subtasks`, `routines`, `calendarSeries`), and `parts[]`: `{index (1-based),
name, bytes, sha256 (lowercase hex of the exact file bytes), counts}`.

Part fields: `exportId`, `index`, `total`, then the v1 row arrays in v1's storage form (`series`,
`occurrences`, `subtasks`, `routines`, `calendarSeries`); `profile` is in part 1 only.

Names (informative only): `dottoday-backup-<yyyy-MM-dd>-<last 8 of exportId>-manifest.json` and
`…-part-03-of-07.json`, dated in the profile's zone, never content. The last 8 characters are the
id's random tail (its first 8 are its time, shared by exports a minute apart: B7 gate G3).

### Compatibility and refusal
| File given to | Older importer (shipped builds) | New importer |
|---|---|---|
| Legacy single file ≤ 25 MB | imports | imports, unchanged |
| Legacy single file with `calendarSeries` | imports, skips the key | imports with templates (pending) |
| Manifest alone | refused before any write: no `version: 1` ("not a backup") | asks for all of its parts |
| One part, or parts without the manifest | refused before any write: no `version: 1` | recognised; says the manifest and the missing parts are needed |
| Any file over 25 MB | refused before reading (`PickTooLarge`) | refused before reading |

Old builds' `decodeExportJson` returns `invalidFormat` when `json['version'] != 1` before reading any
row, so the absence of `version` is the refusal guarantee; a test pins it (B1).

## 3. Integrity
- Each part's SHA-256 over its exact bytes is in the manifest and is checked while the part is
  streamed in. A mismatch refuses the whole import.
- `exportId` in every part must equal the manifest's; `index` must be in `1…total`, unique; a second
  file with the same index is accepted only if its hash is identical (a duplicate download).
- Hashes detect corruption, truncation, mixing parts of two exports and accidental edits. **They do
  not authenticate the source**: anyone can edit a part and recompute its manifest entry. Protection
  against deliberate tampering is unchanged: every row passes the entity validators, references must
  resolve, rows of more than one owner are refused, everything is re-owned to the importing account,
  and the server's RLS applies on sync.

## 4. Splitting (export)
- Rows are written in table order (profile, series, occurrences, subtasks, routines,
  calendarSeries), read in keyset pages inside one read transaction (one consistent cut; D1's count
  check runs in the same transaction).
- **Part target: 10 MB written** (provisional, §7). A new part starts before a row would push the
  current one past the target. **Read cap: 25 MB per file**, unchanged.
- A single row larger than the target fails the export loudly; nothing is ever left out. Today's
  field limits (title 200, notes 10,000 UTF-16 units, 50 steps, 5 alerts, 30 routine items) bound one
  row at about 100 KB even with worst-case JSON escaping, so this is a guard, not an expected path.
- Relationship groups (a series and its instances, an instance and its steps) may span parts: the
  import resolves references across the whole set (§5), never per part.

## 5. Staged import (one pipeline for every import and restore)
Sources: a legacy single file, a multipart set, a stored backup (multipart or legacy, §8).

1. **Begin**: record an import session `(importId, owner, ownerGeneration)` for the shown account
   (`beginPull` semantics). Only one active import per owner.
2. **Stage, one part at a time**: length-check (≤ 25 MB) before reading, stream the bytes through
   SHA-256, decode, validate rows with the existing validators, insert into staging tables keyed by
   `importId`, then drop the decoded part. At most one decoded part is in memory.
3. **Global checks in SQL on staging**: manifest totals; unique ids per table; every
   `series_id`/`occurrence_id` resolves inside the staged set; exactly one profile; one owner.
4. **Pre-import backup** of the current account, through the multipart backup writer (§8). If it
   fails, the import is refused before any live change.
5. **Commit, one transaction** on the app database: `checkPull` (shown account, same generation, not
   sealed, not being removed); stream staged rows in chunks (about 500) through the existing entity
   writers (sync outbox, HLC, validation as today); move live rows absent from the import to Trash in
   SQL (today's "replace"); stash calendar templates as pending (Stage A, now atomic with the rest);
   bump the write revision once. Then delete the staging rows.
6. **After a failure** at any step: staging rows are deleted; nothing live changed.

Re-ownership happens only at commit, to the session's owner. A → B → A between begin and commit
refuses the commit (generation changed). Repeating an import is idempotent (same ids upsert; Trash
rule; template keys replace).

## 6. Staging security requirements (gate for B2; each needs a test)
| Requirement | Design | Verification (B2) |
|---|---|---|
| Ownership and generation fencing | Every staging row carries `import_id` and `owner`; the session row stores `owner_generation`. Each staging write and the commit run `checkPull`. | A → B → A, sealed and removal-pending tests refuse staging writes and commit. |
| Isolation between accounts | Staging is read only by the importer, always filtered by `(import_id, owner)`; owner removal deletes that owner's staging (owned-table list + profile cascade). | Two owners staging at once see only their own; removal test. |
| Encrypted at rest, native | Staging tables live in the SQLCipher main database. SQLite temporary files (large sorts, temp indexes) must also be covered: verify whether SQLCipher encrypts them under the current build; if not, set `PRAGMA temp_store = MEMORY` only if memory acceptance (§7) still holds, else keep large sorts out of staging queries. | Byte scan of the database, WAL and any temp files for a known plaintext marker. |
| Encrypted at rest, web | The web database is opened on `sqlite3mc.wasm` (SQLite3 MultipleCiphers, ADR-0003, `web_cipher.dart`) with the app key; staging tables inherit it. | Same marker scan over the IndexedDB-stored blocks. |
| Never synced, never in normal queries | Staging tables are not in the `change_log` entity CHECK, not in any synced-table list, not read by any repository or DAO; no trigger touches them. | Policy test: only `data/backup/staged_import*` references the staging tables; sync push/pull tests with staged rows present. |
| Startup cleanup | On open, delete staging rows of any session not marked active, and any session older than 24 h. | Kill-and-reopen test. |
| Bounded growth | Manifest totals and part sizes are known before staging; refuse a set whose declared size exceeds the accepted total (§7). Staging is deleted after commit or failure. | Size-cap and cleanup tests; staging bytes ≤ 1.2 × file bytes. |
| Rollback on failure, disk full, termination | Live changes only in the one commit transaction; `SQLITE_FULL` or any exception rolls back; termination rolls back via the journal on next open, then startup cleanup. | Forced `SQLITE_FULL`, exception injection, kill during commit. |

### B2 verification (2026-11-11, local)
| Requirement | Result |
|---|---|
| Ownership and generation fencing | `staged_import_store_test.dart`: another owner, A → B → A, sealed and removal pending refuse staging and beginning |
| Isolation | Two owners stage at once and each reads only its own; a forged (import, owner) pair reads and stages nothing; account removal deletes only that owner's staging |
| Encrypted at rest, native | Database, WAL and shm hold no staged text while open and after close (host `staging_encryption_test.dart`; `integration_test/staging_encryption_test.dart` on device). Temp storage: this SQLCipher build is compiled `TEMP_STORE=2` (in memory), checked per connection; a file scan can't prove it, since SQLite unlinks temp files at once |
| Encrypted at rest, web | The CI web probe stages 2,000 rows carrying the probe secret and forces a sort: 0 plaintext hits in browser storage (Chromium). This sqlite3mc build sets no `TEMP_STORE`, so the web connection now sets `PRAGMA temp_store = MEMORY` (decision 2) |
| Never synced, never in normal queries | Policy test: only the store, the schema and account removal name the tables; the outbox CHECK, search triggers and synced-table list don't. Staging writes no outbox entry and no write revision |
| Startup cleanup | Another run's import, a day-old one and one "in the future" are deleted; a killed-and-reopened file is cleaned by the next run. Main isolate only (cross-runtime policy test); wired in when the pipeline goes live |
| Bounded growth | Over 64 MiB declared refused; a part that would pass the declared size refused whole |
| Rollback | A part stages all or nothing (duplicate id, missing id, over size). Commit rollback, disk full and kill during commit are B3's gate |

### B3 verification (2026-11-11, local)
Built: `data/backup/staged_import.dart` (the importer), `staged_import_sources.dart` (v1 text, multipart
set a part at a time, stored backup read in place with `json_each` pages), `staged_import_checks.dart`
(the whole set, in v1's order: decode every row, drop imported events and their steps, validate the
rest with v1's validators via `domain/export/import_rows.dart`, then one profile, one owner, references
and template keys in SQL), `staged_import_commit.dart` and `staged_import_trash.dart`.

Two design points the build settled:
- **After-write effects never run inside the commit.** Writing each chunk through
  `WriteUseCase.apply` inside the commit transaction scheduled the effects (notification re-sync, day
  snapshot) in that transaction's zone, so they read uncommitted or rolled-back data and collided with
  its end (found by the Finding X rollback test). `DriftWriteUseCase.applyWithoutEffects` is `apply`
  without them (same validation, seal, shown-owner and foreign-row checks, own savepoint); the importer
  schedules the effects once after the commit. Owner-approved (option A).
- **Trash first.** The rows to trash are the owner's live rows before the import (as `restorePlan`
  takes `current`); computing them after writing the set also trashed instances materialised for the
  imported series.
- A stored backup is restored under `guestBackupFence` from the visibility check to the commit, so no
  privacy scrub can rewrite it in between; its safety backup runs inside the fence (B4/B5 wiring).

| Gate | Result |
|---|---|
| Same result as today | `staged_import_test.dart`: a v1 file, a multipart set of it and a stored backup each give exactly today's rows (re-owned, normalised, Trash rule), pending templates and outbox entries; ids materialised at run time compared as one placeholder. A backup not the owner's, or with another's profile inside, refused |
| Rollback | `staged_import_rollback_test.dart`: bad row in a later part, orphan step, two owners, another account's row (Finding X, inside the commit), A → B and A → B → A between staging and commit, seal, removal begun, refused safety backup, failure part-way through the commit, full disk (`max_page_count`): owner's and other owner's data, outbox and revisions unchanged, staging gone |
| Crash | `staged_import_crash_test.dart`: the SQLCipher/WAL files copied inside the commit after 3 chunks reopen with the owner's data as before; the next run's cleanup removes the staging (same-process copy, not a process kill). No effect scheduled inside the commit, one after |
| Mutations | No transaction, no Trash step, no templates, imported events kept, effects inside the commit: each caught |
| Memory and time (host VM, SQLCipher file, WAL; three runs) | 24 MB v1 file: 54–56 MB above idle, 3.5–3.9 s. 59 MB multipart (6 parts): 51–52 MB, 9.3–9.7 s. 30 MB stored backup over the import limit, read in place: about 40 MB, 4.3–5.0 s. All within §7's 150 MB; not device figures, web not measured. On an in-memory database the same runs showed 143–264 MB because its own pages count as process memory |

Not yet: the pipeline is not wired to any caller (B5); its safety backup is the caller's, and today's
verified backup refuses accounts over 25 MB until B4; multipart staging of a stored backup above the
64 MiB provisional total is refused.

### B4 verification (2026-11-11, local)
Built: backup schema 3 (`backup_parts`: backup id and part index as key, SHA-256, bytes, the part's
text; `ON DELETE CASCADE` from `backups`, foreign keys switched on at every open; STRICT, CHECKs on
index, hash length, size and JSON), `domain/export/multipart_planner.dart` (where parts end, shared
with B1's splitter), `data/backup/multipart_backup_writer.dart`, `multipart_backup_store.dart` and
`backup_creation.dart`; retention, the audit and the staged restore read parts.

Owner decisions (B4 plan, recommendations 1–4):
1. **Parts only above 25 MB.** A backup that fits is today's single file; an account whose last
   backup was already large goes straight to parts, without reading itself into memory whole.
   *Amended 2026-11-11 (option A, see "Backup memory" below): an account's backup is always parts;
   this rule now applies to guests only.*
2. **Guest backups stored as parts stay hidden and unscrubbed**, like oversized ones (I1): the privacy
   scrubs can't read a manifest, so they count it as unreadable and leave it, hidden (fail closed).
3. **Verified** means: the manifest decodes, every part is present, its hash, index, total and counts
   match, part 1's profile is the owner's, and the totals equal the rows read.
4. **Retention is unchanged** for existing oversized single-file backups.
5. **Until B5, safety backups are never parts** (2026-11-11). Today's restore, and so Undo, reads one
   file only, so an import or restore for an account too large for one file is refused before any
   change, as before B4. Daily backups of it are stored as parts. B5 lifts the refusal when the
   staged pipeline becomes the restore path.
6. **Stored backups use 5 MB parts** (2026-11-11), not the 10 MB of an exported file
   (`backupPartTargetBytes`): see Memory and time below.

How a write stays all-or-nothing: the account is read twice inside one read transaction (one
consistent cut; the first pass plans where parts end, the second writes them, one part in memory at a
time), and the backup row, its parts and its manifest go in one transaction of the backups file. Then
the stored set is read back a part at a time and checked; one that fails is deleted (its parts with
it) and the backup is refused. Drift resolves a query's transaction from the
innermost zone, so the second pass runs its page reads back in the main database's transaction zone
(otherwise they wait on that transaction: a deadlock, found as a hung test).

| Gate | Result |
|---|---|
| Any backup restores | `multipart_backup_world_test.dart`: an account (the hostile file imported) backed up as parts restores through B3 to exactly what its single-file backup restores to (rows, Trash, templates, outbox); staging gone. A stored single file over the import limit takes the same `json_each` path B3 measured |
| All or nothing | `multipart_backup_test.dart`: a write that fails at part 2 leaves no backup row and no part; parts that don't read back whole are removed and the backup refused (`BackupNotRestorableFailure`) |
| Retention | Eight newer copies with a damaged part: the oldest, only restorable backup is kept. `backup_safety_test.dart`: daily backups too large for one file are verified parts, retention keeps 7 |
| Privacy | A guest's backup stored as parts stays hidden, unlisted, unchanged and unrestorable through promotion and P2; removing the account removes its own parts |
| Today's restore | The in-memory restore refuses a backup stored as parts and changes nothing. `backup_safety_test.dart`: an import or restore whose safety backup would need parts is refused (`BackupNotRestorableFailure`), nothing changed, nothing stored (decision 5) |
| Audit | Parts that verify are restorable, sized by their parts; damaged ones are malformed |
| Mutations | Parts written outside one transaction, no read-back after writing, retention or the audit trusting parts unread, foreign keys off, a restore staging a manifest as one file, no profile-is-the-owner check in the restore or in verification, a safety backup stored as parts: each caught. The two profile checks are caught by parts that are wholly another account's (profile and every row, hashes recomputed); a set with only the profile changed is also refused by B3's one-owner check |
| Memory and time (host VM, SQLCipher files, WAL; three runs each) | 59 MB account written as 5 MB parts (decision 6): 4.6–4.8 s, 61–86 MB above idle, within §7's 100 MB. As 10 MB parts it measured 120–131 MB, over it: peak grows with part size (a part is in memory as rows, a sorted copy, its text and its bytes). Restoring the 5 MB parts: 4.7–4.9 s, 30–56 MB above an idle already raised by the write, so a lower bound. Not device figures; web not measured |

### B5 verification (2026-11-11, local)
Settings import, backup restore and Undo now run through the staged pipeline
(`DriftBackupService.importJson` / `restore` → `StagedImporter`); the in-memory path is removed
(`_replaceFrom`, `domain/backup/restore_plan.dart` and its test). B4's refusal (decision 5 above) is
lifted: a safety backup may be parts, since the restore, and so Undo, reads them. No schema change,
dependency or new string: the pipeline's failures are the ones Settings already words.

Owner decisions (B5 plan):
1. **Stale staging is cleaned at start and resume**, in the backup maintenance the daily check runs
   (main isolate, under `guestBackupFence`): imports of any other app run (`importRunId`, one per
   isolate) or begun over 24 h ago go; a failure is logged and retried.
2. **The import preview stays until B7**: Settings still decodes the picked file (at most 25 MB) for
   the confirmation's date and count; a multipart file is refused there as before.
3. **Web**: the CI web database probe (`tool/web_db_probe.dart`) now stages a v1 file through the
   pipeline's staging and whole-set checks on the encrypted web database.

Found while switching: the pipeline checked other accounts' row ids (Finding X) only inside the
commit, after its safety backup, where the in-memory path refused before it; a refused import left a
needless safety backup (`foreign_ids_restore_test.dart`). The check now runs with the whole-set
checks, before the safety backup (the commit still checks again).

| Gate | Result |
|---|---|
| Legacy single-file regression suite unchanged | Every existing backup, owner, Settings, export and undo test passes without edits. The B3 equivalence tests compared against the in-memory path; just before removing it, its result was recorded (`fixtures/pre_b5_replace_state.txt`, the import of the hostile file and the restore of it as a stored backup, which were identical; deterministic over two runs). The pipeline and the service now match it for a v1 file, a multipart set and a stored backup. Edited: B4's own tests (safety backups as parts now go ahead; the service restores parts) |
| Any backup restores, from Settings | `staged_import_wiring_test.dart`: a stored 27 MB single-file backup restores through the service; `backup_safety_test.dart`: an import for an account too large for one file, then Undo from its parts; `multipart_backup_test.dart`: the service restores parts |
| Stale staging | An earlier run's import is removed by maintenance, this run's kept |
| Mutations | No safety backup, import or restore without its safety backup, no stale cleanup, cleanup ignoring this run, other accounts' rows checked only at commit: each caught |
| Web (built-in browser, Chromium, local) | `PROBE:OK cipher=chacha20 temp_store=2 import=occurrences+profile`. Not run locally: the probe's Playwright storage scan (CI) and a web commit |
| Memory and time (host VM, SQLCipher files, WAL; three runs; `test/perf/backup_service_memory_test.dart`) | Through the service, safety backups included. 24 MB file import: 3.2–3.9 s, 54–59 MB above idle. 60 MB restore from 5 MB parts with its safety backup (as parts): 7.7–9.0 s, 34–44 MB above an idle already raised (lower bound). **Undo of that import: 1.8–2.1 s but 309–312 MB above idle, over §7's 150 MB.** The restore is small (the safety backup of the small account before the import); the peak is its own safety backup of the account now, 24 MB written as one file. The single-file path holds the whole account, its 24 MB JSON text and, to verify it, the text read back and decoded. That path is unchanged since M2.4 and serves every daily and safety backup up to 25 MB; B5 only measured it. Not device figures; web not measured. Fixed after B5 by option A ("Backup memory" below) |

### Backup memory (option A, 2026-11-11, local)
B5 measured an Undo of a 24 MB import at 309–312 MB above idle: the safety backup of a 24 MB account
written as one file (the account, its JSON text and, to verify it, the text read back and decoded).
Measured per form, each in a fresh process (host VM, SQLCipher files): one file costs about ten times
its size (1 MB: 24 MB; 10 MB: 98 MB; 24 MB: 237 MB above idle), parts stay under about 70 MB at any
size (1 MB: 19 MB; 10 MB: 69 MB; 24 MB: 65 MB) and take up to 1.3 times as long.

Owner decision (option A): **an account's backup is always parts**, at any size
(`backup_creation.dart`, `isAccount`). **A guest's backup keeps today's rule** (one JSON v1 file up
to 25 MB, parts above), because the I1 privacy scrubs (P2, P3) clean only one-file backups and would
leave a guest's parts hidden instead (B4 decision 2); a guest's large backup can still peak about
240 MB. Rejected: parts above 5 MB for everyone (guest backups of 5–25 MB would be hidden, not
cleaned); teaching the scrubs to clean parts (an I1 change, its own stage). Existing single-file
backups are unchanged and still restore, prune, audit and scrub as before. An older app version
can't read the new backups (the backup database is schema 3 since B4 already).

| Gate | Result |
|---|---|
| Form | `backup_form_test.dart`: a small account's backup is verified parts (its row holds the manifest) and restores; a guest's within the limit is one JSON v1 file |
| Regression | Full unit suite passes; one edit: `multipart_backup_world_test.dart`'s single-file reference is now inserted as a v1 row (an account's backup is parts) |
| Mutations | Accounts back to one file: caught (the form gate). Guests to parts: caught by six I1 privacy tests (`guest_backup_privacy_test.dart`, `scrub_memory_test.dart`), which is why guests keep one file |
| Memory and time (three runs) | Undo of the 24 MB import through the service: 2.6–2.9 s, **74–80 MB above idle** (was 309–312 MB). 24 MB import: 3.3–4.1 s, 55–60 MB. 60 MB restore from parts with its safety backup: 7.9–8.0 s, 37–43 MB above a raised idle (lower bound). Not device figures; web not measured |

### B6 verification (2026-11-11, local)
Built, reachable from tests only until B7 (owner decision 1 below):
- `data/export/part_stream.dart`: reading an account's rows as parts, shared by backups and exports
  (one way to read, one format). `RowScope.standard` (a backup or Settings export: imported calendar
  events and their steps left out) or `RowScope.accountDeletion` (D1: imported events kept as ordinary
  tasks, every calendar-series template). B4's backup writer now uses it unchanged in behaviour.
- `data/export/multipart_export.dart`: one read transaction, a planning pass (D1's completeness check
  runs inside it), then each 10 MB part prepared; an account that fits one part gets today's single
  file (`FitsOneFile`); a row larger than any part fails it (`ExportTooLargeFailure`).
- `data/export/prepared_file.dart`: **prepared** (§10 state 1). Native writes each file to a temporary
  folder (`.part`, flushed, renamed), reads it back and checks the hash, one part in memory at a time;
  the web keeps the bytes for its downloads. A mismatch fails the export and removes what was prepared.
- `domain/export/export_handoff.dart`: the three states and `checkPossession` (the manifest must be
  exactly the prepared one; every part matched once).
- `data/owners/account_export_set.dart`: D1 with a set. A handoff is `uncertain`, closing the sheet
  `cancelled`, a part not prepared or a handoff error `failed`, a row too large `tooLarge`; `done` only
  after `confirmOwnerSet`. `setShortfall` keeps the deletion waiting after `uncertain` exactly as after
  `cancelled` (another export, a confirmation, or "Delete without a saved copy"). The single-file D1
  rule is unchanged (decision 7).
- The set's file names are shared with B1's splitter (`partFileStem`, `partFileName`,
  `manifestFileName`).

Owner decisions (B6 plan):
1. **Tests only until B7**: Settings keeps its 25 MB refusal and D1 its `tooLarge` until B7 wires
   both with picking, "Check my files" and approved copy, so nobody can export a set they can't yet
   import. No new strings in B6.
2. **Settings switches to multipart automatically above the part target** when B7 wires it
   (decision 6 in §11).
3. **Exporting a stored backup** is not an existing feature and stays out of scope.

| Gate | Result |
|---|---|
| Stage C consent extended to multipart | `account_export_set_test.dart`: a handoff is `uncertain` with every row the device has (imported event kept as a task, its step, the template); closed sheet `cancelled`; handoff error `failed`; row too large `tooLarge`; fits one part → the single-file rule; `done` only by exactly the files; the deletion waits after `uncertain`, `cancelled` and `failed`, never after `done`; the completeness check fails with one row fewer in any table |
| Prepared, possession | `multipart_export_test.dart`: several parts, each prepared, named by the set, read back to its hash, at most the target; the set imports through B3 to exactly the account; fits one part → single file; row too large refused; a file that doesn't read back fails it and removes what was prepared; an incomplete set prepares nothing; native temporary files read back and removed; possession confirmed for exactly the set in any order, refused for a missing, changed or doubled part, another export's manifest or parts |
| Backups unchanged | Every backup test passes after the writer moved onto the part stream |
| Mutations | Completeness not checked (prepare and D1), handoff counted as done, confirmation without the check, `uncertain` letting the deletion through, D1 dropping imported events, native store skipping its read-back, possession ignoring the manifest or a missing part, never a single file: 10 of 10 caught |
| Memory and time (host VM, SQLCipher file, three runs per scope) | 59 MB account as 6 parts prepared as temporary files: Settings scope 2.9–3.0 s at 49–71 MB above idle; D1 scope 2.2–2.3 s at 52–70 MB. Within §7's 100 MB. Idle measured after a 60 MB import in the same process; not device figures; web not measured |

### B7a verification (2026-11-11, local)
Settings › Export › Everything (JSON) over one part is a set, automatically (B6 decision 2); below one
part nothing changes. iPhone and Android hand every prepared file to one share sheet by path; the Mac
copies them into a folder the person picks (`.part`, then renamed); then a sheet says "Exported as N
files" with what that means and "Check my files…". The web lists one Download per file (the browser
may block a burst), each marked "Downloaded" once asked, with the same check. The check
(`data/export/picked_set_check.dart`) reads the picked files one at a time and answers complete, how
many are missing, or that they don't match. The prepared files are removed when the sheet closes, or
at once when the share sheet is closed or fails. New: `FileGateway.pickJsonFiles`,
`deliverPrepared`, `downloadPrepared`; `ExportService.prepareSet`.

Copy: the owner approved the B7 copy (2026-11-11). Eleven strings land in B7a; German, French and
Spanish are drafted here and **pending native-speaker review**, like B0's size refusal. Import (B7b)
and D1 (B7c) add theirs.

| Gate | Result |
|---|---|
| Flow | `export_set_test.dart`: native hands every file over at once (no single file), then the sheet and a complete check; missing and another export's files answered; a closed share sheet shows nothing; the web lists one Download per file, marks each, hands nothing over by share. Accessibility guidelines (targets, labels, contrast) pass on both |
| Check | `picked_set_check_test.dart`: complete in any order; the manifest, some parts or everything missing (counted); another export, this set's parts under another manifest, a changed or unreadable file, a file or manifest twice: wrong |
| Goldens (derived) | `export_set_native_*` (light/dark × compact/medium/expanded × 1×/2×, + 2.0 text, RTL) and `export_set_web_*` (medium, expanded) |
| Regression | Every existing Settings and export test passes; edits: three D1 test fakes forward `prepareSet`, the shared fake gateway and export service gain the new methods |
| Mutations | JSON never a set, the check ignoring missing parts or another manifest, the web handing over like native, a closed share sheet still showing the sheet: 5 of 5 caught (the foreign-manifest case needed its own test, added) |
| Web build | `flutter build web` compiles the new code (the conditional prepared-file store) |
| Not yet | The device and web screenshot sweep runs with B7's gate after B7c; not run on devices |

### B7b verification (2026-11-11, local)
Settings › Export › Import a backup… takes one JSON v1 file (today's import, unchanged) or the files
of a set, picked at once or over several picks (`data/export/picked_import.dart`). Files are read one
at a time; one over the import limit is refused by its size, unread. A set's files must all be one
export's (the first file says which); another backup's file is refused ("This file isn't part of this
backup. Nothing was changed."). While files are missing, "Add the rest of this backup" says "{added}
of {total} files added." with "Add files…". Once every file is in, the set is checked whole (every
hash, index and count); a changed part is refused and leaves the draft, so the right file can be added
in its place. Then today's confirmation, with the set's date and its tasks not in Trash (owner
decision 2), and `BackupService.importSet` runs it through the staged pipeline under the fence after
the verified pre-import backup; Undo as before. One picker for every import (owner decision 1):
`FileGateway.pickBackup` and its result types are gone. Four approved strings; de, fr and es pending
native-speaker review.

| Gate | Result |
|---|---|
| Reader | `picked_import_test.dart`: one v1 file is today's import; a whole set complete, live tasks counted (a task in Trash not), read in order; gathered over picks, a part twice harmless; another backup's file, a v1 file among a set's, two v1 files: foreign; a changed part refused and removed, the right file completes it; over the limit refused unread; not UTF-8 or not a backup refused |
| Flow | `import_set_test.dart`: a whole set goes to today's confirmation (date, 3 tasks) and imports in order, not as a single file; part of a set opens Add the rest, another backup's file is refused there, the rest completes it; closing it imports nothing; another backup's file in the first pick is refused before any question. Accessibility guidelines pass |
| Same result | `staged_import_test.dart`: a set imported through the backup service gives exactly the pre-B5 fixture, after one pre-import backup |
| Goldens (derived) | `import_set_add_rest_*` (light/dark × 3 widths × 1×/2×, + 2.0 text, RTL) |
| Regression | Every existing Settings and export test passes; one named edit: `export_page_test.dart` asserted that the picker was handed the 25 MB limit, now that it opened once (the limit is checked by size before reading, which its too-large test still covers). The import tests' single-file shorthand (`PickedBytes`, `PickTooLarge`, `PickCancelled`) moved into the test fake |
| Mutations | One v1 file among others accepted, any set accepted, no whole check, a changed part kept, size not checked before reading, Trash counted, a set imported without its safety backup, a set imported as a single file: 8 of 8 caught (the Trash count needed a task in Trash in the test set, added) |
| Not yet | Device and web screenshot sweep with B7's gate after B7c |

### B7c verification (2026-11-11, local)
Delete account › "Export my data first" for an account too large for one file is a set; one that
fits keeps the single-file rule unchanged (decision 7). The set goes through the export service
(`prepareSet(forAccountDeletion: true)`, D1's completeness check in the same read) and is handed to
the share sheet or a folder, or on the web to one Download per file; it counts as handed over only
once every file was asked for (owner decision 2), else `cancelled`. Handed over, it is
`OwnerExportOutcome.uncertain` (owner decision 1: one outcome type; B6's separate type is gone), said
as "Your data was handed over as {count} files. We can't confirm you saved all of them. Check your
files, or export again.", with "Check my files…". `AccountActions.checkExport` compares the picked
files with the set D1 kept (`data/owners/deletion_sets.dart`); only exactly its files make the export
`done`, and only in the D1 session and owner session it was made in, and only if no newer export
started meanwhile. While `uncertain` the deletion waits as after `cancelled`; "Delete without a saved
copy" asks "Delete without a confirmed copy? We can't confirm all {count} files were saved…". The set's
files stay until D1 closes or another export starts (owner decision 3). The rule itself is
`exportShortfall` (`account_export_set.dart`). Shared rows with Settings: `DownloadList`,
`CheckFilesRow` (`features/settings/widgets/set_file_rows.dart`). Two approved strings; de, fr and es
pending native-speaker review.

| Gate | Result |
|---|---|
| Stage C consent extended to multipart | `deletion_set_test.dart` (the real D1 actions, parts of 4,000 bytes): handed over is `uncertain` and the deletion waits; a check missing a file changes nothing; exactly the files makes it `done` and the deletion goes; after `uncertain`, "Delete without a saved copy" lets it go; closing D1 removes the files and the set; A → B → A, a later check never lets it go; a check still reading when a new export starts never marks the new one done; a new export removes the set before it and its files; a closed sheet, or the web closing its downloads early, is `cancelled` with no set kept. `account_export_set_test.dart`: every row (imported event as a task, its step, the template), completeness, cancelled/failed keep no set, too large, fits one file → the single-file rule, `exportShortfall` |
| Screen | `delete_account_set_test.dart`: the uncertain status and a complete check → "Exported. You can delete your account now."; a check missing files is said and stays uncertain; deleting while uncertain asks the set question with "Try export again"; web: one Download per file, all of them → uncertain, closing early → cancelled. A11y guidelines pass |
| Goldens (derived) | `account_delete_set_native_*` (compact, + 2.0 text, RTL), `account_delete_set_web_*` (expanded), `account_delete_set_without_copy_*` |
| Regression | Every existing D1, Settings and export test passes. One named edit: `deletion_consent_test.dart`'s "too large" case used a 27 MB account; under §10 that is a set now, so the case is one task larger than any part (parts of 1,500 bytes), with the same assertions. Test support: `DeletionWorld` gives the app version and an optional part size; the fakes gain the new methods |
| Mutations | `uncertain` letting the deletion through, no session/generation/newer-export guard, any check counting as done, closing D1 keeping the files, a new export keeping the old set, the web counting any download as handed over, the set question never asked, large accounts as one file: 8 of 8 caught (the guard and the new-export case needed their own tests, added) |
| Device and web | B7's gate, below |

### B7 gate: device and web sweep (2026-11-12, local)
The set screens of B7a–c on every target, light and dark, each with its live accessibility tree
checked (44 pt / 48 dp targets, every tappable node labelled; `integration_test/support/a11y_tree.dart`).
`integration_test/cr160_set_sweep_test.dart` starts the real app through `bootstrap()` with two
test-only overrides (`bootstrap(overrides:)`, which the app never passes): parts of 16 KB, so forty
seeded tasks with long notes make a set, and `SweepGateway`, which stands in for the native share
sheet, folder picker and file picker that a test can't drive (every handoff "delivers"; every pick
returns files it was handed). Delete account runs against the **local** Supabase stack only (a lab
account, never deleted; the hosted project untouched). Shots: `app/build/sweep/<platform>[_dark]_cr160_*`
(web: `web[_dark]_<width>_cr160_*`). Runs: `tool/device_tests.sh <ios|android> cr160_set_sweep`
(`DEFINES` = local-stack defines), `SWEEP_TARGET=integration_test/cr160_set_sweep_test.dart
tool/mac_sweep.sh`, and on the web a profile build with `SWEEP_HOST_SHOTS=true` driven by
`tool/cr160/web_set_sweep.mjs` (Playwright Chromium 156, which saves each announced shot).

| Target | Light | Dark | Shots |
|---|---|---|---|
| iPhone 17 Pro simulator (iOS 26.5) | PASS, 9/9 a11y | PASS, 9/9 a11y | export set, check missing, check complete; import "Add the rest" (2 of 7), another backup's file refused, Replace question; D1 uncertain, the set question, confirmed |
| Android API 37 emulator | PASS, 9/9 a11y | PASS, 9/9 a11y | the same nine |
| This Mac (debug, its kept container: the guest had grown to 66 files) | PASS, 9/9 a11y | PASS, 9/9 a11y | the same nine |
| Chromium, expanded (1280×800) | PASS | PASS | ten: the nine less the native set sheet, plus the Download lists (Settings, D1) |
| Chromium, compact (390×844) | **FAIL** (2 findings) | **FAIL** (same) | the same ten; D1 all PASS |

The real platform sheets, opened for a set (`integration_test/cr160_real_sheet_sweep_test.dart`, no
gateway override): iPhone, the share sheet says "7 Documents" with Save to Files
(`ios_cr160_real_sheet.png`); Mac, the folder picker over Export (`macos_cr160_real_sheet_window.png`,
cropped to the app window). With either open nothing says it was saved. Not covered: closing the
Mac picker for real (macOS refused the keystroke to this session; the cancelled path is unit- and
widget-tested), picking real files in iOS Files, Android's file chooser and a browser's file dialog
(the owner's by-hand device list).

Findings, graded (docs/08 §7):

| # | Grade | Where | Finding |
|---|---|---|---|
| G1 | **BLOCKER** (a11y floor) | Web compact, Settings › Export, the set sheet with its Download list | Once the list is taller than the sheet (7 files on 390×844), the sheet's title and close button scroll up under the drag handle and are cut off; the half-visible close button is a 48×22 target (48×44 one step earlier), under the 44 / 48 floor. From the shared `showAppSheet` when its content scrolls; D1's own Download sheet passed |
| G2 | FIX | Mac and web expanded, "Delete without a confirmed copy?" (and Stage C's "Delete without a saved copy?", the same dialog) | A title-less `AlertDialog` with no width cap: it spans almost the whole window as one line of text. B7c's golden covered compact only |
| G3 | FIX | Export file names (`partFileStem`) | The stem takes the export id's first 8 characters, a UUID v7's time: two exports about a minute apart get identical file names, so a second export can overwrite the first in a folder and the two sets look alike in a picker. Import still refuses the other set's file by its content (shown on every target) |
| G4 | NOTE | Web compact, Download list | Long file names wrap mid-name ("…-2026-11-1 / 2-01a1ce18-part-01- / of-06.json") |

Sweep fixes made on the way (test code only): the iOS run never created `build/sweep/`
(`device_tests.sh`); `mac_sweep.sh` matched shot names with `[a-z_]*`, which cut `cr160` short; theme is
the owner's setting, so the sweep pins it after signing the lab account in (a new account follows the
system, which is dark on this Mac); Android's soft keyboard leaves D1's buttons just below the scrolled
view, so the sweep scrolls to them as a person would; a web build without `flutter drive` has no test
text input, so the typed word goes through the field's controller. The three sweep steps moved from
`sweep_test.dart` to `support/sweep_steps.dart`, unchanged; the main design sweep was **not re-run**
after that move. Gate: **not passed** until G1 is fixed and the compact web run is clean.

#### G1–G3 fixed (2026-11-12, local)
| # | Fix | Proof |
|---|---|---|
| G1 | `AppSheet` keeps its title row (and close button) fixed above the body; only the body scrolls. Every titled sheet, unchanged at rest | `test/shared/sheets/app_sheet_scroll_test.dart` (fails on the old sheet: the close button scrolled 736 px off); all 2,334 goldens unchanged by it |
| G2 | Dialogs are capped at `DotSize.promptWidth` (480) in the theme's `DialogThemeData`; `showAppSheet`'s popover keeps its own 560. D1's and the sign-out prompt's own 480 caps are removed (the theme holds it now). Three buttons that don't fit side by side stack, Flutter's own `OverflowBar` | `test/core/theme/dialog_width_test.dart` |
| G3 | `partFileStem` takes the export id's last 8 characters (random), not its first 8 (time) | `test/domain/export/part_file_names_test.dart`; 8 web export-set goldens re-made for the new names, nothing else in them changed |

Re-run after the fixes (local):

| Target | Light | Dark |
|---|---|---|
| Chromium compact, `cr160_set_sweep` | PASS, no A11Y finding | PASS, no A11Y finding |
| Chromium expanded, `cr160_set_sweep` | PASS | PASS |
| Mac, `cr160_set_sweep` | PASS, 9/9 | PASS, 9/9 |
| iPhone 17 Pro simulator, main design sweep (`sweep`, `.env.example`) | PASS, 39/39 | PASS, 39/39 |

The main sweep re-run also covers the `sweep_steps.dart` move. iPhone and Android `cr160_set_sweep`
were not re-run: G1 and G2 only showed at the web compact and expanded widths, and G3 is pinned by its
test. A widget-test note: Flutter's tap-target guideline also flags a row cut in half at a scroll
edge (a normal scroll position, not a defect), so the G1 test asserts the header, not the guideline,
after scrolling; the at-rest guideline checks in `app_sheet_test.dart` still run. G4 stays a note.
Seen in passing, not from this work: the main sweep's `wake_up_explain` shot shows iOS's own "schedule
alarms and timers" prompt over the sheet (Wake Up, out of scope here). Gate: **passed** locally (not CI).

## 7. Size policy and acceptance criteria (provisional)
Provisional limits: **10 MB per written part, 25 MB per file read.** No maximum part count is adopted
yet. Each limit is confirmed or changed only from measurements against these criteria (B8):

| Measure | Criterion | How |
|---|---|---|
| Import peak memory | ≤ 150 MB above the app's idle RSS on native for any part ≤ 25 MB; web tab heap ≤ 300 MB for the reference account | `ProcessInfo.currentRss` sampling in an integration test; Chrome performance memory on web |
| Export peak memory | ≤ 100 MB above idle on native | same |
| Staging storage | ≤ 1.2 × total file bytes, released after commit | file sizes before/after |
| Commit transient storage | ≤ 5 × total file bytes (WAL, outbox, search index) | WAL and file sizes during commit |
| Supported account size | reference account of 60 MB JSON round-trips on the low-end device set (a 3 GB Android phone, an iPhone with 4 GB, a Mac, Chrome desktop) within the memory criteria | B8 device matrix |

If the 60 MB reference fails a criterion on a platform, that platform's supported size is lowered
and stated in the release notes; it is never silently truncated.

## 8. Backups, including existing ones over 25 MB
**Ordering gate (correction A):** the staged pipeline becomes the active import path only after the
pre-import backup it takes is restorable at any size (B4 before B5, §9).

- **New backups**: a backup that fits the 25 MB import limit is today's JSON v1 row, unchanged. One
  over it is stored as parts in the backup database (backup schema 3: a `backup_parts` table beside
  `backups`, the `backups` row holding the manifest), written by the multipart writer one part at a
  time, restored through §5. Built in B4 (see B4 verification).
- **Existing backups over 25 MB**: restorable since B5 (the legacy backup source below, built in B3,
  measured in B3, live in B5); before B5 they could not be restored. Normal retention can still remove
  them (unchanged; decision 5). This work never rewrites, deletes or marks them unusable.
  **Built in B3 (originally proposed here):** make them restorable through §5 with a **legacy backup
  source** that reads the stored JSON **inside the encrypted backup database with SQLite's JSON
  functions** (`json_each(json, '$.occurrences')` and so on, paged), decoding one row at a time, with
  no new dependency and without decoding the whole document in Dart. Whether this meets the §7
  memory criteria (SQLite still parses the stored text) and restores every row correctly must be
  proven by measurement and correctness tests in B3–B4 before it is relied on.
- **Validation of a legacy backup** before any live change: the same row validators and global
  checks as any import; row counts must equal `json_array_length` of each array; the backup's owner
  column and profile id must equal the restoring owner (today's `requireOwner` rule).
- **Conversion** (optional, after the source above is proven): write a multipart copy beside the
  original, verify it restores to the same staged rows, and keep both until the owner decides
  (decision 4 in §11). Retention pruning is unchanged by B0; whether to pause pruning of oversized
  backups until B4 ships is decision 5.

## 9. Revised stages and gates
| Stage | Scope | Gate to start the next |
|---|---|---|
| **B0** | This specification, ADR-0019, and the Settings export size refusal (§10). | Owner review. |
| **B1** | Domain: manifest and part model, splitter, SHA-256 streaming check, recognition of manifests and parts in the single-file import with clear refusal; memory measurement harness. | Old-decoder refusal and format round-trip tests. |
| **B2** | Staging tables (app schema 21), inactive (no UI, no caller but tests); all §6 requirements. | Every §6 verification passes on native and web. |
| **B3** | Staged pipeline core (§5) for all three sources, including the legacy backup source (§8), reachable only from tests. | Atomicity, rollback, disk-full and kill tests. |
| **B4** | Multipart backup storage and restore of every backup through B3. | **Any backup, any size, restores** (correction A). |
| **B5** | Switch Settings import and backup restore to the staged pipeline; remove the in-memory path. | Legacy single-file regression suite unchanged. |
| **B6** | Multipart export for D1, Settings and backups; handoff states and D1 consent (§10 B). | Stage C consent tests extended to multipart. |
| **B7** | Platform delivery and picking UI (web per-part downloads, "add files", verify step), copy approval, goldens, accessibility. | Screenshot sweep. |
| **B8** | Acceptance measurement (§7) and the full regression plan on the device matrix. | Release review. |

## 10. Multipart handoff and consent (correction B)
Per part and per export, three distinct states, never collapsed:
1. **Prepared**: the file was written and re-read with a matching hash on this device.
2. **Handoff attempted**: the share sheet or save dialog returned success, or the browser was asked
   to download it. On iOS and Android one share result covers all N files and cannot show that every
   file reached its target (a target app may take only the first). On the web a download request does
   not show the browser allowed it (repeated downloads are often blocked or prompted).
3. **Possession confirmed**: the person picked the manifest and all N parts back into the app and
   every hash and count matched ("Check my files"), on this device, at that moment.

D1 (Stage C) with a multipart export:
- Only **possession confirmed** counts as an export that ended well (Stage C's `done`).
- **Handoff attempted** without confirmation is an **uncertain** outcome. It is treated like
  `cancelled`: deletion is refused until the person either confirms possession or makes Stage C's
  separate "Delete without a saved copy" choice, with copy that says the app can't confirm all N
  files were saved (new copy, needs approval).
- Any part not prepared is `failed`. Too large is no longer a reason once multipart exists, except
  for a single row over the target (§4), which stays `failed` with its real reason.
- The single-file D1 rule is unchanged until the owner decides otherwise (decision 7).

### Settings export size refusal (built in B0)
A JSON export over the import limit (the same rule `decodeExportJson` applies, `exceedsImportLimit`)
is refused by `ExportService.build` with `ExportTooLargeFailure`: no file is made or handed over,
nothing says "Exported", and Settings shows: "This export is too large for Dottoday to restore using
the current import format. No restorable export was created." (de, fr and es translations pending
native-speaker review). Exactly 25 MB is still allowed. CSV and ICS are reports, never imported, and
are not limited. D1 maps the same failure to its existing `tooLarge` outcome, so Stage C is
unchanged. The 25 MB import limit is unchanged.

## 11. Open decisions
1. Part target (10 MB provisional) and accepted total (64 MiB provisional in B2,
   `maxStagedImportBytes`), after §7 measurements.
2. ~~Whether SQLite temporary files need `temp_store = MEMORY`~~ Decided in B2: native SQLCipher is
   compiled `TEMP_STORE=2` (memory) already; the web sets `temp_store = MEMORY`. Web memory under it
   is measured with the rest in B8.
3. ~~Staging session lifetime and concurrency~~ Decided in B2: 24 h, one import per owner, and an
   import never survives into another app run.
4. Converting existing oversized backups to parts, or reading them in place only.
5. Pausing retention pruning of oversized backups until B4 ships (keeps originals; costs storage).
6. ~~Whether Settings exports above the part target switch to multipart automatically or ask
   first~~ Decided in B6: automatically, wired in B7.
7. Whether single-file D1 exports also require possession confirmation.
8. ~~New copy for every multipart state~~ Approved 2026-11-11 (B7 plan); de, fr and es pending
   native-speaker review.
9. Web per-part download UI and the "Check my files" verify step (design review, B7).
