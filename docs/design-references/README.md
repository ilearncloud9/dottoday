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
