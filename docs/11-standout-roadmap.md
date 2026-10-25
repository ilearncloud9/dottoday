# 11 · Standout roadmap — "the dot that helps you start, see time, and stay in control"

Status: **adopted** (ADR-0009, ADR-0010). This document extends `02-prd.md` and `10-ui-concept-a.md`; it does not replace them. Every feature here is built with the Concept A components and rules (§3–§4 of `10-ui-concept-a.md`); new screens get reference renders in `docs/design-references/png/` (set B) or are derived from this spec and `10-ui-concept-a.md` §5.3–5.4.

Tags: **built** = exists on main; **PRD** = already in `02-prd.md`; **new** = this document adds it; **M6.5** = must ship in the delivery-guarantees milestone before M7.

The one-line position after this roadmap ships: **"Your day as a thread. Always visible, one dot at a time."** Three advertised pillars: *see time*, *replan in one tap*, *it learns how long things really take you*; underneath, the trust line: core free forever, same app everywhere, data on your device.

---

## 0. Shared building blocks (decide and build first — several features reuse each)

| Block | Used by | Spec |
|---|---|---|
| **B1 Actual timestamps** — `occurrence.actualStartUtc`, `occurrence.actualEndUtc` (nullable ms epoch, synced like other fields) | A0, B2, B3, C3, C4 | Set `actualStart` on the first tap of the live dot / "Start" / Focus open; set `actualEnd` on Done. Never inferred. Migration adds both columns; export includes them. **M6.5.** |
| **B2 Subtask model** — ordered subtasks with `durationMin` (nullable), per-occurrence completion (R-09) | B1, B2, B3, A3 | Already per-occurrence; add `durationMin` and `sortIndex`. Task duration may be "sum of steps" (flag `durationFromSteps`). |
| **B3 Proposal sheet** — one component: ghost preview + editable list + Accept / Discard; never auto-applies | B1, B4, C1, C2, C3 | `ProposalSheet(before: DaySnapshot, after: DaySnapshot, edits: [...])` renders the current thread faded with the proposed thread over it (Concept A: ghost segments at 35 % alpha, proposed dots outlined in accent). Accept writes through the repository in one transaction; Undo 30 s. |
| **B4 Model service** — `ThinkingService` with two backends: on-device (Apple Foundation Models on iOS 26+/macOS 26+, Gemini Nano via AICore on Android where available) and cloud (metered, Pro). One interface: `breakDown(task)`, `planFromText(text, day)`, `suggestDuration(task)`. Output is always a structured proposal, never applied without B3. | B1, B3, B4, C1 | On-device first; if unavailable → cloud only when the user is Pro and has opted in; otherwise the feature degrades to rule-based (e.g. duration suggestions from history only). Optional "use my own API key" (advanced). All prompts/outputs logged locally only. ADR-0009. |
| **B5 Day snapshot** — an immutable record of a day's thread (planned + actual) as data **and** as a rendered image | A1, A2, D1, D3, F3 | Written at Bedtime and on demand; stored in the app-group / shared store so widgets, Live Activity, menu bar and watch read it without the Flutter engine. Phone is the source of truth; every surface consumes the snapshot. |
| **B6 App Intents** — exactly five: `AddTask`, `WhatsNext`, `MarkDone(occurrence)`, `AddFifteen`, `StartFocus(occurrence)` | A1, A3, B6 | Defined once (App Intents on Apple, App Actions/Shortcuts on Android); widgets, controls, Live Activity, Siri, Shortcuts and the watch call these and nothing else. |

## A. See time — the dot lives outside the app

### A0 · Alarms that actually fire — **M6.5** (precondition for A1–A3)
*Problem:* dot-start reminders get downgraded or killed by the OS; a planner that fires silently has failed (Tiimo's most-cited bug).
- iOS: every dot-start notification uses the **time-sensitive** interruption level. No critical-alert entitlement in v1.
- Android: a dedicated **alarm channel** (IMPORTANCE_HIGH, alarm audio attributes, full-screen intent), request `SCHEDULE_EXACT_ALARM` with the in-app explanation, battery-optimisation exemption prompt re-checked on every launch, re-arm on `BOOT_COMPLETED` and `TIMEZONE_CHANGED`.
- Defaults, no per-task settings in v1: the **first dot of the day** and any **routine-start** dot are alarm-loud; every other dot is a normal time-sensitive ping. Quiet hours still apply to normal pings, never to the first dot.
- Proof of delivery: onboarding step O4 gains **"Send me a test alarm"** (fires in 60 s, the screen waits and confirms); Settings › Reminders gains a **Notification health** panel that reads the real OS state (permission, exact-alarm, battery exemption, Focus/DND) and says in plain words what's off and how to fix it.
- Deferred (not M6.5): per-task alert tier (nudge / alert / alarm); escalation when no `actualStart` arrives within N minutes (shares its trigger with B2 Smallest step — build the trigger once, later).
- Entitlement note: the time-sensitive interruption level needs the `com.apple.developer.usernotifications.time-sensitive` entitlement, which a Personal Team cannot provision. Add the entitlement to the Release/TestFlight configuration now, keep Debug on the Personal Team without it (the simulator honours the level regardless), and list "verify time-sensitive delivery on a real iPhone" under the paid-account release gates.
- Background sync (carried from the M6 known limits): the same `workmanager` job that re-arms alarms also runs a sync pull/push on iOS BGAppRefresh and Android WorkManager, so a day planned on the Mac is on the phone before Wake Up. Clock-skew guard: when the device clock is > 5 min off, show one line in the notification-health panel ("your clock is 7 min fast — reminders may be early") instead of silently pausing sync; sync resumes when corrected.
- AC: property test "no occurrence ever has > 1 pending alarm per alert"; integration test on iOS simulator and Android emulator that a scheduled dot-start fires with the app killed; the health panel's four states each have a golden. Use the `local-notifications-scheduler` skill.

### A1 · The live dot on OS surfaces — PRD (widgets, Mac menu bar) + **new**
- **iOS Live Activity** (lock screen + Dynamic Island): the live dot's conic ring, title, "38 min left", buttons Done / +15 (B6). Starts when a dot goes live, ends on Done or at planned end + 30 min. Pulled **ahead** of the other widget work: it is the second line of defence when a ping is missed.
- **Android ongoing notification** with chronometer and the same two actions; same lifecycle.
- **Interactive widgets** (iOS 17+/Android): "Next up" with Done button; "Today thread" (medium/large) read-only; "Inbox count". **Control Center / Action button**: Add task, Start focus.
- **Mac menu bar**: the day dot that fills + next up; click → What's next menu with Done / +15.
- **Watch complication** (Phase 2 per F3 rule): the day dot; tap → watch "Now".
- All surfaces read B5 and call B6; none talk to Supabase. Render: `B-ios-live-activity.png` (lock screen, Dynamic Island, Live Activity card and the dot-start notification).

### A2 · Day dot as wallpaper / watch face — **new**
- Lock-screen wallpaper (iOS via Shortcuts automation + a generated image; Android via live wallpaper service) that fills from Wake Up to Bedtime; Watch face complication (large) same. Pure B5 consumer. Phase 2 after A1.

### A3 · Focus — **new** (merges "Focus the dot" and OS focus integration)
- One tap on the live dot (or `StartFocus`) opens a full-screen **Focus** view: the ring at 160 px (as `B-ios-focus.png`), title, current subtask with its own timer (B2), optional interval chime (every N min, off by default), Done / +15 / Next step. Nothing else on screen. The Live Activity (A1) continues when the user leaves.
- OS integration: a dot flagged **deep work** turns on iOS Focus / Android DND via intents when it goes live and off when it ends. **Constraint:** a deep-work dot must never silence the next dot's start — dot starts are time-sensitive (A0) and break through.
- Render: `B-ios-focus.png`.

## B. Start — help with the thinking before a task reaches the thread

### B1 · Break it down — **new** (free on-device, cloud in Pro)
- One button, "Break it down", in Add step 1 and in the task sheet. The task becomes ordered subtasks with a duration each (B2, B4), shown as a **mini thread inside the dot** (B3 proposal): the user edits, reorders, deletes, then Accept. Nothing applies before Accept. Total duration = sum of steps (user may override).
- Recursive on any step; **depth capped at 3**.
- **"My usual breakdown"**: accepted breakdowns are saved per task title; the next "Clean the kitchen" offers the saved steps first (no model needed). Learned step durations come from B1 timestamps when the user ticks steps in Focus.
- Degrades without a model: offers the saved breakdown or an empty 3-step template.
- AC: breakdown proposal in < 2 s on-device; accepted steps tick off in Focus with timers; golden of the mini thread at 1, 3, 7 steps. Render: `B-ios-break-it-down.png`.

### B2 · Smallest step — **new**, companion to B1
- Trigger: planned start + N minutes (default 10) with no `actualStart` and the task has subtasks → the reminder and the task row change to **"Just <first step> · 2 min?"** with one button Start. Starting it sets `actualStart` for the task. Shares its trigger with the deferred escalation in A0; build the trigger once.

### B3 · Unstick — **new**, companion to B1
- A task with no subtasks that has been moved ≥ 3 times (counter on the series) shows a quiet row under its title: "What's the very first thing you'd physically do?" with a one-line field; the answer becomes step 1 (B2) and the counter resets. Never a modal, never on first move.

### B4 · Brain-dump to thread — PRD Phase 2
- Free text or dictation → proposed dots on the chosen day (B4 model, B3 proposal) → Accept. History of dumps kept locally, searchable. Cloud-only cases are Pro.

### B5 · Paper plan to thread — **new, future, do not build now**
- Photo → on-device OCR → Inbox items via B3. Recorded here so the data model (B2) and B3 are ready; no milestone.

### B6 · Capture anywhere — Siri/Shortcuts PRD Phase 2 + **new**
- Share sheet (link / email / message → Inbox task with source attached), Action button / Control Center "Add", Watch dictation (queues locally, F3 rule), private **email-to-Inbox** address (Pro). All through `AddTask` (B6) and the existing parser.

## C. Stay in control — the day adapts, the user decides

### C1 · Rebalance — mechanics **built**; proposal **new**
- Triggers: "Running late", a task overrunning its planned end by > 10 min, an imported event moving, "Shift the rest" with > 2 followers. Instead of applying, open the **ProposalSheet** (B3): the current thread faded, the proposed thread over it with each change labelled (shifted 15 min · shrunk to 30 min · sent to Inbox · moved to tomorrow · pinned, untouched), one tap Accept, Discard keeps everything. Rules first (shift → shrink optional tasks → push to tomorrow past Bedtime), model optional for wording only. Never auto-applies. Render: `B-ios-rebalance.png`.
- Rules as built (docs/09 M11.1): a pin ends "Shift followers" (it anchors the rest of the day, as Shift the rest does); events are stepped around, never moved. **Optional** = the user's own task, unpinned, not started, energy not high; it may be shrunk by at most a quarter and never below 15 min. Past Bedtime → tomorrow's first free slot from Wake Up, else the Inbox. Triggers open the sheet only when the change is real: the overrun after 10 min, "Shift the rest" when it moves more than two tasks, an imported event only when the calendar moved it later the same day into another planned task (Rebalance then runs from the event's old end, the event kept where the calendar put it; M11.1b).

### C2 · Routines as thread fragments — **new**
- A **routine** is a saved slice of thread: ordered dots with durations and gaps, relative to a start time. Create from a selection on any day ("Save as routine") or from scratch. Drop onto any day via Add › Suggestions ("Your usual Tuesday?", "Morning"), the week strip, or the Inbox. Routine-start dots are alarm-loud (A0). Three routines free, unlimited in Pro. Render: `B-ios-routines.png`.

### C3 · Reality thread — **new, highest priority after A0**
- With B1 data, Today draws the **planned thread as a ghost** under the **actual thread** (real start/end): slipped starts, overruns and gaps become visible without judgement. Toggle in the day card header ("plan / reality").
- Learning (local, rule-based, no model needed): per task title, median actual duration and median start offset over the last 10 occurrences. Used by Add (duration chip pre-selected: "usually 2 h 20"), by the ThreadPicker caption ("you tend to start this ~15 min late"), and by C1 proposals.
- Honest copy: "usually", never "you're late". Render: `B-ios-reality-thread.png`.

### C4 · Energy-aware suggestions — energy field **built**; learning **new**, depends on C3
- From completed high-energy tasks' actual times, derive the user's best window; Add suggests placement ("you finish deep work best 9–11"). Suggest / Off switch in Settings › Planning; default Off until 20 completions exist.
- As built (docs/09 M11.5): a completion = a task marked done, energy high, with a real actual start and end (B1), in the last 90 days. The window is the 2-hour stretch in which most of them really started, in the profile zone (a tie goes to the window starting at the busier hour, then the earliest). Under 20 the switch is off and locked ("After 20 finished high-energy tasks · 7 so far"); from 20 it is on unless turned off. Add says it only for a task whose title is one of those high-energy tasks — "you finish high-energy tasks best 9:00 – 11:00 AM" — with "Try 9:00 AM" when the task starts outside the window (rejected: the render's "deep work" category, which the data doesn't have; suggesting it for every task).

## D. No shame — reflection without streaks

Enforced by `app/test/policy/no_shame_copy_test.dart` over every English string (M6.5.11): no late / missed / failed / streak / overdue / behind, and no error red in features or shared UI. The one exception (owner, 2026-10-23) is the **Running late** action — the button, its menu item and sheet, the help answer about it and the setting naming its nudge — because it is the user's own words for their action. Everything the app says *about* the user is reworded: "missed" → "not done" (dot states unchanged), "started 12 min late" → "started 12 min after plan", "ran over by 25 min" → "took 25 min longer", the nudge "Running late?" → "Need more time?".

### D1 · Bedtime review — basic **built** (M3f); **new**: weekly picture, no-streak principle, shareable image
- Daily: unchanged mechanics; copy audited against the principle: counts and moves, never red, never "missed streak". Writes the B5 snapshot.
- Weekly (Sunday at Bedtime or on demand): the week as **seven dots** — one per day, size = hours planned, ring split into that day's tasks in their colours (done solid, not done faint), done count in the centre, tap a day to pop out its thread — with Busiest/Lightest chips and one sentence. **No streaks anywhere in the product.**
- Share: the day's (or week's) thread as an image, task titles optional (off by default). Render: `B-ios-week-review.png` (seven dots).

### D2 · Low-energy mode — **new**
- One switch in the Today header menu and in Settings: Today collapses to the next dot and a "later" pile, counts and "N planned" hidden, all nudges off, Rebalance offers "move everything optional to tomorrow" once. Turns itself off at the next Wake Up. Render: `B-ios-low-energy.png`.

### D3 · Thread journal — **new**
- Every past day kept as a B5 snapshot: scroll back by day, search ("when did I last run?"), export a year strip (the month grid's completion dots, 12 rows). Lives under Search › "Past days". Pro.

## E. Together

### E1 · Body double, dot only — **new**, Pro
- Pair with exactly one person by link. Each sees the other's **current dot** (colour, icon, live/done) in their Today header and nothing else; tap to send a nudge (a gentle push notification). Pairing revocable by either side instantly; nothing shared is stored beyond the current dot. Shared household threads: Phase 3.

## F. Platform and data

### F1 · Windows and Linux — **new**
- Flutter desktop targets with the Mac layout (expanded width). Check plugin support for notifications, secure storage and SQLCipher before promising; menu bar → system tray.

### F2 · Reminders / Google Tasks two-way, Todoist / Notion import — **new**
- Apple Reminders (EventKit) and Google Tasks two-way into the Inbox; Todoist and Notion one-way import. Keep the Inbox the door; never become a hub. Pro.

### F3 · Watch rule — **write into the PRD now**, Phase 2 build
- The watch **never authenticates**. The phone pushes a B5 snapshot; check-offs and +15 queue on the watch and sync back when reachable. No network, no Supabase token on the wrist. Native Swift (watchOS) / Compose (Wear OS), not Flutter. ADR-0010.

---

## Free / Pro split — DRAFT, to be reviewed by the owner before any paywall is built (principle from `00-vision.md`: core free forever)

Nothing in M6.5–M12 is gated. Build every feature ungated; the only pricing-related code allowed before the owner signs off a final split is a single `entitlements` service with one flag (`isPro`, default true in all builds) that features may read. The split and prices below are a proposal for that review.

Proposed free: the thread, recurrence, calendars, notifications, sync, widgets, **the live dot on every surface (A1)**, Focus (A3), Rebalance (C1), Break it down on-device (B1), Smallest step, Unstick, three routines, Bedtime review (daily), Reality thread view, low-energy mode, export.
Proposed Pro: unlimited routines, Reality-thread learning + energy suggestions, weekly review + share image, thread journal, brain-dump and cloud model fallback, email-to-Inbox, themes and icon packs (and, if ever built, integrations and body double). Indicative price: €2.99/month, €24.99/year, €69.99 lifetime; 7-day trial on any plan; lifetime honoured forever (R-18).

## Milestone proposal (the agent re-plans `09-implementation-plan.md` from this)

| Milestone | Contents | Gate |
|---|---|---|
| **M6.5 Delivery guarantees** (before M7) | A0; B1 timestamps + migration; B2 subtask durations; F3 rule into PRD; ADR-0009/0010 | alarm fires with app killed on both simulators; health panel |
| M7, M8 | as planned (calendars; export + l10n) | — |
| **M9 See time** | A1 (Live Activity + ongoing notification first, then widgets/controls/menu bar), B6 intents, B5 snapshot | all surfaces show the same dot within 1 s of a change |
| **M10 Start** | B2 model service (on-device + cloud + BYOK), B3 ProposalSheet, B1 Break it down, B2 Smallest step, B3 Unstick, A3 Focus | breakdown < 2 s on-device; proposal never auto-applies (test) |
| **M11 Control** | C1 Rebalance, C3 Reality thread, C2 Routines, C4 energy (behind switch) | ghost thread golden; learning tests on synthetic history |
| **M12 Reflect + capture** | D1 weekly + share, D2 low-energy, D3 journal, B6 capture anywhere, B4 brain-dump | no-streak audit of every string |
| Phase 2 (ideas, not committed — the owner decides later) | F1 Windows/Linux, F2 integrations, E1 body double, A2 wallpaper/watch face, watch app (F3), B5 paper plan, household threads | — |

Done criteria for every task: `10-ui-concept-a.md` §7 unchanged, plus: every proposal flow has a test proving nothing is written before Accept; every new surface reads B5 and calls B6 only; every new string passes the no-shame audit (no "late", "missed streak", "failed", red).
