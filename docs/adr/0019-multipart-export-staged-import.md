# ADR-0019 · Multipart export and one staged import pipeline

Status: Proposed (design accepted conditionally, 2026-11-10; built in stages B1–B8) · Date:
2026-11-10 · Spec docs/cr-160-multipart-export.md · Part of CR-160 (release blocker) · Amends
docs/05 "Export format"

## Context
JSON v1 is one file, and the import refuses anything over 25 MB (06 §7). An account above that has
no restorable copy: D1's export reports "too large", Settings › Export handed over a file its own
import refused (fixed in B0), and automatic backups are written at any size but cannot be restored
above 25 MB. Every import also holds the file, the decoded bundle, the current account and one
`WriteBatch` in memory, so raising the limit is not an option.

## Decision
- **D1 · Manifest plus separate JSON parts, no archive dependency.** A manifest
  (`format: "dottoday-multipart"`) lists the parts (`format: "dottoday-part"`) with counts, sizes and
  SHA-256 hashes (`crypto`, already a dependency). Neither carries `version: 1`, so every shipped
  importer refuses them before writing anything. An export that fits one part stays today's v1 file.
- **D2 · Limits.** 10 MB per written part, 25 MB per file read (unchanged), both provisional until
  the acceptance criteria in the spec §7 are measured. No maximum part count yet.
- **D3 · Hashes are integrity, not authenticity.** Tampering is still handled by row validation,
  reference checks, single-owner checks, re-owning to the importing account and server RLS.
- **D4 · One staged pipeline for every import and restore.** Parts (or a legacy file, or a stored
  backup) are validated one at a time into owner-fenced staging tables in the encrypted main
  database, checked globally in SQL, and applied in one transaction through the existing entity
  writers. Live data changes only in that transaction. The current in-memory path is removed when
  the pipeline goes live ("replace, don't layer").
- **D5 · Backups first.** The pipeline becomes the active import path only after the pre-import
  backup it takes is restorable at any size: multipart backups, plus existing oversized backups,
  kept unmodified and proposed to be read in place with SQLite's JSON functions (unverified: needs
  memory and correctness tests before it is relied on).
- **D6 · Handoff is not possession.** Prepared, handoff attempted and possession confirmed are
  separate states; for a multipart D1 export only confirmed possession counts as a saved copy, and an
  uncertain handoff goes through Stage C's explicit "Delete without a saved copy" choice.
- **D7 · Every JSON export obeys the import limit now** (B0): a file the app could not restore is
  never made.

## Alternatives rejected
- **Raise the 25 MB limit.** Memory grows with the file (decoded objects several times its size)
  on the devices most likely to fail; it moves the cliff instead of removing it.
- **A ZIP archive.** Needs a new dependency and a streaming unzip with its own size and path checks;
  sharing several plain files works with what the app has.
- **A streaming JSON parser dependency.** Parts bound memory without one, and stored backups can be
  read row by row with SQLite's JSON1 functions.
- **A separate staging database file.** A second key and file lifecycle to secure and clean up; the
  main database already has encryption, owner fencing and transactions.

## Consequences
- App schema 21 (staging tables) and backup schema 3 (`backup_parts`), each with migration tests.
- New user-facing states and copy (multipart handoff, missing parts, verify step) need approval.
- A large restore writes a large sync outbox; push volume after it is a sync risk outside this ADR.
- Stage gates in the spec §9 decide when each piece ships; CR-160 stays a release blocker until the
  pipeline and its acceptance criteria are met.
