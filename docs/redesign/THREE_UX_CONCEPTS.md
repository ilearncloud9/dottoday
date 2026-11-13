# Three UX concepts (Prompt C)

**Status:** proposal for owner review, 2026-11-03, `redesign/design-lab` at `c798c3d4`. Planning and documentation only. No UI code changed; nothing here is built.

**Inputs:**
- `PRODUCT_BRIEF.md` (approved).
- Q1–Q9 (`OPEN_PRODUCT_DECISIONS.md`).
- `FEATURE_READINESS.md` and `FEATURE_PARITY_MATRIX.md` (Prompt A).
- `PLATFORM_BASELINE.md`, `ARCHITECTURE_AUDIT.md`, `UX_AUDIT.md` and `REUSE_VS_REPLACE.md` (Prompt B).
- `DESIGN_PRINCIPLES.md`, `PLATFORM_QUALITY_MATRIX.md` and the guide (`references/platform-guidelines/premium-native-experience.md`, cited as "guide §").

**Comparison, six-task exercise and recommendation:** `CONCEPT_COMPARISON.md`.

**Labels:**
- **[Approval]**: changes brand, a core workflow or product behaviour, or removes/merges/renames a destination or entry point (`DESIGN_PRINCIPLES.md` §4). Needs the owner's yes before it's prototyped as the default.
- **[Adapt]**: ordinary platform adaptation. Shown at review, no separate approval.
- **[Future]**: planned or not yet working. Shown as such, never as if it already works.
- **[Feasibility]**: needs a technical check (rendering, package or native view) before Prompt E.

**Owner ruling (2026-11-03, start of Prompt D):** every [Approval] item, including all 16 in `CONCEPT_COMPARISON.md` §4, is a **design hypothesis, NOT APPROVED FOR IMPLEMENTATION**. They're prototyped for comparison only. Three get explicit before/after comparisons in Prompt D: Settings placement, the unified task surface, and merging duplicate screens. **iOS long-press keeps hold-to-select by default** (R-05) in every concept; any alternative is shown only as a labelled option.

**Tap counts** follow `UX_AUDIT.md` §2: taps and key presses, typing excluded, a drag counts as 1.

---

## 1. What stays identical in all three concepts

**Features and meaning:**
- Every row of `FEATURE_PARITY_MATRIX.md` stays reachable on every platform it reaches today.
- Domain, data, sync, notifications, Wake Up, entitlements (free; `isPro => true`) and pricing are unchanged.
- The proposal rule stands: Brain dump, Rebalance, Break it down and Routine drop write nothing before Accept.
- Overlap-on-add stays, and so does the overlap look (the knot) (Q2).
- Snooze stays reminder-only (Q1).
- Minimal mode remains a standing choice (ADR-0016).
- AI stays on-device first. Cloud AI isn't shown (Q12).

**Copy:**
- The no-shame rule applies.
- Any visible "late/missed/failed" is removed. *New observation:* rows say "· not done" after a task's end time (curated shots 11–12).
- **Every concept replaces shame-oriented copy with respectful, useful language:**
  - "· not done" → "ended 9:15 · still open", or simply the ring with "Mark done" / "Move" offered;
  - "late" → "need more time?";
  - an unfinished day → "3 open · carry over?".
  - The rule is part of each prototype's copy check.

**Routes and deep links (one meaning everywhere, guide §13.2):**
- Kept: `/today`, `/day/:date`, `/week`, `/month`, `/inbox`, `/search`, `/settings/...`, `/task/:id`, `/add`, `/focus/:id`, `/review`, `/wake-up`, `/wake-up/mission/:date/:kind`, `dottoday://`.
- **Changes in every concept [Adapt]:**
  - `/day/:date`, `/month` and `/task/:id` move inside the shell (A1, `ARCHITECTURE_AUDIT.md` §7).
  - The selected day, week or month and the open task go in the URL (`/day/2026-11-03?task=<id>`), so web refresh and Back/Forward restore them.
  - Web moves from hash URLs to path URLs [Feasibility: server rewrite on the static host].
- A concept that adds a destination (B's Plan and Review, C's Now) adds a route. It never renames an existing one.

**Fixes all three concepts apply:**
- The Prompt B findings are fixed by design in every concept:
  - **R1:** side-day labels wrap, never clip.
  - **R2:** toasts sit above the navigation, never over it, and time out (4–6 s, longer with an action, never sticky).
  - **R3:** at most one tip shows at a time, and prompts never push the plan below the fold.
  - **R4:** an Add control is visible at every width.
  - **R5:** reading width is capped.
- Every Today action gets a non-gesture path, including a "Move to…" screen-reader action (`UX_AUDIT.md` §7).
- The nine blank screens get loading and error states. Offline state shows everywhere, not only inside the shell.

**Approval rule for new IA:** each concept says where every Today ⋯ item lives (Q3). Brain dump and Routines get an entry at most 1 tap from Today or Add.

## 2. Platform presentation baseline (applies to every concept)

This is the guide's §9 matrix turned into Dottoday decisions. Each concept uses this baseline and lists only where it differs. All entries are **[Adapt]** unless marked otherwise.

| Element | iPhone | iPad | Mac | Android phone | Android tablet / foldable | Web desktop | Web mobile |
|---|---|---|---|---|---|---|---|
| **Primary destinations** | Tab bar (iOS 26 floating style) | Sidebar ⇄ tab bar by window width | Sidebar + toolbar; Settings in its own window (⌘,) | M3 navigation bar | Navigation rail with Add at its top, or drawer when expanded | URL-aware sidebar | Bottom bar, browser-safe |
| **Secondary navigation** | Push stack, large titles that collapse | List-detail; push when compact | Panes and selection; inspector | Back stack, top app bar | List-detail, supporting pane | Routed panes | Routed pages |
| **Temporary flows** | Sheets with detents, action sheets, pull-down menus | Popovers anchored to the control; sheets when compact | Popovers, menus, attached sheets, inspector | M3 bottom sheets, dialogs | Side sheets, dialogs | Popovers, dialogs; each opening is a history entry | Full-page routes or bottom sheets that respect browser chrome |
| **Back** | Back button + edge swipe; sheets swipe down | Same, plus ⌘[ and Esc | Esc dismisses; ⌘W closes the window; ⌘[ ⌘] for history | System Back + predictive Back; closes transient UI first | Same, plus pane logic | Browser Back/Forward authoritative; Esc closes popovers | Browser Back; **no left-edge swipe gestures** (Safari uses them) |
| **Controls** | Cupertino switch, wheels in pickers, segmented control | Same, pointer-aware | Mac-style switch/checkbox, popup buttons, steppers, compact date fields | M3 switch, M3 time picker (dial or input), chips | M3 large-screen | Web controls: checkbox-style toggles, inline date fields, visible focus | Touch-sized web controls |
| **Pointer** | — | Hover lift, pointer shapes | Hover, cursors, right-click menus | — | Hover and right-click with a mouse | Hover, cursors, right-click menu | — |
| **Keyboard** | Hardware-keyboard shortcuts | Full set; hold ⌘ shows the list | Full menu-bar set (below) | Contextual | Ctrl set | Single-key shortcuts outside text fields (`n` add, `/` search, `t` today, `[` `]` days, `?` help); never ⌘/Ctrl N, T or W | — |
| **Selection** | Long-press hold (R-05) or Select in the menu | + ⌘/⇧-click with a pointer | Click, ⌘-click, ⇧-click range | Long-press | + Ctrl/Shift-click | Click, Ctrl/⌘-click, Shift-click | Long-press |
| **Feedback** | iOS haptics (snap tick, complete success); spring motion | Pointer + haptics on touch | Hover/focus/menu highlight; no haptics | M3 state layers + Android haptics | Same | Hover/focus/active | Active state |
| **Motion** | Spring and zoom transitions; sheet morph | Same | Crossfade and slide-over; no iOS page slide | M3 container transform, predictive-Back preview | Same | Short fades; no page slide | Same as desktop web |
| **Sharing / files** | iOS share sheet; share into Inbox | Same + drag and drop | Native save panel; share extension | Sharesheet | Same + cross-app drag | Download/upload | Download; Web Share where available |
| **Type** | System font for chrome; content face per concept (K6) | Same | Same | Same | Same | System stack for chrome | Same |
| **Glass / materials** | Approximated with blur + tint, labelled; native only with a platform view [Feasibility, K8] | Same | Vibrancy approximated [Feasibility] | Tonal surfaces; no glass | Same | Solid surfaces | Solid surfaces |
| **Chrome icons** | Platform-style chrome icons; task icons stay one library (K9). SF Symbols need a native path [Feasibility] | Same | Same | Material Symbols style | Same | Concept's own | Same |
| **Accent** | Concept palette; no wallpaper colour (K7) | Same | Same | Same | Same | Same | Same |

**Mac menu bar (every concept):**
- **App:** About, **Settings… ⌘,**, Hide, Quit.
- **File:** New Task ⌘N, New Brain Dump ⇧⌘N, Export…, Import…, Close Window ⌘W.
- **Edit:** Undo/Redo, Cut, Copy, Paste, Select All, Find ⌘F.
- **View:** concept-specific views ⌘1–⌘4, Show Sidebar ⌃⌘S, Show Inspector ⌥⌘I.
- **Go:** Today ⌘T, Previous/Next Day ⌘[ ⌘], Go to Date… ⇧⌘G.
- **Day:** Running Late, Shift the Rest, Duplicate Day, Copy Day as Text, Review the Day.
- **Window**, **Help**.
- Menu items show live enabled state.

This fixes Prompt B's Mac gaps (no Edit or Help menu, no ⌘W, no hover or cursors). The existing `PlatformMenuBar` and the menu-bar status item stay.

**Android:**
- Edge-to-edge with the system-bar style set.
- Predictive Back on every route and sheet.
- No iOS wheel: time is set with the M3 time picker (dial or keyboard input).
- **Foldables:** panes split at the hinge (`displayFeatures`), never across it.
- **Split-screen:** each pane keeps its selection when resized.

**iPad landscape, Mac and foldables** weren't verified at runtime in Prompt B. These designs come from the guide and code, not from observed behaviour.

---

## 3. Concept A — Refined Timeline: "the thread, finished"

### 3.1 Idea and identity

The day is still one vertical thread of dots, "the timeline is the product", but finished to a premium standard.

**Brand: keep and refine (brief §15):**
- **Dots:** gain depth: a soft inner highlight and a task-colour halo.
- **Thread:** fills with colour as time passes. The now-marker becomes a glowing bead moving along the thread.
- **Completing a task:** the dot fills, and a short pulse runs down the thread to the next dot (it collapses to a fade under reduced motion).
- **Overlap knot:** keeps its meaning and gets a cleaner drawing.
- **Type:** content stays in a refined Inter scale; chrome uses system type (K6).

**Changes Today's chrome, not its model.**
- The ⋯ catch-all becomes one organised **Day menu** plus two first-class actions.
- Settings becomes five jobs.
- The task sheet and the editor merge into one surface.

### 3.2 Destinations

| | iPhone | iPad | Mac | Android phone | Android tablet | Web desktop | Web mobile |
|---|---|---|---|---|---|---|---|
| **Primary** | Tabs: **Today · Inbox · Calendar · Search** | Sidebar: Today, Inbox (count), Calendar (Week, Month), Search, Routines, Reviews | Same sidebar | Nav bar: Today · Inbox · Calendar · Search | Rail (Add on top) + same four | Sidebar, same as Mac | Bottom bar, same four |
| **Settings** | Avatar button in Today's top bar | Sidebar footer | **App menu ⌘, window** (not in the sidebar) | Avatar in the top app bar | Rail footer | Sidebar footer + `/settings` | Avatar in the header |

**[Approval]** for the destination set:
- **Settings leaves the tab bar.** It's reached from the avatar, the sidebar footer or ⌘,.
- **"Calendar" is a new tab:** Month on compact; Week + Month where the width allows (Q5). On phones this replaces reaching Month only by pulling open the week strip, which still works.
- Week stays out of compact widths (no phone Week view is added).

### 3.3 Today

**Compact (iPhone 390 pt, Android 412 dp):**

```text
┌──────────────────────────────────┐
│ Tue 3 Nov ▾            ⟳  (◉)    │  large title collapses; ⟳ sync dot; avatar
│ M  T  W  T  F  S  S              │  week strip (swipe = change week)
│    ●                              │
│ ┌ 1 tip ───────────────── × ┐    │  at most one tip, one line (R3)
│ ☀ Wake Up 7:00                   │
│ ●─ 9:00–9:15  Standup        ○  │  swipe → Done; swipe ← Move / Delete
│ │  45 min free · add here        │
│ ●─ 10:00–12:00 Deep work     ○  │
│ ◉ now ───────────────────────── │  glowing bead
│ ☾ Wind Down 23:00                │
│                                  │
│ [Day ▾]                 [ + ]    │  Day menu chip · Add (long-press: Brain dump,
│ Today  Inbox  Calendar  Search   │  Routine, Paste list)
└──────────────────────────────────┘
```

**Inbox tray:** pull up from the bottom edge of Today, or tap the Inbox count in the title. It shows Inbox items you can drag straight onto the thread. That's Inbox → timeline in 2 actions on phones (target ≤ 2, `00-vision.md`; today it's 3). [Adapt]

**Day menu**, one control replacing ⋯, grouped:

| Group | Items |
|---|---|
| Replan | Running late (+5/15/30), Shift the rest |
| Plan | Brain dump, Drop a routine, Pick today's one thing, Duplicate day |
| Reflect | Review the day, This week |
| View | Low-energy mode, Show less (minimal), Plan/Reality |
| Share | Copy day as text |

- **iPhone:** native pull-down menu with sections.
- **Android:** M3 menu.
- **Mac:** the menu-bar **Day** menu and a toolbar button.
- **Web:** a popover.

**Every item works on every day [Approval]**, except where the feature itself is about today:
- Running late is greyed out with a reason.
- Brain dump still plans into today, or into the day being viewed if you approve that behaviour change.

**Medium (iPad portrait 834 pt, Android tablet portrait, web 600–839):**
- A collapsible sidebar overlays the content.
- The thread is centred with a capped reading width (R5).
- The task opens in a **popover** (iPad) or **side sheet** (Android). The phone-style bottom sheet with a drag handle goes (R3).

**Wide (≥ 840; iPad landscape, Mac, Android tablet landscape, web):**

```text
┌ sidebar ──┬ toolbar: ‹ Today › [Tue 3 Nov ▾] [Running late] [Day ▾] [+] ─┬ inspector ┐
│ Today      │  Mon (dimmed) │  TUE · TODAY  │  Wed (dimmed)                │ Standup   │
│ Inbox  2   │  thread       │  thread       │  thread                      │ 9:00 15m  │
│ Calendar   │               │               │                              │ repeat…   │
│ Search     │  labels wrap, never clip (R1)                                │ alerts…   │
│ Routines   │                                                              │ subtasks  │
│ Reviews    │  Inbox shows as a supporting column from ≈ 1220 px           │ [Done]    │
│ ⚙ Settings │                                                              │           │
└────────────┴──────────────────────────────────────────────────────────────┴───────────┘
```

- **Date title:** a date picker popover, which fixes the spread's missing date picker.
- **Spread:** one-day ⇄ three-day toggle (View ⌘1/⌘2).
- **Inspector:** at 840–1100 px it **overlays** rather than squeezing Today to 339 px (`PLATFORM_BASELINE.md` §3). It docks from 1100 px.

### 3.4 Capture, edit, complete

- **Add (2):** + → one line with live chips for time, duration and day as you type ("Gym 6pm 1h" shows three chips) → Return.
  - "Add another" stays.
  - Pasting a list shows "Add 4 tasks" (R-07).
  - **iPhone:** a sheet at the medium detent that grows with the keyboard.
  - **Mac:** a popover from the toolbar +, or ⌘N anywhere.
  - **Web:** a popover; `n` from anywhere.
- **Brain dump and Routine** are modes in the same Add surface. They're a segmented control at the top: **Task · Brain dump · Routine**. Both are also in the long-press menu on +, and in File ⇧⌘N on Mac.
  - This makes them 1 tap from Add (Q3 rule).
  - Both still go through the proposal sheet.
- **One task surface [Approval: merges the task sheet, the `/task/:id` page and the editor panel; keeps all three entry points]:** tap a dot.
  - **Phones:** a sheet opens at the medium detent with the summary and four actions: **Done · Move · Shift the rest · Focus**. Pulling it to the large detent *is* the full editor, with no second sheet. Edits save as you go; Done closes. That's one fewer step than today's sheet → Edit → Save.
  - **iPad and wide windows:** the same content in the popover or inspector.
- **Move** fixes the dead Move tile. It opens a day and time picker:
  - iPhone: wheels;
  - Android: M3 time picker;
  - Mac and web: inline fields.
  - It is also the screen-reader "Move to…" action.
- **Complete (1):** tap the ring, or swipe the row (iPhone leading swipe, Android swipe). Undo is in the toast and ⌘Z.
- **Reopen (1):** tap the filled ring.

### 3.5 Scheduling and calendar

- **Change day:**
  - week strip or swipe (1);
  - far date: tap the title → month popover/sheet → day (2; today it's 3 on wide);
  - Mac: ⇧⌘G.
- **Calendar destination:** Month grid on phones. Week and Month on wider windows, with a segmented Week | Month control and View ⌘3/⌘4.
  - Tapping a day goes to `/day/:date` **inside the shell** (A1).
- **Drag to move:** unchanged, overlaps allowed, the knot kept.
  - **Shift the rest:** from the live row (1–2) or the Day menu.
  - **Running late:** the toolbar button on wide windows (1 + choice = 2), Day menu on phones (3).
- **Device and online calendars:** events stay on the thread, as today.

### 3.6 Settings (P1)

The root has **six rows** under the account header. Each row opens a page, or a pane on wide windows.

| Group | Contents |
|---|---|
| **Your day** | **Wake Up & Wind Down dial** (one control for both times), different days, sleep target, Wind Down learning, night on the day dot, Wake Up alarm + options + missions + test alarm |
| **Planning** | Default duration, snap, shift policy, free time, nudges, low-energy, roll unfinished, **Routines**, learning (reality, durations, steps, energy) |
| **Reminders** | Task alert defaults, sounds, quiet hours, day-start summary, Wind Down reminder, **Notification health** |
| **Appearance** | Layout (full/minimal), theme, accent, language, time format, week start |
| **Data & privacy** | Account & sync, calendars, export/backups/import, trash, app lock, AI status |
| **Help & about** | Help, What's new, Siri & Shortcuts (iOS/iPad), feedback, about |

- **Search Settings** sits at the top (pull-down search on iPhone, search field elsewhere).
- **Duplicates merged, every entry point kept [Approval per parity matrix §7]:**
  - the alarm switch and both times live once, under Your day; onboarding and the Today sun/moon caps open the same control;
  - one test-alarm card;
  - notification health appears once and is linked from Wake Up;
  - the two "After" labels are renamed by meaning.
- **Layout by platform:**
  - iPad, Android tablet and web: a two-pane layout.
  - Mac: a Settings window with toolbar panes, one per group.
- **The dial (P5):** a 24-hour ring with a sun handle and a moon handle; the arc between them is "awake". It saves on release (one write, one alarm re-sync).
  - **[Future] [Approval: Q8 domain change]:** crossing midnight is shown, and is marked "needs the after-midnight model" until approved.
  - **Android** may instead use the M3 dial idiom for the single-time picker inside each handle's detail.

### 3.7 Wake Up and missions (P7)

- **Wake Up card:** full-screen. The sun rises along the thread, then today's first three dots slide in.
- **Missions fill the screen:**
  - Catch the dot gets particle trails and physics;
  - Breathe is a full-screen expanding ring.
  - The `keepMission` timer, routes and minimal variant are unchanged.
- **Reduced motion:** a calm static scene with the same information.

### 3.8 Planned and partial features in A

- **Shown as [Future] with a disabled state and a plain-language reason:**
  - the dial crossing midnight (Q8);
  - glass labelled "approximated" [Feasibility];
  - SF Symbols chrome [Feasibility].
- **Shown only where they work today:**
  - web push (labelled "while this tab is open" until delivery is complete);
  - PWA offline.
- **Not shown:** cloud AI and calendar webhooks.

### 3.9 Accessibility and usability

- The thread reads as an ordered list.
- Each dot exposes: Done, Move to…, Shift the rest, Select, Focus.
- Text scale to 200 % re-stacks rows, as today.
- **Risks:**
  - the Day menu is still a menu (better grouped, but one level deep);
  - the inbox tray gesture needs a visible handle;
  - the medium-detent sheet must stay usable at 200 % text.

### 3.10 Complexity and tradeoffs

**Medium.** Per `REUSE_VS_REPLACE.md`:
- **Reused:** painters, gestures, providers and routes.
- **Rebuilt:** shells, the task surface, Settings, the Day menu and missions.
- **Lowest risk** to the owner's top job ("the timeline is the product").
- **Downside:** it's the least different. It can feel like "the same app, polished", and wide windows remain a day thread rather than a planning workspace.

---

## 4. Concept B — Productivity Workspace: "plan on the left, do on the right"

### 4.1 Idea and identity

The IA follows the task flow: **capture → plan → do → review**.

**Destinations:**
- **Today:** do.
- **Plan:** Inbox, Routines and Brain dump beside a time canvas (day, three-day or week).
- **Review:** the day review, This week, Past days, reality and learning in one place.
- **Search:** with a command palette on keyboards.

**Brand: evolves substantially [Approval] (brief §15):**
- **Workspace palette:** graphite and paper with one accent; denser type for planning, generous type for Today.
- **Tasks:** drawn as **time-proportional blocks** on a shared time grid in Plan.
- **The dot** remains the block's icon chip and is the only colour.
- **Today** keeps a simplified thread so "what's next" stays instant.
- **Overlap knot:** kept on overlapping blocks (must-keep). It's drawn on the block edge, and the blocks sit side by side.

**Rearranges existing features only (Q6).** No projects or tags.
- **[Future] sketch only:** a greyed "Lists" group in Plan's sidebar, labelled "possible later; not part of this release". It isn't built and isn't counted in parity.

### 4.2 Destinations

| | iPhone | iPad | Mac | Android phone | Android tablet | Web desktop | Web mobile |
|---|---|---|---|---|---|---|---|
| **Primary** | Tabs: **Today · Plan · Review · Search** | Sidebar: Today · Plan (Inbox, Routines, Brain dump) · Calendar views · Review · Search | Same sidebar + **⌘K command palette** | Nav bar: Today · Plan · Review · Search | Rail + list-detail | Sidebar + **Ctrl/⌘K** (works in browsers) | Bottom bar, same four |
| **Settings** | Avatar | Sidebar footer | ⌘, window | Avatar | Rail footer | Sidebar footer | Avatar |

**[Approval]:**
- **Inbox stops being a tab;** it becomes the first section of Plan, and `/inbox` opens Plan with Inbox selected.
- **Review is a new destination** that merges three day-review forms, This week and Past days. Past days moves **out of Search**.
- **Week becomes reachable on compact** as a **week agenda** list in Plan, a new presentation of existing week data. Q5 only covered "wherever width allows".

### 4.3 Today

Today is deliberately lighter than in A: it's the "do" view.

```text
compact                                   wide (Mac / web / iPad landscape)
┌──────────────────────────────┐   ┌ sidebar ┬ Plan ─────────────────────────────────┬ inspector ┐
│ Today · Tue 3 Nov      (◉)   │   │ Today   │ INBOX (2)   │ Mon   Tue   Wed   Thu  │ Deep work │
│ NOW  Deep work  10:00–12:00  │   │ Plan ▸  │ + capture…  │ ▇▇    ▇▇▇         ▇    │ 10:00 2h  │
│ ━━━━━━━━━━━━━━━  52 min left │   │  Inbox  │ ▢ Birthday  │ ▇     ▇▇◇▇  ▇▇         │ alerts…   │
│ NEXT Lunch 12:30             │   │  Routin.│ ▢ Car svc   │       ▇▇    ▇    ▇▇    │           │
│ ───────── thread (rest) ──── │   │  Dump   │ ROUTINES    │ drag blocks; ◇ = knot  │           │
│ ●─ 12:30 Lunch            ○ │   │ Review  │ ▢ Morning   │                        │           │
│ ●─ 18:00 Gym              ○ │   │ Search  │ BRAIN DUMP  │                        │           │
│ [Replan ▾]           [ + ]  │   │ ⚙       │ ▢ (compose) │ [Day|3 days|Week|Month]│           │
│ Today  Plan  Review  Search │   └─────────┴─────────────┴────────────────────────┴───────────┘
└──────────────────────────────┘
```

- **Replan menu** (replaces the replan half of ⋯): Running late, Shift the rest, Rebalance, Low-energy mode, Pick one thing.
- **Today's toolbar:** Copy day as text and Duplicate day sit under a Share/More button.

### 4.4 Capture, plan, edit

- **Capture field:** always visible at the top of Plan's Inbox ("+ capture…"). It also opens from + on Today.
  - **Quick add (2):** with a time, the task goes straight to the day; without one, it lands in Inbox.
- **Brain dump:** a composer section in Plan.
  - **Taps:** Plan → Brain dump (2) → type or speak → Plan it (3) → Accept (4).
  - It's a first-level item, never buried.
- **Routines:** a section in Plan. On wide windows, drag a routine onto a day column; Accept the proposal.
- **Inbox → timeline:**
  - **Wide:** drag from Inbox onto the canvas (1 drag). Done in 1.
  - **Compact:** Plan (1) → item → Schedule (2) → pick a slot on the mini-thread (3). That's **3**, one more than A.
- **Edit:** the inspector on wide windows; on phones, the same merged task sheet as A [Approval, same merge].
- **Complete and reopen:** 1 tap on Today's rows; a checkbox on blocks.

### 4.5 Scheduling and calendar

- **Plan's canvas:**
  - Day, 3 days and Week share one time grid, plus a Month view.
  - Drag a block to move it; drag across columns to change the day.
  - Overlaps are allowed (the knot).
  - **Snapping:** keeps the user's setting. Today Week snaps to a fixed 15 min; making it follow the setting is a behaviour change [Approval].
- **Change day:** Today's title opens a month popover (2); Plan's arrows or ⌘[ ⌘].
- **Mac/web keyboard grid navigation:** arrows move focus between blocks; ⌥↑↓ move the block by the snap step; Return opens it.

### 4.6 Review destination [Approval]

**One place:** Today's review, This week (with share), Past days with the year strip, the Reality thread and learning reveals.
- **Today keeps a single, dismissible "Review the day" prompt card** in the evening (that entry point is kept).
- **Wind Down notification:** opens `/review`, as today.

### 4.7 Settings

- **Same six groups as A**, plus **contextual settings** where the work happens:
  - Plan › "Plan settings…" (defaults, snap, nudges);
  - Review › "Learning settings…";
  - a task's alerts › "Alert defaults…".
- **Global Settings remains the complete index**, so every row stays reachable in one place.
- **Mac:** Settings window with toolbar panes.

### 4.8 Wake Up and missions

- **Wake Up card:** becomes a **morning briefing**: today's blocks, inbox count, and "plan the rest" (opens Plan).
- **Missions:** same full-screen treatment as A, in B's visual language.
- **Dial:** in Settings › Your day (Q8, as A).

### 4.9 Planned and partial features in B

- **Same handling as A.**
- **Plus:** the "Lists" sketch, labelled [Future], is non-interactive and outside parity.

### 4.10 Accessibility and usability

- **The time grid is the hardest surface to make accessible.**
  - It needs a parallel list structure for screen readers (per day, ordered by time);
  - full keyboard grid navigation;
  - non-drag "Move to…".
  - Drag between columns needs a clear drop preview.
- **Risks:**
  - **Density can overwhelm** the ADHD audience (brief §2, "Calm").
  - **Phones get a heavier app:** Inbox is one level deeper and scheduling takes 3 taps.
  - **Two kinds of visual** (blocks in Plan, thread in Today) dilute "the timeline is the product".

### 4.11 Complexity and tradeoffs

**High.** New pieces:
- the time-grid canvas with cross-column drag and its accessibility;
- the command palette;
- the Review hub;
- the Plan workspace, in three layouts;
- a new visual language.

**Reused:** domain, data, providers, proposal sheet and gestures (mechanics only).

**Strongest for:** multi-device time-blockers on Mac, web and tablets.

**Weakest for:** a phone-first, "just tell me what's next" user.

---

## 5. Concept C — Focus-First Planner: "Now"

### 5.1 Idea and identity

**The entry point answers one question: what do I do now?** The timeline is one swipe away and never loses a capability.

**Brand: new identity allowed (brief §15) [Approval]:**
- **The orb:** one large dot that fills like a clock as the current block progresses.
- **The day ribbon:** a thin horizontal strip of the whole day under it, so the timeline is always visible at a glance.
- **Palette and type:** warm, calm, generous type.
- **Thread:** the full vertical thread survives as the **Day** view, restyled in the orb language.

**Time-of-day aware:** Now changes with the day shape.
- **Morning**, after Wake Up: "plan your day" with today's one thing and a routine.
- **Daytime:** current and next.
- **Evening**, after Wind Down: review and plan tomorrow.

### 5.2 Destinations

| | iPhone | iPad | Mac | Android phone | Android tablet | Web desktop | Web mobile |
|---|---|---|---|---|---|---|---|
| **Primary** | Tabs: **Now · Day · Inbox · Search** | Sidebar: Now, Day, Calendar, Inbox, Search, Reviews | Sidebar + a **floating "Now" mini window** (Window › Show Now ⌥⌘0) and the existing menu-bar item | Nav bar: Now · Day · Inbox · Search | Rail + list-detail (Now + Day side by side) | Sidebar | Bottom bar, same four |
| **Settings** | Avatar on Now | Sidebar footer | ⌘, | Avatar | Rail footer | Sidebar footer | Avatar |

**[Approval]:**
- **Now becomes the default entry; Today becomes "Day".** `/today` keeps working and opens the Day view of today, so links don't break. A new `/now` route is added.
- **The Mac mini window is a new window type** [Feasibility: multi-window support in Flutter desktop].

### 5.3 Now (compact)

```text
┌──────────────────────────────────┐
│ Tue 3 Nov · 10:42           (◉)  │
│ ▁▂▂▅▅▅▅▅▃▁▁▂▂▁  ribbon (tap=Day) │  whole day; now = notch
│                                  │
│            ◯◯◯◯◯                 │
│          ◯  ORB   ◯              │  fills as Deep work progresses
│            ◯◯◯◯◯                 │
│        Deep work                 │
│      10:00–12:00 · 78 min left   │
│ [ Done ]  [ Focus ]  [ More time ▾ ]   More time = Running late +5/15/30, Shift the rest
│                                  │
│ NEXT  12:30 Lunch                │
│ THEN  18:00 Gym · 2 more         │
│                                  │
│ [ + Add ]        [ Clear your head ]   Clear your head = Brain dump
│ Now   Day   Inbox   Search       │
└──────────────────────────────────┘
```

- **Running over:** "More time" moves forward as the primary action. There's no red and no "late" wording; the copy says "need more time?".
- **Morning state:** "Today's one thing" (pick or confirm), "Start a routine" (Routine drop), and the first three blocks.
- **Evening state:** "How did today go?" (day review) and "Shape tomorrow" (opens Day for tomorrow).
- **Low-energy mode:** a "Gentle day" toggle on Now; the behaviour is unchanged.
- **Nothing scheduled now:** "Free until 12:30" plus Inbox suggestions to pull in. Those go through a proposal: nothing is written before Accept.

### 5.4 Day, capture, edit

- **Day:** the full thread, same capabilities as A, in C's visuals:
  - the week strip;
  - Calendar (Week/Month) through the title;
  - drag, multi-select and Shift the rest.
  - The **Day menu** holds Duplicate day, Copy as text, This week, Show less and Plan/Reality.
- **Add (2):** + on Now or Day → one line → Return. Brain dump: "Clear your head" on Now (1) → type → Plan → Accept (3).
- **Edit:** tap the orb title or a dot → the same merged task surface as A [Approval, same merge].
- **Complete (1):** Done on Now for the current task. Other tasks are on Day (2).
- **Inbox → timeline:** Inbox (1) → Schedule (2) → slot on the mini-ribbon (3). On Now's free-time state, a suggestion → Accept (2).

### 5.5 Wide (Mac, iPad landscape, web, Android tablet)

```text
┌ sidebar ┬ NOW (360 px) ─────────┬ DAY (thread) ───────────────────────┬ inspector ┐
│ Now     │ orb · Deep work        │ ☀ 7:00                              │ (task)    │
│ Day     │ 78 min left            │ ●─ 9:00 Standup                     │           │
│ Calend. │ [Done][Focus][More ▾]  │ ●═ 10:00 Deep work  ◀ now           │           │
│ Inbox 2 │ NEXT Lunch 12:30       │ ●─ 12:30 Lunch                      │           │
│ Search  │ [+ Add] [Clear head]   │ ☾ 23:00                              │           │
└─────────┴────────────────────────┴─────────────────────────────────────┴───────────┘
```

- **Medium:** Now and Day stack, with Now collapsing to a header strip when you scroll Day.
- **Foldable (tabletop posture):** Now on the top half, Day on the bottom.

### 5.6 Settings

- **Progressive disclosure.** The root opens **Essentials** with 8 rows:
  - Wake Up & Wind Down dial;
  - Wake Up alarm;
  - default reminder;
  - default duration;
  - layout;
  - theme;
  - account & sync;
  - notification health.
- **"All settings"** opens the six groups from A.
- **Mac:** Settings window with an Essentials pane first.

### 5.7 Wake Up and missions

- **The alarm flows into Now's morning state:** missions → "Good morning" → today's one thing.
- **Missions:** full-screen orb animations. Catch the dot becomes catching the orb; Breathe follows the orb's breathing.

### 5.8 Minimal mode in C

**Risk:** Now already looks minimal.
- **Minimal C:** Now without the ribbon, Inbox or Search tabs. A floating + and a "Later" row are kept, matching today's minimal semantics.
- **Full C** keeps the four tabs.
- **The difference must stay visible** (ADR-0016).

### 5.9 Planned and partial features in C

- **Same as A.**
- **Plus:** the Mac mini window [Feasibility]. The Live Activity / ongoing notification already shows "now" on phones; C's visuals extend to it later.

### 5.10 Accessibility and usability

- **Now is excellent for screen readers and focus:** one heading and three actions.
- **Risks:**
  - **Now updates over time:** changes must be announced politely, never move focus and never auto-switch the current task while the user is acting.
  - **Visual planners lose the at-a-glance thread on phones,** keeping only the ribbon. Owner job 1 says "the timeline is the product", so Day must be 1 tap and the ribbon must be readable (labels on long-press).
  - **Daytime Now with no task** must not feel like a nag.

### 5.11 Complexity and tradeoffs

**Medium-high.**
- **New:** the Now screen with time-of-day states, the orb and ribbon painters, a new visual identity, the multi-window spike (Mac), and the Now/Day composition at wide widths.
- **Reused:** the thread (Day), gestures, domain and proposal flows.
- **Strongest for:** the ADHD/"what's next" audience and the brief's "Focused/Calm".
- **Riskiest for:** the owner's first job if the timeline feels secondary.

---

## 6. Feature homes (Q3, parity §7) across the concepts

| Feature (was) | A Refined Timeline | B Workspace | C Focus-First |
|---|---|---|---|
| Brain dump (⋯ only, today) | Add mode + long-press + + Day menu; ⇧⌘N | Plan › Brain dump section; ⇧⌘N | Now "Clear your head"; Add mode; ⇧⌘N |
| Routines (5 places) | Add mode; sidebar (wide); Settings › Planning | Plan › Routines (drag onto days) | Now morning "Start a routine"; Add mode; Settings |
| Pick today's one thing (⋯ only) | Day menu › Plan | Replan menu; morning briefing | Now morning state (first-class) |
| Low-energy (⋯ / header / Settings) | Day menu › View; Settings › Planning | Replan menu; Settings | "Gentle day" toggle on Now; Settings |
| Duplicate day, Copy as text (⋯ only) | Day menu; Mac Day menu | Today › Share/More; Mac Day menu | Day menu; Mac Day menu |
| This week (⋯ only) | Day menu › Reflect; sidebar "Reviews" | **Review** destination | Day menu; sidebar "Reviews"; Now evening |
| Review the day (3 forms) | Day menu; evening prompt; `/review` | Review destination; evening card; `/review` | Now evening state; `/review` |
| Running late / Shift the rest | Live row; toolbar (wide); Day menu | Live row; Replan menu | Now "More time" (primary); live row; Day menu |
| Month (pull-open + route) | Calendar tab; title popover; pull-open kept | Plan › Month; title popover | Day title; Calendar (sidebar) |
| Past days / year strip (Search) | Search (unchanged) | **Review** [Approval] | Search (unchanged) |
| Settings | Avatar / sidebar footer / ⌘, | Same + contextual | Avatar / ⌘, + Essentials |

Every current entry point that a concept moves is listed in `CONCEPT_COMPARISON.md` §4, with the approval it needs.
