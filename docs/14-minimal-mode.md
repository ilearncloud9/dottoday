# 14 · Minimal mode — Dottoday without the noise

## 1. Why and position

Minimal mode is a second presentation of the same Dottoday: the thread, the next dot, Add and Done, with every other control folded away until it is wanted. It is a view flag, not a lite tier, not a separate data set, and nothing in Pro depends on it.

Status: **adopted** (ADR-0016). Ships as M16; see §7. Extends `02-prd.md`, `10-ui-concept-a.md` and `11-standout-roadmap.md`; built with the Concept A components unchanged.

**Who it is for.** ADHD users who open a planner, meet a wall of settings, colours, energy levels and reviews, and never come back. Their complaint about Structured and Tiimo is not missing features; it is that the app asks for decisions before it gives anything. Dottoday already risks the same: by M12 it ships widgets, Focus, routines, Reality thread, energy learning, reviews, a journal and a sound library.

**The promise.** *Open it, see the next dot, do it, tap Done.* Measured as: at most three primary controls on Today, two taps from app open to a saved task, zero required settings after onboarding, and no number on screen that judges the day.

**What it is not.** Not low-energy mode (D2): that is a one-day switch that resets at Wake Up; minimal mode is a standing choice. Not a beginner mode that nags you to upgrade: full mode is one tap away, but minimal is a complete, permanent way to use the app.

## 2. Principles

Every minimal-mode decision in this document follows six rules. A new feature that cannot satisfy them ships hidden in minimal mode by default.

1. **Hide, never remove.** Same tasks, same thread, same sync. Switching modes changes no row in the database; a user can flip back and forth with nothing lost.
2. **Three verbs on screen: Add, Done, Next.** Anything else lives behind a long-press, the task sheet, or a single *More* row.
3. **Defaults decide.** Minimal never shows a setting that has a sane default. Duration, colour, reminder tier, sound and placement come from defaults and from what the app has learned (C3), not from the user.
4. **Reveal in context, never as a wall.** A hidden feature may introduce itself once, after a trigger that shows it would help (three moves → Unstick; three similar mornings → Routines). At most one hint per day, each hint twice in a lifetime, dismissible forever.
5. **No number that judges.** No planned-hours total, no done count on Today, no percentage, nothing red. Same audit as the no-shame rule in `11-standout-roadmap.md`.
6. **The exit is always in the same place.** *Show everything* sits in the Today header menu and as the first row of Settings, in both modes, forever.

## 3. Feature matrix

Every feature keeps one of four states in minimal mode. **Shown** = unchanged. **Simplified** = same feature, fewer controls, defaults instead of choices. **Hidden** = fully working, reachable through *More* or revealed by a trigger. **Off** = the flag is off until the user switches to full mode. Background behaviour (alarms, timestamps, learning, Smallest-step trigger) runs in every state except Off.

| Feature | Status | In minimal mode | What changes |
| --- | --- | --- | --- |
| Today thread, day pager | built | Shown | Header shrinks to date + menu; no counts, no "N planned" |
| Week strip + month pull-open | built | Simplified | Strip stays for swiping days; month opens without per-day completion dots |
| Mac Week / Month views | built | Hidden | Mac shows Today; Week and Month under the View menu |
| Add task, two steps + parser | built | Simplified | One step: title field, parser sets time and recurrence, duration chip pre-filled from history; everything else under More |
| Task sheet | built | Simplified | Title, time, duration, Done, Tomorrow, Later, Delete; colour, icon, energy, notes, recurrence, subtasks under More |
| Recurrence editor | built | Hidden | Typed recurrence ("every Monday") still works; editor under More |
| Inbox | built | Simplified | One "Later (3)" row at the end of the thread; no tab |
| Move, reorder, drag | built | Shown | Unchanged |
| Shift the rest / Running late | built | Simplified | One button on the live dot; before/after preview, Accept or Discard |
| Wake Up / Wind Down | built | Shown | Set once in onboarding; never on Today |
| Tap a Wake Up / Wind Down cap to change its time | built | Hidden | The caps stay plain labels; the times change in onboarding or Settings (owner, 2026-10-31: Wind Down rename and tappable caps) |
| Wind Down sleep block | not built | Hidden | No sleep block exists: the thread ends at the Wind Down cap and draws no sleep segment; the row is a no-op (M17 audit, `docs/audits/m17-wake-up-inventory.md`) |
| Notifications + sound library | built | Simplified | One switch "Remind me when a dot starts", one default tone; library under More |
| Wind Down review, daily | built | Simplified | One card: "3 things left — tomorrow or Later?"; one tap, then the snapshot writes |
| Sign-in and sync | built | Shown | Silent; one Settings row |
| Calendar import | built | Simplified | Connected calendars draw as dots; calendar management under More. A repeating event is one series: the This one / All scope question shows as for any repeating task (F5.7) |
| Export | built | Hidden | Settings › More |
| Light/dark, language | built | Shown | Follow the device; no setting shown |
| Onboarding | built | Simplified | Mode choice, then three steps: Wake Up/Wind Down, reminders + test alarm, first task |
| A0 alarms + Notification health | M6.5 | Shown | A0 defaults as specified; health panel shows as a banner only when something is off |
| W1 Wake Up alarm | M17 | Simplified | Settings › Wake Up alarm shows the switch and the alarm sound; vary, ramp and snooze under More options. The ringing screen is the time, one big "I'm up" and Snooze as a link (docs/15 §10) |
| W2 Wake Up card | M17 | Simplified | Opens only after "I'm up" (or its notification), never by itself on first open. The first dot and Start the day; the late-start line when it applies; the day dot, the next dots and the chips behind "Show my day" (docs/15 §10) |
| W3 Wake Up Check | M17 | Shown | Identical: already one line and one Start (docs/15 §10); its settings under More options |
| A0 Start nudge | M17 | Shown | Identical: one "Start <dot>?" notification with Start; its switch is in Settings › Planning, which minimal Settings reaches through Everything else… |
| W4 + W6 Sleep target and the night | M17 | Shown | Unchanged: the onboarding sleep slider, the night on the day dot, the review's first line and the Wind Down nudge's words are geometry and copy, not chrome (docs/15 §7b) |
| W5 Missions (modes, rules, skip offer) | M17 | Simplified | Settings › Wake Up shows one Missions row (the mode); kind, steps, days and backup under More options. The mission screen is the same: the ring, one line and "Can't right now" (docs/15 §8) |
| W5 Stand up | M17 | Shown | Identical: one line and a live "upright" state |
| W5 Walk | M17 | Shown | Identical: one line and the step count |
| W5 Light | M17 | Shown | Identical: one line and the light meter's text state |
| W5 Breathe | M17 | Shown | Identical: the ring and "Hold · Let go" |
| W5 Catch the dot | M17 | Shown | Identical: one moving dot and the count |
| W5 Pick today's one thing | M17 | Shown | The pick screen is identical; the ring and "Your one thing" show on minimal Today too, since it is the day's one decision. Picking from Today's ⋯ is full mode only, as minimal ⋯ holds three items (§4); the morning mission still picks |
| W5 Make sure I'm up | M17 | Simplified | The Wind Down review's toggle shows; the task sheet's switch sits under More options |
| B1 actual timestamps | M6.5 | Shown | Invisible; recorded on tap and Done exactly as in full mode |
| B2 subtask durations | M6.5 | Hidden | Appear only once Break it down has been used on that task |
| A1 Live Activity / ongoing notification | M9 | Shown | Unchanged; this surface is minimal mode's heart |
| A1 widgets, controls, menu bar | M9 | Simplified | "Next up" widget and the menu-bar dot are offered; Today-thread and Inbox-count widgets installable but not suggested |
| A2 wallpaper / watch face | Phase 2 | Simplified | Wallpaper and large watch complication show the day dot only, no next-up text; one switch "Day dot on my lock screen", no refresh or style options |
| A3 Focus | M10 | Shown | Tap the live dot; interval chime and deep-work flag under More |
| B1 Break it down | M10 | Simplified | One button in the task sheet; recursion on steps hidden |
| B2 Smallest step | M10 | Shown | Automatic; no setting |
| B3 Unstick | M10 | Shown | Automatic; no setting |
| B4 Brain-dump to thread | M12 | Simplified | The Add field accepts several lines and opens the proposal; no dump-history screen |
| B5 Paper plan to thread | future | Simplified | Camera button inside Add; photo becomes items in the Later row through the proposal sheet, no crop, language or OCR settings |
| B6 Capture anywhere | M12 | Shown | Share sheet, Siri, Action button; nothing to configure |
| C1 Rebalance proposal | M11 | Simplified | Before/after ghost only, no per-change labels; Accept or Discard |
| C2 Routines | M11 | Hidden | Revealed after three similar mornings: "Save this as your morning?" |
| C3 Reality thread view | M11 | Hidden | Plan/reality toggle hidden; **learning stays on**, it feeds the duration and start-time defaults minimal relies on |
| C4 Energy suggestions | M11 | Off | No energy field on the task, no caption. Off goes through the existing opt-in switch (13 §3, M13.5), as §6 says; the switch is under Everything else (owner, 2026-10-30) |
| D1 Weekly review + share image | M12 | Hidden | Opt-in from Settings; hinted once after 14 days of use |
| D2 Low-energy mode | M12 | Shown | Same switch in the header menu; inside minimal it collapses Today to one dot |
| D3 Thread journal | M12 | Hidden | Settings › More |
| E1 Body double | Phase 2 | Simplified | Partner's current dot as a small ring in the Today header, nothing else; pairing by link from Settings › Account, no nudge button in minimal |
| F1/F2 Windows/Linux, integrations | Phase 2 | Hidden | Integrations under Settings › More |
| F3 Watch | Phase 2 | Shown | The watch is already minimal; unchanged |
| Themes, icon packs, Pro upsell | Pro | Hidden | No banners; one Settings row "Dottoday Pro" |
| Today header extras: `DayDot` (or "● Today" away from today), day numbers ("2 of 13 · 10 h planned") | ADR-0015 + amendment | Hidden | One line: the date title "October 21, 2026 ⌄" (still opens the month) and ⋯; no dot, no numbers line |
| `DoneCircle` on every row | ADR-0015 | Shown | Unchanged; it is minimal's Done on every row, the live one included |
| Task dot tap → task sheet (live dot → Focus) | ADR-0015 | Shown | Unchanged; the sheet opens in its minimal form |
| Overlapping tasks ("Tasks are overlapping") | ADR-0015 | Shown | Unchanged; it describes, never warns |
| Live row details: subtask ring "1 of 3", "38 min left" | M3b | Simplified | "min left" stays; the subtask ring shows only once the task has steps |
| Long-press multi-select + selection bar | M3b | Shown | Unchanged; appears only after a long-press (R-05) |
| Structured drag: dot follows the finger with its time, landing preview, 700 ms hover-paging over the week strip | ADR-0015 amendment | Shown | Unchanged |
| Drop on Wake Up = all day; all-day chip dragged onto the thread | ADR-0015 amendment | Shown | Unchanged |
| Drag the + button onto the thread to add at a time | ADR-0015 amendment | Shown | Unchanged; the floating Add is still the + |
| Drop on the Inbox tab to unschedule | ADR-0015 amendment | Simplified | No tab in minimal: the Later row takes the same drop |
| Trash target above + while dragging (Trash with Undo) | ADR-0015 amendment | Shown | Unchanged; text colour, never red |
| Pinned tasks (lock glyph, Pin switch) | M3f | Simplified | The lock glyph stays on the row; the Pin switch is under the sheet's More |
| All-day chips | M3b | Shown | Unchanged |
| Empty-day actions (Add to the day, Pull from Inbox, Copy a day) | M3f | Simplified | An empty day shows its quiet line, the Add button and the Later row only |
| Duplicate day…, Copy day as text, Routines… (⋯) | M3f.6, M11.4 | Hidden | Not in minimal's three-item header menu; full ⋯ only |
| Brain dump ⋯ entry, Earlier dumps | M12.5 | Hidden | Reached by typing several lines into Add (B4 row) |
| Dictation mic (Brain dump, Notes) | M14.5–6 | Hidden | Mic stays wherever Brain dump and Notes are shown (both under More) |
| Today prompt: Inbox nudge card | M3f | Hidden | The Later row replaces it |
| Today prompt: "Need more time?" nudge | M6.5 | Hidden | Running late sits on the live dot instead |
| Today prompt: ran-over / calendar-moved rebalance ("Rebalance?") | M11.1, M11.1b | Simplified | Same quiet row; opens the simplified C1 proposal |
| Today prompt: This week on the last day | M12.1 | Hidden | Follows D1 |
| Siri tip card + Settings › Siri & Shortcuts + onboarding Siri line | M14.3 | Hidden | §5's hints are minimal's only tip channel; the page is under Everything else |
| Reality-coming caption, insight strip, reality highlight | M13.6 | Hidden | Learning runs; the caption and highlight wait for full mode |
| Learned lines ("usually 2 h 20") + explain-on-tap sheet | M13.7 | Hidden | The learned value is the pre-filled duration chip; the line and its explanation are under More |
| Settings › Learning page | M13.5 | Hidden | Under Everything else; learning keeps running |
| Travel time (row meta, suggestion card, editor row, Calendars › Travel) | M7 | Hidden | Stored travel blocks still apply; suggestions and editing under More |
| Calendar write-back + move-with-calendar (line in editor, Calendars rows) | M7 | Hidden | Keeps working as set, series edits included; settings under Calendars in Everything else. "Delete from the calendar too" is still asked, since it can't be undone here (F5.7) |
| Time zones: zone banner, Time ⋯ › Time zone | M6 | Simplified | The banner shows when the device zone changed (a fact, not a choice); picking a zone is under More |
| Search tab, recent searches, filters | M3d | Hidden | No Search tab in minimal; Search is under Everything else |
| Past days + Year strip (where D3 lives in code) | M12.3 | Hidden | Under Search, as D3 |
| Navigation bar / rail (bold icons, ADR-0015 amendment) | M3a | Simplified | Compact: no tab bar, one floating Add. Medium/expanded: the rail keeps Today and Settings; Inbox is the Later row |
| Mac/web spread with its greeting title, Inbox sidebar, `TaskEditor` panel | M3e, ADR-0015 amendment | Simplified | Expanded minimal shows Today alone with the phone's one-line date header (no spread, no greeting, no sidebar); the editor panel opens in its minimal form; keyboard shortcuts unchanged |
| Inbox page extras: filters, completed group, Routines button, swipe hint, Drop on today panel | M3b–M11.4 | Hidden | The Later row opens the Inbox list with Next free slot, swipe and Place only |
| Task sheet extras: +15, Shift the rest, Move, Edit, Alerts, Sound, Travel, Pin, calendar line | M3b–M15 | Hidden | Under the sheet's More, in today's sheet layout |
| Task icon library picker | ADR-0013 | Hidden | Under the sheet's More with colour; Add uses the default dot |
| Sounds page, task Sound row, Start and Done sounds | M15 | Hidden | Sounds play exactly as set (defaults for new users); pickers under Everything else |
| In-app haptics switch | M15.7 | Hidden | Haptics tap as set (on for new users); the switch is on the Sounds page under Everything else |
| Quiet hours, Wind Down reminder, Day summary | M5–M6.5 | Hidden | Keep running as set; under Everything else |
| Day shape extras: per-weekday times, 12/24 h, week start | M3d | Hidden | Under Everything else; minimal rows 2–3 edit the "same every day" times |
| Planning settings: default duration, snapping, shift default, roll over unfinished, show free time, nudges, low-energy row | M3d–M12.2 | Hidden | Values keep applying; under Everything else |
| Accent colour | M3d | Hidden | A stored accent keeps applying |
| Backups, import, restore | M8 | Hidden | Settings › Everything else › Data, with Export |
| Trash | M3d | Hidden | Under Everything else |
| Help, Feedback, What's new, About + licences | M8 | Hidden | Under Everything else |
| Privacy page (AI status, clear thinking/searches) | M10, M14.2 | Hidden | Under Everything else |
| Proposal model-status line (`StatusHint`) | M14.2 | Hidden | Proposals open without the "simple rules" tip |
| App lock | M8 | Shown | The lock gate always applies when on; its switch is under Everything else › Privacy |
| Sync conflicts banner, Sync sheet | M6.3 | Shown | Silent while healthy; the banner always appears when something needs the user (R-08) |
| Database recovery screen | M6.5 | Shown | System state; unchanged |
| Web install banner | M8 | Hidden | No install prompt in minimal |
| Onboarding extras: welcome, account step, habits step, calendar connect, Done step | M4 | Simplified | Welcome → step 0; minimal skips account and Done, and turns habits into the first-task step |

**Matrix notes from the M16 inventory (30 Oct 2026).** Where a row above was written before the code it describes:

- *Today thread.* Since ADR-0015 a dot looks the same before and after Done; a task is marked done by its row's `DoneCircle` (filled, title struck), and tapping the dot opens the task. Minimal keeps this; "past dots fade" is withdrawn.
- *Week strip.* The strip's own 8 px completion dots are hidden too, not just the month's: both are done ratios.
- *Mac Week / Month.* The Mac View menu already lists Week and Month; minimal removes Week from the rail only.
- *Task sheet.* Tomorrow and Later reuse the Wind Down review's "Move to tomorrow" / "Send to Inbox" actions; Delete reuses the editor footer's delete (its confirm and Undo unchanged).
- *Shift the rest / Running late.* Minimal's live row shows Done and Running late (the existing sheet); +15 and Shift the rest move under the sheet's More.
- *Inbox.* The Later row is `LaterRow`, one quiet row (tray glyph, "Later · 3") that opens the Inbox and takes a dragged task (ADR-0016); low-energy's "Later" pile is today's remaining tasks, not the Inbox.
- *Wind Down sleep block.* Not built: the thread already ends at the Wind Down cap and draws no sleep segment. The row stays as a no-op.
- *Notifications.* Minimal row 4 maps on/off onto the existing default alert ("at start" / "none"); no new notification setting.
- *Light/dark, language.* Hidden settings keep their stored values; nothing is reset.
- *B4 Brain dump.* Add already splits a pasted list into tasks directly (R-07). In minimal, several lines route to Brain dump's planner and open its `ProposalSheet`.
- *D1, D3.* There is no weekly-review switch in Settings today, and the journal lives in Search › Past days.
- *Not built yet.* A2, B5, E1, F1/F2 and F3 (Phase 2 / future) have rows and `FeatureId`s but no View to subtract from.
- *Pro.* No "Dottoday Pro" row until the owner signs off pricing (09 › Pricing; `isPro` is true in every build).

From now on every new feature spec declares its row in this table before it is built; the row is part of its done criteria.

## 4. The minimal screens

Five screens change; everything else is reached through them. All are the Concept A components with elements removed, not new designs; reference renders go in `docs/design-references/png/` as set C (`C-ios-today-minimal.png`, `C-ios-add-minimal.png`, `C-ios-settings-minimal.png`, `C-ios-onboarding-mode.png`).

**Today.** The thread on the full-width day sheet (ADR-0015), running under the floating Add to the bottom edge. Header on one line: the date title ("October 21, 2026 ⌄", opens the month) and one menu button (Show everything · Low-energy day · Settings), without the day dot or the numbers line; the week strip stays without completion dots. Rows keep their tinted dots and `DoneCircle`s; a done task keeps its place with its title struck, and there is no done count. The live dot carries its ring and two actions: Done and Running late (becomes +15 in Focus). The thread ends in one quiet row, "Later (3)", which is the Inbox. One floating Add button. That is the whole screen: three primary controls (Add, Done, Running late).

**Add.** One sheet, one field, keyboard up. The parser reads time, duration and recurrence from the text ("dentist 3pm 45 min", "gym every Tuesday"). Under the field, two chips at most: when (next free slot, pre-selected) and how long (learned median from C3, else 30 min). *More* expands to the full Add step 2. Enter saves; the sheet closes; the dot is on the thread. Two taps from app open.

**Task sheet.** Title, time, duration (the only place a length changes since ADR-0015), then four buttons: Done · Tomorrow · Later · Delete. *Break it down* appears once B1 ships. *More* expands colour, icon, energy, notes, recurrence and subtasks in the existing sheet layout.

**Settings.** One page, eight rows, no sections:

1. Layout — Minimal / Full (the switch, always first)
2. Wake Up
3. Wind Down
4. Remind me when a dot starts — on/off
5. Send me a test alarm
6. Calendars — connect
7. Account and sync
8. Everything else… — opens the full Settings tree

Notification health (A0) is not a row; it appears as a banner above row 1 only when the OS state is wrong.

**Onboarding.** Step 0 (render `C-ios-onboarding-mode.png`, owner 2026-10-31) shows the day dot, asks one question ("How much do you want to see?", "You can change this any time, from the top of Settings.") with two radio cards, each with a sketch of its thread: *Just the next dot* ("What's now and what's next. Add, do, done. Nothing to set up.") and *The full planner* ("The whole thread, week and month, routines, reviews, widgets and every setting."). Continue is pinned at the bottom with the flow's step dots under it; step 0 has no top bar. Minimal then runs three steps: Wake Up and Wind Down, reminders permission with the test alarm, first task. Full runs the existing O1–O4 flow. Either way the choice is one tap to undo later.

## 5. Entering, leaving, revealing

The mode is chosen in onboarding step 0, changed in two places, and overruled by nothing. Switching is instant and reversible; it never shows a confirmation, a tour, or a loss warning, because nothing is lost.

**Where the switch lives.** Settings row 1 (both modes) and the Today header menu as *Show everything* / *Show less*. Nowhere else: no banner, no onboarding re-prompt, no "try full mode" nudge after N days.

**Progressive reveal.** Hidden features earn their way onto the screen through a trigger, as a single quiet row in context (the same component as B3 Unstick's row), never a modal or a toast. Fixed budget: one hint per calendar day, each hint at most twice ever, *Not now* dismisses forever. Hints never fire inside Focus, in a Wind Down review, or while low-energy mode is on.

| Trigger | Hint row | Reveals |
| --- | --- | --- |
| Same task moved 3 times | "What's the very first thing you'd physically do?" | B3 Unstick (already in the roadmap) |
| Three mornings with the same first three dots | "Save this as your morning?" | C2 Routines |
| A task over 60 min saved without steps | "Break it into steps?" | B1 Break it down |
| First Live Activity dismissed by the user | "Want the next dot on your home screen too?" | A1 Next-up widget |
| 14 days of use | "See your week as seven dots?" | D1 Weekly review |
| Three tasks finished more than 20 min after plan in a week | "Dottoday can start pre-filling times from how long things really take." | C3 learned defaults (already on; the hint only names it) |

**Relationship to low-energy mode (D2).** Low-energy is a one-day state; minimal is a standing layout. Both can be on. Inside minimal, low-energy keeps only the live dot and the Later row and offers "move everything optional to tomorrow" once; at Wake Up it turns itself off and minimal stays.

**Pro.** Minimal mode is free in both the draft split and any future one. A hint never reveals a Pro-only feature to a free user as a paywall; if the owner's final split gates a hinted feature, that hint is removed from the table rather than turned into an upsell.

## 6. Data and architecture

Minimal mode is one presentation flag read in the View layer through a single visibility policy. No repository, DAO, sync or notification code branches on it.

**The flag.** `settings.uiLayout` with values `minimal | full`, stored with the other user settings, synced per account (one layout on every device; a per-device override is an open question below). Default for existing users on upgrade: `full`, so nobody's app changes under them. Default for new installs: decided in onboarding step 0 (see open questions).

**One policy object, not scattered ifs.** As built (ADR-0016; CLAUDE.md §3 forbids feature-to-feature imports): `domain/layout/` holds `FeatureId` and `LayoutPolicy`, `data/layout/` the providers and `watchFeature`, `shared/layout/` the switch. `LayoutPolicy` with `visibility(FeatureId) → Visibility {shown, simplified, hidden, off}` backed by one table that mirrors §3 exactly, plus `uiLayoutProvider` exposed through Riverpod and read with `ref.watch(select)` so a flip rebuilds only what changes. Views ask the policy; they never read the raw flag. A new `FeatureId` without a row in the table fails a policy test, so the matrix cannot drift from the code.

**Hidden runs, off does not.** `hidden` is a View-only state: alarms (A0), timestamps (B1), learning (C3), the Smallest-step trigger (B2) and the B5 snapshot keep running untouched. `off` is the only state that reaches a service, and only through the existing feature switches those services already expose (C4 energy, E1 body double, A2 wallpaper).

**Hints.** A `reveal_hints` table: `hintId`, `shownCount`, `lastShownUtc`, `dismissedAtUtc`, synced. The hint scheduler is a pure function over (today's events, the table, an injected `Clock`) returning at most one hint, so the one-per-day and twice-ever rules are unit-tested without a widget.

**What does not change.** The Concept A component set, the schema for tasks and occurrences, export format, entitlements, widgets and App Intents (B5/B6 already read a snapshot that has no layout notion). Goldens double: Today, Add, task sheet, Settings and onboarding each get a minimal variant in the existing light/dark × text-scale matrix.

**Dependency.** Minimal mode only needs the learned duration default from C3 to feel complete; until C3 ships, the Add chip falls back to the last duration used for that title, then 30 min.

## 7. Milestones, acceptance criteria, open questions

Placement, revised 30 Oct 2026: M1–M15 are on main (M13 learning reveal, M14 voice + AI clarity, M15 sounds), so every row in §3 is now a built feature and this ships as **M16**, the last feature milestone before the v1.0.0 release gates. Because the features already exist, the work is almost entirely View-layer: the flag, the policy table, and the minimal variants of five screens. The hints (§5) ship in the same milestone since all their trigger features exist.

| Milestone | Contents | Gate |
| --- | --- | --- |
| **M16 Minimal layout** (after M15, before release gates) | `uiLayout` flag + sync + migration (existing users default `full`); `LayoutPolicy` with a row for every `FeatureId` in §3; Today, Add, task sheet, Settings and onboarding step 0 in minimal form; `reveal_hints` + scheduler + the six hints in §5; set C renders; ADR-0016; no-shame audit of every new string | two taps to a saved task on a cold install; mode flip round-trips with zero data change; policy test fails on a missing row; one hint per day proven by test |
| v1.0.0 release gates | as planned, plus the minimal goldens in the design-review sweep | — |

**Acceptance criteria for M16**

- [x] Widget test enumerates every tappable control on minimal Today and asserts the set is exactly {Add, Done (each row's `DoneCircle` and the live row's Done), task row → sheet, Running late, header menu, Later row, day swipe and week-strip day} (owner, 2026-10-30: ADR-0015 put a done circle on every row and made rows open their sheet). As built, day navigation also counts the date title and the sheet's pull handle (both open the month), and a task row also counts the thread's own "N tasks after Wind Down" row (`test/minimal_mode/minimal_today_test.dart`)
- [x] Property test: for any seeded database, `full → minimal → full` leaves every table byte-identical
- [x] Policy test: every `FeatureId` has a row; every `hidden` feature is reachable within two taps from a *More* row (traversal test over the route table). The *More* rows are Settings › Everything else…, the task sheet's and Add's More, and the header menu's Show everything (owner, 2026-10-30: weekly review, the journal and Search have no Settings path; Everything else… gains a Search row)
- [x] Golden matrix: 5 minimal screens × light/dark × largest text scale × RTL
- [x] Onboarding in minimal is three steps after the mode choice and asks for no setting that has a default
- [x] No string in minimal mode or in a hint fails the no-shame audit (no "late", "missed", "failed", no red)
- [ ] Manual on a real device: cold install to first dot on the thread in under 20 seconds

**Open questions for the owner** — all answered as proposed (owner, 2026-10-30)

- [x] Default for new installs: preselect *Just the next dot*, preselect *The full planner*, or no preselection? Proposal: preselect minimal; the full planner is a tap away and the first impression is the one that keeps ADHD users
- [x] Name in the UI: "Minimal", "Simple", or "Just today"? Proposal: no name, just the two card titles and the Settings row *Layout: Minimal / Full*
- [x] One layout per account (synced) or per device? Proposal: per account, with the Mac free to show Week/Month in its View menu either way
- [x] Should the Mac in minimal mode hide Week and Month entirely, or keep them one click away? Proposal: one click away under View
- [x] Does the Wind Down review stay in minimal as the one-card version, or go hidden? Proposal: stay, because "tomorrow or Later?" is the one decision that keeps the thread honest
