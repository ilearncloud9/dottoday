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

Calendar checks (M7.7): `calendar_prompt`, `calendar_denied`, `calendar_import`, `calendar_write_back`, `calendar_revoked` (Android also taps Try again) and, on iOS, `calendar_regranted`, run in that order. The script sets the calendar permission before each launch, never through the prompt (iOS `simctl privacy reset|revoke|grant`; Android `pm revoke|grant` plus `user-fixed` for "denied without a prompt"), because revoking ends a running app on both OSes and granting ends it on iOS. The tests write to a calendar of their own ("Dottoday QA", recreated each run) through `device_calendar`, standing in for the Calendar app. A test prints `DEVICE_SHOT <name>` for a screenshot (`build/device_shots/<platform>_<name>.png`), `DEVICE_AWAY <name>` before a tap that leaves the app (the script shoots and brings it back: a backgrounded app draws no frames and iOS suspends it), and `DEVICE_GRANT calendar`. `flutter drive` uninstalls the app when it stops it, so `calendar_write_back` and `calendar_revoked` keep it for the test after them. Not in CI: `flutter test` reinstalls the app, which drops the permission set up front.

## 6. Release gates (all must pass)

Grouped by who does them. Collected from the M5/M6 readiness notes in `09-implementation-plan.md` and the roadmap (M6.5–M12). Status is reported at every milestone close and in full at M12.6.

### 6.1 Owner (accounts, money, consoles, hardware)
- [ ] **Apple paid developer account** (Personal Team today): unlocks the App Group (widgets and Live Activity on a device, `DaySnapshot` sharing), the time-sensitive entitlement in Release, associated domains, TestFlight. Mac signing team JBHAWSBYLG.
- [ ] **Bundle IDs** registered on that account (app, `DottodayWidgets` extension, App Group id) and Play application id.
- [ ] **Google Play Console**: app created, internal track; declarations for `SCHEDULE_EXACT_ALARM` (M5.6) and `USE_FULL_SCREEN_INTENT` (M6.5.5); data-safety form.
- [ ] **Supabase project** (`pmwgtwosihtcvfrzvobu`): schema pushed — 0001–0003 done 2026-10-23 (M6.0), 0004 (M6.5.1), 0005 `calendar_oauth` 2026-10-24 (M7.4, pre-approved); later migrations (M10.7, routines M11.4) need the owner's go per push; deploy Edge Functions `delete-account`, `send-push`, `calendar-oauth`, `calendar-sync` (calendar secrets: the M7.4 item below); secrets `RESEND_API_KEY`, `ACCOUNT_MAIL_FROM`, VAPID keys; the push cron (`supabase/snippets/`); Auth redirect URLs.
- [ ] **OAuth consoles**: Apple Services ID + key for Sign in with Apple; Google OAuth client; both redirect URLs (M6.1). Google/Microsoft calendar OAuth clients (M7.4): the steps below.
- [ ] **Google and Microsoft calendars (M7.4, ADR-0011)**. The app holds no OAuth client. Both providers redirect only to the `calendar-oauth` Edge Function, which swaps the code and puts the refresh token in Vault. Until these steps are done, Connect says the server isn't set up (the `placeholder…` values count as unset).
  - **Redirect URIs** (the same on every platform, because the provider always returns to the function):
    - Hosted: `https://pmwgtwosihtcvfrzvobu.supabase.co/functions/v1/calendar-oauth/callback`
    - Local: `http://localhost:54321/functions/v1/calendar-oauth/callback`. It must match `CALENDAR_OAUTH_REDIRECT_URL` in `supabase/functions/.env`.
    - iOS, Android and macOS have no redirect URI and no OAuth client of their own. After the swap, the function sends the browser to `dottoday://settings/calendars` (the M5.0 scheme, already allow-listed).
    - Web: no redirect URI at the provider either. The function sends the tab back to `<web origin>/#/settings/calendars` only when that origin is in `CALENDAR_RETURN_ORIGINS` (for example `https://app.dottoday.app`, plus `http://localhost:8099` for local).
  - **Google Cloud** (console.cloud.google.com, project "Dottoday"):
    1. APIs & Services › Library: enable **Google Calendar API**.
    2. Google Auth Platform › Branding: app name Dottoday, support email, logo, home page, privacy policy and terms URLs. Authorized domains: your own domain. Google verification wants the redirect domain to be one you own, so if it rejects `supabase.co`, use a Supabase custom domain (paid) and change the redirect URIs to it.
    3. Audience: **External**. While the app is in Testing, add your Google accounts as test users. For launch, Publish and submit verification: both calendar scopes are sensitive and need the justification text, a demo video of Settings › Calendars › Connect, and the privacy policy.
    4. Data access › Add scopes: `openid`, `.../auth/userinfo.email`, `https://www.googleapis.com/auth/calendar.calendarlist.readonly`, `https://www.googleapis.com/auth/calendar.events`.
    5. Clients › Create client › **Web application**, named "Dottoday calendar". Authorized redirect URIs: the hosted and local URIs above. No JavaScript origins.
    6. Copy the client ID and secret into `GOOGLE_CALENDAR_CLIENT_ID` and `GOOGLE_CALENDAR_CLIENT_SECRET`.
  - **Microsoft Entra** (entra.microsoft.com › Identity › Applications › App registrations):
    1. New registration, named "Dottoday calendar". Supported account types: **any organizational directory and personal Microsoft accounts** (this is tenant `common`). Redirect URI: platform **Web**, the hosted URI. Register.
    2. Authentication: add the local URI as a second **Web** redirect. Leave implicit grant (access/ID tokens) unchecked.
    3. Certificates & secrets › New client secret (24 months at most). Copy its **Value** into `MICROSOFT_CALENDAR_CLIENT_SECRET` and diarise the expiry for rotation.
    4. API permissions › Add › Microsoft Graph › **Delegated**: `openid`, `email`, `offline_access`, `Calendars.ReadWrite` (keep the default `User.Read`). Users consent for themselves; organisations that block user consent grant it as admins.
    5. Branding & properties: logo, home page, terms and privacy URLs. Do **publisher verification** (a Microsoft AI Cloud Partner Program ID), otherwise users in many work tenants can't consent to a new multi-tenant app.
    6. Overview: copy the Application (client) ID into `MICROSOFT_CALENDAR_CLIENT_ID`. Set `MICROSOFT_CALENDAR_TENANT=common`.
  - **Supabase (hosted)**: Database › Extensions: `supabase_vault` is on (it is the default). `supabase secrets set GOOGLE_CALENDAR_CLIENT_ID=… GOOGLE_CALENDAR_CLIENT_SECRET=… MICROSOFT_CALENDAR_CLIENT_ID=… MICROSOFT_CALENDAR_CLIENT_SECRET=… MICROSOFT_CALENDAR_TENANT=common CALENDAR_RETURN_ORIGINS=https://<web origin>`. Leave `CALENDAR_OAUTH_REDIRECT_URL` unset on hosted: it defaults to the hosted URI. Then `supabase functions deploy calendar-oauth` (`verify_jwt = false` comes from `config.toml`: the provider's redirect carries no JWT, and the function checks the caller's JWT itself) and `supabase functions deploy calendar-sync`.
  - **Check on iPhone, Android, Mac and web**: Settings › Calendars › Connect Google Calendar leads to Google's consent and back to Calendars with the account listed, and its events appear on Today. With Send changes back on, dragging an event moves it in Google Calendar. Changing the same event in both places shows the clash banner. Disconnect asks first, then the events leave. Revoking access at myaccount.google.com/permissions shows Reconnect while the events stay. Then the same with an outlook.com account and a work account.
- [ ] **Calendars on this Mac (M7.1b–M7.6, from M7.7)**: needs a person at the macOS prompt (an agent may not answer it, and TCC can't be granted from a script). Settings › Calendars › Connect, Allow; then the §6.2 M7.1b row (`flutter test integration_test/mac_calendar_bridge_test.dart -d macos` reads a week of events), then by hand in Calendar.app and Dottoday: an event appears on Today in its calendar's colour after switching back to Dottoday; a repeating one on each day; moving it in Calendar moves it here and keeps a subtask added here; deleting it removes it (Trash with a subtask); switching its calendar off removes its events; with Send changes back on, a drag, a resize and a rename reach Calendar.app within seconds; a repeating event changes here only and the editor says so; a change on both sides shows the clash banner, Keep mine and Use calendar's do what they say; a shift with Calendar events too carries a one-off event and not a repeating one.
- [ ] **Calendars on a real iPhone (from M7.7)**: Settings › Calendars › Calendar access is off › Open settings lands on Dottoday's page in Settings (the iOS 26 simulator opens Settings' top level); with Send changes back on, moving an invitation (an iCloud or Exchange event with invitees) keeps its invitees in Calendar (EventKit refuses invitees on the simulator's local calendar, so this was checked on Android only).
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
- [x] Manual (iOS simulator and Android emulator, at M7.7): Settings › Calendars › Connect shows the system prompt with the usage text; allowed lists the device's calendars; denied shows "Calendar access is off" and Open settings lands on Dottoday's page (iOS) — M7.1. Done 2026-10-24 through `calendar_prompt` / `calendar_denied` / `calendar_import` on the iPhone 17 Pro simulator and the Android API 37 emulator (screenshots in `build/device_shots/`): the iOS prompt shows the usage text, Android its own dialog; denied shows the notice; Android's Open settings says where to go. One difference: on the iOS 26 simulator Open settings opens Settings at its top level, not Dottoday's page (the call is the standard `app-settings:`); checked on a real iPhone in §6.1.
- [ ] → owner, §6.1 (this Mac, needs a person at the system prompt; re-checked 2026-10-24 at M7.7: status still `notAsked`): Settings › Calendars › Connect shows the macOS prompt with the usage text; allowed lists the Mac's calendars by account with colours, and `flutter test integration_test/mac_calendar_bridge_test.dart -d macos` then also reads a week of events; denied shows the notice and Open settings lands on Privacy & Security › Calendars — M7.1b. (Run on 2026-10-24: bridge answers, status `notAsked`; the allow/deny path is this gate.)
- [x] Manual (iOS simulator and Android emulator, at M7.7, calendars allowed; the Mac part is in §6.1): an event in the device's Calendar app appears on Today in its calendar's colour within a resume; a repeating event shows on each day; moving it in Calendar moves it here and keeps a subtask added here; deleting it there removes it here (or puts it in Trash when it has a subtask); switching its calendar off removes its events; a link in its notes opens the browser — M7.2. Done 2026-10-24 by `calendar_import` on both (iOS opens the link in Safari's in-app view, Android in Chrome).
- [x] Manual (iOS simulator and Android emulator, at M7.7, calendars allowed; the Mac part is in §6.1): with Send changes back on for a calendar, dragging one of its events here moves it in the Calendar app within seconds (resize and rename too), keeping its notes, alerts and invitees; a repeating or all-day event changes here only and the editor says so; changing the same event's time in Calendar and here before Dottoday sends shows "This event changed in your calendar too" and both Keep mine and Use calendar's do what they say; with access revoked, an edit shows "1 change hasn't reached your calendar yet" and Try again sends it once access is back — M7.3. Done 2026-10-24 by `calendar_write_back`, `calendar_revoked` (and `calendar_regranted` on iOS) on both, together with M7.6 (a drag with Shift later tasks + Calendar events too carries the writable event and sends it; the repeating one stays). Notes, alerts and invitees come back unchanged on Android; on iOS notes and alerts (the simulator can't hold an event with invitees). iOS ends an app whose calendar access changes, so there the waiting edit goes out by itself on the next launch; Try again is for access coming back while the app runs (Android).
- [ ] Manual (M8.1, run in M8.5 on iPhone, Android, Mac, real Chrome): Settings › Export › each format reaches the person — the share sheet on iPhone/Android (Save to Files / Drive works), the Mac save panel (a folder for the three CSVs), downloads in Chrome — and the files open (JSON in a text editor, CSV in Numbers/Sheets with a `=` title shown as text, ICS in Calendar); Import a backup… with that JSON shows the "Replace your tasks" confirm, replaces, and Undo puts the previous tasks back; ON THIS DEVICE lists the pre-import backup. Logic is covered by `export_page_test`, `backup_calendar_test`, `export_service_test`, `folder_writer_test`; the system sheets need a person.
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

