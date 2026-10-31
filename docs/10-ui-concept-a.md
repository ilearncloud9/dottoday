# 10 · UI spec — Concept A, "the thread and the dot"

Status: **adopted** (ADR-0007). This document is the single source of truth for how Dottoday looks and behaves on every platform. Where it conflicts with `03-ux-spec.md`, this document wins; `03-ux-spec.md` keeps the interaction rules that this file does not restate.

Reference renders live in `docs/design-references/png/` (2× PNG) with their HTML sources in `docs/design-references/src/`. `docs/design-references/README.md` indexes them. The renders are the visual target; this document is the contract.

---

## 1. The idea in one paragraph

A day is a **thread**: a vertical line that starts at Wake Up (sun cap) and ends at Wind Down (moon cap). Every task is a **dot** on that thread: a round tint of the task's colour with its bold icon in the colour itself (ADR-0015). The dot looks the same whether the task is upcoming or done; a ring inside it fills while the task is live, and the round **done circle** at the row's end fills with a tick when the task is done. Between dots the thread is a dotted line (free time); over a task it is a thick coloured segment the length of the task. The same dot vocabulary carries the whole app: the **day dot** in the header fills from Wake Up to Wind Down, the **week strip** is seven small completion dots, the **Inbox** is a dotted ring holding loose dots, the Today tab icon is a dot. Nothing else is decorative.

## 2. Tokens

Implement as `app/lib/core/theme/tokens.dart` (primitives) + `DotTheme` `ThemeExtension` (semantic), per `04-architecture.md` and the design-system structure the kit already prescribes. No raw colours or radii outside `app/lib/core/theme/`.

Theme lives in app/lib/core/theme/ (DotTheme as a ThemeExtension); no second theme folder.

### 2.1 Colour

| Semantic | Light | Dark |
|---|---|---|
| surface | `#FAFAF8` | `#121214` |
| raised (cards, sheets, bars) | `#FFFFFF` | `#1C1C20` |
| text | `#1A1A1C` | `#F2F2F0` |
| muted | `#6B6B70` | `#9A9AA0` |
| outline | `#E2E2DE` | `#2C2C32` |
| hairline / free-time dots | `#C9C9C4` | `#3A3A40` |
| accent (default) | `#3B6CF6` | `#7FA0FF` |
| on-accent | `#FFFFFF` | `#0B1020` |
| accent tint (selected pills) | `rgba(59,108,246,.12)` | `rgba(127,160,255,.22)` |
| success | `#2FA37A` | `#2FA37A` |

Accent is user-selectable in Settings › Look from: indigo `#3B6CF6`/`#7FA0FF`, teal `#1F9E9E`/`#4CC9C9`, coral `#E5674F`/`#FF8A73`, violet `#7A5AF8`/`#A58BFF`. Everything "accent" re-themes; task colours do not. The same four on every platform: no system or wallpaper (Material You) accent (PRD F8.3, M8.4c).

**Task colours** (9, same in both themes; used for dots, segments, chips): coral `#E5674F`, amber `#D99A1F`, mint `#2FA37A`, teal `#1F9E9E`, sky `#2E8FD6`, indigo `#3B6CF6`, violet `#7A5AF8`, rose `#D64F86`, slate `#6B6B70`. Segment of an upcoming task = colour at 28–35 % alpha; done = colour at 45 % with the row struck through; live = solid gradient to the current minute.

Theme mode follows the system by default; iPhone renders are light and Android renders are dark only to show both — both platforms support both.

### 2.2 Type

Inter (bundled, not fetched). `font-feature-settings: tnum` everywhere numbers align (times, counts).

| Role | Size / weight | Where |
|---|---|---|
| Greeting / page title | 28/700, −0.02em (Mac 30/700) | Today, Inbox, Search, Settings headers; Android top bar uses 22/600 |
| Caption | 12/600 uppercase, +0.06em, muted | date caption, section headers (`TIME`, `DURATION`, `DAY SHAPE`) |
| Card title | 15/700 | "Wednesday · Today" |
| Row title | 16/500 (live row 17/600) | task rows |
| Row meta | 12/500 muted | time range, "1 h free" |
| Tab label | 10/500, 10/600 active (Android 12) | tab bar |

### 2.3 Shape, spacing, elevation

Radius: cards 16–18, sheets 28 (top corners), pills 999, Android FAB 16 (rounded square), Mac rail items 16. Hairline outline `0 0 0 1px outline` instead of borders. Floating elements: `0 8px 24px rgba(26,26,28,.10)`. Thread: 6 px wide segments (Watch 5), 2 px dotted free line. Dots: 36 px row dot, 42 px live dot (conic ring 5 px), 44 px day dot (header), 26 px in Mac rows, 22 px in pickers, 8 px week-strip dots, 10/12 px tab-bar dot. Tap targets ≥ 44 px (Android 48).

### 2.4 Motion

Durations 180–240 ms, standard ease-out; all animation collapses to 0 under reduced motion. Dot fill (upcoming → live → done) animates the conic sweep; marking done fills the dot and strikes the title in the same frame with a light haptic. The now-marker (16 px accent dot with 4 px halo) moves on the thread every minute. The day pager snaps with page physics; the month pull-open is a rubber-band drag on the week strip handle.

## 3. Components (names are the Flutter widget names)

| Widget | What it is | Renders in |
|---|---|---|
| `DayDot` | 44 px conic ring, Wake Up→Wind Down progress, small accent dot centre | every header, Watch (18 px) |
| `WeekStrip` | 7 columns: weekday, date, 8 px completion dot (filled past / conic partial / outline future); the selected column filled in the text colour (ADR-0015); on Today the pull handle sits on the day sheet and opens `MonthGrid` | Today (all platforms) |
| `DayPager` | horizontal pager of full-width `DayCard.sheet`s (ADR-0015: no peek, no page dots), always opens on today | iPhone, Android |
| `DayCard` | raised card: "Weekday · Today" + "2 of 7 · 5 h 45 planned", then `Thread`; on Today the `.sheet` form: top-rounded, the month handle on top, no title row (the header carries the numbers, ADR-0015) | iPhone, Android, Mac spread, onboarding |
| `Thread` | the vertical timeline: sun cap, rows, free gaps ("1 h free · add here" drop target), moon cap "Wind Down · 22:00". Both caps are `TaskDot`s at the row-dot size (amber sun, violet sleepy moon); tapping a cap or its time opens its time for every day or only that weekday (R-17) | Today, task sheet, pickers |
| `TaskRow` | dot + segment + meta + title + done circle (ring in the task colour, filled with a white tick when done; ADR-0015); the row stretches with its task (88–288 px); states upcoming / live / done / missed / pinned (lock) / recurring (repeat glyph) | thread, search results |
| `LiveRow` | `TaskRow` expanded: subtask ring "1 of 3", "38 min left", Done / +15 min / Shift the rest | the current task |
| `TaskDot` | the icon dot: tint + bold icon in the task colour, the same in every state; live adds an inner progress ring, skipped a dashed ring and faded icon (ADR-0015) | everywhere |
| `MonthGrid` | 7×(5–6) cells; past cells: completion dot by the date, done titles struck, "missed" in text, "3 of 4 done"; today accent-ringed; future plain; "Light day"/"+N more" | Today pull-open, Mac Month, future-month planning |
| `InboxRow` | outlined dot, duration, title, round accent "+" (Schedule); swipe left = schedule, right = trash | Inbox, Search |
| `NextFreeSlot` | dashed row "Next free slot today 11:30 – 12:30 · fits X" + Place | Inbox |
| `TaskSheet` | tap a row: identity row, Done / +15 / Shift, subtasks (tap to tick), details rows (time, repeat, alerts, colour & icon → editor) | iPhone, Android |
| `AddFlow` | step 1 What (title, colour & icon, Suggestions) → step 2 When (`ThreadPicker`, duration chips, Lands-on row) ; `DurationSheet` (wheel + live preview + presets) ; `TimeMenu` (Change day, Pick from the week, Make it all-day, Send to Inbox, Time zone, Type a time) | iPhone, Android; Mac uses `TaskEditor` panel |
| `ThreadPicker` | scrolling slice of the day's thread through a fixed selection window; new task's segment drawn in its colour; caption "Free until 19:30 · no overlap" or the overlap with the `OverlapKnot` mark | step 2 When, task sheet › time |
| `OverlapKnot` | Dottoday's overlap (ADR-0015 knot amendment): on the thread, two strands in the two tasks' colours cross once between their unchanged dots, beside "Run and Sleep share 15 min"; as a 20 × 14 mark wherever there is no thread | day thread, ThreadPicker caption, Add "Lands on", proposal chips |
| `ProposalSheet` | B3 (11 §0): title + origin chip + ×, the current thread faded to 35 % under the proposed one (accent-outlined dots), a change list with × per line, option chips, Accept / Discard, "Nothing is saved until you accept"; Accept = one write + 30 s Undo | phones as a sheet, Mac/web in the right-hand panel; every proposal flow |
| `ColourIconBlock` | "COLOUR AND ICON": 9 colour dots left, 3 quick icons + "…" right; selected icon tinted in the chosen colour | Add, editors, all platforms |
| `TabBar` (iPhone) / `NavigationBar` (Android) / `Rail` (Mac/web) | Today(dot) · Inbox(tray) · [Week bars, Mac/web only] · Search(magnifier) · Settings(gear); + add button | shells |
| `SettingsGroup` | grouped card, 48 px rows (Android 56), toggles; first group "DAY SHAPE" has the sun→moon mini-thread | Settings |
| `CapacityRing` | 36–40 px conic: planned/15 h, hours inside | Mac Week |
| `WeekSummaryStrip` | Busiest · Lightest · Free · unplanned · Done chips | Mac Week |
| `MicButton` | 44 px round button inside a text box's bottom-end corner: `mic` glyph idle, the Concept A dot pulsing in the accent while listening (static under reduced motion), a dimmed glyph while busy; semantics "Dictate" / "Stop dictation" with a toggled state; Space/Enter; haptic tick on start/stop. Dumb: state in, callbacks out (M14.5, ADR-0014) | Brain dump, Notes — only where on-device speech exists |
| `LaterRow` | minimal layout's Inbox (docs/14 §3, ADR-0016): one quiet row where the thread ends — tray glyph, "Later · 3" in muted meta, 44 px; opens the Inbox; a dragged task let go on it goes back to the Inbox | minimal Today |
| `BackToToday` | "‹ Today" above a page reached from Today when there is no tab bar (minimal, compact); system Back goes there too (ADR-0016) | minimal Inbox, Settings, Search |
| `StatusHint` | one quiet line under a sheet's subtitle: muted text + accent link part, a 44 px tap target, a trailing × "Don't show again"; never red, never a modal (M14.2, D4) | proposal sheets (Break it down, Brain dump); minimal Today's reveal hint (docs/14 §5) |

Icon set: stroke 2 (2.4 when active), round caps, 24-unit grid, drawn as SVG path data (`DotGlyph`). Nav icons are fixed (§3 table). Task icons are the **task icon library** (ADR-0013): 524 icons in 16 categories, generated from `app/assets/design/task_icons.json` by `app/tool/gen_task_icons.dart`. Their English names match Structured's icon names; brand logos are left out. The drawings come from Lucide (ISC) and Tabler (MIT), from Concept A's original 26, and from Dottoday's own drawings. The first category, **Planning & rhythm**, is Dottoday's own: icons for how a day is planned (focus block, buffer, anytime, wind down, week review, low/high energy…), drawn with the thread-and-dot motif. Hand-drawn icons also fill gaps the libraries miss (broom, mop, laundry basket, oven, sink, dishwasher…). The full picker is a full-height sheet (a tall popover from medium width): colour dots, a search field (matches the localized name, the category title and the English key, ignoring accents), then each category under a caption header, built lazily. `ColourIconBlock`'s quick icons are unchanged. Stored keys of the original 26 never change; a stored key the app cannot draw falls back to the plain dot.

## 4. Shells per platform (adaptive by width class, never by `Platform.isX` for layout)

| Width class | Shell |
|---|---|
| compact (< 600) — iPhone, Android phones | floating pill tab bar (iPhone) / Material 3 NavigationBar (Android) with the round/rounded-square add button; sheets from the bottom; Today = `DayPager` |
| medium (600–840) — tablets, narrow windows | `NavigationRail` left, content as compact but wider cards |
| expanded (≥ 840) — Mac, web, large tablets | left rail Today · Inbox · Week · Search · Settings; Inbox as a 300 px sidebar on Today; Today = three-day spread (Yesterday \| Today \| Tomorrow, today as the card); Week = capacity board; Month = grid; editing in a right-hand `TaskEditor` panel, no sheets |

Platform idioms that may differ (and only these): bar shape and height, sheet handle, switch style, chip radius (iOS pill / M3 8 px), FAB shape, menu corners (iOS popover 28 px / M3 menu 16 px, e.g. the A4 Time ⋯ menu; added after M3c), keyboard shortcuts on Mac/web (⌘N add, ⌘T today, ⌘←/→ day, ⌘D done, esc close). Everything else — dot states, thread geometry, copy, order of controls, colours — is identical.

Web = the Mac layout at expanded width and the Android layout (Material) at compact width; it must look like the same app at both.

## 5. Screen inventory — every screen the app needs

"Ref" points at a reference render; "no ref" means build from this spec using the components above. All screens exist on all four platforms unless noted.

### 5.1 First run
| # | Screen | Content | Ref |
|---|---|---|---|
| O1 | Welcome | the dot draws itself, "Your day, as a thread." one-line value prop, Get started / Sign in | no ref — compose from `DayDot` + `Thread` sample |
| O2 | Day shape | "When does your day start and end?" two wheels Wake Up / Wind Down with the live sun→moon mini-thread; this is the one onboarding question that matters | no ref — reuse Settings › DAY SHAPE preview |
| O3 | Habits (optional, skippable) | pick 3–5 starter tasks from suggestion chips (Morning run, Deep work, Lunch, …); they land on tomorrow's thread as upcoming dots | no ref — `ColourIconBlock` + suggestion rows from Add step 1 |
| O4 | Reminders | explain the two notification types (task starts, Wind Down reminder), request permission with the system prompt; optional row "Connect a calendar" (PRD F10) | no ref |
| O5 | Account | Sign in with Apple / Google / email magic link, or "Continue without an account" (local only; sync later) | no ref — plain, raised card, accent primary |
| O6 | Done | the user's first thread with their habits placed; "Open today" | no ref |
Also: returning-user sign-in, magic-link "check your mail", account error, and a restore-from-sync progress state.

### 5.2 Core
| # | Screen | Ref |
|---|---|---|
| T1 | Today (day pager) | `Main`, `A-android-today` |
| T2 | Today with month pulled open | `A-ios-today-month` |
| T3 | Planning a future month (month → pick a day → that day's thread) | `A-ios-future-month` |
| T4 | Task sheet (tap a row) | `A-ios-task-sheet` |
| T5 | Mac/web Today three-day spread | `A-mac-today-alt1-spread` |
| W1 | Week (Mac/web only; phones use the strip + month) | `A-mac-week-alt3-board` |
| M1 | Month (Mac/web) | `A-mac-month` |
| I1 | Inbox | `A-ios-inbox`, `A-android-inbox`, `A-mac-inbox` |
| A1 | Add step 1 What | `A-ios-add-what`, `A-android-add-what` |
| A2 | Add step 2 When | `A-ios-add-when`, `A-android-add-when` |
| A3 | Duration sheet | `A-ios-add-duration`, `A-android-add-duration` |
| A4 | Time ⋯ menu | `A-ios-add-time-menu`, `A-android-add-time-menu` |
| E1 | Task editor (Mac/web panel; on phones the task sheet's Edit opens the same fields as a full sheet) | `A-mac-editor` |
| S1 | Search | `A-ios-search`, `A-android-search` (Mac: same content in the main pane) |
| P1 | Settings | `A-ios-settings`, `A-android-settings` (Mac: same groups in the main pane) |
| WA1 | Watch "Now" | `Watch` (Watch is a companion: Now, Next, Done / +15; no editing) |

### 5.3 Secondary (no refs — derive)
Repeat editor (never / daily / weekdays / weekly on … / monthly / custom; end date; "this one or all future" on edit and delete); Alerts editor (at start, N min before, Wind Down reminder); Subtask editor (reorder, rename); Colour & icon full picker (sheet with the 26 icons in a grid); Change day picker (the month grid in a sheet); Time zone picker; "Running late" sheet (shift the rest / skip / shorten); Day review at Wind Down ("3 of 7 done · move the rest to tomorrow?"); Inbox swipe confirmations and Undo snackbar; Completed group expanded; Search empty and no-results; Settings sub-pages (Calendars import list, Export, Help, Privacy, About); Account page (sign in/out, delete account with confirm); Sync status sheet (last synced, conflicts: local vs remote with "keep mine / keep theirs"); offline banner; permission-denied states for notifications; Mac/web keyboard shortcut sheet (⌘/).

Added in M14 (owner, 2026-10-28; derived, no render): **Settings › Siri & Shortcuts** (iPhone only, D3 — the five phrases, how to ask Siri, Open Shortcuts); **Brain dump with mic** (the `MicButton` in the box, the listening caption, a first-use tip card, the denied line); **Notes with mic** (the editor's NOTES field with the `MicButton`); **the "simple rules" proposal state** (origin "simple rules" + the optional `StatusHint`); Settings › Privacy › Help with thinking with the AI status line.

### 5.4 System states — every list/screen must implement
Loading (skeleton dots on a dotted thread, never a spinner for > 300 ms), empty (Today: "Nothing planned · pull the strip to plan or tap +"; Inbox: "Inbox is clear"), error (inline, actionable, never a raw exception), offline (banner, everything still editable), reduced motion, large text (200 %: rows grow, nothing truncates to ellipsis without a tooltip/sheet), RTL (all geometry Directional), dark/light, VoiceOver/TalkBack (every dot has a label with state: "Deep work, live, 38 minutes left").

## 6. Behaviours that define the concept (must-haves)

- Today always opens on the current date; swiping the pager or tapping the strip changes day; the header caption chevron and the strip's pull handle both open the month.
- Tap the done circle = mark done (with undo); tap it again = not done; the task keeps its place. Tap the dot or the row = task sheet (the live dot opens Focus). Long-press = drag to another time / day: drop on a free gap (kept inside it when it fits) or on another task's row, which overlaps the two — drawn as the knot between their unchanged dots with "Run and Sleep share 15 min" (ADR-0015); on Mac drag between columns. A task's length changes in the sheet's duration; the day thread has no edge resize (ADR-0015). While dragging, a landing preview sits on the thread at the drop time; holding over a week-strip day pages to it; Wake Up is the all-day drop zone; the Inbox tab unschedules; a Trash target shows above + (Trash with Undo); the + button itself drags onto the thread to add at a time (ADR-0015 amendment).
- The live task's dot fills in real time; the now-marker travels the thread; "38 min left" updates every minute.
- Free gaps are drop targets and carry "N h free · add here".
- Add never asks for what it can infer: typing "Go shopping 5pm 1h" fills time and duration; Suggestions come from the user's own history (same title → last used time, duration, colour, icon).
- The `ThreadPicker` never lets the user pick a time blind: the slice shows neighbours and warns on overlap.
- Wake Up / Wind Down drive: the day dot, the thread's caps, free-time maths, capacity rings, the week's "Free · unplanned", and the Wind Down reminder.
- Past days show what happened: completion dot, struck done titles, "missed" items, "N of M done".
- Mac/web never use sheets for editing; the right panel edits in place. Esc closes, ⏎ saves, ⌘D marks done.

## 7. Done criteria for any UI task

1. Matches the reference render (or this spec where there is none) at 1× and 2×, light and dark, in a golden test.
2. Uses only `DotTheme` tokens and the components in §3 (no ad-hoc colours, radii, icons).
3. Works at compact / medium / expanded widths; the Mac and web builds are pixel-equivalent at the same width.
4. Passes the a11y checklist in `08-testing-qa.md` plus: every `TaskDot` has a semantic label with its state; 44/48 px targets; 4.5:1 text contrast on both themes.
5. All copy from the l10n ARB; the strings in the renders are the English source.
6. Screenshot sweep added to the design-review matrix (`08-testing-qa.md`) for the new screen.
