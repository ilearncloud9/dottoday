# Design references — Concept A

> **Superseded in part by ADR-0015 (2026-10-30).** The task dots (now a tint with a bold icon, the same in every state), the done circle (filled with a tick when done), Today's day card (now a full-width sheet with no title row, peek or page dots) and the header (the day's numbers under the title) no longer match these renders. Where they disagree, ADR-0015 wins and the goldens are the reference.

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
| `png/A-ios-settings.png` | iPhone · Settings: DAY SHAPE (Wake Up / Wind Down with mini-thread), Planning, Reminders, Look, Data, About |
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
| Minimal layout (M16, docs/14 §4): Today (date + ⋯, Done / Running late on the live row, the Later row, no tab bar), one-step Add (when and length chips, Add / More), the task sheet (Done · Tomorrow · Later · Delete, More), eight-row Settings, onboarding step 0's two cards, the reveal hint row (derived until set C arrives). The task sheet's 2.0-text and RTL cells capture a finished task (`minimal_task_sheet_done_*`): on the live task, white bold "Done" on the accent fill at 200 % rasterises 0.14 % differently by test order (engine-side, over the 0.1 % tolerance); the live sheet keeps light/dark 1×/2× (`minimal_task_sheet_*`) (owner accepted, 2026-10-31) | docs/14 §4–§5 + `Main`, `A-ios-add-what`, `A-ios-task-sheet`, `A-ios-settings` | `minimal_today_*`, `minimal_add_*`, `minimal_task_sheet_*`, `minimal_settings_*`, `minimal_onboarding_layout_*`, `minimal_today_hint_*` |
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
| Send feedback with diagnostics on (the exact block shown before sending); About › What's new (changelog page). The update banner reuses `BannerStrip` (M8.2) | §5.3, PRD F11, R-19 | `settings_feedback_diagnostics_*`, `settings_page_changelog_*` |
| Settings › REMINDERS (M8.4d): Task starts as the default alert *set* ("10 min before +2", the shared Alerts editor), Sound (sheet: System sound + the bundled set, a tap plays it), Quiet hours (switch; From / Until rows when on; `bellOff` glyph), Day-start summary (sheet: one switch per weekday). The in-app reminder strip's second action is Snooze 10 min for a task (Open / Later for Wind Down and the summary) | §5.3 "Alerts editor", §5.4 strip, PRD F6.2, F6.4, F6.6 | `settings_reminders_*`, `settings_sound_*`, `settings_day_summary_*`, `in_app_alert_banner_*` |
| Spread side day with nothing planned ("Nothing planned"), the spread at 840 px | §3 `DayCard`, PRD F1, `A-mac-today-alt1-spread` | `today_spread_*` |
| Inbox Sort menu (added / duration / first fit), "No room this week", the Inbox sidebar's empty list | §3 `InboxRow`, `A-mac-inbox` | `inbox_*_expanded_*`, `today_inbox_sidebar_*` |
| Week at 840 px (controls under the title, sideways scroll), drag preview pill, the board's "Drop a task here" on an empty day | §3 `CapacityRing`/`WeekSummaryStrip`, `A-mac-week-alt3-board` | `week_*` |
| Month at 840 px, an empty month (no badges, no numbers) | §3 `MonthGrid`, `A-mac-month` | `month_*` |
| Editor panel header ("EDIT TASK", esc, ×) | §3 `AddFlow` → `TaskEditor`, `A-mac-editor` | `today_editor_panel_*` |
| Task sheet and editor LINKS (the notes' web links, each a tappable row, M7.2) | §3 `TaskSheet`, `A-ios-task-sheet` | `task_sheet_links_*` |
| Task sheet TRAVEL TIME suggestion (an imported event's place, Add N min before · Not now, M7.5) | §3 `TaskSheet`, §5.4 card, `A-ios-task-sheet` | `task_sheet_travel_*` |
| Keyboard shortcut sheet (⌘/), focus ring on buttons | §5.3 "Mac/web keyboard shortcut sheet" | widget tests (`app_shortcut_groups_test`, `focus_ring_test`); golden at the M3e.9 sweep |
| Repeat editor (choices, weekday chips, custom interval, ends) and the "Change which? / Delete which?" scope sheet | §5.3 "Repeat editor", R-01 | `picker_repeat_*`, `picker_scope_*` |
| Alerts editor (task alerts, add choices, five at most, Wind Down switch) | §5.3 "Alerts editor", R-10 | `picker_alerts_*` |
| Subtask rows in the editor (rename dialog, ×, drag handle, "now", Use this list every time); full colour & icon picker | §5.3 "Subtask editor", "Colour & icon full picker", R-09 | `task_editor_*`; widget tests |
| Running late sheet (+5 / +15 / +30; shift the rest with the pinned task named, skip, shorten), Today's ⋯ (Running late…, Review the day) | §5.3 "Running late sheet", PRD F1, R-04 | `today_running_late_*` |
| Day review card at Wind Down ("2 of 13 done · Send the rest to the Inbox?", Not now) and the running-late nudge card | §5.3 "Day review at Wind Down" | `today_day_review_*`, `today_late_nudge_*` |
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
| Drag chips (M7.6): "Calendar events too" beside "Shift later tasks" while that is on (derived) | 03 §3.2 "Calendar events in a shift" | `shift_chip_*`; `thread_drag_test` |
| Step lengths in the editor (M10.3): a length chip on each subtask row ("15 min" / "+ time", pill on iPhone, 8 px elsewhere) and "Length = sum of steps" under DURATION (derived) | 11 §B2 + the M3f subtask editor; chip geometry from `B-ios-break-it-down` | `task_editor_steps_*`; `editor_step_lengths_test` |
| Break it down entry points (M10.4): "Break it down" under Add step 1's title (shown once there is a title, then "3 steps · saved with the task") and beside "+ Add" in the task sheet's / Mac-web panel's Subtasks header (derived) | 11 §B1 "one button, in Add step 1 and in the task sheet" | `add_what_*`, `task_sheet_*`; `task_sheet_breakdown_test` |
| Notification health's Sound row (docs/12 §4): "The sound for Lift is muted in system settings" with Open settings; at > 130 % text a row's fix button sits under its text (derived) | 11 §A0 health panel + `SettingsGroup` rows | `settings_health_sounds_*`; `notification_health_test`, `muted_sounds_test` |
| Settings › Reminders › Sounds (docs/12 §6): System sound, None, then Dottoday / Quiet / Clear / Playful groups (tap picks and plays), Start sound and Done sound rows opening their own lists (Insistent captioned), Sounds in app, the credit line; muted banner (derived) | docs/12 §6 + `SettingsGroup` rows + the Notification health page frame | `settings_sounds_*`; `sounds_page_test` |
| Task Sound row and picker (docs/12 §6): "Sound · Default · Dot" in the editor and task sheet; full-height picker with Default / None / sections and Done pinned (derived) | docs/12 §6 + the editor's Repeat/Alerts rows + the icon picker's sheet frame | `task_editor_sound_*`, `task_editor_*`, `task_sheet_*`; `task_editor_test` |
| Focus on Mac/web and the Deep work variants (M10.5): the same Focus view centred in the content area (readable column) with the rail kept, Esc to leave; Deep work's "Allow Dottoday to turn on Do Not Disturb" line (Android), the "Turn on Focus with Shortcuts" sheet (iPhone/Mac) and the web's no-switch row (derived) | `B-ios-focus` + 10 §4 ("no sheets at expanded") + 11 §A3 OS integration | `focus_*`; `focus_view_test`, `focus_frame_test` |
| Smallest step row and reminder (M10.6): under the live dot's summary, "Just Gather documents · 10 min?" in the accent with a Start pill (8 px off iPhone); the reminder at start + 10 min with the same words over the task's title and one Start action (derived) | 11 §B2 ("Smallest step reminder/row" in set B's derived list) | `thread_smallest_step_*`; `smallest_step_plan_test` |
| Learning reveal (M13, docs/13): Settings › LEARNING (rows with the progress ring and "7/10" under the subtitle, the privacy footer), Today's learning caption at the top of the thread with ×, the Plan / Reality toggle's one-time accent hold, and a learned value's explanation line ("based on your last 6 times · median", reset or inline Reset · Keep) (derived) | docs/13 §4–§6 + `SettingsGroup`, `CapacityRing`, `DayCard` | `settings_learning_*`, `today_learning_caption_*`, `today_reality_highlight_*`, `add_when_learned*`, `focus_step_learned_explained_*`; `learning_reveal_test`, `learned_line_test` |
| Overlap knot (ADR-0015 knot amendment, owner 2026-10-31): two strands in the two tasks' colours cross between unchanged dots, "Run and Sleep share 15 min"; the `OverlapKnot` mark in the picker caption, Add's "Lands on" and proposal chips (derived) | ADR-0015 + `TaskDot`, thread segment | `thread_overlap_*`; `thread_test`, `thread_day_test` |
| Unstick row (M10.7): under the title of a task moved three times with no steps, "What's the very first thing you'd physically do?" in muted text and a one-line field with a send arrow; the answer becomes step 1 (Undo snackbar) and the row goes; never a modal (derived) | 11 §B3 ("Unstick row" in set B's derived list) | `thread_unstick_*`; `today_unstick_test` |
| Google and Microsoft (M7.4): Settings › Calendars › an account group (its calendars' switches, Read-only, Disconnect with a confirm, Reconnect when revoked), GOOGLE AND MICROSOFT with Connect Google Calendar / Connect Microsoft Outlook, the cross-device note; signed out: "Sign in to connect Google or Microsoft"; with no device calendars and no sync, only "No calendars connected yet" | §5.3 "Settings sub-pages" | `settings_page_calendars_google_*`, `settings_page_calendars_*`; `calendars_page_test` (a11y both themes, both widths, signed in/out) |
| Sync status as text: "Kody · synced just now" under Settings (as `A-ios-settings`), "● Synced · just now" at the foot of the Inbox sidebar (as `A-mac-week-alt3-board`), with syncing / offline / paused / needs-you states | the two renders' text, §5.4 (M6.3) | `settings_synced_*`, `sync_status_line_*` |
| Sync sheet clock line: "Your clock is 7 min fast — reminders may be early" and, when fast, "Changes from this device wait until the clock is right…" (also the slow wording) | §5.3 "Sync status sheet", 11 A0 (M6.5.7) | `sync_sheet_clock_fast_*` |
| Settings › Reminders › Notification health (THIS DEVICE rows: permission, exact alarms, battery, Do Not Disturb, Focus, web push, clock — each with its plain-words line and one fix), and the REMINDERS row "Notification health · All good / 1 thing to fix" | `SettingsGroup` rows, 11 A0 (M6.5.8) | `settings_health_{all_good,permission_off,android_off,clock_off}_*`, `settings_notifications_off_*` |
| "Send me a test alarm" (CHECK IT WORKS group on O4 once notifications are allowed, and under Notification health): the owner's explanation with Send / Cancel, "Ringing in 42 s…", "Did it ring?" Yes / No and the line after each | 11 A0, §5.1 O4 (M6.5.9) | `onboarding_reminders_allowed_*`, `settings_test_alarm_{waiting,ask}_*`, `settings_health_*` |
| Save failed (M8.5b, R-08): a strip above Add's fields (and the editor's) — warning glyph, "Couldn't save on this device. Try again.", Try again — while the draft stays | `BannerStrip`, §5.4 | `add_save_failed_*`; `add_save_failure_test`, `editor_save_failure_test` |
| Calendar moved prompt (M11.1b): "CALENDAR CHANGED · Standup moved to 10:30 · Rebalance?" with Rebalance / Not now above the late nudge; the Rebalance sheet titled "Calendar changed" (derived) | 11 §C1 + the M3f.5 prompt card | `calendar_moved_prompt_test`; `rebalance_sheet_*` chrome |
| Reality thread details (M11.2–M11.3): the Plan / Reality switch only once a task really started; "· planned 6:45" + "took 34 min" instead of the render's "started 12 min late" (11 §D); the live row's "12 min in" and "usually 2 h 20"; the insight strip wraps instead of truncating | `B-ios-reality-thread` + 11 §C3, §D | `reality_thread_*`, `reality_spread_*`, `reality_plan_*`, `reality_dst_*` |
| Add learning lines (M11.3): "usually 1 h 20" under the duration chips and "you tend to start this ~15 min after plan" under the picker caption; the Running late sheet's "Deep work usually takes 2 h 20" under its amounts (derived) | 11 §C3 | `add_learning_test`, `running_late_sheet_test` |
| Routines extras (M11.4): the WHICH DAY week strip on the Routines page (no pull handle; picks where "Drop on …" lands), the empty page, the routine editor (name, When: At Wake Up / At a time / Ending at Wind Down, steps with colour dot, name, length, ↑ ↓ ×, kept gaps as "15 min free"; a sheet on phones, a dialog when wide), "Save as routine" on the selection bar, Routines… in Today ⋯, "Drop a routine…" in the Inbox header, ROUTINES chips in Add step 1, and the drop's proposal ("new" lines, plus "already here · overlaps" for a task a step meets) (derived) | `B-ios-routines` + 11 §C2, the B3 proposal sheet | `routines_*`, `routines_empty_*`, `routine_editor_*`, `routine_drop_*`, `today_selecting_*`, `inbox_*` |
| Weekly review extras (M12.1): "This week" as a sheet on phones and a popover from the medium width (not the right-hand panel, which the Place proposal uses); the tapped day's thread inline under the dots (first three tasks, "7 h 35 · busiest", "+4 more"); the count moves under the date at large text; the Wind Down prompt on the week's last day ("Your week in seven dots · See the week"); the share card with titles on (one line per day) (derived) | `B-ios-week-review` + 11 §D1 | `week_review_*`, `week_share_titles_off_*`, `week_share_titles_on_*` |
| Low-energy extras (M12.2): the next dot before it starts ("at 2:00 PM"), nothing left ("Nothing else today. Rest well."), Later opened as rows with times, the Mac/web spread (today card = low-energy view, side days dimmed, no Running late), the Settings › Planning switch, the ⋯ items (derived) | `B-ios-low-energy` + 11 §D2 | `today_low_energy_*`, `settings_*` |
| Thread journal (M12.3): Search › Past days entry (while nothing is typed), the Past days page (day cards with date, "4 of 5 done", dots in task colours, "+N"), its search ("When did I last…", "Last: Sun, Sep 27 · 28 days ago · 10 days", matching tasks with times, no match), the Year strip sheet (twelve rows of completion dots, Share image) (derived) | 11 §D3, `A-ios-search`, `A-ios-today-month` dots | `past_days_*`, `past_days_search_*`, `year_strip_*`, `search_empty_*` |
| Brain dump (M12.5): the sheet (multi-line field, Today / Tomorrow, Plan it, EARLIER DUMPS with search and Use again) and its proposal with a "no room · to the Inbox" line (derived) | 11 §B4, the B3 proposal sheet | `brain_dump_*`, `brain_dump_proposal_*` |
| Task icon picker (ADR-0013): full-height sheet: colour dots, search field, then the icon library under category captions, Planning & rhythm first; "No icons match …" when nothing matches (derived) | 10 §3 "Icon set" + the M3f.3 full colour & icon picker | `task_icon_picker_*`, `task_icon_library_*`; `colour_icon_block_test`, `task_icons_test` |
| AI status (M14.2): Settings › Privacy › Help with thinking — the status line per vendor and the next step (+ Open Settings where the OS allows); a proposal answered by the rules with the "simple rules" origin and the `StatusHint` under its subtitle; Brain dump's "Plans with …" caption under Plan it (derived) | 11 §B4 AI status, ADR-0009, 10 §3 `StatusHint` | `privacy_ai_status_*`, `proposal_rules_hint_*` |
| Siri & Shortcuts (M14.3, iPhone only): the page (what Siri can do, the five phrases, how to ask, Open Shortcuts), the one-time Today tip card, onboarding Done's Siri line (derived) | 11 §B6 (D3), `SettingsGroup` | `siri_page_*`, `today_siri_tip_*` |
| Brain dump with mic (M14.5): `MicButton` bottom-end in the box (idle, listening with the caption "Pause, or say "next", to start a new task."), the first-use tip card, the mic-aware placeholder, the quiet denied line with Open Settings (derived) | 11 §B7, `B4` sheet, 10 §3 `MicButton` | `brain_dump_mic_idle_*`, `brain_dump_mic_listening_*`, `brain_dump_mic_tip_*` |
| Notes with mic (M14.6): the editor's NOTES field with the `MicButton` bottom-end (derived) | 11 §B7, the M3f editor | `editor_notes_mic_*` |

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

## Set C (minimal layout, docs/14)

| Render | Screen | Golden |
|---|---|---|
| `C-ios-onboarding-mode.png` | Onboarding step 0: the day dot, the question, two radio cards with thread sketches, Continue and the step dots (owner, 2026-10-31) | `minimal_onboarding_layout_*` |

`C-ios-today-minimal.png`, `C-ios-add-minimal.png` and `C-ios-settings-minimal.png` are not drawn yet; those screens are derived (above).
