# 09 — Implementation Plan

The agent works top to bottom. A milestone is done only when every task is `[x]` and `/ship-check`
passes. Each task lists the spec sections and `R-xx` IDs it must satisfy. Keep tasks small; split a
task rather than leaving it half-done. Add new tasks here when discovered — never keep them in your head.

Legend: `[ ]` todo · `[x]` done · `[~]` in progress (only one at a time).

---

## Milestone 0 — Project bootstrap (goal: `flutter run` on all four targets with a blank themed screen)

- [x] M0.1 Run `flutter create` in `app/` per `app/README.md`; restore seeded files; `flutter pub get`; commit lockfile.
- [x] M0.2 Folder layout from CLAUDE.md §3 with placeholder `README.md` in each top-level dir explaining its boundary.
- [ ] M0.3 `core/env`: load `.env` via flutter_dotenv; fail fast with a clear message if `SUPABASE_URL` missing. (06 §1)
- [ ] M0.4 `core/theme`: tokens from 03 §1 (colours light/dark, typography, spacing, radii, motion durations); `AppTheme.of(context)`; respects reduced motion. Golden test light/dark.
- [ ] M0.5 `core/router`: go_router with routes `/today`, `/day/:date`, `/inbox`, `/week`, `/month`, `/search`, `/settings`, `/task/:id`; allow-listed deep links. (07 shared)
- [ ] M0.6 `core/l10n`: ARB setup (en source), `AppLocalizations`; lint that forbids string literals in `features/**/widgets` (custom_lint rule or test scanning). Also an import-boundary test (scans `lib/**` imports) failing on: `features/X` → `features/Y`, `domain/` → `package:flutter`, `shared/` → `features/`. (CLAUDE.md §3)
- [ ] M0.7 `core/clock`, `core/logger` (PII redaction + test that `Logger.info('title: x')` is rejected by lint/test), `core/failures` sealed class.
- [ ] M0.8 CI: GitHub Actions `analyze → format → test` for the app; `supabase start && supabase test db` for RLS. gitleaks step.
- [ ] M0.9 Supabase project: apply `supabase/migrations/0001_init.sql`; run `supabase/tests/0001_rls.sql`; fix any dialect issues found in the `sync_push` dynamic SQL (keep allow-listing and `auth.uid()` enforcement). (05, 06 §3)
- [ ] M0.10 CHANGELOG.md created; `/ship-check` passes.
- [ ] M0.11 Codegen/lint toolchain upgrade: move to custom_lint/riverpod_generator (or riverpod_lint 3 native analyzer plugin) that support analyzer ≥ 7.4; drop the `analyzer` pin in `pubspec.yaml` and the `analysis_options_deprecated_plugins: ignore` in `analysis_options.yaml`; `build_runner build` + `flutter analyze` clean. Discovered in M0.1.

## Milestone 1 — Domain core (goal: pure-Dart engine fully tested before any UI)

- [ ] M1.1 Entities with freezed: `Series`, `Occurrence`, `Subtask`, `Alert`, `CalendarAccount`, `CalendarLink`, `Profile/Settings`. Validators per 05 "Validation". Unit tests.
- [ ] M1.2 `RecurrenceExpander` (rrule + timezone): expand series → occurrences for a window; exceptions; tests listed in 08 §2 `recurrence_expander_test`. (ADR-0004, R-01, R-09)
- [ ] M1.3 `Materialiser`: idempotent 90-day materialisation; subtask instantiation from template per occurrence; `subtask_occurrence_test`. (R-09)
- [ ] M1.4 `DaySchedulerService`: `shiftFollowers`, `insert(policy)`, `runningLate`, `suggestSlots`; property tests from 08 §2. (04 §5, R-04, R-05, R-17)
- [ ] M1.5 `QuickAddParser` (en, de, fr, es; 12/24 h): tests from 08 §2. (R-06, R-07, R-20)
- [ ] M1.6 `NotificationPlanner`: desired-set computation; windowing (iOS 64 limit); quiet hours; tests. (R-10)
- [ ] M1.7 `ConflictResolver` + HLC implementation; tests for LWW, 60-s same-field conflict. (ADR-0002)
- [ ] M1.8 Export/import model (JSON v1 schema, CSV, ICS writers) with round-trip tests. (R-11)
- [ ] M1.9 Coverage ≥ 90 % on `lib/domain`; `/ship-check`.

## Milestone 2 — Data layer (goal: encrypted local DB + repositories, no network yet)

- [ ] M2.1 Drift schema mirroring 05 + sync columns + `change_log`, `sync_cursors`; SQLCipher key from secure storage; web WASM/OPFS variant behind the same interface. (06 §4, ADR-0003)
- [ ] M2.2 DAOs + repository implementations (`OccurrenceRepository`, `SeriesRepository`, `SubtaskRepository`, `SettingsRepository`) with reactive streams for day/inbox/week/month queries.
- [ ] M2.3 Write path: every mutation goes through a `WriteUseCase` that updates DB, appends `change_log`, triggers `Materialiser` (if series), `NotificationPlanner` diff, widget snapshot write. Tests.
- [ ] M2.4 `BackupService`: daily local JSON backup (keep 7), pre-migration backup; restore. Tests. (R-08, R-11)
- [ ] M2.5 Trash: soft delete, 30-day restore, purge; undo token API for UI (30 s). (R-11)
- [ ] M2.6 Search index (FTS5) over title/notes/subtasks incl. completed. (R-11)
- [ ] M2.7 Performance test: 10 000 occurrences, day query < 16 ms, search < 50 ms. (R-15)
- [ ] M2.8 `/ship-check`.

## Milestone 3 — Timeline UI (goal: the home screen, complete and flawless, local only)

- [ ] M3.1 Shared components: `AppSheet`, `TimeInput` (typed + optional wheel, 12/24 h, tests from 08 §2), `DurationChips`, `ColorIconPicker`, `UndoSnackbar`, `SyncPill` (static for now). (03 §3.3–3.4, R-16, R-20)
- [ ] M3.2 Timeline canvas: hour gutter, lazy sliver blocks, now-line (1-min tick), past tint, outside-hours zones, all-day strip, overlap columns, full-24h golden test. (03 §3.1, R-14, R-15)
- [ ] M3.3 Block widget: anatomy + states (done/overdue/pinned/recurring/calendar/alerts); semantics label per 03 §4. Golden at 100/200 % text, light/dark. (R-12)
- [ ] M3.4 Gestures: long-press pick-up, drag with snapping + ghost + floating time label + auto-scroll; edge resize handles; tap vs scroll disambiguation test; haptics; reduced-motion path. (03 §3.2, R-05)
- [ ] M3.5 Shift-followers chip during drag; settings default `ask|always|never`; pinned and calendar rules; partial-shift toast. (R-04, R-17)
- [ ] M3.6 "Running late" (+5/+15/+30) in header menu; Snooze on block context menu. (R-04)
- [ ] M3.7 Multi-select (long-press then tap / Shift-click): move, delete, duplicate, change colour. (R-05)
- [ ] M3.8 Gap affordance: long-press/double-click gap → Quick Add prefilled with time. "Insert here" draggable marker. (R-17)
- [ ] M3.9 Day navigation: swipe/keys, date header → month picker, "Today" chip, Duplicate day, Export day. (03 §3.1)
- [ ] M3.10 Keyboard map for desktop/web per 02 F1; focus ring; semantics widget tests; screen-reader manual pass on 2 platforms. (R-12)
- [ ] M3.11 Empty/loading/error/offline states. (03 §3.8)
- [ ] M3.12 Perf: 200 blocks ≥ 55 fps profile run on Android mid-range; fix hot spots. (R-15)
- [ ] M3.13 `/ship-check`.

## Milestone 4 — Capture: Quick Add, editor, inbox, recurrence UI

- [ ] M4.1 Quick Add sheet/popover with live token chips, duration chips, "Add"/"Add another", Enter/Shift+Enter, multi-line paste → N tasks confirmation. (03 §3.3, R-06, R-07)
- [ ] M4.2 Task editor sheet with all fields from 02 F2; autosave; nothing lost on dismiss; typed confirmation for delete on desktop. (03 §3.4)
- [ ] M4.3 Alerts editor: up to 5, kinds before/at start/at end/overdue, sound picker, defaults from settings. (R-03, R-10)
- [ ] M4.4 Recurrence editor: presets + custom RRULE builder (every N, weekdays, nth weekday, end conditions); human-readable summary; edit-scope dialog (this / following / all). (R-01)
- [ ] M4.5 Inbox screen: groups, swipe actions, reorder, bulk select, schedule suggestions sheet, drag to timeline (desktop) / to Today tab (mobile). (02 F3)
- [ ] M4.6 Subtasks UI: inline add, reorder, per-occurrence completion with progress ring on block. (R-09)
- [ ] M4.7 Week and Month views (free), Search screen. (02 F8, R-03, R-14)
- [ ] M4.8 Settings screen (all items in 02 F8) incl. per-weekday boundaries, snapping, shift default, alerts default, theme/accent, 12/24 h, language. (R-16, R-17)
- [ ] M4.9 Onboarding (≤ 3 screens, skippable, < 90 s), with notification pre-prompt. (02 F10)
- [ ] M4.10 Integration test: onboarding → quick add → drag w/ shift → recurrence edit scopes. `/ship-check`.

## Milestone 5 — Notifications, widgets, platform polish

- [ ] M5.1 `NotificationScheduler` diffing against OS pending set; IDs from `hash(occurrenceId, alertIndex)`; actions Done/Snooze/Open; channels (Android), interruption levels (iOS); exactness test 20/20/0 duplicates on iOS+Android. (04 §6, R-10)
- [ ] M5.2 Background refresh: iOS BGAppRefresh, Android WorkManager — re-materialise + re-plan daily. (07)
- [ ] M5.3 Web push: service worker, VAPID, `send-push` Edge Function; in-app fallback. (07 Web)
- [ ] M5.4 Widgets: iOS/Android "Next up", "Today timeline", "Inbox count" via `home_widget`; snapshot JSON updated on every write; macOS WidgetKit shares app group. (02 F9, R-08)
- [ ] M5.5 macOS: menu bar + shortcuts, window min size, sandbox entitlements; crash-free verification on Intel + Apple Silicon. (07 macOS, R-13)
- [ ] M5.6 Android: predictive back, edge-to-edge, exact-alarm rationale + inexact fallback. (07 Android)
- [ ] M5.7 Web: PWA manifest, offline page, CSP headers, keyboard-first audit, responsive 360 px. (07 Web, 06 §8)
- [ ] M5.8 App lock (biometric/passcode), blur in switcher, FLAG_SECURE. (06 §2)
- [ ] M5.9 Time-zone change banner (keep vs shift). (07 shared)
- [ ] M5.10 `/ship-check` incl. accessibility manual pass on all four.

## Milestone 6 — Accounts & sync

- [ ] M6.1 Auth screens: magic link, Sign in with Apple, Google (PKCE); session in secure storage; "sign out everywhere". App remains fully usable without an account. (02 F7, 06 §2)
- [ ] M6.2 `SupabaseGateway` + `SyncEngine`: push via `sync_push`, Realtime subscription, periodic `since` pull, HLC, tombstones, server-error-never-deletes-local; tests from 08 §2 `sync_engine_test`. (04 §4, ADR-0002, R-08)
- [ ] M6.3 Sync status pill + details screen (conflicts list with keep mine/theirs). (R-08)
- [ ] M6.4 First-sync merge for users who created local data before signing in (local wins, server rows merged by id). 
- [ ] M6.5 Account deletion Edge Function + settings flow + email confirmation; export before delete prompt. (06 §6)
- [ ] M6.6 Two-device integration test (two app instances against local Supabase): offline edit both, reconnect, no loss, conflict surfaced only for same-field-within-60 s.
- [ ] M6.7 Sentry wiring with PII scrubbing test. (04 §9)
- [ ] M6.8 `/ship-check` incl. RLS tests and security checklist.

## Milestone 7 — Calendar import & write-back

- [ ] M7.1 Device calendars (iOS/macOS EventKit, Android CalendarContract): permission flows with explain + deep link; per-calendar toggles; colour inheritance; all-day strip. (02 F5, R-02)
- [ ] M7.2 Map external events → occurrences (`source=calendar`, `calendar_links`); local-only subtasks/notes on them; links tappable. (R-02, R-09)
- [ ] M7.3 Write-back (opt-in per calendar): move/resize/rename → provider; failure banner + retry; etag conflicts. (R-02)
- [ ] M7.4 Google + Microsoft via Edge Functions (`calendar-oauth`, `calendar-sync`), tokens in Vault; web parity. (04 §7, 06 §1)
- [ ] M7.5 Travel-time buffer suggestion for events with a location. (R-17)
- [ ] M7.6 Include-calendar-in-shift option in drag chip and settings. (R-04)
- [ ] M7.7 `/ship-check`.

## Milestone 8 — Export, feedback, release hardening

- [ ] M8.1 Export JSON/CSV/ICS + Import JSON (backup before import) on all platforms; share sheet / file save. (R-11)
- [ ] M8.2 Send feedback (mail composer with redacted diagnostics opt-in); in-app What's new; changelog screen. (R-19)
- [ ] M8.3 Localisation de/fr/es complete; pseudo-locale test for truncation.
- [ ] M8.4 Generate `docs/parity-checklist.md` from PRD and verify on all four platforms. (R-13)
- [ ] M8.5 Full manual QA matrix (08 §4) + beta via TestFlight/Play internal/web staging.
- [ ] M8.6 Store assets, privacy labels, privacy policy page, age gate copy. (06 §6)
- [ ] M8.7 Release gates (08 §6) all green → tag `v1.0.0`.

---

## Phase 2 backlog (do not start before v1.0.0 is tagged)

- AI planner (brain dump → editable proposal → add all), with history. (Play complaints: no recall, no edit-before-add)
- Habit history/streaks, analytics, energy-based suggestions.
- Pro tier: themes, icon packs, AI, analytics. Core free forever; honour lifetime purchases. (R-18)
- Apple Watch app + complications; Live Activities; Shortcuts/App Intents; Android Quick Settings tile.
- Shared schedules / read-only share links.
- Apple CalDAV on web; Reminders import; duplicate-day templates library.
- HttpOnly-cookie session proxy for web (ADR-0003 follow-up).
