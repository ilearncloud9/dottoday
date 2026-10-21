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
