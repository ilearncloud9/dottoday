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
| Wake Up / Bedtime | built | Shown | Set once in onboarding; never on Today |
| Wind Down sleep block | built | Hidden | Thread ends at Bedtime; no sleep segment drawn |
| Notifications + sound library | built | Simplified | One switch "Remind me when a dot starts", one default tone; library under More |
| Bedtime review, daily | built | Simplified | One card: "3 things left — tomorrow or Later?"; one tap, then the snapshot writes |
| Sign-in and sync | built | Shown | Silent; one Settings row |
| Calendar import | built | Simplified | Connected calendars draw as dots; calendar management under More |
| Export | built | Hidden | Settings › More |
| Light/dark, language | built | Shown | Follow the device; no setting shown |
| Onboarding | built | Simplified | Mode choice, then three steps: Wake Up/Bedtime, reminders + test alarm, first task |
| A0 alarms + Notification health | M6.5 | Shown | A0 defaults as specified; health panel shows as a banner only when something is off |
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
| C4 Energy suggestions | M11 | Simplified | No energy field on the task; the Add "when" chip silently prefers the learned best window once 20 completions exist, no settings switch, no "you finish deep work best 9–11" caption |
| D1 Weekly review + share image | M12 | Hidden | Opt-in from Settings; hinted once after 14 days of use |
| D2 Low-energy mode | M12 | Shown | Same switch in the header menu; inside minimal it collapses Today to one dot |
| D3 Thread journal | M12 | Hidden | Settings › More |
| E1 Body double | Phase 2 | Simplified | Partner's current dot as a small ring in the Today header, nothing else; pairing by link from Settings › Account, no nudge button in minimal |
| F1/F2 Windows/Linux, integrations | Phase 2 | Hidden | Integrations under Settings › More |
| F3 Watch | Phase 2 | Shown | The watch is already minimal; unchanged |
| Themes, icon packs, Pro upsell | Pro | Hidden | No banners; one Settings row "Dottoday Pro" |

From now on every new feature spec declares its row in this table before it is built; the row is part of its done criteria.

## 4. The minimal screens

Five screens change; everything else is reached through them. All are the Concept A components with elements removed, not new designs; reference renders go in `docs/design-references/png/` as set C (`C-ios-today-minimal.png`, `C-ios-add-minimal.png`, `C-ios-settings-minimal.png`, `C-ios-onboarding-mode.png`).

**Today.** The thread, full height. Header: the date and one menu button (Show everything · Low-energy day · Settings). The live dot carries its ring and two actions: Done and Running late (becomes +15 in Focus). Past dots fade, no done count. The thread ends in one quiet row, "Later (3)", which is the Inbox. One floating Add button. That is the whole screen: three primary controls (Add, Done, Running late).

**Add.** One sheet, one field, keyboard up. The parser reads time, duration and recurrence from the text ("dentist 3pm 45 min", "gym every Tuesday"). Under the field, two chips at most: when (next free slot, pre-selected) and how long (learned median from C3, else 30 min). *More* expands to the full Add step 2. Enter saves; the sheet closes; the dot is on the thread. Two taps from app open.

**Task sheet.** Title, time, duration, then four buttons: Done · Tomorrow · Later · Delete. *Break it down* appears once B1 ships. *More* expands colour, icon, energy, notes, recurrence and subtasks in the existing sheet layout.

**Settings.** One page, eight rows, no sections:

1. Layout — Minimal / Full (the switch, always first)
2. Wake Up
3. Bedtime
4. Remind me when a dot starts — on/off
5. Send me a test alarm
6. Calendars — connect
7. Account and sync
8. Everything else… — opens the full Settings tree

Notification health (A0) is not a row; it appears as a banner above row 1 only when the OS state is wrong.

**Onboarding.** Step 0 asks one question with two cards: *Just the next dot* ("Dottoday shows what's now and what's next. Add, do, done.") and *The full planner* ("Thread, routines, reviews, widgets and every setting."). Minimal then runs three steps: Wake Up and Bedtime, reminders permission with the test alarm, first task. Full runs the existing O1–O4 flow. Either way the choice is one tap to undo later.

## 5. Entering, leaving, revealing

The mode is chosen in onboarding step 0, changed in two places, and overruled by nothing. Switching is instant and reversible; it never shows a confirmation, a tour, or a loss warning, because nothing is lost.

**Where the switch lives.** Settings row 1 (both modes) and the Today header menu as *Show everything* / *Show less*. Nowhere else: no banner, no onboarding re-prompt, no "try full mode" nudge after N days.

**Progressive reveal.** Hidden features earn their way onto the screen through a trigger, as a single quiet row in context (the same component as B3 Unstick's row), never a modal or a toast. Fixed budget: one hint per calendar day, each hint at most twice ever, *Not now* dismisses forever. Hints never fire inside Focus, in a Bedtime review, or while low-energy mode is on.

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

**One policy object, not scattered ifs.** `features/layout/` holds `LayoutPolicy` with `visibility(FeatureId) → Visibility {shown, simplified, hidden, off}` backed by one table that mirrors §3 exactly, plus `uiLayoutProvider` exposed through Riverpod and read with `ref.watch(select)` so a flip rebuilds only what changes. Views ask the policy; they never read the raw flag. A new `FeatureId` without a row in the table fails a policy test, so the matrix cannot drift from the code.

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

- [ ] Widget test enumerates every tappable control on minimal Today and asserts the set is exactly {Add, Done, Running late, header menu, Later row, day swipe}
- [ ] Property test: for any seeded database, `full → minimal → full` leaves every table byte-identical
- [ ] Policy test: every `FeatureId` has a row; every `hidden` feature is reachable within two taps from a *More* row (traversal test over the route table)
- [ ] Golden matrix: 5 minimal screens × light/dark × largest text scale × RTL
- [ ] Onboarding in minimal is three steps after the mode choice and asks for no setting that has a default
- [ ] No string in minimal mode or in a hint fails the no-shame audit (no "late", "missed", "failed", no red)
- [ ] Manual on a real device: cold install to first dot on the thread in under 20 seconds

**Open questions for the owner**

- [ ] Default for new installs: preselect *Just the next dot*, preselect *The full planner*, or no preselection? Proposal: preselect minimal; the full planner is a tap away and the first impression is the one that keeps ADHD users
- [ ] Name in the UI: "Minimal", "Simple", or "Just today"? Proposal: no name, just the two card titles and the Settings row *Layout: Minimal / Full*
- [ ] One layout per account (synced) or per device? Proposal: per account, with the Mac free to show Week/Month in its View menu either way
- [ ] Should the Mac in minimal mode hide Week and Month entirely, or keep them one click away? Proposal: one click away under View
- [ ] Does the Bedtime review stay in minimal as the one-card version, or go hidden? Proposal: stay, because "tomorrow or Later?" is the one decision that keeps the thread honest
