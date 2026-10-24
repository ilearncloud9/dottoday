# 08 — Testing & QA

## 1. Test pyramid
- **Unit (domain)**: target ≥ 90 % line coverage. Recurrence, scheduler, parser, notification planner, conflict resolver, validators. Property-based tests with `glados` or hand-rolled generators for scheduler invariants.
- **Repository/sync**: in-memory Drift + fake Supabase gateway; test push/pull/conflict/tombstone paths and "server error never deletes local".
- **Widget**: every screen's states (empty/loading/error/offline); semantics tests (labels exist, focus order, tap targets ≥ 44).
- **Golden**: timeline at 100 %/200 % text scale, light/dark, 0/1/30/200 blocks, bottom-of-day rendering (R-14), overlap columns.
- **Integration** (`integration_test`): onboarding → quick add → drag with shift-followers → recurrence edit scopes → offline edit → reconnect sync → export/import round-trip.
- **RLS** (pgTAP in `supabase/tests`): user A cannot read/write/delete user B's rows for each table; `sync_push` ignores spoofed `user_id`.
- **Performance**: `flutter drive --profile` timeline scroll with 200 blocks; frame build < 16 ms p95 on a mid-range Android.

## 2. Critical test cases (must exist, named as below)
- `recurrence_expander_test`: monthly on the 31st, Feb 29 yearly, DST spring-forward 02:30 Europe/Berlin, DST fall-back duplicate hour, `UNTIL` in another zone, `COUNT` with exceptions.
- `day_scheduler_test`: pinned never moves; shift stops at pinned and reports partial; calendar excluded by default; running-late skips done blocks; insert bump preserves gaps; no overlaps unless allowed.
- `quick_add_parser_test`: "7am", "19:00", "noon", "tmrw 3pm 45m", "every mon,wed 6pm gym", "@inbox call mom", German "morgen 15 Uhr", 12/24-h locale switch, garbage input stays title.
- `notification_planner_test`: exactly one pending per (occurrence, alert); edit reschedules; delete cancels; quiet hours; 64-limit windowing on iOS.
- `sync_engine_test`: offline queue replay order; LWW per field; same-field-within-60s creates conflict; tombstone restore; server 500 leaves local intact.
- `time_input_test`: AM/PM edge (12:00 AM/PM), typing "930" → 09:30, locale separators, never changes the date (R-20).
- `subtask_occurrence_test`: completing subtasks on today's occurrence never affects tomorrow's (R-09).
- `export_import_test`: round trip equals original; import rejects oversize and bad schema; backup taken before import.

## 3. Accessibility QA (each milestone)
- Automated: semantics tests; `flutter_a11y` style checks; axe-core on web build.
- Manual (release): VoiceOver on iOS, TalkBack on Android, VoiceOver on macOS, NVDA/Chrome on web — complete the core flow (add, move, complete, edit recurrence) with screen reader only. 200 % text; reduced motion; keyboard only on desktop/web.

## 4. Manual QA matrix (release)
Devices: iPhone SE (small), iPhone 15 Pro, Pixel 6a, Samsung A-series (One UI), iPad (compat), MacBook Intel + Apple Silicon, Chrome/Safari/Firefox desktop, Safari iOS PWA.
Scenarios: fresh install; upgrade with data; offline for a day then sync; two devices editing same task; time-zone change; calendar permission denied; notification permission denied; low storage; 1 000 tasks.

## 5. Beta
TestFlight + Play internal track + web staging. Collect: crash-free rate, sync error rate, notification delivery (self-reported "did it fire?" prompt once), feedback form.

## 5b. Running device tests (M6.5.12)
Always through `app/tool/device_tests.sh android|ios [device] [test …]` (and `tool/killed_app_check.sh` for the killed-app check), never a bare `flutter test integration_test`: each test is built with its own entry, installed as an update, every permission is answered up front (Android `pm grant` POST_NOTIFICATIONS + `appops` SCHEDULE_EXACT_ALARM; iOS provisional authorisation, which never prompts — `integration_test/support/no_dialog_notifications.dart`), then run with `flutter drive --use-application-binary`. A run over 15 minutes fails with TIMEOUT; every run's full log is in `app/build/device_logs/<platform>_<test>.log`. Why: `flutter test` reinstalls (new uid, grants lost) and force-stops the app, and a system dialog can stall a run for an hour (found in M6.5.12). `thread_perf` is excluded: it needs `flutter drive --profile --no-dds` on physical hardware (M5.9b).

## 6. Release gates (all must pass)

Grouped by who does them. Collected from the M5/M6 readiness notes in `09-implementation-plan.md` and the roadmap (M6.5–M12). Status is reported at every milestone close and in full at M12.6.

### 6.1 Owner (accounts, money, consoles, hardware)
- [ ] **Apple paid developer account** (Personal Team today): unlocks the App Group (widgets and Live Activity on a device, `DaySnapshot` sharing), the time-sensitive entitlement in Release, associated domains, TestFlight. Mac signing team JBHAWSBYLG.
- [ ] **Bundle IDs** registered on that account (app, `DottodayWidgets` extension, App Group id) and Play application id.
- [ ] **Google Play Console**: app created, internal track; declarations for `SCHEDULE_EXACT_ALARM` (M5.6) and `USE_FULL_SCREEN_INTENT` (M6.5.5); data-safety form.
- [ ] **Supabase project** (`pmwgtwosihtcvfrzvobu`): schema pushed — 0001–0003 done 2026-10-23 (M6.0), later migrations (0004 M6.5.1, 0005 M10.7, routines M11.4) need the owner's go per push; deploy Edge Functions `delete-account`, `send-push`; secrets `RESEND_API_KEY`, `ACCOUNT_MAIL_FROM`, VAPID keys; the push cron (`supabase/snippets/`); Auth redirect URLs.
- [ ] **OAuth consoles**: Apple Services ID + key for Sign in with Apple; Google OAuth client; both redirect URLs (M6.1). Google/Microsoft calendar OAuth clients (M7.4).
- [ ] **Domain**: web hosting with the CSP headers (M5.7), `apple-app-site-association` / `assetlinks.json` (templates in `app/tool/well_known/`), privacy policy page.
- [ ] **`.env.prod` values**: `SUPABASE_URL`, `SUPABASE_ANON_KEY`, `SENTRY_DSN` (Sentry project), `FEEDBACK_EMAIL` (a monitored inbox), `WEB_PUSH_VAPID_PUBLIC_KEY`.
- [ ] **App icons** and store assets (screenshots from the sweep can seed them).
- [ ] Verify **time-sensitive delivery on a real iPhone** (locked phone, app killed, Focus on) — M6.5.4.
- [ ] With the paid team: add `com.apple.developer.usernotifications.time-sensitive` to `macos/Runner/Release.entitlements` (left out because the Personal Team can't provision it and a local Mac Release build fails without a profile) and flip the macOS case in `test/policy/time_sensitive_entitlement_test.dart` — M6.5.4.
- [ ] **Live Activity on a real iPhone** (lock screen + Dynamic Island, Done / +15 work) — M9.3.
- [ ] The test alarm from onboarding rings on your own iPhone and Android phone with the app killed (M6.5.9).
- [ ] Hardware passes needing your devices: VoiceOver on an iPhone and a Mac, TalkBack on an Android phone, through onboarding, Today, Add, the task sheet, Settings › Privacy, the travel banner, Focus and the proposal sheets (the simulator has no VoiceOver; `adb` swipes don't drive TalkBack); the manual QA matrix (§4) on physical devices (M8.5).
- [ ] Beta: crash-free ≥ 99.5 % over the last TestFlight / Play internal build (needs the accounts above).

### 6.2 Agent (everything else)
- [ ] CI green: analyze, format, unit, widget, golden, integration (Android), RLS, policy tests (no-shame, surface contract, single notification import, manifest permissions, Release-only time-sensitive entitlement).
- [ ] RLS tests green against the hosted project after each owner push (`tool/hosted_rls_test.sh`).
- [ ] Platform parity checklist (`docs/parity-checklist.md` generated from PRD feature list) all ✓ on iOS, Android, macOS, Web.
- [ ] Accessibility automated pass on all four (08 §3) and labels/roles/targets from the accessibility trees on simulators.
- [ ] Offline day scenario and two-device conflict scenario pass.
- [ ] Notification exactness: 20 scheduled alerts, 20 fired, 0 duplicates, on the iOS simulator and Android emulator; a dot-start fires with the app killed (M6.5.10).
- [ ] Every proposal flow has its nothing-written-before-Accept test (M10–M12).
- [ ] Security checklist (06 §9) signed off.
- [ ] CHANGELOG and in-app "What's new" updated.
- [ ] Manual (desktop Chrome, notifications allowed): a reminder posts as a system notification through `sw.js`; its Done ticks the task and Open shows it, also when the tab was closed (the built-in test browser blocks service workers — run in real Chrome).
- [ ] Manual (Mac): View › Enter Full Screen — the rail and Today lay out with no title bar; the menu-bar dot stays.
- [ ] Manual: ⌘/ (Ctrl+/ on Windows/Linux) opens the shortcut list in real desktop Chrome.
- [ ] Manual (iOS simulator and Android emulator, at M7.7): Settings › Calendars › Connect shows the system prompt with the usage text; allowed lists the device's calendars; denied shows "Calendar access is off" and Open settings lands on Dottoday's page (iOS) — M7.1.
- [ ] Manual (this Mac, needs a person at the system prompt): Settings › Calendars › Connect shows the macOS prompt with the usage text; allowed lists the Mac's calendars by account with colours, and `flutter test integration_test/mac_calendar_bridge_test.dart -d macos` then also reads a week of events; denied shows the notice and Open settings lands on Privacy & Security › Calendars — M7.1b. (Run on 2026-10-24: bridge answers, status `notAsked`; the allow/deny path is this gate.)
- [ ] Manual (iOS simulator, Android emulator and this Mac, at M7.7, calendars allowed): an event in the device's Calendar app appears on Today in its calendar's colour within a resume; a repeating event shows on each day; moving it in Calendar moves it here and keeps a subtask added here; deleting it there removes it here (or puts it in Trash when it has a subtask); switching its calendar off removes its events; a link in its notes opens the browser — M7.2.
- [ ] Manual (real desktop Chrome): on a fresh load the first Tab shows "Skip to content" and Enter moves focus past the rail.

## 7. Design-review matrix (Concept A, docs/10 §7)
Every UI component and screen has goldens for each cell of: light / dark × compact 390 / medium 700 /
expanded 1280 × 1× / 2× (`test/support/dot_golden.dart` `goldenMatrix`). Components that exist only
from a width class up (Mac/web Week, Month) list their widths; chrome idioms (iPhone pill bar vs
Material bar) run as separate entries. Goldens are verified on the macOS CI runner and never blessed
in CI.

The **reference sheet** puts each golden beside the matching crop of its render in
`docs/design-references/png/`, at the same pixels per point
(`test/reference_sheet/reference_entries.dart`). Run
`REFERENCE_SHEET=1 flutter test --tags reference-sheet`; CI uploads it as the `reference-sheet`
artifact. It is a review aid, not a pass/fail gate: pixel-equality with HTML renders is not
achievable (different text engines), so differences are judged against the docs/10 contract,
with spacing allowed within ±4 px (CLAUDE.md §11).

Since the M3c follow-up the golden frame wraps the root navigator, so a golden's `act` can open a
sheet, popover or menu and it is captured at every width. Browser-only widget tests (`@TestOn('browser')`,
tag `web`) run in CI with `flutter test --platform chrome --tags web test/web`.

Sweep entries (add a row per screen as it lands):

| Component / screen | Golden test | Reference |
|---|---|---|
| Tokens | `test/core/theme/dot_theme_golden_test.dart` | §2 |
| DotIcons | `test/core/theme/dot_icons_golden_test.dart` | §3 icon set |
| TaskDot | `test/shared/dot/task_dot_golden_test.dart` | `Main` |
| Thread / TaskRow / LiveRow | `test/shared/dot/thread_golden_test.dart` | `Main`, `A-android-today` |
| DayDot / WeekStrip | `test/shared/dot/week_strip_golden_test.dart` | `Main` |
| DayCard / DayPager | `test/shared/dot/day_card_golden_test.dart` | `Main`, `A-android-today` |
| MonthGrid | `test/shared/dot/month_grid_golden_test.dart` | `A-ios-today-month`, `A-ios-future-month`, `A-mac-month` |
| Shells | `test/shared/navigation/dot_shell_golden_test.dart` | `Main`, `A-android-today`, `A-mac-today-alt1-spread` |
| ColourIconBlock | `test/shared/dot/colour_icon_block_golden_test.dart` | `A-ios-add-what` |
| Shift chip | `test/shared/dot/shift_chip_golden_test.dart` | derived |
| Today T1/T2/T3, selecting | `test/features/timeline/today_golden_test.dart` | `Main`, `A-ios-today-month`, `A-ios-future-month` |
| Task sheet T4 | `test/features/timeline/task_sheet_golden_test.dart` | `A-ios-task-sheet` |
| Task sheet · LINKS (imported event) | `test/features/timeline/task_sheet_links_golden_test.dart` | derived |
| Phone editor E1 | `test/features/timeline/task_editor_golden_test.dart` | `A-mac-editor` (fields) |
| Inbox I1 + empty | `test/features/inbox/inbox_golden_test.dart` | `A-ios-inbox`, `A-android-inbox` |
| Add A1 What (+ Android idiom, no-habits) | `test/features/task_editor/add_golden_test.dart` | `A-ios-add-what`, `A-android-add-what` |
| Add A2 When + ThreadPicker (+ Android idiom) | `test/features/task_editor/add_golden_test.dart` | `A-ios-add-when`, `A-android-add-when` |
| Inbox · Pick a time | `test/features/inbox/inbox_golden_test.dart` | derived |
| Add A3 Duration sheet (+ Android idiom) | `test/features/task_editor/add_golden_test.dart` | `A-ios-add-duration`, `A-android-add-duration` |
| Add A4 Time ⋯ menu (+ Android idiom) | `test/features/task_editor/add_golden_test.dart` | `A-ios-add-time-menu`, `A-android-add-time-menu` |
| Add · paste "Add N tasks?" | `test/features/task_editor/add_golden_test.dart` | derived |
| A4 sub-pickers: Change day, week, time zone | `test/shared/pickers/pickers_golden_test.dart` | derived |
| A4 Type a time | `test/features/task_editor/type_time_golden_test.dart` | derived |
| Search S1 + empty + no results (+ Android idiom) | `test/features/search/search_golden_test.dart` | `A-ios-search`, `A-android-search`; empty/no-results derived |
| Settings P1 (+ Android idiom, lower half), Different days, Send feedback | `test/features/settings/settings_golden_test.dart` | `A-ios-settings`, `A-android-settings`; sheets derived |

