# UX audit (Prompt B)

**Status:** audit only. 2026-11-03, `redesign/design-lab` at `f449aa76`. No app code changed.

**Labels:**
- *VERIFIED*: read in code.
- *INFERRED*: reasoned, not run.
- *OBSERVED*: seen in the owner's real-iPhone screenshots of the current app (`references/baseline/owner-ios-2026-11-02/`; `03` and `04` are local only because they show personal tasks) or in the Prompt B simulator/emulator sweep and web probe (local only, listed in `references/baseline/PROMPT_B_EVIDENCE.md`).
- *P1–P7*: the brief's problems.

Paths are under `app/lib/` unless noted.

## 1. Do the brief's complaints hold up?

| Brief | Evidence | Verdict |
|---|---|---|
| **P1** Settings busy | 43–47 rows in 8 groups on one long page; Day shape alone 10–11 rows, Planning 10 (`features/settings/widgets/*_group.dart`). One centred column at every width; no two-pane on tablet or Mac (`settings_screen.dart:54-58`). Wake Up controls in three places (Day shape row, Wake Up page, onboarding). App lock under Privacy. Notification health is the last Reminders row | **Supported** (VERIFIED + OBSERVED `01`, `02`) |
| **P2** Not iOS-feeling | Material ripples (45 `InkWell`), Material bottom sheets with drag handles, Material `showMenu`, Material dialogs; no iOS context menus, large titles or action sheets. Only the pill bar, switch and wheels are Cupertino. No materials or glass (0 `BackdropFilter`) | **Supported** (VERIFIED) |
| **P3** Features buried in ⋯ | Only reachable through Today ⋯: Brain dump, One thing, Low-energy (outside Settings), Duplicate day, Copy as text, This week. The first five vanish on any day except today. The menu covers the header (owner screenshot `03`, local only) | **Supported** (VERIFIED + OBSERVED) |
| **P4** Duplicated screens | See §5: day review ×3 hosts, month grid ×3, test-alarm card ×4, Running late ×4 entries, task detail ×3, Inbox scheduling ×3 surfaces | **Supported**, but most share one body widget, so merging is cheap |
| **P5** Linear Wake Up slider | `DayShapeSlider` on Settings plus Wake Up/Wind Down rows with a `CupertinoDatePicker` wheel on every platform | **Supported**. The dial needs the Q8 domain change for after-midnight times |
| **P6** Visuals basic | Flat cards, hairlines, one Inter weight scale, no depth or materials, no motion beyond 180–240 ms fades and fills | **Supported** (subjective; screenshots agree) |
| **P7** Missions lack motion | `catch_dot_mission.dart`, `breathe_mission.dart`: simple controllers, reduced-motion aware, small graphics in a padded column (`05`) | **Supported** |

## 2. Core journeys: tap counts (VERIFIED from code paths, not timed)

Compact = phone width with the tab bar. Expanded = ≥ 840 with the rail.

| Journey | Compact | Expanded | Friction |
|---|---|---|---|
| Quick add with a time | **2** (+, type "Gym 6pm", Return) | **0 taps** with ⌘N; by touch: Inbox sidebar field or "add here" gap, **1–2** | **No + button at expanded width** (`dot_shell.dart:113-115`), so a touch iPad in landscape has no visible add button |
| Edit / reschedule | Drag, or row → Edit → time → Save: **3** | Click row → time → ⌘S: **2** | Phone editing is sheet → second full sheet |
| Complete | **1** | **1** | Good |
| Change day | Swipe or week strip **1**; far date **2** | ‹ › per day. **The spread header has no date picker** (`spread_header.dart:49-73`); far date = Week → Month → day, **3**, landing on `/day/:date` outside the shell | Far dates on desktop are awkward |
| Reopen | **1** (toggle) or Undo | **1** | Good |
| Shift the rest / Running late | Live row **1–2**; via ⋯ **4** | Spread button → Shift → Accept **3** | Four different entry points |
| Brain dump | ⋯ → Brain dump → type → Plan → Accept: **4** | same | Buried (P3); today only; no shortcut |
| Routines (drop on a day) | ⋯ → Routines → Drop → Accept: **4** | same | Pushing Routines from Today switches the shell to the Settings tab (INFERRED) |
| Change Wake Up time | Settings → Wake Up → Done: **3**; or tap the thread's sun cap | same; Mac ⌘, | Fine, but the cap tap is undiscoverable |
| Inbox → schedule | Inbox → + → slot: **3** | Sidebar drag or + → slot: **2** | Three different scheduling surfaces |

Vision targets (`00-vision.md`):
- Inbox → timeline in ≤ 2 taps: met on expanded, **3 on compact**.
- Shift the rest in one gesture: met from the live row.
- Plan tomorrow in < 90 s: not measured.

## 3. Information architecture

- **Tabs:**
  - Compact: Today · Inbox · Search · Settings.
  - Expanded: Today · Inbox · Week · Search · Settings, with Week only on wide windows.
- **Settings is a tab** on every platform. On Mac that duplicates the ⌘, convention (guide §5.2: Settings belongs in the app menu). On iPhone it competes with content tabs.
- **Search is a tab** but holds Past days and the year strip, which are review features rather than search.
- **"This week"** is the weekly review sheet, while "Week" is a tab. Same word, different things.
- **Month** has no tab. It's reached by pulling open the week strip (phones), ⌘4, or Week's Month switch. Its route sits outside the shell.
- **Inbox placement:**
  - Phones: a tab.
  - Wide windows: a 300 px sidebar beside Today from ≈ 1220 px, so the sidebar and the tab coexist.
  - Minimal: a "Later" row at the end of the thread.
- **Delete is inconsistent:**
  - the editor confirms with a dialog;
  - the minimal sheet and ⌫ trash immediately with Undo;
  - the selection bar confirms.

## 4. Settings in detail (VERIFIED)

| Group | Rows | Notes |
|---|---|---|
| Header | 1 | Name, sync line, avatar → Account |
| Layout | 1 | Minimal/full |
| Day shape | 10–11 | Slider, Wake Up, alarm, Wake Up options →, Wind Down, sleep target, learn, night, different days, week start, time format |
| Planning | 10 | Default duration, Routines →, snap, shift later, free time, late/start/Inbox nudges, low-energy, roll unfinished |
| Learning | 4 | Reality, durations, steps, energy |
| Reminders | 6–8 | Task starts, Sound →, quiet hours (+2), day summary, Wind Down reminder, Notification health → |
| Look | 3 | Theme, accent, language |
| Data | 4 | Sync, Calendars →, Export →, Trash |
| About | 4–5 | Help, Siri (iOS), Privacy (holds App lock), About, Feedback |

- **Sub-pages:** 13 (Account, Notifications, Sounds, Wake Up, Calendars, Routines, Export, Help, Privacy, About, Changelog, Siri, Everything).
- **Minimal Settings:** 9 rows. Its "Everything else" repeats the whole tree.
- **Only reachable from Settings:** App lock, Trash/backups/restore, Calendars and travel time, Sounds, Notification health, Help, Changelog, quiet hours, day summary, snap, shift policy, week start, time format, default alerts.

**Observation for concepts:** the rows group naturally into five jobs:
1. Your day (shape, Wake Up, Wind Down)
2. Planning help (defaults, nudges, routines, learning)
3. Reminders and alarms
4. Look
5. Data, account and privacy

A two-pane Settings fits iPad, Mac and web. A grouped list fits phones.

## 5. Duplicates (VERIFIED)

| Surface | Hosts | Shared body? |
|---|---|---|
| Day review | ⋯ sheet, `/review` page, inline Today prompt | Yes, `DayReviewBody` |
| Month grid | Today pull-open, `/month`, the day picker used by six flows | Yes, `MonthGrid` |
| Test alarm card | Minimal Settings, Wake Up page, Notification health, onboarding | Yes, one widget |
| Task detail | Task sheet, `/task/:id` page, expanded editor panel | Sheet and page share `TaskSheetBody`; the panel is the editor |
| Running late | Today ⋯, spread button, minimal live row, prompt card | One sheet, four entries |
| Inbox scheduling | Schedule sheet (raw), pick-time sheet, Drop-on-today panel | No |
| Capture | Add sheet and Inbox add field; both parse and can schedule timed lines | Shared parser |
| Wake Up alarm switch | Day shape, Wake Up page, onboarding | Shared provider |

Q4 lets concepts merge these while keeping every entry point (`FEATURE_PARITY_MATRIX.md` §7).

## 6. States (VERIFIED)

- **Loading and error:** one shared primitive (`shared/states/screen_states.dart`: skeleton thread, `ErrorState` with Try again). Used by Today, Inbox, Week, Month, Search, Past days, Settings root, Routines, Calendars and the task sheet.
- **Screens that show blank while loading or failed** (`SizedBox.shrink`): Day review page, Wake Up page, Sounds, Calendars list, weekly review, Wake Up card, Mission, Everything, Add sheet.
- **Empty:** each screen has its own line. There's no shared empty component, and no explicit empty state for Week or Month (INFERRED).
- **Dense:** overlap knot (must-keep), before/after-day fold, Month "+N more", Week card ellipsis. No overflow handling for many all-day chips (INFERRED).
- **Offline:** only the sync banner, and only inside the shell. It's absent on `/month`, `/day`, `/task`, `/focus`, `/review` and Wake Up.

## 7. Accessibility and keyboard

- **Strong:**
  - semantics on every painted element;
  - 48 dp minimum targets;
  - no text clamping, with measured re-stacking at large text;
  - central reduced motion;
  - a11y guideline tests in 81 files;
  - axe on web;
  - a skip link;
  - full keyboard on Today (↑↓, ⌘↑↓, Space, ↩, Delete, Esc).
- **Gaps:**
  - no "Move to…" semantics action on thread rows;
  - nav labels in fixed-height boxes, with shell goldens lacking a 200 % variant;
  - no bold-text or high-contrast reads;
  - no pointer cursors;
  - ⌘3/⌘4 work where the Week tab is hidden (minimal, compact);
  - no shortcuts for Search, Settings (except Mac ⌘,), Running late or Brain dump.
- **Discovery:** reveal and discovery hints appear only in the compact Today, not in the spread (`today_screen.dart:210-214`, `today_spread.dart:39`), so expanded users never see them.

## 8. Minimal mode (VERIFIED)

- **Wired well:** shell (no tab bar on phones, floating +, hidden tabs, Back-to-Today), Today (no spread, no numbers, Later row), ⋯ (3 items), Add (one step), task sheet (4 tiles + More), Settings (9 rows).
- **Declared hidden but still reachable** (no consumer reads the `FeatureId`):
  - the Inbox Routines button, filters and Completed group (`inbox_screen.dart:199,237,264`);
  - dictation mic;
  - Past days via Search.
- About 28 of 130 `FeatureId`s have a reader.

This is a `main` defect (`ARCHITECTURE_AUDIT.md` A5). Concepts must still show minimal mode, because it's a standing owner choice (ADR-0016).

## 9. Usability findings ranked for the concepts

1. **Today's tools are buried and today-only** (P3). Brain dump and Routines need a first-level home; Q3 leaves the placement to each concept.
2. **Settings is one long list on every width** (P1). It needs grouping by job, with two panes where width allows.
3. **Expanded width is uneven:** no + button for touch, no date picker on the spread, the editor squeezing Today, and Month and `/day` outside the shell (`PLATFORM_BASELINE.md` §3).
4. **Too many entry points for the same thing** (P4): Running late ×4, scheduling ×3, day review ×3.
5. **No native feel on Apple platforms** (P2) and no desktop basics on Mac (hover, cursors, right-click, Edit menu).
6. **States aren't uniform:** blank screens instead of loading or error states on 9 surfaces; no shared empty state; offline invisible outside the shell.
7. **Wake Up time setting** is a linear slider plus wheels (P5); missions are small (P7).

## 10. Runtime check

Screenshots from the Prompt B simulator/emulator sweep (local only) and a local-browser web probe at the playbook widths back this audit. They add R1–R6 (`PLATFORM_BASELINE.md` §9.3): clipped Wind Down labels in the tablet spread, the Undo toast covering the rail's Settings gear, iPad portrait as a stretched phone, and no add button at expanded width confirmed at runtime.
