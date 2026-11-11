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

Names (informative only): `dottoday-backup-<yyyy-MM-dd>-<first 8 of exportId>-manifest.json` and
`…-part-03-of-07.json`, dated in the profile's zone, never content.

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
- **Existing backups over 25 MB**: today they **cannot be restored**, and normal retention can still
  remove them (unchanged by B0; decision 5). This work never rewrites, deletes or marks them unusable.
  **Proposed, not built or verified:** make them restorable through §5 with a **legacy backup
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
6. Whether Settings exports above the part target switch to multipart automatically (proposed) or
   ask first.
7. Whether single-file D1 exports also require possession confirmation.
8. New copy for every multipart state (approval needed before B6/B7).
9. Web per-part download UI and the "Check my files" verify step (design review, B7).
