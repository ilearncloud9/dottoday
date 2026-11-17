# CR-160 release review: Stage B (multipart export, import and backups)

Prepared 2026-11-12 for the owner's release review (`docs/cr-160-multipart-export.md` §9, B8's gate).
Branch `fix/cr-160-account-ownership`, PR #75 (draft). All evidence is **local**: this Mac, its iOS
Simulator, the Android emulator, Playwright's Chromium and one physical iPhone 17 Pro for measurements.
No CI run, nothing against the hosted Supabase project. **CR-160 stays CRITICAL, OPEN and a release
blocker**; this review covers Stage B only.

## What Stage B delivers
- Any account size exports, imports and backs up: data over one file becomes a checked set of parts
  (manifest + parts, each hashed), and every import, restore and Undo runs through one staged,
  all-or-nothing pipeline (B1–B5).
- Settings export, account deletion's export and backups hand sets over per platform (share sheet,
  folder, the web's per-file downloads), with "Check my files" before a set counts as saved (B6–B7c).
- An import that fills the disk rolls back and says so (B8).

## Gates and their evidence
| Gate | Result | Where |
|---|---|---|
| B1–B6 (format, staging, pipeline, any backup restores, legacy suite, consent) | Passed, owner-reviewed per stage | `cr-160-multipart-export.md` B1–B6 sections |
| B7 screenshot sweep | Passed after G1–G3 fixes: iPhone, Android, Mac, Chromium compact and expanded, light and dark | B7 gate section |
| B8 §7 measurements | Native passes every row (storage rows revised by the owner); web supported size 30 MB | B8 section |
| B8 regression | Device suite 11/11 on the iPhone simulator and the Android emulator; criterion 11 on all four targets; web flows 1–5 | B8 section |
| Unit suite | 4,381 / 4,381 (goldens 2,334 at B7) | local runs |

## Decisions recorded (§11)
All nine are closed: 1 (10 MB export parts, 5 MB backup parts, 64 MiB total), 2, 3, 4 (oversized
backups read in place, not converted), 5 (not needed), 6, 7 (single-file D1 export needs no check),
8 (copy approved), 9 (closed on the owner's review of B7's screenshots).

## Known limits to state in the release notes
- On the web, accounts up to about 30 MB of exported data are supported (CHANGELOG). A larger one
  still imports, slowly, with the tab's memory high (about 1.9 GB at 60 MB).
- An import needs free storage of about ten times its files' size at its peak (the single commit
  transaction's WAL); with less, it refuses and changes nothing.
- German, French and Spanish strings: reviewed by the agent (16 fixed), pending a native speaker.

## Still open before CR-160 can close (not Stage B)
- The owner's by-hand list: §7's 4 GB iPhone and 3 GB Android phone, Firefox and Safari, physical
  devices for the account flows (criterion 11), real file picks in each platform's picker, the
  release APK.
- Hosted Supabase: migration 0014 and staging runs, each after the owner's separate go
  (`cr-160-rollout.md`).
- The release-blocker list of 2026-11-09 (`cr-160-verification.md`, items 2–6 and 8: Wake Up
  ownership, the Android ringing alarm, the offline sign-out message, "Sync now" feedback, the Concept
  E visuals, older-build data). Stage B did not touch them; their status is as recorded there.
- Seen once in B8, not reproduced and not CR-160: a 6–12 px overflow in `DayCard` on a freshly erased
  simulator.

## Asked of the owner
Sign off Stage B, or name what to change. Nothing here pushes, merges or deploys.
