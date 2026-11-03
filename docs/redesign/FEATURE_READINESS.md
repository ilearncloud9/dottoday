# Feature readiness (Prompt A)

Audit of `redesign/design-lab` at `7ee9a359` (code identical to `main` `4dd92b35`), 2026-11-02. **Audit only: no app code was changed.**

## How this was checked

- Five read-only code audits by area, each reading the implementation and its tests rather than the plan checkboxes: timeline and replanning; capture and editing; mornings, alarms and sounds; data, sync and calendars; settings, onboarding and system surfaces. The five areas are summarised in the tables below.
- Claude re-read the code behind the four most serious findings itself (marked **S**).
- Nothing was run beyond the Step 1.3 baseline (6,021 tests passing; four Supabase tests not run). Device integration tests exist, but there is no pass record for them, so anything that needs real hardware is marked **unverified on device**.
- Confidence labels: **V** = an auditor read the code path and its tests; **S** = spot-checked by Claude; **I** = inferred from names or a grep. Paths are relative to `app/` unless they start with `docs/` or `supabase/`.

Status words: **working** = implemented, reachable from the UI, and tested. **partial** = code exists but a piece is missing or unwired. **buggy** = a confirmed defect. **experimental** = behind a flag or dev-only. **planned** = in docs only. **owner** = needs an owner decision.

## Headline

1. **The product is substantially built.** Almost every feature in the PRD and the standout roadmap exists in code, is wired to a reachable entry, and has tests. `lib/` has no TODO/FIXME/HACK markers, and free/Pro gates nothing (`lib/domain/entitlements/entitlements.dart`: `isPro => true`, no callers).
2. **What isn't proven is device behaviour.** Alarms, AlarmKit, Doze, widgets, Live Activity, controls, the share extensions, sensors and service-worker offline all depend on native code that has no native unit tests and no recorded device run.
3. **Three defects should be fixed before migrating the UI**, because a redesign would build on them (§ Stabilise first). The most serious is a sync pull stall that can silently stop changes arriving.
4. **The owner's complaints are supported by the code.** Settings has 43–47 rows in 8 sections, with 14 settings reachable from two or more places. Brain dump, Pick one thing and turning on Low-energy mode are reachable only from Today ⋯. The day review exists in three forms, Month in two, and the test-alarm card is built three times.
5. **No tablet-specific UI exists.** Layout depends only on width (rail at ≥ 600 px; Week and the Inbox sidebar at ≥ 840 px). Settings and onboarding are one centred column at every width, with no two-pane view. iPad is treated as an iPhone for alarms and Siri.

## Status by area

### Today, timeline and replanning

| Feature | Status | Evidence | Conf. |
|---|---|---|---|
| Today `/today`, `/day/:date`, DayPager (±365 days), week strip, month pull-open | working | `lib/features/timeline/today_screen.dart`, `lib/shared/dot/day_pager.dart`, `week_strip.dart`, `widgets/today_month.dart` | V |
| `/day/:date` date handling | **buggy (impact unverified)** | `parseRouteDate` returns `DateTime.utc` (`lib/core/router/app_routes.dart:114`). `todayDate` returns a local `DateTime` (`state/timeline_providers.dart:22`). `d == today` (`today_screen.dart:65`) is therefore never true for a deep-linked date, and dates more than 365 days away are not range-checked | S |
| Month `/month`, Week `/week` | working | `month_screen.dart`, `week_screen.dart`. Week is shown by **width** (expanded, `app_shell.dart:155`), so large iPads and Android tablets get it too, while `docs/10 §3` says Mac/web only. Week drag snaps to a hard-coded 15 min (`week/week_day_column.dart:64`) | V |
| Three-day spread, Inbox sidebar (expanded width) | working | `widgets/today_spread.dart`, `features/inbox/inbox_sidebar.dart` | V |
| Drag to move with overlaps, overlap knot, multi-select, selection bar | working | `widgets/day_drag.dart`, `shared/dot/thread_drag.dart`, `overlap_knot.dart`, `thread_select.dart` | V |
| Shift the rest, shift followers on drag, pinned blocks, snapping setting | working | `widgets/day_actions.dart:114`, `domain/scheduling/move_with_followers.dart`, `thread_day.dart:222` | V |
| Running late +5/+15/+30 | working | `widgets/running_late_sheet.dart`, `domain/scheduling/running_late.dart` | V |
| Insert-bump on Add | partial | `InsertPolicy` exists (`day_scheduler_service.dart:114`), but Add never bumps; `fitNextGap` and `overlap` have no UI caller | V |
| Snooze shifts followers (PRD F6.4) | **owner** | Snooze only re-reminds (`lib/data/notifications/notification_responder.dart:22`), which contradicts `docs/02-prd.md:204` | V |
| Now-marker, LiveRow → Focus, done circle + Undo, "tasks before Wake Up" fold, reality thread | working | `thread_axis.dart`, `live_row.dart`, `done_circle.dart`, `thread_outside.dart`, `state/reality_thread.dart` | V (now-marker: goldens only) |
| Today ⋯ menu: all 10 items wired | working | `widgets/today_menu.dart`. "Review the day" and "Routines…" are not tested through the menu | V |
| Minimal mode on Today | working | `domain/layout/layout_policy.dart`, `data/layout/layout_providers.dart`, `test/minimal_mode/*` | V |
| Adaptive shell (pill bar / Material bar / rail) | working | `shared/navigation/dot_shell.dart:99`, `core/theme/dot_metrics.dart:231`. Layout never branches on `Platform.isX` | V |

### Capture, editing and thinking help

| Feature | Status | Evidence | Conf. |
|---|---|---|---|
| Quick Add with natural-language time, colour/icon guess, Inbox | working | `features/task_editor/add/*`, `domain/quick_add/quick_add_parser.dart` | V |
| Paste a list, Add another, duration chips, typed time 12/24 h | working | `add_save.dart`, `shared/duration/*`, `shared/time_input/*` | V |
| Paste a list in **minimal** layout | working, different behaviour | Hands the lines to Brain dump (a proposal) instead of writing directly (`add_flow_sheet.dart:246`). Same gesture, two results | V |
| Task sheet + `/task/:id` | **buggy** | The **Move** tile has no `onTap` (`features/timeline/widgets/sheet_actions.dart:129`), so it always renders disabled (`_Tile`: `enabled = onTap != null`) | S |
| Editor (title, time, colour, icon, duration, pin, energy, notes with links, subtasks per occurrence, repeat with "this one or all future", up to 5 alerts, travel buffer) | working | `features/timeline/editor/*` (not `features/task_editor`), `shared/pickers/*`, `domain/recurrence/*`. Autosave flushes on dispose | V |
| Icon library (≈ 525 icons) | working | `core/theme/task_icons.gen.dart`, `shared/pickers/task_icon_picker.dart`. Golden test only; the picker's behaviour is untested | I |
| Inbox, Inbox → timeline in 2 taps | working | `features/inbox/*`, `widgets/schedule_sheet.dart` | V |
| Brain dump, typed and spoken (on-device) | working | `features/timeline/brain_dump/*`, `data/speech/*`, `ios/Runner/SpeechBridge.swift`, Android `SpeechBridge.kt`. Web mic only on Chrome/Edge. Text is lost if the sheet is dismissed before "Plan it" | V |
| ThinkingService on-device, AI status, rules fallback | working | `domain/thinking/*`, `data/thinking/*`, `ios/Runner/ThinkingBridge.swift` (iOS/macOS 26+), Android ML Kit `genai-prompt` (beta) | V |
| Cloud AI backend | owner (stub) | `RemoteThinkingBackend` interface with `ThinkingFlags.remoteBackends = false`; no implementation | V |
| ProposalSheet, nothing written before Accept | working | `shared/proposals/proposal_sheet.dart`, `features/proposals/proposal_host.dart`, `data/proposals/proposal_acceptor.dart`, tested in 7 flows | V |
| Break it down, Smallest step, Unstick, Rebalance | working | `features/task_editor/breakdown/*`, `state/day_cues.dart`, `state/rebalance_flow.dart`. Smallest step, Unstick and Rebalance appear only when triggered, with no manual entry | V |
| Routines (save from selection, drop on a day) | working | `features/routines/*`, `selection_commands.dart:109`. Lives under the Settings route | V |
| Focus `/focus/:id` | working | `features/focus/*`. No Focus action in the task sheet. Deep-work mode is Android only | V |
| Pick today's one thing, Low-energy mode | working | `timeline/one_thing/*`, `timeline/low_energy/*` | V |

### Mornings, nights, alarms and sounds

| Feature | Status | Evidence | Conf. |
|---|---|---|---|
| Day shape (Wake Up/Wind Down slider), different days, sleep target, Wind Down from tomorrow's first dot, learn offer, night on the day dot | working | `shared/dot/day_shape_slider.dart`, `domain/time/*`, `domain/wake_up/wind_down_learn.dart`. The night arc has no direct test | V |
| Wake Up alarm, iPhone (AlarmKit iOS 26+; notification fallback iOS 16–25) | working, **unverified on device** | `ios/Runner/AlarmBridge.swift`, `ios/Shared/WakeUpAlarmKit.swift`, `lib/data/notifications/os_alarm_gateway.dart`. No Swift tests | V |
| Wake Up alarm, Android (`setAlarmClock`, full-screen activity, boot re-arm) | working, **unverified on device** | `android/.../alarms/*`, `integration_test/wake_up_alarm_test.dart`. No Kotlin tests | V |
| Wake Up on Mac/web | working (fallback) | `alarmCapabilities` returns `notAPhone`: notification only, on-screen missions only | V |
| Snooze, Wake Up card `/wake-up`, Wake Up Check | working | `wake_up/wake_up_card_screen.dart`, `WakeUpChecks.kt`, notification in `WakeUpAlarmKit.swift` | V |
| Missions: stand up, walk, light (sensors) | working, **unverified on device** | `data/wake_up/channel_mission_sensors.dart`, `ios/Runner/MissionSensors.swift` (iPhone Light uses the camera), `MissionSensors.kt` | V |
| Missions: breathe, catch the dot, one thing; "Can't right now" hold | working | `features/timeline/wake_up/mission/*` | V |
| Wind Down review `/review` | working | `review/day_review_screen.dart`. No widget test for the route itself | V |
| Notifications: occurrence-keyed and idempotent, lead time, up to 5 alerts, health page, test alarm | working | `domain/notifications/notification_id.dart`, `data/notifications/notification_sync.dart:73`, `domain/validation/field_rules.dart:18` | V |
| iOS pending-notification cap (budget of 50, earliest kept) | working, with a known weakness | `notification_planner.dart:33,197`. The cut keeps the earliest 50, not the alarm-grade ones first | V |
| Web push | partial | `web/sw.js`, `supabase/functions/send-push`. The cron that sends due pushes (`supabase/snippets/send_push_cron.sql`) is gitignored and not in the repo, so delivery with the tab closed depends on an undocumented owner step | V |
| Sounds (58 entries, per-dot, Start sound) | working | `domain/notifications/sound_catalogue.gen.dart`, `features/settings/pages/sounds_page.dart` | V |
| Android time-zone change while the app is closed | **risk (inferred)** | `TimeChangeReceiver.kt` re-plans through a background engine that can't reach `dottoday/alarm`, so Wake Up likely rings at the old zone's time until the app opens | I |

### Data, sync, accounts and calendars

| Feature | Status | Evidence | Conf. |
|---|---|---|---|
| Local DB schema v16, idempotent migrations, pre-migration snapshot (native) | working | `lib/data/db/app_database.dart`, `connection/pre_migration_snapshot.dart`. Web takes no snapshot; there is no drift schema dump | V |
| SQLCipher key (secure storage / web IndexedDB vault), DB recovery screen | working | `database_key_store.dart`, `web/key_vault.dart`, `features/recovery/database_recovery.dart` | V |
| UUID v7 IDs, deterministic occurrence IDs, UTC epoch ms + IANA zone | working | `core/ids/id_generator.dart`, `domain/recurrence/instance_ids.dart` | V |
| Sync push/pull, per-field HLC, tombstones, conflicts, status UI | **buggy (stall)** | See Stabilise first #1. `data/sync/sync_engine.dart:122-152`, `supabase_sync_gateway.dart:35-38`, `supabase/migrations/0001_init.sql:10` | S |
| Event-driven sync (no polling), OS background sync | working | `engine_sync_service.dart`, `realtime_nudges.dart`, `background_sync.dart`. The plan item for this is open, but the code agrees with it | V |
| Accounts (Apple, Google, magic link, PKCE), sign out everywhere, delete account, app lock | working; needs hosted provider config | `data/auth/supabase_account_service.dart`, `features/settings/pages/account_page.dart` (`features/auth` is empty), `features/lock/*`. No app lock on web | V |
| Local backups and restore, export JSON/CSV/ICS and import, Trash (30 days), Undo/Redo | working | `data/backup/*`, `domain/export/*`, `data/trash/*`, `data/undo/*` (UI is in Settings; `features/export` is empty). Undo is memory-only by design | V |
| Device calendars import and write-back | working | `data/calendar/*`. Not available on web | V |
| Google/Microsoft calendars | working; owner-gated deploy | `supabase/functions/calendar-oauth`, `calendar-sync` | I |
| Repeating calendar events as one series | working | `calendar_series_*.dart`, schema v13 | V/I |
| Calendar change webhooks | planned (owner gate) | No code in `supabase/functions/*` | V |
| Supabase: 13 migrations, RLS on every table, 4 edge functions, pgTAP tests | working | `supabase/migrations/*`, `supabase/tests/*` | V |

### Settings, onboarding, search, reflection and system surfaces

| Feature | Status | Evidence | Conf. |
|---|---|---|---|
| Settings, full layout: 43–47 rows in 8 sections | working, **owner complaint confirmed** | `features/settings/settings_screen.dart` (`settingsGroups`). Duplicates are listed in `FEATURE_PARITY_MATRIX.md` § Duplicates | V |
| Settings, minimal: 9 rows (doc says 8), plus Everything else | working | `minimal_settings.dart`, `pages/everything_page.dart` | V |
| Settings sub-pages (13) | working | `pages/*`. `/settings/siri` has no platform guard. Two different Wake Up settings are both labelled "After" | V |
| Onboarding (step 0 + O1–O6, test alarm; full 7 steps, minimal 5) | working | `features/onboarding/*`, `integration_test/onboarding_test.dart` | V |
| Search with completed history, Past days, year strip | working | `features/search/*`, `domain/review/journal.dart` | V |
| Day review (sheet + page + prompt), weekly review + share, learning reveal, tips and hints | working | `timeline/widgets/day_review.dart`, `timeline/review/*`, `domain/reveal/*`, `domain/tips/*` | V |
| iOS widgets, Live Activity, Controls, App Intents/Siri | working, **unverified on device** (intents: tested) | `ios/DottodayWidgets/*`, `ios/Shared/*`, `lib/data/widgets`, `lib/data/live_activity` (`features/widgets_home` is empty) | V/I |
| Android widgets, ongoing notification, Quick Settings tiles, static shortcuts | working, **unverified on device** | `android/.../widgets/*`, `OngoingDot.kt`, `DotTiles.kt`. No Kotlin tests | V/I |
| Share extension (iOS, macOS, Android); no web share target (owner choice) | working, **unverified on device** for iOS/macOS | `ios/DottodayShare`, `macos/DottodayShare`, `ShareIntake.kt` | V |
| macOS menu bar, app menus, keyboard shortcuts | working | `macos/Runner/DayDotStatusItem.swift`, `app_menu.dart`, `core/shortcuts/app_shortcuts.dart` | V |
| Web PWA (install banner, service worker, tab dot) | partial | `lib/data/pwa/*`, `web/sw.js`. Offline behaviour has no automated browser test | I |
| Deep links (`dottoday://` only, no universal links) | working | `core/router/deep_link_guard.dart`, `native_deep_links.dart` | V |
| Feedback (`mailto:`), What's new banner | working | `widgets/feedback_sheet.dart`, `whats_new_banner.dart` | V |
| Localisation en/de/fr/es (2,134 keys each), no RTL | working | `core/l10n/arb`, `l10n_parity_test.dart` | V |

## Recommendations (playbook categories)

### (a) Stabilise before UI migration

These sit under the screens the redesign will rebuild. Fix each on `main` through the normal PR flow, then merge it in and log it in `SYNC_LOG.md` (decision 4).

1. **Sync pull stall (data loss risk, S).**
   - How it happens: pull pages 500 rows with `gte(updated_at)` ordered by `updated_at, id`. If a full page's rows all share the cursor's instant, the loop stops and saves the same cursor (`sync_engine.dart:150`). The server stamps `updated_at := now()`, which is one instant per transaction.
   - Effect: once 500+ rows of one table come from a single transaction, that table never pulls again, and later changes from other devices silently stop arriving.
   - Why tests miss it: the test fake gives every row a unique timestamp (`test/support/fake_sync_server.dart`).
   - Confidence: confirmed by reading the code, not reproduced.
2. **Task sheet Move tile is dead (S).** It's a visible control that can never be used.
3. **`/day/:date` UTC vs local mismatch and no range check (S).** It affects deep links, Wake Up, widgets and any new navigation the redesign adds. The user-visible effect is unverified.
4. **Stale-ID taps (I).** `firstWhere` in `widgets/day_actions.dart:42` and `_find(pin)!` in `widgets/day_drag.dart:208` throw if a task disappears between render and tap, for example after a sync update.
5. **Android time-zone change re-plan for Wake Up (I).** Verify on a device first, then fix if confirmed.

### (b) Design now, build later

- **Circular Wake Up / Wind Down dial (owner P5).** Today's model can't express a Wind Down after midnight: `DayShape.on` puts both ends on the same date, and windows end by 23:59 (`docs/05`). A dial that crosses midnight needs a domain change first. Keep the save-on-release behaviour so one drag stays one settings write and one alarm re-sync.
- **Mission screens (owner P7).** Redesign their visuals and motion, but keep the `keepMission` timer (or the alarm rings again), the route kinds (`app_routes.dart` `missionKinds`, `deep_link_guard.dart`) and the minimal-mode variant.
- **Tablet two-pane layouts for Settings, Inbox and the task editor.** None exist; only shortlisted concepts need them (Q7).

### (c) Complete after the design system is selected

- **Settings regrouping (P1):** 14 duplicated paths and two "After" labels.
- **Today ⋯ menu split (P3):** give Brain dump, Routines, Pick one thing and Low-energy primary homes.
- **Consolidate duplicates (P4):**
  - the day review (sheet, page, prompt)
  - Month (pull-open and route)
  - the test-alarm card (3 builds)
  - two Today headers
  - two capture fields
  - three Inbox scheduling sheets
  - Everything else repeating the full Settings tree
  - "This week" (review) vs the Week tab
- **Missing tests to add with each migrated screen:** menu paths for Review and Routines; `DayReviewScreen`; the icon and travel pickers; snapping on drop; the now-marker; the night arc.

### (d) Leave out of the redesign until the owner decides

See `OPEN_PRODUCT_DECISIONS.md`: snooze shifting followers, insert-bump on Add, the cloud AI backend, the merge behaviour when switching accounts, web-push delivery, Week on tablets, calendar webhooks, and Phase 2.

## Fragile domain dependencies (do not change in the redesign)

| Area | Keep stable | Where |
|---|---|---|
| IDs | UUID v7, deterministic occurrence and subtask IDs | `core/ids/id_generator.dart`, `domain/recurrence/instance_ids.dart` |
| Local schema | v16 tables, backup DB v1 | `data/db/app_database.dart`, `data/db/tables/*`, `data/backup/backup_database.dart` |
| Sync contract | `syncedEntities`, `pushableColumns`, `sync_push` RPC, Realtime channel `dottoday-sync`, `field_versions`, settings JSON validated server-side | `data/sync/server_columns.dart`, `supabase/migrations/0010_minimal_mode.sql` |
| Export | JSON v1 format | `domain/export/export_bundle.dart` |
| Secure storage | `db-cipher-v1`, `dottoday.auth.session`, `dottoday-keyvault`, `dottoday-db-generation` | `data/db/database_key_store.dart`, `data/auth/session_storage.dart`, `data/db/web/*` |
| `local_meta` keys testers already have | `app_lock`, `sync_account`, `hlc_*`, `onboarding`, `whats_new_seen`, `armed_wake_ups`, `tip_*`, `learning_*`, `thinking_*`, `brain_dumps`, and others | `data/db` (full list in the audit notes) |
| Routes | `SettingsPage` names are URL paths; `dottoday://auth-callback` and `dottoday://settings/calendars` are on the OAuth allow-list; mission kinds | `core/router/app_routes.dart` |
| Notification IDs | FNV-1a of `occurrence#alertIndex` | `domain/notifications/notification_id.dart` |
| Layout policy | `FeatureId.docRow` must match `docs/14 §3` word for word (policy test) | `domain/layout/` |

**Interaction contracts a redesign can easily break:**
- Long-press both lifts a drag and selects. The drag must coexist with page swipes, week-strip hover-paging, drop targets and auto-scroll.
- The ShiftChip is an `OverlayEntry`.
- Row height is derived from duration, and drop spans depend on it.
- CustomPainters are visual only, so hit areas and semantics live on the row widgets.
- About 730 timeline, dot and minimal goldens will need re-recording.

## Shared-service and test-safety risks

- `test/supabase/local_supabase.dart` reads `SUPABASE_URL`, `SUPABASE_ANON_KEY` and `SUPABASE_SERVICE_ROLE_KEY` from the environment. A shell with hosted values exported would create and delete users on the **hosted** project.
- `tool/device_tests.sh` builds with `--dart-define-from-file=.env`, so device tests reach whatever project `app/.env` names. That file wasn't read in this audit.
- `tool/sync/realtime_live_check_test.dart` is hard-coded to the shared local stack (`127.0.0.1:54321`).
- The Supabase tests leave users behind, and `supabase db reset` would wipe the other worktree's local data. This feeds the open item for an isolated test stack.

## Data-loss risks

- The sync pull stall (above).
- Signing into a second account uploads everything on the device, including the first account's data (`data/sync/account_adoption.dart` `requeueAll`).
- Restore replaces settings and soft-deletes rows not in the backup, and that syncs to every device. A safety backup is taken first.
- Server tombstones are purged after 30 days, so a device offline longer than that may bring deleted rows back (I).
- Web takes no pre-migration snapshot.
- Brain dump text is lost if the sheet is dismissed before "Plan it". Closing the Add sheet discards the draft, which is deliberate and tested.

## Documentation inconsistencies

| # | Finding | Evidence | Suggested fix (not applied; decision 12) |
|---|---|---|---|
| D1 | **Wake Up status is stale in doc 15.** `docs/15-wake-up.md §0` still says "proposed (needs ADR-0017)". ADR-0017 is *Accepted, 2026-10-31, built in M17.1–M17.2*, and doc 15 was edited twice on 2026-11-02 without updating the line. Its §1 checkboxes are also unticked | `git log` of both files: 448c5b74, 82fcec79, 8992201a, a867037a | Status line: "accepted (ADR-0017, 2026-10-31); W1–W6 built in M17.1–M17.7; open: real-device gates (08 §6.1 C)" |
| D2 | **Two ADRs numbered 0015** | `docs/adr/0015-reminder-sounds.md`, `0015-structured-style-day-thread.md` (both Accepted 2026-10-30) | Renumber one, or use 0015a/0015b |
| D3 | Week is documented as Mac/web only but is gated by width, so tablets get it | `docs/10 §3`, `app_shell.dart:155` | Decide in OPEN_PRODUCT_DECISIONS Q5 |
| D4 | Minimal Settings "eight rows" vs 9 in code | `minimal_settings.dart` | Correct the doc comment or the row |
| D5 | PRD F6.4 "snooze shifts followers" isn't built, and the code comment says it's intended | `docs/02-prd.md:204`, `notification_responder.dart:22` | Owner decision Q1 |
| D6 | `maxAlerts = 5` is defined twice | `domain/validation/field_rules.dart:18`, `shared/pickers/alerts/alerts_editor.dart:11` | Use one source |
| D7 | `siriAvailable` is true on iPad while its comment says iPhone only; iPad is mapped to `iphone` for alarms | `data/notifications/health_providers.dart:15` | Decide in OPEN_PRODUCT_DECISIONS Q6 |
