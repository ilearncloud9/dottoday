# Design references — Concept A

Rendered at 2× from the design canvas (version 124, 2026-10-21). `png/` is what to match; `src/` is the HTML each PNG was rendered from (inline styles; `{{accent}}` = the accent token). Sizes: iPhone 390×844, Android 412×915, Mac/web 1280×800, Watch 198×242.

| File | Shows |
|---|---|
| `png/A-ios-task-sheet.png` | iPhone · tap a task row → task sheet (Done / +15 / Shift, subtasks, details) |
| `png/A-ios-future-month.png` | iPhone · planning a future month: month grid → pick a day → its thread |
| `png/A-ios-today-month.png` | iPhone · Today with the month pulled open from the week strip |
| `png/Main.png` | iPhone · Today: greeting, day dot, week strip + pull handle, all-day chips, day pager card with the thread, tab bar + add dot |
| `png/A-ios-inbox.png` | iPhone · Inbox: loose dots, quick-add field, next-free-slot suggestion, completed group |
| `png/A-ios-add-what.png` | iPhone · Add step 1 What: title, colour & icon, Suggestions from habits |
| `png/A-ios-add-when.png` | iPhone · Add step 2 When: ThreadPicker, duration chips, Lands-on row |
| `png/A-ios-add-duration.png` | iPhone · Duration sheet: wheel, live segment preview, presets |
| `png/A-ios-add-time-menu.png` | iPhone · the ⋯ menu on TIME |
| `png/A-ios-search.png` | iPhone · Search: field, filter chips (incl. colour/icon), results grouped by day, recent |
| `png/A-ios-settings.png` | iPhone · Settings: DAY SHAPE (Wake Up / Bedtime with mini-thread), Planning, Reminders, Look, Data, About |
| `png/A-android-today.png` | Android (dark, Material 3) · Today — same structure as iPhone |
| `png/A-android-inbox.png` | Android · Inbox |
| `png/A-android-add-what.png` | Android · Add step 1 What |
| `png/A-android-add-when.png` | Android · Add step 2 When |
| `png/A-android-add-duration.png` | Android · Duration sheet |
| `png/A-android-add-time-menu.png` | Android · the ⋯ menu on TIME (M3 menu) |
| `png/A-android-search.png` | Android · Search |
| `png/A-android-settings.png` | Android · Settings (M3 lists and switches) |
| `png/A-mac-today-alt1-spread.png` | Mac/web · Today: three-day spread (Yesterday | Today card | Tomorrow), rail, no sidebar |
| `png/A-mac-week-alt3-board.png` | Mac/web · Week: capacity board — hour axis, cards placed by time, capacity ring per day, Busiest/Lightest tags, Inbox sidebar drag-to-plan, summary strip |
| `png/A-mac-month.png` | Mac/web · Month: past days with completion dots, struck done titles, missed items, 'N of M done' |
| `png/A-mac-inbox.png` | Mac/web · Inbox |
| `png/A-mac-editor.png` | Mac/web · Task editor panel beside Today (Colour & icon block, when, duration, repeat, alerts, subtasks, notes) |
| `png/Watch.png` | Apple Watch · Now: current dot with ring, next task, Done / +15 |

Screens without a reference (onboarding, repeat/alert editors, sync, empty/error states…) are specified in `../10-ui-concept-a.md` §5.3–5.4 and are built from the same components.

## Derived

Screens and components built without a render (CLAUDE.md §11). Each has goldens in the
design-review matrix (`docs/08-testing-qa.md` §7).

| Item | Derived from | Golden |
|---|---|---|
| `TaskDot` skipped (dashed) and missed states | §3 `TaskDot`, `A-ios-future-month` | `task_dot_*` |
| Thread "missed" meta and skipped rows | §3 `TaskRow`, `A-mac-month` | `thread_*` |
| Medium-width rail (600–840) | §4 | `shell_rail_*_medium_*` |
| Add A1 with no habits yet (no Suggestions, helper line) | §5.2 A1, `A-ios-add-what` | `add_what_blank_*` |
| Inbox schedule sheet › "Pick a time…" (Today / Tomorrow on a `ThreadPicker`, Place) | §3 `ThreadPicker`, `A-ios-add-when` | `inbox_pick_time_*` |
| Paste confirmation "Add N tasks?" (Add title and Inbox field) | 03 §3.3, §5.4 | `add_paste_*` |
| Add A2 all-day state (picker and chips hidden, "Lands on Today · all day") | §3 `AddFlow`, `A-ios-add-time-menu` | `add_time_menu_*` (menu); behaviour in `add_time_menu_test` |
| Change day picker (month in a sheet with each day's planned dots, M3f.4) | §5.3 "Change day picker", `MonthGrid` | `picker_change_day_*` |
| Pick from the week (`WeekStrip` with ‹ ›) | §5.3, `A-ios-add-time-menu` | `picker_week_*` |
| Time zone picker (search over IANA Region/City ids); the editor's "Time zone · City" row (M3f.4) | §5.3 "Time zone picker" | `picker_zone_*`, `task_editor_*` |
| Type a time sheet (`TimeInput` + Done) | §5.3, R-20 | `picker_type_time_*` |
| Duration sheet's "Or type a length" field | §3 `DurationSheet`, R-16 | `add_duration_*` |
| Search empty (hint + recent) and no results (with Show all) | §5.3 "Search empty and no-results" | `search_empty_*`, `search_no_results_*` |
| Settings › Different days (per-weekday sliders), Send feedback sheet, Trash sheet | §5.3, PRD F1/F8/F11 | `settings_weekdays_*`, `settings_feedback_*` |
| Spread side day with nothing planned ("Nothing planned"), the spread at 840 px | §3 `DayCard`, PRD F1, `A-mac-today-alt1-spread` | `today_spread_*` |
| Inbox Sort menu (added / duration / first fit), "No room this week", the Inbox sidebar's empty list | §3 `InboxRow`, `A-mac-inbox` | `inbox_*_expanded_*`, `today_inbox_sidebar_*` |
| Week at 840 px (controls under the title, sideways scroll), drag preview pill, the board's "Drop a task here" on an empty day | §3 `CapacityRing`/`WeekSummaryStrip`, `A-mac-week-alt3-board` | `week_*` |
| Month at 840 px, an empty month (no badges, no numbers) | §3 `MonthGrid`, `A-mac-month` | `month_*` |
| Editor panel header ("EDIT TASK", esc, ×) | §3 `AddFlow` → `TaskEditor`, `A-mac-editor` | `today_editor_panel_*` |
| Task sheet and editor LINKS (the notes' web links, each a tappable row, M7.2) | §3 `TaskSheet`, `A-ios-task-sheet` | `task_sheet_links_*` |
| Keyboard shortcut sheet (⌘/), focus ring on buttons | §5.3 "Mac/web keyboard shortcut sheet" | widget tests (`app_shortcut_groups_test`, `focus_ring_test`); golden at the M3e.9 sweep |
| Repeat editor (choices, weekday chips, custom interval, ends) and the "Change which? / Delete which?" scope sheet | §5.3 "Repeat editor", R-01 | `picker_repeat_*`, `picker_scope_*` |
| Alerts editor (task alerts, add choices, five at most, Bedtime switch) | §5.3 "Alerts editor", R-10 | `picker_alerts_*` |
| Subtask rows in the editor (rename dialog, ×, drag handle, "now", Use this list every time); full colour & icon picker | §5.3 "Subtask editor", "Colour & icon full picker", R-09 | `task_editor_*`; widget tests |
| Running late sheet (+5 / +15 / +30; shift the rest with the pinned task named, skip, shorten), Today's ⋯ (Running late…, Review the day) | §5.3 "Running late sheet", PRD F1, R-04 | `today_running_late_*` |
| Day review card at Bedtime ("2 of 13 done · Send the rest to the Inbox?", Not now) and the running-late nudge card | §5.3 "Day review at Bedtime" | `today_day_review_*`, `today_late_nudge_*` |
| Inbox Completed group open (done day, ↺ not done, Clear completed); the day ⋯ with Duplicate day… and Copy day as text | §5.3 "Completed group expanded", 03 §3.1 | `inbox_completed_open_*`; `day_menu_test` |
| Settings sub-pages: Account (signed out; signed in in tests), Calendars, Export, Help, Privacy, About; the new DATA / ABOUT rows | §5.3 "Settings sub-pages", "Account page" | `settings_page_*`, `settings_lower_*` |
| Sync sheet (no account; state, last synced, pending, Sync now, conflict cards with Keep mine / Keep theirs), the sync banner (offline / conflicts), the notifications-off notice (Settings, Alerts editor) | §5.3 "Sync status sheet", §5.4 offline / permission-denied | `sync_sheet_*`, `sync_banner_offline_*`, `settings_notifications_off_*` |
| Recovery screens: can't open your tasks (Start fresh → kept at … → Continue), open in another tab (Use it here), moved to another tab | §5.4 system states, 06 §4 | `recovery_*` |
| Loading skeleton (dots on a dotted thread) and inline error with Try again, on every screen | §5.4 loading / error | `state_loading_*`, `state_error_*`; `screen_states_test` |
| Inbox reorder handles (own order) and selecting (checks, Plan these / Colour / Delete bar) | PRD F3, §3 `InboxRow`, the M3b.7 bar | `inbox_*`, `inbox_selecting_*` |
| App lock screen (thread dot, "Dottoday is locked", Unlock) and the APP LOCK group on Privacy | §5.4 system states, 06 §2 (M5.8) | `lock_screen_*`, `settings_page_privacy_*` |
| Travel banner "You're now in … — keep times or shift?"; on phones a two-action strip puts its actions under the text (also the in-app reminder) | §5.4 strip, 07 travelling (M5.9) | `zone_banner_*`, `in_app_alert_banner_*` |
| Account page signed in (Sign out, Sign out everywhere, Delete account with "Export my data first"), the email steps on Account and O5 (address → "Check your mail"), O5 "Welcome back" | §5.3 "Account page", §5.1 O5, 06 §2/§6 (M6.1, M6.5) | `settings_page_account_signed_in_*`, `onboarding_*` |
| Settings › Calendars connected (calendars grouped by account, inherited colour, Read-only, switches) and denied (calendar notice); O4's "Connect a calendar" row | §5.3 "Settings sub-pages", §5.1 O4, §5.4 permission-denied (M7.1) | `settings_page_calendars_*`, `onboarding_reminders_*` |
| Write-back (M7.3): Settings › Calendars › SEND CHANGES BACK (one switch per writable calendar, then what it does); the clash banner "This event changed in your calendar too" with Keep mine / Use calendar's and the "… hasn't reached your calendar yet" banner with Try again; the editor's line "Changes go back to Work" / "From Holidays · changes stay in Dottoday" | §5.3 "Settings sub-pages", §5.4 strip, 03 §3.4 "calendar write-back status" | `settings_page_calendars_connected_*`, `write_back_banner_*`; `write_back_banner_test` |
| Sync status as text: "Kody · synced just now" under Settings (as `A-ios-settings`), "● Synced · just now" at the foot of the Inbox sidebar (as `A-mac-week-alt3-board`), with syncing / offline / paused / needs-you states | the two renders' text, §5.4 (M6.3) | `settings_synced_*`, `sync_status_line_*` |
| Sync sheet clock line: "Your clock is 7 min fast — reminders may be early" and, when fast, "Changes from this device wait until the clock is right…" (also the slow wording) | §5.3 "Sync status sheet", 11 A0 (M6.5.7) | `sync_sheet_clock_fast_*` |
| Settings › Reminders › Notification health (THIS DEVICE rows: permission, exact alarms, battery, Do Not Disturb, Focus, web push, clock — each with its plain-words line and one fix), and the REMINDERS row "Notification health · All good / 1 thing to fix" | `SettingsGroup` rows, 11 A0 (M6.5.8) | `settings_health_{all_good,permission_off,android_off,clock_off}_*`, `settings_notifications_off_*` |
| "Send me a test alarm" (CHECK IT WORKS group on O4 once notifications are allowed, and under Notification health): the owner's explanation with Send / Cancel, "Ringing in 42 s…", "Did it ring?" Yes / No and the line after each | 11 A0, §5.1 O4 (M6.5.9) | `onboarding_reminders_allowed_*`, `settings_test_alarm_{waiting,ask}_*`, `settings_health_*` |

## Set B (Concept A+, standout features)

Rendered at 2× from the canvas (version 128, 2026-10-23). iPhone 390×844 only; Android and Mac/web derive per `10-ui-concept-a.md` §4 (same geometry, states and copy; only the allowed chrome differs). Spec: `docs/11-standout-roadmap.md`.

| File | Shows | Roadmap item |
|---|---|---|
| `png/B-ios-live-activity.png` | lock screen with the Dynamic Island expanded state, the Live Activity card (mini thread, Done / +15 intents) and a time-sensitive dot-start notification | A0, A1 |
| `png/B-ios-focus.png` | Focus the dot: 160 px ring, current subtask with its own timer, step list, chime + Focus toggles, Done / +15 / Next step | A3, B2 model |
| `png/B-ios-break-it-down.png` | Break it down proposal: steps as a mini thread with per-step durations, depth 2 sub-steps, total, Accept / Discard, "nothing saved until you accept" | B1, B3 proposal |
| `png/B-ios-rebalance.png` | Rebalance proposal: ghost current thread vs proposed thread, per-change chips (shifted / pinned / shrunk / moved to tomorrow), per-row undo, three rule toggles, Accept plan | C1, B3 proposal |
| `png/B-ios-reality-thread.png` | Today with Plan / Reality toggle: planned ghost lane + actual lane, "started 12 min late · took 34 min", "usually 2 h 20", insight card | C3, B1 timestamps |
| `png/B-ios-routines.png` | Routines list: mini thread per routine, steps as chips, Drop on today / Edit, "save a selection from any day" | C2 |
| `png/B-ios-week-review.png` | Sunday review, chosen design "seven dots": one dot per day sized by hours planned, ring split into that day's tasks (done solid / not done faint), done count in the centre, tap a day to pop out its thread; chips, one sentence, carry-forward, share image | D1, B5 snapshot |
| `png/B-ios-low-energy.png` | Low-energy mode: one next dot, no counts, "Later" pile as dots, propose-to-tomorrow, nudges off | D2 |

Derived (no render; build from the spec and components): Smallest step reminder/row (B2), Unstick row (B3), notification-health panel and "send me a test alarm" step (A0), Android ongoing notification (A1, mirror of the Live Activity card in M3 style), interactive widgets and Control Center controls (A1), Mac menu-bar dot (A1), thread journal (D3), body-double dot in the Today header (E1), brain-dump sheet (B4, reuse Add step 1 + ProposalSheet).
