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

## 6. Release gates (all must pass)
- [ ] CI green: analyze, format, unit, widget, golden, integration (Android), RLS.
- [ ] Platform parity checklist (`docs/parity-checklist.md` generated from PRD feature list) all ✓ on iOS, Android, macOS, Web.
- [ ] Accessibility manual pass on all four.
- [ ] Offline day scenario and two-device conflict scenario pass.
- [ ] Notification exactness test: 20 scheduled alerts, 20 fired, 0 duplicates, on iOS and Android.
- [ ] Security checklist (06 §9) signed off.
- [ ] Crash-free ≥ 99.5 % over the last beta build.
- [ ] CHANGELOG and in-app "What's new" updated.
