# 04 — Architecture

## 1. Overview

```
┌────────────── Flutter app (iOS · Android · macOS · Web) ──────────────┐
│ features/*  ──►  domain (entities, use-cases, scheduler, recurrence)   │
│      │                        ▲                                        │
│      ▼                        │ interfaces                             │
│ data/: Drift (SQLCipher) ◄── repositories ──► SyncEngine ──► Supabase  │
│           ▲ local source of truth                      (REST+Realtime) │
│ platform channels: widgets, calendar (EventKit/CalendarContract), push │
└────────────────────────────────────────────────────────────────────────┘
Supabase: Postgres (RLS) · Auth · Realtime · Edge Functions (calendar OAuth, account deletion, push)
```

Principles: local-first, boring, testable. The UI never talks to Supabase directly.

## 2. Layers

- **domain/** — pure Dart. `Task`, `Occurrence`, `Series`, `Subtask`, `Alert`, `CalendarLink`
  (freezed). Services: `RecurrenceExpander` (RRULE → occurrences, tz-aware), `DayScheduler`
  (shift-followers, bump-on-insert, pin rules, running-late), `QuickAddParser`, `NotificationPlanner`
  (which notifications should exist for a window), `ConflictResolver`. Repository *interfaces*.
- **data/** — Drift schema (`app_database.dart`, one table file each), DAOs, repository
  implementations, `SupabaseGateway`, `SyncEngine`, `BackupService`, `ExportService`.
- **features/** — Riverpod notifiers + widgets per feature. Notifiers call use-cases, never DAOs.
- **shared/** — `TimeInput`, `DurationChips`, `ColorIconPicker`, `AppSheet`, `UndoSnackbar`, etc.
- **core/** — theme tokens, router, l10n, `Clock`, `Logger` (PII-redacting), `Env`, failures.

## 3. Time model (the part that bites)

- Store `startUtc` (int ms) + `tzId` (IANA) on every occurrence; display with `TZDateTime`.
- Durations in minutes, never end timestamps (end = start + duration; DST-safe).
- Recurrence stored as RFC 5545 `RRULE` string + `dtstartLocal` + `tzId`; expansion happens in the
  series' zone, then converted. Exceptions table stores `(seriesId, originalStartUtc)` → override or skip.
- "Day" is defined by the user's day boundaries in their *current* zone; occurrences are bucketed by
  local date for the timeline.
- Inject `Clock` everywhere; tests fix time.

## 4. Offline-first sync

**Local tables mirror server tables** plus sync columns: `updatedAt` (server-assigned on ack, client
HLC before), `deletedAt`, `dirty`, `version`. A `change_log` table records `(entity, id, field, value,
hlc)` per local write.

**Push**: batched upserts to Supabase via a `sync_push` RPC that applies per-field LWW using a hybrid
logical clock (HLC) carried in each change; the RPC returns the authoritative rows.

**Pull**: initial full pull per table paged by `updatedAt`; afterwards Realtime `postgres_changes`
on the user's rows + a periodic `since` pull as a safety net (every 5 min foreground, on resume).

**Conflicts**: per-field LWW by HLC. If two devices change the *same field* of the same row within
60 s, record a `conflict` row and show "keep mine / keep theirs" in Sync details; default keeps server.
Deletes are tombstones (30-day retention = Trash). Never hard-delete locally because of a server error.

**Safety**: writes are local-first and immediate; sync failures only change the status pill; daily
local backup (JSON, last 7) before any migration or bulk import.

**Widgets** read a lightweight JSON snapshot (`next 24 h`) written to the app-group container on every
local write, so they are correct even if sync is down.

## 5. Scheduling algorithms (domain/`day_scheduler.dart`)

- `shiftFollowers(day, movedId, deltaMin, {includeCalendar=false})`: for blocks after the moved block
  (ordered by start), add delta while preserving gaps; skip pinned and (unless included) calendar
  blocks; never move a block across a pinned block — stop shifting at the first pinned block and
  report `partial`. Pure function, returns a new list + a `ShiftReport`.
- `insert(day, newBlock, policy)`: `overlap` (default off), `bump` (push followers), `fitNextGap`.
- `runningLate(day, now, deltaMin)`: shifts all unpinned, not-done blocks whose start ≥ now.
- `suggestSlots(day, durationMin, prefs)`: next free gaps respecting boundaries and energy windows.
All are property-tested (no overlaps created unless allowed; pinned never moves; order preserved).

## 6. Notifications

`NotificationPlanner` computes the desired set `{notificationId → (fireAtUtc, payload)}` for the next
7 days from occurrences × alerts. `NotificationScheduler` diffs against the pending set from the OS and
only adds/cancels deltas. IDs are `hash(occurrenceId, alertIndex)` (stable 32-bit). Runs after every
write and on app start/resume. Web uses a service worker + server-sent push for exactness.

## 7. Calendar integration

Mobile/macOS: `device_calendar` for read, plus write-back when permission is granted. Web (and as a
cross-device option): Google/Microsoft OAuth handled by Supabase Edge Functions storing refresh tokens
encrypted server-side; the function fetches events and upserts into `calendar_events` for the user;
the client subscribes like any table. External events map to `Occurrence` rows with `source =
calendar` and `externalId`; local-only fields (subtasks, notes) live on the occurrence.

## 8. Platform channels / plugins

| Capability | iOS | Android | macOS | Web |
|---|---|---|---|---|
| Local notifications | flutter_local_notifications | same | same | service worker |
| Widgets | WidgetKit via `home_widget` | Glance via `home_widget` | WidgetKit | n/a (PWA shortcut) |
| Calendar | EventKit | CalendarContract | EventKit | OAuth via backend |
| Secure storage | Keychain | EncryptedSharedPrefs/Keystore | Keychain | IndexedDB + WebCrypto-wrapped key |
| DB | SQLCipher | SQLCipher | SQLCipher | drift WASM + OPFS (encrypted blobs) |

## 9. Observability

Sentry for crashes/perf (scrubbed: no titles/notes), structured logs, a `diagnostics.json` the user
can attach to feedback (IDs, counts, versions only).

## 10. Build & CI

GitHub Actions: `analyze → test → build (ios/android/macos/web) → integration (android emulator) →
RLS tests (supabase db reset + pgTAP)`. Fastlane for store uploads. Web deploys as a PWA behind the
Supabase project's domain or Vercel.
