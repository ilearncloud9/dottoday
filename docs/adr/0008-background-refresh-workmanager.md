# ADR-0008: Daily background refresh through `workmanager`

**Status**: accepted · **Date**: 2026-10-23 · **Decided by**: owner (M5.2 pre-run question:
"Add workmanager")

## Context
Repeating tasks are materialised 90 days ahead when a series is saved (M1.3, M2.3), and the OS holds
only the next 7 days of alerts (M1.6). Both windows must move forward every day, also on days the
app isn't opened (docs/07: iOS `BGAppRefreshTask`, Android `WorkManager`). Before M5.2 nothing moved
them, so a repeat ran out 90 days after its last edit.

## Decision
- `DailyRefresh` (data) re-saves the series whose window ends within a day of the 90-day horizon
  through the write path (which materialises them and re-plans notifications), or just re-plans
  when none is due. It runs at start, on every resume, every 6 h while the app stays open (Mac and
  web windows live for days), and from the OS background scheduler.
- `workmanager` ^0.10 schedules it: Android WorkManager (periodic, 24 h) and iOS BGTaskScheduler
  (`dottoday.refresh` in `BGTaskSchedulerPermittedIdentifiers`, handler registered in
  `AppDelegate.swift`). The worker runs `backgroundRefreshDispatcher` (lib/background_refresh.dart),
  a small composition root that opens the same encrypted database (key readable after first unlock,
  06 §4) in its own isolate.
- macOS and web use the start/resume/timer path only.

Rejected: hand-written Swift `BGTaskScheduler` + Kotlin `androidx.work` behind a platform channel
(same native dependencies, more code to own); no background refresh (alerts would stop after 7 days
for someone who never opens the app, and repeats after 90).

## Consequences
- One new dependency (federated: android/apple/linux/web implementations come along).
- Two database connections can be open at once (app + worker); SQLite WAL with `synchronous=FULL`
  serialises writers. The app's Drift streams don't see the worker's writes until the next query,
  which the next resume's refresh makes moot.
- iOS background runs can't be exercised on the simulator; they are checked on a device in M8.5.
  Android is covered by `integration_test/background_refresh_test.dart`.
