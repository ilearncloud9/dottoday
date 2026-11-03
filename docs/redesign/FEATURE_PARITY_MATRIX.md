# Feature parity matrix

The checklist every redesigned screen is measured against (playbook "Definition of DONE": *no lost feature from the parity matrix*). Built from the code audit in `FEATURE_READINESS.md` (2026-11-02, `7ee9a359`). **A redesign may move any entry point (owner decision 9), but every row must stay reachable on every platform it reaches today.**

**Legend:**
- **✓** built and tested in Dart.
- **✓d** built; only a device run proves it (native code with no native tests).
- **~** a deliberate fallback (named in the notes).
- **—** not available on that platform, by design.
- **✗** defect (see `FEATURE_READINESS.md`).

Tablet columns: there is no tablet-specific code. iPad behaves like iPhone and Android tablets like Android phones, except that width alone switches the shell at ≥ 600 px (rail) and ≥ 840 px (Week tab, Inbox sidebar, three-day spread).

## 1. Today and timeline

| Feature | Current entry points | iPhone | iPad | Mac | And. phone | And. tablet | Web | Notes |
|---|---|---|---|---|---|---|---|---|
| Today timeline, day paging ±365 days | Today tab, `/today`, swipe | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | |
| Go to a date | `/day/:date`, week strip, month | ✓ ✗ | ✓ ✗ | ✓ ✗ | ✓ ✗ | ✓ ✗ | ✓ ✗ | UTC/local mismatch, no range check |
| Week strip, month pull-open | Today header | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | |
| Month view | `/month`, Week header, Mac menu | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | Same grid as the pull-open |
| Week view | Week tab (expanded width only) | — | ✓ wide | ✓ | — | ✓ wide | ✓ | Docs say Mac/web only (Q5). Snaps to a fixed 15 min |
| Three-day spread + Inbox sidebar | expanded width | — | ✓ wide | ✓ | — | ✓ wide | ✓ | |
| Drag to move, overlaps allowed, overlap knot | long-press (touch) / press (mouse) | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | Drag-resize removed (ADR-0015) |
| Multi-select + selection bar (incl. Save as routine) | long-press without moving, ⇧/⌘-click, screen-reader "Select" | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | |
| Shift the rest / shift followers / pin | live row, drag chip, sheet pin | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | > 2 followers opens Rebalance |
| Running late +5/15/30 | ⋯ (today), spread button, live row (minimal) | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | |
| Now-marker, live dot, done + Undo, ⌘Z | automatic, tap | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | |
| Tasks before Wake Up fold | tap the fold | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | |
| Reality thread | Plan/Reality toggle once learned | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | |
| Duplicate day, Copy day as text | ⋯ only | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | |
| Minimal layout (Show less / Show everything) | ⋯, Settings Layout row, onboarding step 0 | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | `FeatureId` policy test |

## 2. Capture and editing

| Feature | Current entry points | iPhone | iPad | Mac | And. phone | And. tablet | Web | Notes |
|---|---|---|---|---|---|---|---|---|
| Quick Add with natural-language time | + button, ⌘N, `/add`, `dottoday://add`, intents/controls | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | No + button at expanded width (⌘N) |
| Paste a list → tasks | paste into Add or the Inbox field | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | Minimal layout routes to Brain dump |
| Add another, duration chips, typed time | Add sheet | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | |
| Task sheet, `/task/:id` | tap a dot | ✓ ✗ | ✓ ✗ | ✓ ✗ | ✓ ✗ | ✓ ✗ | ✓ ✗ | Move tile is dead |
| Editor: time, duration, colour, icon, notes and links, subtasks, repeat, alerts (≤ 5), pin, travel, energy | sheet › Edit; side panel at expanded width | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | Separate modal on phone, panel on Mac/web |
| Inbox, schedule in ≤ 2 taps | Inbox tab, sidebar (wide) | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | Three different scheduling sheets |
| Brain dump (typed) | **⋯ only** (today, full layout); minimal: paste several lines into Add | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | Owner P3 |
| Brain dump (spoken) | mic in Brain dump / Notes | ✓d | ✓d | ✓d | ✓d | ✓d | ~ Chrome/Edge only | Hidden in minimal |
| On-device AI and AI status | inside flows; Privacy | ✓d iOS 26+ | ✓d iOS 26+ | ✓d macOS 26+ | ✓d (ML Kit beta) | ✓d | ~ Chrome Prompt API | Rules fallback everywhere |
| Proposal sheet (nothing written before Accept) | every generated change | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | |
| Break it down | sheet, Add, hint, intent | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | |
| Smallest step, Unstick, Rebalance | automatic triggers only | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | No manual entry |
| Routines (save, drop on a day) | ⋯, Settings › Planning, Inbox header, hint, Add chips | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | Route sits under Settings; hidden in minimal |
| Focus `/focus/:id` | live row, Start, notification, Wake Up | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | Deep work: Android only |
| Pick today's one thing | **⋯ only**, Wake Up mission | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | |
| Low-energy mode | ⋯ (turn on), header switch (when on), Settings › Planning | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | |

## 3. Mornings, nights and alerts

| Feature | Current entry points | iPhone | iPad | Mac | And. phone | And. tablet | Web | Notes |
|---|---|---|---|---|---|---|---|---|
| Day shape (Wake Up / Wind Down), different days, week start, time format | Settings › Day shape, onboarding | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | Linear slider (P5) |
| Sleep target, Wind Down from tomorrow, learn offer, night on the day dot | Settings night rows, review | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | |
| Wake Up alarm (alarm-grade) | Day shape row, Wake Up page, onboarding | ✓d AlarmKit (iOS 26+; notification on 16–25) | ✓d (treated as iPhone) | ~ notification | ✓d `setAlarmClock` + full screen | ✓d | ~ notification | |
| Snooze, Wake Up card, Wake Up Check | alarm UI, `/wake-up` | ✓d | ✓d | ~ | ✓d | ✓d | ~ | |
| Missions: stand up, walk, light | `/wake-up/mission/...` | ✓d sensors (Light = camera) | ✓d | — | ✓d sensors | ✓d | — | Mac/web skip sensor missions |
| Missions: breathe, catch the dot, one thing; hold-to-skip | same | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | Owner P7 (visuals/motion) |
| Wind Down review `/review` | notification, ⋯ "Review the day", prompt | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | Three forms of one screen |
| Task alerts: lead time, ≤ 5 per task, exactly once | editor, Settings › Reminders defaults | ✓d | ✓d | ✓d | ✓d | ✓d | ~ web push (partial) | iOS/macOS: earliest 50 pending kept |
| Notification health, test alarm | Settings › Reminders, Wake Up page, minimal card, onboarding | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | |
| Quiet hours, day-start summary, Wind Down reminder, nudges | Settings › Reminders / Planning | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | |
| Sounds (per dot, Start sound, haptics) | Settings › Sounds, editor | ✓d | ✓d | ✓d | ✓d per-channel | ✓d | ~ | |

## 4. Data, sync and accounts

| Feature | Current entry points | iPhone | iPad | Mac | And. phone | And. tablet | Web | Notes |
|---|---|---|---|---|---|---|---|---|
| Encrypted local DB, recovery screen | automatic | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ (one tab; no pre-migration snapshot) | |
| Sync + status (banner, sheet, sidebar line) | Settings header / Data › Sync, banner | ✓ ✗ | ✓ ✗ | ✓ ✗ | ✓ ✗ | ✓ ✗ | ✓ ✗ | Pull stall (stabilise first) |
| Account: Apple, Google, email; sign out everywhere; delete | Settings › Account, onboarding O5 | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | Providers need hosted config |
| App lock | Settings › Privacy | ✓ | ✓ | ✓ | ✓ | ✓ | — | |
| Backups, restore, export JSON/CSV/ICS, import | Settings › Export, Mac File menu | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | Share sheet on mobile |
| Trash (30 days), Undo/Redo | Settings › Data › Trash; snackbar, ⌘Z | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | |
| Device calendars + write-back | Settings › Calendars | ✓ | ✓ | ✓ (EventKit) | ✓ | ✓ | — | |
| Google/Microsoft calendars | Settings › Calendars › Connect | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | Owner-gated deploy |
| Search with history, Past days, year strip | Search tab; minimal: Everything else | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | |
| Weekly review + share, learning reveal, hints | ⋯ "This week", prompts, Today | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | "This week" ≠ the Week tab |

## 5. System surfaces

| Feature | iPhone | iPad | Mac | And. phone | And. tablet | Web | Notes |
|---|---|---|---|---|---|---|---|
| Home/lock-screen widgets | ✓d | ✓d | — (menu bar instead) | ✓d | ✓d | — | |
| Live Activity / ongoing notification | ✓d | — (inferred: ActivityKit not on iPad) | — | ✓d | ✓d | ~ tab live dot | |
| Controls / Quick Settings tiles | ✓d (iOS 18) | ✓d | — | ✓d | ✓d | — | |
| App Intents, Siri & Shortcuts page | ✓ | ✓ (comment says iPhone only, D7) | — | ~ static shortcuts | ~ | — | |
| Share into Inbox | ✓d | ✓d | ✓d | ✓ | ✓ | — (paste instead, owner choice) | |
| Menu bar, app menus | — | — | ✓ | — | — | — | |
| Keyboard shortcuts (⌘1–4, N, /, Z) | ✓ hw keyboard | ✓ | ✓ | ✓ | ✓ | ✓ | |
| Deep links `dottoday://` (no universal links) | ✓ | ✓ | ✓ | ✓ | ✓ | ~ URL routes | |
| PWA install, service worker | — | — | — | — | — | partial | Offline untested |
| Languages en/de/fr/es (no RTL) | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | |
| Feedback, What's new | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | |

## 6. Settings inventory (current)

Full layout, `settings_screen.dart`, 43–47 rows:

| Section | Rows |
|---|---|
| Header | 1: account, opens Account |
| (untitled) | 1: Layout |
| Day shape | 10 (+1): slider, Wake Up, Wake Up alarm, Wake Up options, Wind Down, Sleep target, [learn switch], Show night, Different days, Week starts, Time format |
| Planning | 10: Default duration, Routines, Snap to, Shift later, Show free time, Running-late nudge, Start nudge, Plan-your-inbox nudge, Low-energy mode, Roll unfinished |
| Learning | 4: Reality thread, Durations, Steps, Energy suggestions |
| Reminders | 6 (+2): Task starts, Sound, Quiet hours [From, Until], Day-start summary, Wind Down reminder, Notification health |
| Look | 3: Theme, Accent, Language |
| Data | 4: Sync, Calendars, Export, Trash |
| About | 4–5: Help, Siri & Shortcuts (iOS), Privacy, About, Send feedback |

Minimal layout: 9 rows plus Everything else (which repeats the full tree). There are 13 sub-pages. The Wake Up page alone has about 23 rows.

## 7. Duplicates and reach (the redesign should consolidate these, keeping reach)

| Item | Reached from | Count |
|---|---|---|
| Wake Up alarm switch | Day shape row, Wake Up page, onboarding | 3 |
| Wake Up / Wind Down times | slider + 2 rows on one screen, onboarding | 3 |
| Test alarm card | minimal Settings, Wake Up page, onboarding | 3 builds |
| Notification health | Reminders row, Wake Up link, minimal summary | 3 |
| Layout (full/minimal) | Settings row, Today ⋯, onboarding | 3 |
| Low-energy mode | Settings › Planning, Today ⋯, header switch | 3 |
| Routines | Settings › Planning, Today ⋯, Inbox header, hint, Add chips | 5 |
| Default alerts | Reminders › Task starts, minimal "Remind me…" | 2 |
| Account / sync | header, Data › Sync, minimal row, sync sheet link | 4 |
| Feedback / What's new | About + Help / About + banner | 2 / 2 |
| Export | Data row, Mac File menu | 2 |
| Wake Up explainer | Help, Wake Up "How it works" | 2 |
| Wind Down controls | time row, Reminders switch, sleep-target time, learn offer + learn switch | 5 |
| Day review | sheet, `/review` page, Today prompt | 3 forms |
| Month | Today pull-open, `/month` | 2 |
| Today header | TodayHeader, SpreadHeader | 2 |
| Capture field | Add sheet, Inbox field | 2 |
| Inbox scheduling | schedule sheet, pick-time sheet, drop-today panel | 3 |
| Label clash | two different Wake Up settings both labelled "After" | — |

**Only reachable through Today ⋯** (owner P3): Brain dump (typed, full layout), Pick today's one thing, turning on Low-energy mode (outside Settings), Duplicate day, Copy day as text, the weekly review ("This week").
