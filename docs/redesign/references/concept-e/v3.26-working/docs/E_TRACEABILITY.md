# Concept E · traceability checklist

**Purpose.** This list maps every accepted design decision, every board proposal and every built feature to its home on the Concept E boards. It exists so that nothing silently disappears between the boards and the implementation spec (ED-076). Each row says what the implementation must do and how far verification has got.

**Nothing here authorises implementation.** Round 2 and Prompt E are still needed. Group 2 to Group 4 of the register are still open (ED-074: no Flutter work until Group 2 is complete and reconciled).

## Sources (all read 2026-11-04)

| Source | Date | Role |
|---|---|---|
| `E-Phones.dc.html` (live-33) | 2026-11-04 | Active. Full phones |
| `E-PhonesMinimal.dc.html` (live-33) | 2026-11-04 | Active. Minimal phones |
| `E-Minimal.dc.html` (live-32) | 2026-11-04 | Active. Minimal Mac and web |
| `E-FullA-v2.dc.html` (design-r1) | 2026-11-04 | Active. Approved Full Mac and web (ED-073) |
| `E-PhonesCalendar.dc.html` (design-r1) | 2026-11-04 | Calendar screens; approved and merged into E-Phones (ED-079) |
| `E-Workspace.dc.html` (live-32) | 2026-11-04 | Reference only. E-FullA-v2 wins where they differ (ED-074) |
| `FEATURE_PARITY_MATRIX.md` | 2026-11-02 | Every built feature |
| `E_DESIGN_DECISIONS.md` | 2026-11-04 | ED-001 to ED-076 |
| `E_DECISION_REGISTER.md` | 2026-11-04 | G1 (resolved), G2-1 (resolved), G2-2 to G2-13, G3, G4 |
| `E_DESIGN_RULES.md` §8, §9.0 · `E_SCREEN_INVENTORY.md` | 2026-11-04 | Rules and drawn coverage |

Board text was read from captions (Built today, Design-only, Hypothesis / Proposed, Platform note) and section comments.

## Status words

| Word | Meaning |
|---|---|
| **APPROVED** | An explicit owner approval exists. The ED number is cited. |
| **ADOPTED FROM BOARD** | Drawn on a current E board as a proposal or hypothesis, with no conflict found. Per ED-076 the boards are the preferred direction. This is not explicit approval. |
| **OPEN** | Tied to an unresolved register decision (G2-x, G3-x, G4-x). |
| **NOT DESIGNED** | A parity feature with no E board home yet. The row says what needs drawing. |
| **REJECTED** | The ED log says rejected. The row stays so it is visibly excluded. |

**Verification** is "Not started" everywhere, because nothing is implemented. "NV: needs device" marks features the parity matrix marks ✓d (only a device run proves them).

**Board short names.** EP = E-Phones · EPM = E-PhonesMinimal · EM = E-Minimal · FA2 = E-FullA-v2 · EPC = E-PhonesCalendar · EW = E-Workspace (reference). F = frame, I = inset.

---

## A. Accepted design decisions

ED-070 and ED-071 (the G1-1 option boards) are superseded by ED-073 and have no row. ED-062 is resolved by ED-064.

| ID | What | Board / screen | Implementation requirement | Status | Verification |
|---|---|---|---|---|---|
| ED-001 | Workspace board (B's layout, A's look) | EW, now carried by FA2 | Build the Full Mac/web layout from FA2, which is EW's frames with listed edits; EW itself is reference only. | APPROVED (ED-001, ED-073, ED-074) | Not started |
| ED-004 | Focus board (C's full layout) | archived v1.0 `E-Focus` | Do not build a wide Focus presentation; keep only Focus the feature. | APPROVED, superseded by ED-065 | Not started |
| ED-006 | Minimal phone board | EPM, all frames | Minimal on phones follows EPM's six frames and band. | APPROVED (ED-006) | Not started |
| ED-007 | Concept E is a copy of the latest A; A untouched | all E boards | Use E boards only as the design source; never restore A to Round 1. | APPROVED (ED-007) | Not started |
| ED-008 | Every change recorded as rules | `E_DESIGN_RULES.md` | Each future design change adds an ED entry and a rules update before code. | APPROVED (ED-008) | Not started |
| ED-009 | Task-dot states: done solid, now progress ring, ahead outline, icon inside | all thread frames, legends | One dot widget renders exactly three states plus calendar grey, with the icon inside. | APPROVED (ED-009) | Not started |
| ED-011 | Brand mark = outlined circle with filled centre, teal | web sidebars (FA2, EM) | The web sidebar brand mark uses the Today icon in #11615C; Mac menu bar shows the word only. | APPROVED (ED-011) | Not started |
| ED-012 | Manrope content type, tabular numerals, teal #11615C, ink #241F2B / #6A6273, C's task palette, cream #FBF7F1, rounder radii | all boards | `DotTheme` tokens carry these values; system fonts stay on platform chrome. | APPROVED (ED-012); production typeface RESOLVED G3-3: Manrope (ED-110) | Not started |
| ED-013 | Warm surfaces, flat full-height sidebar, tone shifts instead of hairlines | all boards | Surface tokens #FFFDF9 / #F6F1EA / #F1EBE3; web sidebar #F3ECE2; no hairlines between large panes. | APPROVED (ED-013) | Not started |
| ED-015 | Faint lavender menus, lavender-grey dividers, warm-violet greys, tonal teal secondary buttons, pale indigo inside now-dots | all boards | Menu, divider, grey and secondary-button tokens use these values; no cool greys remain. | APPROVED (ED-015) | Not started |
| ED-017 | Wake Up amber (#FBEBC8 / #9A5A0E), Wind Down pale indigo (#E6E3F7 / #4B3FB0) | caps on every thread, headers, strip marks | One cap colour pair per cap on every platform and board. | APPROVED (ED-017) | Not started |
| ED-019 | Status-tag colours, cream Clear-your-head button, teal focus rings, white now-bead ring | all boards | Focus rings are teal; the now-bead has a white ring and no apricot cap. | APPROVED (ED-019) | Not started |
| ED-020 | C's orb as the large now-dot (track #E4E3F7, indigo arc, big minutes) | EPM F1/F5, EM Now pane (ED-059 "the orb") | One orb component with an accessible label such as "85 percent elapsed, 18 minutes left". | APPROVED (ED-020, ED-059); one drawing everywhere OPEN G3-2 | Not started |
| ED-021 | Compact thin ring with bold minutes in the Now mini window | EM I-mini | Use the compact ring in the mini window if the window passes its feasibility check. | APPROVED (ED-021); window itself needs feasibility (ED-066) | Not started |
| ED-022 | Bold, lean finish: 700 titles, 800 headlines, tabular numerals, no glows, shadows only on floating surfaces | all boards | Type weights and shadow tokens enforce this; no glow or drop-shadow filters. | APPROVED (ED-022) | Not started |
| ED-024 | Bigger Focus-board dots (first step) | superseded by ED-025 | No separate implementation; ED-025 values apply. | APPROVED, superseded by ED-025 | Not started |
| ED-025 | Large, comfortable scale (dots 32–34, now-dot 40 phones / 38 wide, thread 4, names 17 / 15) | all boards | Dot, thread and row tokens use the large values; native controls keep native size. | APPROVED (ED-025); final direction OPEN G3-1 | Not started |
| ED-027 | Add-field dot matches normal dots (34 px, 4 px ring, 19 px icon), 58 px field | EP F2 | The Add field reuses the standard dot at 34 px with the drawn insets. | APPROVED (ED-027) | Not started |
| ED-028 | True iOS controls (switch, segmented control, sheet proportions, glass Close, iOS 26 tab bar, keyboard, 250 px pull-down) | EP iPhone frames | iPhone frames use native Cupertino controls or platform views where tagged. | APPROVED (ED-028); switch tint RESOLVED G3-4: teal (ED-112), design verification PASS (ED-117) | Not started (switch tint: 3 known gaps, rules §4.2) |
| ED-031 | Return key reads "Add" in app teal | EP F2, EPM F3 | The iPhone Add keyboard shows an "Add" action in teal via a custom key or input accessory bar. | APPROVED (ED-031); drawn as stock keyboard + neutral return (G3-7 C, ED-135) · was OPEN G3-7 | Not started |
| ED-033 | iPhone tab bar is see-through Liquid Glass | EP, EPM tab bars | Tab bar uses native glass material or an approximation; the thread shows under it. | APPROVED (ED-033); native vs approximated OPEN G3-6 | Not started |
| ED-034 | Liquid Glass across iPhone chrome (tab lens, Sync + avatar capsule, ‹ Today, Day chip, Day pull-down, Close) | EP, EPM | All listed iPhone chrome elements use glass; sheets do not. | APPROVED (ED-034); OPEN G3-6 | Not started |
| ED-035 | Android translucent tonal M3 bars, blur on 12+, solid below, no glass | EP F5, EPM F5 | NavigationBar and Day button use translucent tonal surface with RenderEffect blur on Android 12+; FAB and menus stay solid. | APPROVED (ED-035) | Not started |
| ED-038 | Inbox is a tab with a count badge on phones | EP F1/F5, EPM F1/F5 | Phones reach the Inbox only through its tab with a badge; drag-from-Inbox stays wide only. | APPROVED (ED-038) | Not started |
| ED-040 | iPhone date title in the nav row ("Tue 3 Nov ▾"), summary under it | EP F1, F4 and dimmed backgrounds | The iPhone date title is a 28 px left button in the top row beside the glass capsule. | APPROVED (ED-040) | Not started |
| ED-059 | The minimal hero is "the orb" | EPM F1/F5, EM Now | Name the component "orb" in code and rules; no visual change. | APPROVED (ED-059, visual) | Not started |
| ED-060 | C boards are reference only | C-Minimal, C-PhonesMinimal | Never use C boards as a design source for E code. | APPROVED (ED-060) | Not started |
| ED-061 | Task dot change applies to A/E only | E boards | No action outside E. | APPROVED (ED-061) | Not started |
| ED-064 | E-Minimal is the wide Minimal layout | EM Mac, EM web | Build wide Minimal from EM's layout (sidebar, Now pane, Day column). Its inner behaviours stay in section B. | APPROVED (ED-064, direction only) | Not started |
| ED-065 | Two modes, Full and Minimal; Focus is a feature in both; Workspace is planning inside Full | all boards | Implement exactly two presentation modes; Focus reachable from both; no third layout. | APPROVED (ED-065) | Not started |
| ED-066 | Minimal opens on Now; Full shows the current task on the Today timeline | EPM F1/F5, EM Now; FA2 ring under the 10:42 line | Minimal launches on Now; Full has no Now destination and marks the live task on the timeline. | APPROVED (ED-066); mini window and status item need feasibility | Not started |
| ED-067 | Full/Minimal switch in the Day menu and first Settings row, plus Mac View menu; switching keeps task, day and navigation state | EP I3/I6, EPM F2, FA2 Day menu, View menu, "Settings, first row", "What the switch keeps" | One per-account setting; switch entries in Day menu, Settings row 1, Mac View menu; open task, selected day and view survive a switch. | APPROVED (ED-067); keys OPEN G2-10; unsaved edits OPEN G2-5 | Not started |
| ED-068 | Minimal navigation: phones Now · Today · Inbox; Mac/web sidebar Now · Inbox · Calendar · Search; the sets differ on purpose | EPM tab bars, EM sidebars | Build both sets as drawn; do not unify them; supersedes doc 14 §3 on this branch only. | APPROVED (ED-068) | Not started |
| ED-069 | Full phones keep the EP tab bar (Today · Inbox · Calendar · Search) | EP F1, F5 | Full phones use four tabs: Today, Inbox (badge), Calendar, Search. | APPROVED (ED-069) | Not started |
| ED-072 | FA2 accepted as the Option A candidate board ("Looks right") | FA2 | Use FA2 as the Full Mac/web reference; its keys, routes, increments and Replan move stay proposals (section B). | APPROVED (ED-072, board only) | Not started |
| ED-073 | Full Mac/web = Workspace (sidebar, Inbox and Routines column, Day / 3 days / Week / Month grid, docked inspector) | FA2 Mac Week, web Day | Full wide is the Workspace layout from FA2; Show Everything in Minimal opens it. | APPROVED (ED-073) | Not started |
| ED-074 | Group 2 one by one; FA2 active, EW reference; no Flutter work until Group 2 is reconciled | process | Where EW and FA2 differ (Running Late, Replan, ⌘M, ⇧⌘G, `/plan/...`), follow FA2. | APPROVED (ED-074) | Not started |
| ED-075 | Calendar tab opens Month; title ▾ opens the quick month sheet; pull-down month stays; one `MonthGrid` / `month_data` | EP I4, EPC all frames | One shared month component reached three ways on phones; Week wherever width allows. | APPROVED (ED-075, behaviour); EPC drawings under review | Not started |
| ED-076 | Latest E boards are the preferred direction; this checklist exists | process | Board items stay in the spec unless a conflict is listed; no item is dropped silently. | APPROVED (ED-076) | Not started |
| ED-124 | iPhone bottom row: shortened glass tab bar (21 from bottom and left, right 90, 63 tall) with a separate 63 pt teal glass + 6 pt to its right; Day ▾ right-aligned with the +, 16 above; Full and Minimal | EP iPhone frames with the tab bar (7), EPM (5); source `E-G3-6-BottomRow` | Build the row as rules §9.15: destinations unchanged, + tap/hold unchanged, Search a regular tab, + aligned to the capsule's measured frame, iOS 16 minimum kept with a same-geometry fallback; Reduce Transparency solid. | APPROVED (ED-124); Architecture SELECTED: N3 native composition (ED-128 D1); iOS 16–25 F2 conditional (D2) | Not started · N3 device spike shows the arrangement (ED-122); hands-on and accessibility checks open |
| ED-132 | iPhone Minimal on iOS 26+: native three-tab capsule width, 6 pt from the +, larger left inset | EPM iPhone frames with the tab bar (5) | Align the + 21 / 21 and the capsule 6 pt from it using the rendered capsule bounds each layout pass; never hardcode 274; F2 keeps 21 / 6 / 21. | APPROVED (ED-132) | Simulator measured 274 on iOS 26.5 (ED-131); other sizes, rotation, accessibility settings PENDING |
| ED-125 | Android bottom row, revised C: floating frosted navigation toolbar (16/80/24, 72 tall), icon-only 56 dp + beside it, Day left 16 dp above; Full and Minimal | EP Android frames with navigation (5), EPM (2); source `E-G3-6-Android` C | Build as rules §9.15: frosted blur on 12+, solid tonal on 11 and older, ≥ 48 dp targets, system insets (gesture and 3-button), hidden with the keyboard; a custom Material-inspired arrangement, never called Liquid Glass. | APPROVED (ED-125); Architecture SELECTED: Flutter widget (ED-128 D5) | Not started |
| ED-130 | Mac sidebar: native NSVisualEffectView sidebar material with a `#EFE7DB` 35 % warm tint inside it (light mode) | E-Minimal, E-FullA-v2 sidebars (drawn as the flat approximation); source `E-G3-6-Remaining` capture 2 | Native material + tint layer under a transparent Flutter view; layout, rows, selection, type and interaction unchanged; solid fallback with Reduce Transparency; dark treatment from G4-6; never a flat Flutter blur in its place. | APPROVED visual direction (ED-130) | Spike measured ink 12.1:1, teal 5.5:1 (ED-129); Reduce Transparency, Increase Contrast, VoiceOver, keyboard, dark mode PENDING |

---

## B. Board proposals (hypotheses)

### B.0 Board tags already settled by an owner answer

These are still tagged "Hypothesis · not approved" on a board, but a later owner answer settles them. The boards are stale here, not the decision.

| Item | Board / frame | Settled by |
|---|---|---|
| Glass tab bar kept in minimal with Now · Today · Inbox | EPM F1 | ED-068 |
| NavigationBar kept in minimal (Now, Today, Inbox) | EPM F5 | ED-068 |
| Inbox is its own tab / sidebar row, not doc 14's "Later" row | EPM band, EM band | ED-068 |
| Sidebar kept in wide minimal | EM Mac caption | ED-068 |
| Now as the entry place in Minimal | EM web caption | ED-066 (the `/now` route stays OPEN G2-11) |
| "G1-1 open · owner considering option A · not approved" header | FA2 header | ED-073 (G1-1 resolved) |
| Header tag "Hypothesis · not approved" over the owner's dot, type, colour, finish and scale changes | EP header | ED-009, ED-012, ED-013, ED-015, ED-022, ED-025 |
| Show everything "opens E's standard wide layout, which is an owner decision" | EM band | ED-073 (it opens the Workspace) |

### B.1 Open proposals

| Item | Board / frame | Status | Conflict, if any | Implementation requirement |
|---|---|---|---|---|
| Settings leaves the tab bar: avatar on phones, ⌘, own window on Mac, sidebar foot and `/settings` on web | EP F1, F5; EPM F1, F5; EM sidebar; FA2 platform note | OPEN G2-3 | Built app has a Settings tab; every entry must still reach Settings. | Settings opens from the avatar on phones, ⌘, window on Mac, sidebar foot on web. · **Close-out (ED-335):** settled: G2-3 ED-238 |
| Brain dump and Routine as Add modes (segmented Task · Brain dump · Routine; hold on +; M3 FAB menu) | EP F2, EP I5 | OPEN G2-8 | iOS hold menu is not drawn; a hold-only path needs a visible alternative (accessibility). | Add offers Task, Brain dump and Routine; both modes go through the proposal sheet. · **Close-out (ED-335):** settled: G2-8 ED-091 |
| Unified task surface: pull up to the large detent = full editor (iPhone); one M3 bottom sheet (Android) | EP F3, EP F6 | OPEN G2-5 | Save model (autosave vs Save) is undecided; large-detent layout not drawn. | One task surface per platform that grows into the editor; save behaviour per G2-5. · **Close-out (ED-335):** settled: G2-5 ED-086 |
| Move opens a day + time picker (fixes the dead tile); M3 dial on Android | EP F3, EP F6 (Design-only) | OPEN G2-7 | Built Move tile is dead (✗). iOS picker not drawn. | Move opens one day-and-time picker; also a screen-reader "Move to…" action. · **Close-out (ED-335):** settled: G2-7 ED-077, ED-099 |
| Day ▾ menu replaces the ⋯ catch-all (Replan · Plan · Reflect · View · Share) | EP I3, I6 (Design-only) | OPEN G2-9 | Uses "Running late", which breaks the no-"late" rule (G3-10). | One grouped Day menu per platform holding every former ⋯ item. · **Close-out (ED-335):** settled: G2-9 ED-093; G3-10 ED-162 |
| Day menu on Mac/web: Time · Plan · Day · Layout sections; Replan button removed | FA2 Mac Day menu, web popover, empty-day disabled states | OPEN G2-9 | Has no Plan / Reality item, which the phone Day menu has (parity loss on wide). | Wide Day menu as drawn, plus a Reality-thread entry. · **Close-out (ED-335):** settled: G2-9 ED-093 |
| "Need More Time…" behaves like the built Running late | FA2 open items | OPEN G2-9, G3-10 | None with built behaviour. Name differs across boards. | Rename only; extend the live task and move the rest, as built. · **Close-out (ED-335):** settled: G2-9 ED-093; G3-10 ED-162 |
| One set of increments +5 / +15 / +30 everywhere | FA2 inspector, Day menu, web chips | OPEN G3-11 | Phones (EP F3, EPM) and EM show only +15 / +30. Built app has +5. | Show +5, +15 and +30 on every platform; check 44 pt targets on phones. · **Close-out (ED-335):** settled: G3-11 ED-163 |
| "Plan from Inbox · 3" button on the empty iPhone day | EP F4 | OPEN G2-13 | Owner removed the Inbox tray; unclear if this button too (ED-039). | Keep or remove per G2-13; it is a built empty-day action. · **Close-out (ED-335):** settled: G2-13 ED-077, adopted from board; owner question open (ED-335) |
| No Inbox suggestions on an empty minimal day | EPM F4 | OPEN G2-13 | None found. | Empty minimal day shows Add only; Inbox stays one tab away. · **Close-out (ED-335):** settled: G2-13 ED-077, adopted from board; owner question open (ED-335) |
| Done tasks folded into one "Earlier · 3 done" row | EPM F2, EM Day column | OPEN G3-12 | doc 14 §4 keeps done tasks in place; the count is a judging number. | Fold or keep in place per G3-12. · **Close-out (ED-335):** settled: G3-12 ED-164 |
| Summary line shows time, not counts | EPM F1 note, EM toolbar | OPEN G3-12 | Full EP shows "3 of 9 done" (fine in Full). | Minimal summary shows time only. · **Close-out (ED-335):** settled: G3-12 ED-164 |
| Focus by tapping or clicking the big now-dot | EPM F1, EM caption | ADOPTED FROM BOARD | Accessibility: the orb must be a labelled button; EPM phones show no separate Focus button. | The orb is a button labelled "Focus"; keep the Focus tile/button route too. |
| Task screen opens in the Day column and closes back to the Day (✕ / Esc) | EM I-task, EM web caption | OPEN G2-5, G2-6 | EM's set lacks Done and Delete (G2-6 option A wants doc 14's set). Web version only described. | Wide minimal task screen in the right column with Esc focus return. · **Close-out (ED-335):** settled: G2-5 ED-086; G2-6 ED-088 |
| Hide the Day column (⌥⌘D / "Hide the day thread") | EM Mac, EM web | OPEN G2-10 (key) | G2-10 proposes ⌥⌘I instead of ⌥⌘D. | Day column can be hidden and shown; key per G2-10. · **Close-out (ED-335):** settled: G2-10 ED-095 |
| Everything else finder (⌘K Mac, `k` web; also finds tasks) | EM I-finder | OPEN G2-4, G2-10 | FA2 uses ⌘K for the command palette; one key cannot mean both. | One ⌘K meaning across modes, per G2-10; finder contents per G2-4. · **Close-out (ED-335):** settled: G2-4 ED-081, ED-084; G2-10 ED-095 |
| ⌘K command palette (commands and tasks) | FA2 palette inset | OPEN G2-10 | Clashes with EM's ⌘K finder. | Palette as drawn, once G2-10 settles ⌘K. · **Close-out (ED-335):** settled: G2-10 ED-095 |
| Mac keys: ⌘1–4 = Day / 3 Days / Week / Month; Inbox ⇧⌘I; Today ⌘T; ⌘← ⌘→; ⌘[ ⌘]; Go to Date ⇧⌘T; Search ⌘F; Move ⇧⌘M; Focus ⇧⌘F; Show Less ⇧⌘L | FA2 key table, View and Go menus | OPEN G2-10 | Built ⌘2 = Inbox changes meaning. EM uses ⌘1–4 = Now/Day/Calendar/Inbox, ⌘F = Focus, ⌘M Move, ⇧⌘G Go to date. | One key scheme for both modes per G2-10. · **Close-out (ED-335):** settled: G2-10 ED-095 |
| Web single keys (n, b, /, t, [ ], d 3 w m, g, i, ⇧L, f, ?); never ⌘/Ctrl N, T, W, L, 1–4 | FA2 web hint bar, key table; EM web hint | OPEN G2-10 | Built web binds ⌘1–4, which browsers use for tabs. | Single keys outside text fields, per G2-10. · **Close-out (ED-335):** settled: G2-10 ED-095 |
| Web routes: `/today?task=`, `/3-days/<date>`, `/week/<date>`, `/month/<yyyy-mm>`, `/task/<id>` redirects on wide, `/now` only in Minimal | FA2 route table; EM web `/now` | OPEN G2-11 | Path URLs need a static-host rewrite. EW's `/plan/...` is not adopted. | Keep every built route; add dated routes per G2-11. · **Close-out (ED-335):** settled: G2-11 ED-097 |
| What the switch keeps: date, open task, view, scroll | FA2 "What the switch keeps" | ADOPTED FROM BOARD (behaviour approved by ED-067) | None found. | Restore date, task, view and scroll on return to Full. |
| Unsaved inspector edits on a mode switch | FA2 "What the switch keeps" | OPEN G2-5 | None until G2-5. | Follow the G2-5 save model. · **Close-out (ED-335):** settled: G2-5 ED-086 |
| Multi-selection and drag in progress cancelled on switch | FA2 "What the switch keeps" | OPEN (ED-072 open item; no register ID yet) | Needs a register entry. | Cancel on switch with Undo available, if approved. · **Close-out (ED-335):** drawn R2-6 (ED-279) |
| Switching layout is not a Back step; a `/week` link while Minimal is on | FA2 open items | OPEN G2-11 (link); Back rule has no register ID | None found. | Decide before routing work. · **Close-out (ED-335):** settled: G2-11 ED-097 |
| Extra Full sidebar rows: Plan (Inbox, Routines, Brain dump), Review | FA2 sidebar | OPEN G2-2 | None found. | Rows as drawn, per G2-2. · **Close-out (ED-335):** settled: G2-2 ED-080 |
| "Lists (future, not part of this release)" sketch | FA2 sidebar | OPEN G2-2 | Outside parity (brief §9, Q6). | Do not build Lists. · **Close-out (ED-335):** settled: G2-2 ED-080 |
| Hover lift shadow on a web block (Lunch) | FA2 web Day | RESOLVED G3-5 option C (ED-116); merged into FA2 (Lunch hover) | None: rest flat, hover tint `#F5F1EB` + hairline, lift only while dragging (rules §7.4). Motion timing, scale and haptics OPEN (§7.5). | Implement per rules §7.4 when Workspace blocks are built; not yet implemented. |
| Mac Now mini window (Window › Show Now ⌥⌘0) | EM I-mini | ADOPTED FROM BOARD, feasibility check required (ED-066) | New window type; may not be possible in Flutter today. | Spike first; build only if feasible. |
| Mac status item menu (Mark Done, Need More Time?, Show Now Window) | EM I-menu | ADOPTED FROM BOARD, feasibility check required (ED-066) | A status item is already built (`DayDotStatusItem.swift`); EM tags it "Built today". Only the new menu items need checking. | Extend the built status item; keep its current function. |
| Context menu set (Open, Mark Done, Move To…, Duplicate, Copy as Text, Need More Time ▸, Shift the Rest, Focus, Move to Trash) | FA2 Mac right-click; EM horizon right-click | OPEN G2-10, G3-10 | EM uses Delete ⌫ and lacks Need More Time; FA2 uses Move to Trash ⌘⌫. | One item set and naming in both modes; native PlatformMenu. · **Close-out (ED-335):** settled: G2-10 ED-095; G3-10 ED-162 |
| "Gentle Day" / "Low-energy day" / "Low-Energy Mode" | EM menu caption and finder; EPM F2; FA2 Day menu | OPEN G3-10 | Built name is "Low-energy mode". | One name per G3-10. · **Close-out (ED-335):** settled: G3-10 ED-162 |
| iPhone unselected tab-label grey #8E8E93 (≈3.1:1) vs #6E6E73 | EP vs EPM tab bars | OPEN G3-8 | Fails WCAG 4.5:1 text contrast. | Use a grey that passes 4.5:1. · **Close-out (ED-335):** settled: G3-8 ED-154 |
| iOS switch on-state in teal | EP iPhone frames | RESOLVED G3-4 option A (ED-112) · design verification PASS (ED-117) | None in the designs: 8 iOS switches `#11615C`. Built app: 3 switches without a tint (ED-117). | Flutter: NOT YET IMPLEMENTED / VERIFIED (implementation checks in rules §4.2). Dark mode: PENDING G4-6. |
| Whole iPhone keyboard look | EP F2, EPM F3 | RESOLVED G3-7 C (ED-135) | Stock keyboard drawn; teal key removed. | Stock keyboard; neutral return adds; Add in field row / nav bar. |
| Glass and vibrancy: native or approximated | EP, EPM, EM notes | OPEN G3-6 | Native glass needs platform views; reduced-transparency fallback not drawn. | Per G3-6, with a reduced-transparency fallback. · **Close-out (ED-335):** settled: G3-6 ED-133 |
| Large scale vs "C confidence" | all boards | OPEN G3-1 | None found. | Keep large values until G3-1. · **Close-out (ED-335):** settled: G3-1 ED-104 |
| Web orb drawn like the Mac orb | EM web Now | OPEN G3-2 | None found. | One orb drawing per G3-2. · **Close-out (ED-335):** settled: G3-2 ED-106 |
| Minimal phones: Search, Past days, Routines, Export, Trash under Settings › Everything else | EPM band, EPM F3 note | OPEN G2-4 | None found. | Minimal Settings has an Everything else row that reaches each item. · **Close-out (ED-335):** settled: G2-4 ED-081, ED-084 |
| Routines hint after three similar mornings | EPM band | ADOPTED FROM BOARD | None found (built hint). | Keep the built hint as a Routines entry in Minimal. |
| Two chips at most and a "Lands at" preview in minimal Add | EPM F3, F6 (Design-only) | ADOPTED FROM BOARD | None found. | Minimal Add shows at most two parsed chips and the landing preview. |
| Calendar tab Month screen with day preview card, Open day, Add to selected day | EPC iPhone and Android Calendar frames (Proposed · for review) | APPROVED (ED-075, ED-079) | Drawn on EP Calendar row. | Build from the shared month grid; 52 × 62 pt / 56 × 62 dp day buttons. |
| Pull-down month drawn with the same grid and dots | EPC iPhone Today | ADOPTED FROM BOARD | None found. | Reuse the one month component for the peek. |
| Android title opens the month as an M3 modal bottom sheet | EPC Android Today | ADOPTED FROM BOARD | ED-047 said Android would use the M3 date picker; EPC uses the app grid in a sheet. ED-075 allows adapting controls. | Bottom sheet with the shared grid; drag down or Back closes. |
| Up to three task dots per day, then +n; large text swaps dots for a count | EPC "One month component" | ADOPTED FROM BOARD | None found. | Month cells follow this rule at every text size. |
| Minimal phones reach Month, Week and Go to date through Everything else | EPC "Minimal mode" note | OPEN G2-4 | EPM band says the date ▾ opens the month sheet in Minimal. Two boards disagree. | Pick one minimal path; the title ▾ sheet is the simpler one. · **Close-out (ED-335):** settled: G2-4 ED-081, ED-084 |
| Tablets get Month · Week in the Calendar view | EPC note | OPEN G4-4 | No tablet layout is drawn. | Per G4-4. · **Close-out (ED-335):** settled: G4-4 ED-171 |

---

## C. Parity features

Home columns name where each feature lives in Concept E. "Hidden in Minimal, reached via …" means the feature is off-screen in Minimal but still reachable.

### C.1 Today and timeline

| Feature | E home on phones | E home on Mac/web (FA2) | E home in Minimal | Status | Verification |
|---|---|---|---|---|---|
| Today timeline, day paging ±365 | Today tab (EP F1, F5) | Day view and Week grid | Today tab (EPM F2); EM Day column | APPROVED (ED-069, ED-073, ED-068); paging gesture not drawn | Not started |
| Go to a date | Title ▾ month sheet (EP I4), Calendar tab (EPC) | Go › Go to Date…, palette, `/day/<date>` | Title ▾ (EPM band); EM toolbar date button, finder | APPROVED phones (ED-075); wide keys OPEN G2-10. Must fix the built UTC/local defect | Not started · **Close-out (ED-335):** settled: G2-10 ED-095 |
| Week strip, month pull-open | Week strip (EP F1, F5); pull-down kept (EPC) | No strip; Month view instead | Not drawn on EPM; title ▾ sheet | APPROVED (ED-075) | Not started |
| Month view | Calendar tab Month (EPC) | Calendar views › Month ⌘4 | Hidden in Minimal, reached via title ▾ (EPM) or EM Calendar row and finder | APPROVED (ED-075, ED-073) | Not started |
| Week view | None on phones (as built) | Calendar views › Week | Hidden in Minimal, reached via EM finder "Week" or Show Everything | APPROVED (ED-073); tablets OPEN G4-4 | Not started · **Close-out (ED-335):** settled: G4-4 ED-171; tablets R2-12 (ED-293) |
| Three-day spread + Inbox sidebar | None (as built) | 3 days view + Inbox column | Hidden in Minimal, reached via Show Everything; EM Inbox row | APPROVED (ED-073); the A-Wide spread itself is rejected (ED-003) | Not started |
| Drag to move, overlaps, knot | Thread (EP F1, F5 captions) | Grid drag, drag from Inbox | EPM F2, EM web hint | ADOPTED FROM BOARD; drag states APPROVED R2-25 (ED-328) | Not started |
| Multi-select + selection bar (incl. Save as routine) | Tip only "Hold a dot to select several tasks" | Not drawn | EPM caption only | NOT DESIGNED: draw the selection bar, n selected, Save as routine, ⇧/⌘-click | Not started · **Close-out (ED-335):** drawn R2-6 (ED-279) |
| Shift the rest / followers / pin / Rebalance | Task sheet Shift the rest; Day menu | Day menu Time section, context menu, inspector | Need more time? popover "Shift the rest" | OPEN G2-9; pin and drag chip NOT DESIGNED | Not started · **Close-out (ED-335):** settled: G2-9 ED-093; R2-5, R2-26 (ED-276, ED-329); pin and Rebalance still to design |
| Running late +5/15/30 | "Need more time? +15 +30" (EP F3); Day menu "Running late" | Need More Time… ▸ +5/+15/+30 | Need more time? +15/+30 (EPM, EM) | OPEN G3-11, G3-10 | Not started · **Close-out (ED-335):** settled: G3-10 ED-162; G3-11 ED-163; R2-26 (ED-329) |
| Now-marker, live dot, done + Undo, ⌘Z | Now-bead, ring dot on every thread | Now line and bead; ⌘Z | Orb and horizon | APPROVED (ED-009, ED-066); Undo toast NOT DESIGNED | Not started · **Close-out (ED-335):** Undo R2-7 (ED-281) |
| Tasks before Wake Up fold | Not drawn (EP F1 shows Morning run unfolded) | Not drawn | Not drawn | NOT DESIGNED: draw the fold, closed and open | Not started · **Close-out (ED-335):** still to design |
| Reality thread | Day menu › View › Plan / Reality (EP I3, I6) | Missing from FA2 Day and View menus | Not listed in either band | NOT DESIGNED: the Reality screen everywhere, and a wide entry | Not started · **Close-out (ED-335):** R2-23, R2-29 (ED-324, ED-332) |
| Duplicate day, Copy day as text | Day menu Plan / Share | Day menu Day section | Hidden in Minimal phones, reached via Show everything; EM Day menu and finder | OPEN G2-9; target-day picker NOT DESIGNED | Not started · **Close-out (ED-335):** settled: G2-9 ED-093; R2-22, R2-29, R2-30 |
| Minimal layout switch | Day menu Show less / Show everything; Settings row 1 | View › Show Less, Day menu Layout, Settings row 1 | Day ▾ first item; EM View menu, finder | APPROVED (ED-067); onboarding step 0 NOT DESIGNED | Not started |

### C.2 Capture and editing

| Feature | E home on phones | E home on Mac/web (FA2) | E home in Minimal | Status | Verification |
|---|---|---|---|---|---|
| Quick Add with natural-language time | + button, Android FAB (EP F2) | Toolbar + / capture field, ⌘N / `n` | EPM F3, F6; EM Add field | ADOPTED FROM BOARD; wide Add popover and live chips NOT DESIGNED | Not started · **Close-out (ED-335):** tablets R2-3 (ED-271); Mac and web Add popover still to design |
| Paste a list → tasks | Paste into Add (EP I2) | Capture field "Paste a list for several" | Paste into Add → Brain dump proposal | ADOPTED FROM BOARD | Not started |
| Add another, duration chips, typed time | EP F2 | Not drawn | Two chips at most (EPM F3) | ADOPTED FROM BOARD; wide NOT DESIGNED | Not started · **Close-out (ED-335):** no Add another (ED-152); wide Add still to design |
| Task sheet, `/task/:id` | Medium detent (EP F3), M3 sheet (EP F6) | Inspector; `/task/<id>` redirects | Minimal sheet described, not drawn; EM right-column task screen | OPEN G2-5, G2-6, G2-11; dead Move tile OPEN G2-7 | Not started · **Close-out (ED-335):** settled: G2-5 ED-086; G2-6 ED-088; G2-7 ED-077, ED-099; G2-11 ED-097; R2-4, R2-27 (ED-274, ED-330) |
| Editor fields (time, duration, colour, icon, notes, subtasks, repeat, alerts ≤ 5, pin, travel, energy) | Large detent not drawn | Inspector: date, time, repeat, alerts, subtasks, overlaps, notes | Task sheet › More; EM More details | OPEN G2-5; colour, icon, pin, travel, energy NOT DESIGNED | Not started · **Close-out (ED-335):** settled: G2-5 ED-086; R2-4, R2-15, R2-27; pin, travel and energy captions only · **2026-11-15:** pin, travel, energy approved R2-40 (ED-346) |
| Inbox, schedule in ≤ 2 taps | Inbox tab with badge | Inbox column, drag, `m` | Inbox tab (EPM), EM Inbox row | APPROVED (ED-038, ED-068, ED-073); phone Inbox screen NOT DESIGNED; picker OPEN G2-12 | Not started · **Close-out (ED-335):** settled: G2-12 ED-099; R2-13, R2-28 (ED-295, ED-331) |
| Brain dump (typed) | Add segment, FAB menu, Day menu | Sidebar Plan › Brain dump, Inbox column block, Day menu ⇧⌘N | Paste several lines into Add; EM ⇧⌘N and finder | OPEN G2-8, G2-2; Brain dump screen NOT DESIGNED | Not started · **Close-out (ED-335):** settled: G2-2 ED-080; G2-8 ED-091 |
| Brain dump (spoken) | Not drawn | Dictate mic on the Brain dump block | Hidden in Minimal (as built) | NOT DESIGNED: listening, permission denied, web fallback | NV: needs device · **Close-out (ED-335):** still to design |
| On-device AI and AI status | Not drawn | Not drawn | Not drawn | NOT DESIGNED: AI status row and unavailable state | NV: needs device · **Close-out (ED-335):** R2-23 (ED-324) |
| Proposal sheet | "Add 4 tasks" (EP I2) | "Nothing is added until you accept" + Plan it | Brain dump proposal (EPM F3) | ADOPTED FROM BOARD; generic sheet NOT DESIGNED | Not started · **Close-out (ED-335):** R2-22, R2-23 (ED-322, ED-324) |
| Break it down | Not drawn | Not drawn | EM More details list only | NOT DESIGNED: thinking, proposal, AI unavailable | Not started · **Close-out (ED-335):** R2-23 (ED-324) |
| Smallest step, Unstick, Rebalance | Not drawn | Rebalance… in Day menu | Not drawn | NOT DESIGNED (Smallest step, Unstick); Rebalance OPEN G2-9 | Not started · **Close-out (ED-335):** settled: G2-9 ED-093; R2-23 (ED-324); Rebalance still to design |
| Routines (save, drop on a day) | Add segment, FAB menu, Day menu, empty day "Drop a routine" | Sidebar Plan › Routines, Inbox column, Day menu | Hidden in Minimal, reached via hint or Settings › Everything else (EPM); EM View › Routines, finder | OPEN G2-2, G2-8; Routines page NOT DESIGNED | Not started · **Close-out (ED-335):** settled: G2-2 ED-080; G2-8 ED-091 |
| Focus `/focus/:id` | Task sheet Focus tile | Inspector Focus, context menu | Big-dot tap (EPM); EM Focus button | APPROVED as a feature (ED-065, ED-066); Focus session screen NOT DESIGNED | Not started · **Close-out (ED-335):** R2-9, R2-26, R2-30 |
| Pick today's one thing | Day menu Plan | Day menu Plan | Not listed on EPM or EM | OPEN G2-9; screen and minimal path NOT DESIGNED | Not started · **Close-out (ED-335):** settled: G2-9 ED-093; Day menu path still to design |
| Low-energy mode | Day menu View | Day menu Layout (✓) | Day ▾ "Low-energy day"; EM "Gentle Day" | OPEN G3-10; header switch NOT DESIGNED | Not started · **Close-out (ED-335):** settled: G3-10 ED-162; R2-22 (ED-322) |

### C.3 Mornings, nights and alerts

| Feature | E home on phones | E home on Mac/web (FA2) | E home in Minimal | Status | Verification |
|---|---|---|---|---|---|
| Day shape, different days, week start, time format | Settings (not drawn); caps on thread | Settings row list names "Day shape" | Not drawn | No Day shape page: the row is removed (ED-321); its settings are in Wake Up and Wind Down (ED-084, R2-18) and Appearance (ED-161); onboarding Your day step APPROVED (R2-16, ED-305) | Not started |
| Sleep target, Wind Down from tomorrow, learn offer, night on the day dot | Not drawn | Not drawn | Moon cap in end-of-day inset (EPM) | NOT DESIGNED: night editor | Not started · **Close-out (ED-335):** Settings › Wake Up and Wind Down (E-Phones, R2-11) |
| Wake Up alarm (alarm-grade) | Drawn: E-R2-19-B | Not drawn (notification fallback) | Not drawn | APPROVED (R2-19 Option B, ED-314): ringing, snoozed, permission, iOS 16–25 fallback, tablets | NV: needs device |
| Snooze, Wake Up card, Wake Up Check | Drawn: E-R2-19-B | Not drawn | Not drawn | APPROVED (R2-19 Option B, ED-314) | NV: needs device |
| Missions: stand up, walk, light | Drawn: E-R2-19-B | — (as built) | Not drawn | APPROVED (R2-19 Option B, ED-314); also drawn for tablets, not offered there yet | NV: needs device |
| Missions: breathe, catch the dot, one thing; hold-to-skip | Drawn: E-R2-19-B | Not drawn | Not drawn | APPROVED (R2-19 Option B, ED-314), with Can't right now (hold 5 s); also drawn for tablets | Not started |
| Wind Down review `/review` | Day menu Reflect › Review the day | Day menu, sidebar Review | End-of-day card (EPM inset); EM Day menu, finder | OPEN G2-12; full review page NOT DESIGNED | Not started · **Close-out (ED-335):** settled: G2-12 ED-099; R2-14 (ED-297) |
| Task alerts (lead time, ≤ 5, exactly once) | Not drawn (in More) | Inspector Alerts + Add alert | Task sheet › More | ADOPTED FROM BOARD (wide); phones NOT DESIGNED | NV: needs device · **Close-out (ED-335):** R2-20, R2-27 (ED-317, ED-330) |
| Notification health, test alarm | Not drawn | Not drawn | Not drawn | NOT DESIGNED | Not started · **Close-out (ED-335):** R2-20 (ED-317) |
| Quiet hours, day-start summary, Wind Down reminder, nudges | Not drawn | Not drawn | Not drawn | NOT DESIGNED (Settings) | Not started · **Close-out (ED-335):** R2-20 (ED-317) |
| Sounds (per dot, Start sound, haptics) | Not drawn | Not drawn | Not drawn | NOT DESIGNED | NV: needs device · **Close-out (ED-335):** Sound page still to design |

### C.4 Data, sync and accounts

| Feature | E home on phones | E home on Mac/web (FA2) | E home in Minimal | Status | Verification |
|---|---|---|---|---|---|
| Encrypted local DB, recovery screen | Not drawn | Not drawn | Not drawn | NOT DESIGNED: recovery screen | Not started · **Close-out (ED-335):** R2-21 (ED-319) |
| Sync + status (banner, sheet, sidebar line) | Sync icon in the glass capsule / top bar | Sidebar foot "Synced · 10:42" | Top bar (EPM); EM toolbar / footer "Synced" | ADOPTED FROM BOARD (indicator); banner and sheet OPEN G4-7. Must fix the built pull stall | Not started · **Close-out (ED-335):** settled: G4-7 ED-186 to ED-196 |
| Account: Apple, Google, email; sign out everywhere; delete | Avatar | Settings window | Avatar; EM Settings | OPEN G2-3; account screens NOT DESIGNED | Not started · **Close-out (ED-335):** settled: G2-3 ED-238; waits on CR-160 |
| App lock | Not drawn | Not drawn (— on web) | Not drawn | NOT DESIGNED | Not started · **Close-out (ED-335):** R2-24, R2-29, R2-30 |
| Backups, restore, export JSON/CSV/ICS, import | Not drawn | File › Export…; Settings › Data | Hidden in Minimal, reached via Settings › Everything else › Data (EPM); EM finder, File › Export… | OPEN G2-4; panels NOT DESIGNED | Not started · **Close-out (ED-335):** settled: G2-4 ED-081, ED-084; R2-21 (ED-319) |
| Trash (30 days), Undo/Redo | Swipe Delete (EP I1) | Move to Trash ⌘⌫, ⌘Z | EPM swipe Delete; EM finder "Backups and Trash" | OPEN G3-10 (name); Trash page and Undo toast NOT DESIGNED | Not started · **Close-out (ED-335):** settled: G3-10 ED-162; R2-21, R2-30 |
| Device calendars + write-back | Event row "Calendar, read-only" | Event row; Settings › Calendars | Event on horizon and Day column | ADOPTED FROM BOARD (event row); connect and permission screens NOT DESIGNED | Not started |
| Google/Microsoft calendars | Not drawn | Not drawn | Not drawn | NOT DESIGNED | Not started · **Close-out (ED-335):** R2-24, R2-28, R2-29, R2-30 |
| Search with history, Past days, year strip | Search tab | Sidebar Search ⌘F / `/` | Hidden in Minimal phones, reached via Settings › Everything else; EM Search row; Past days in EM finder | APPROVED as a destination (ED-069, ED-068); Search screen and Past days NOT DESIGNED | Not started |
| Weekly review + share, learning reveal, hints | Day menu Reflect › This week | Day menu "This Week", sidebar Review | EM View › Reviews, finder; not listed on EPM | OPEN G3-10, G2-12; screen NOT DESIGNED | Not started · **Close-out (ED-335):** settled: G2-12 ED-099; G3-10 ED-162 |

### C.5 System surfaces

| Feature | E home on phones | E home on Mac/web (FA2) | E home in Minimal | Status | Verification |
|---|---|---|---|---|---|
| Home / lock-screen widgets | Drawn: E-R2-17 | — (menu bar on Mac) | Not drawn | APPROVED (R2-17, ED-309) | NV: needs device |
| Live Activity / ongoing notification | Drawn: E-R2-17 | — (web tab live dot not drawn) | Not drawn | APPROVED (R2-17, ED-309); none on iPad | NV: needs device |
| Controls / Quick Settings tiles | Drawn: E-R2-17 | — | Not drawn | APPROVED (R2-17, ED-309) | NV: needs device |
| App Intents, Siri & Shortcuts page | Not drawn | — | Not drawn | NOT DESIGNED | Not started · **Close-out (ED-335):** Siri & Shortcuts page still to design |
| Share into Inbox | Drawn: E-R2-17 | Not drawn (Mac ✓d; web uses paste) | Not drawn | APPROVED (R2-17, ED-309) | NV: needs device |
| Menu bar, app menus (Mac) | — | Menu bar with View, Go and Day menus drawn | EM menu bar inset and status item | ADOPTED FROM BOARD; keys OPEN G2-10 | Not started · **Close-out (ED-335):** settled: G2-10 ED-095; Edit and Window R2-30 (ED-333) |
| Keyboard shortcuts | Hardware keyboard not drawn | FA2 key tables | EM keys | OPEN G2-10 | Not started · **Close-out (ED-335):** settled: G2-10 ED-095; R2-10 (ED-288) |
| Deep links `dottoday://` and web URLs | Not drawn (scheme unchanged) | FA2 route table | `/now` (EM) | OPEN G2-11 | Not started · **Close-out (ED-335):** settled: G2-11 ED-097; routes ED-097 |
| PWA install, service worker | — | Not drawn | — | NOT DESIGNED (G4-5) | Not started · **Close-out (ED-335):** settled: G4-5 ED-172; R2-24 (ED-326) |
| Languages en/de/fr/es | No board | No board | No board | NOT DESIGNED: a long-string (de/fr) pass on core frames | Not started · **Close-out (ED-335):** long-string pass R2-24 (ED-326) |
| Feedback, What's new | Not drawn | Settings row list names "Help" | Not drawn | NOT DESIGNED | Not started · **Close-out (ED-335):** R2-24 (ED-326) |

### C.6 Settings inventory (grouped by current section)

| Feature | E home on phones | E home on Mac/web (FA2) | E home in Minimal | Status | Verification |
|---|---|---|---|---|---|
| Header: account row | Avatar opens Settings and account | Settings window | Avatar | OPEN G2-3; NOT DESIGNED | Not started · **Close-out (ED-335):** settled: G2-3 ED-238; waits on CR-160 |
| Layout row | First Settings row (rule) | "Settings, first row" drawn | First Settings row | APPROVED (ED-067); phone row not drawn | Not started |
| Day shape (10 + 1 rows) | Not drawn | Named in the row list | Not drawn | CLOSED: no Day shape page (ED-321); the 10 + 1 rows moved to Wake Up and Wind Down (ED-084, R2-18) and Appearance (ED-161) | Not started |
| Planning (10 rows) | Not drawn | Not drawn | Not drawn | OPEN G2-4; NOT DESIGNED | Not started · **Close-out (ED-335):** settled: G2-4 ED-081, ED-084; still to design (Low-energy row only, R2-22) |
| Learning (4 rows) | Not drawn | Not drawn | Not drawn | OPEN G2-4; NOT DESIGNED | Not started · **Close-out (ED-335):** settled: G2-4 ED-081, ED-084; R2-23, R2-29 |
| Reminders (6 + 2 rows) | Not drawn | Named in the row list | Not drawn | OPEN G2-4; NOT DESIGNED | Not started · **Close-out (ED-335):** settled: G2-4 ED-081, ED-084; R2-20 (ED-317) |
| Look (Theme, Accent, Language) | Not drawn | Not drawn | Not drawn | OPEN G2-4, G4-6; NOT DESIGNED | Not started · **Close-out (ED-335):** settled: G2-4 ED-081, ED-084; G4-6 ED-174 to ED-181; E-Phones-3, R2-11 |
| Data (Sync, Calendars, Export, Trash) | Not drawn | Named in the row list | Settings › Everything else › Data | OPEN G2-4; NOT DESIGNED | Not started · **Close-out (ED-335):** settled: G2-4 ED-081, ED-084; R2-21, R2-30 |
| About (Help, Siri & Shortcuts, Privacy, About, Send feedback) | Not drawn | "Help" named | Not drawn | OPEN G2-4; NOT DESIGNED | Not started · **Close-out (ED-335):** settled: G2-4 ED-081, ED-084; R2-24, R2-29, R2-30; Siri page still to design |
| Minimal Settings (9 rows + Everything else) | Not drawn | — | EPM band; EM finder (partial) | OPEN G2-4; NOT DESIGNED | Not started · **Close-out (ED-335):** settled: G2-4 ED-081, ED-084; E-PhonesMinimal, R2-29 |
| 13 sub-pages, incl. the Wake Up page (~23 rows) | Not drawn | Not drawn | Not drawn | NOT DESIGNED | Not started · **Close-out (ED-335):** most drawn R2-11, R2-20 to R2-24; Planning, Sound, Siri still to design |

### C.7 Duplicates and reach (each entry must survive any merge)

| Feature | E home on phones | E home on Mac/web (FA2) | E home in Minimal | Status | Verification |
|---|---|---|---|---|---|
| Wake Up alarm switch (3 places) | Not drawn | Not drawn | Not drawn | OPEN G2-12; NOT DESIGNED | NV: needs device · **Close-out (ED-335):** settled: G2-12 ED-099; R2-19 (ED-314) |
| Wake Up / Wind Down times (3) | Caps on thread only | Not drawn | Not drawn | OPEN G2-12; NOT DESIGNED | Not started · **Close-out (ED-335):** settled: G2-12 ED-099; E-Phones, R2-11, R2-18 |
| Test alarm card (3 builds) | Not drawn | Not drawn | Not drawn | OPEN G2-12; NOT DESIGNED | Not started · **Close-out (ED-335):** settled: G2-12 ED-099; R2-20 (ED-317) |
| Notification health (3) | Not drawn | Not drawn | Not drawn | NOT DESIGNED | Not started · **Close-out (ED-335):** R2-20 (ED-317) |
| Layout full/minimal (3) | Day menu, Settings row 1 | View menu, Day menu, Settings row 1 | Day ▾, EM View menu | APPROVED (ED-067); onboarding has no layout step (R2-16, ED-305) | Not started |
| Low-energy mode (3) | Day menu | Day menu Layout | Day ▾, EM finder | OPEN G3-10; Settings row and header switch NOT DESIGNED | Not started · **Close-out (ED-335):** settled: G3-10 ED-162; R2-22 (ED-322) |
| Routines (5) | Add, FAB menu, Day menu, empty day | Sidebar, Inbox column, Day menu | Hint, Everything else, EM View | OPEN G2-2, G2-8 | Not started · **Close-out (ED-335):** settled: G2-2 ED-080; G2-8 ED-091; R2-22 (ED-322) |
| Default alerts (2) | Not drawn | Not drawn | Not drawn | NOT DESIGNED | Not started · **Close-out (ED-335):** R2-20 (ED-317) |
| Account / sync (4) | Glass capsule (sync + avatar) | Sidebar foot | Top bar; EM toolbar | OPEN G2-3, G4-7 | Not started · **Close-out (ED-335):** settled: G2-3 ED-238; G4-7 ED-186 to ED-196; waits on CR-160 |
| Feedback / What's new (2 / 2) | Not drawn | Not drawn | Not drawn | NOT DESIGNED | Not started · **Close-out (ED-335):** R2-24 (ED-326) |
| Export (2) | Not drawn | File › Export…, Settings › Data | Everything else, EM finder | OPEN G2-4; screens NOT DESIGNED | Not started · **Close-out (ED-335):** settled: G2-4 ED-081, ED-084; R2-21 (ED-319) |
| Wake Up explainer (2) | Not drawn | Not drawn | Not drawn | NOT DESIGNED | Not started · **Close-out (ED-335):** still to design |
| Wind Down controls (5) | Not drawn | Not drawn | Not drawn | OPEN G2-12; NOT DESIGNED | Not started · **Close-out (ED-335):** settled: G2-12 ED-099; E-Phones, R2-18, R2-20 |
| Day review (3 forms) | Day menu | Day menu, sidebar Review | End-of-day card | OPEN G2-12 | Not started · **Close-out (ED-335):** settled: G2-12 ED-099; R2-14 (ED-297) |
| Month (2, now 3) | Calendar tab, title ▾ sheet, pull-down | Month view | Title ▾ / EM Calendar row | APPROVED (ED-075) | Not started |
| Today header (TodayHeader, SpreadHeader) | Nav-row title (ED-040) | Workspace toolbar | EPM top bar; EM toolbar | APPROVED (ED-040, ED-073) | Not started |
| Capture field (Add sheet, Inbox field) | Add sheet | Capture field in Inbox column | Add sheet; EM Add field | OPEN G2-12 | Not started · **Close-out (ED-335):** settled: G2-12 ED-099 |
| Inbox scheduling (3 sheets) | Not drawn | Drag, `m` to move | Not drawn | OPEN G2-12; phones NOT DESIGNED | Not started · **Close-out (ED-335):** settled: G2-12 ED-099 |
| "After" label clash (two Wake Up settings) | Not drawn | Not drawn | Not drawn | OPEN G3-10 | Not started · **Close-out (ED-335):** settled: G3-10 ED-162 |

---

## D. Gaps

Parity features or accepted decisions with no drawn home. Each names what it needs.

- **Multi-select selection bar and Save as routine.** Only a tip is drawn. Needs a drawing on every platform (R-04, R-05, G4-1). **Round 2 close-out (ED-335):** Closed: R2-6 (ED-279).
- **Reality thread.** Phones have a Day menu entry only. FA2's Day and View menus have no entry, so wide Full loses it. Needs a wide entry and the Reality screen. **Round 2 close-out (ED-335):** Closed: R2-23 (ED-324), Android R2-29 (ED-332).
- **Tasks before Wake Up fold.** No board draws it. Needs a folded and open state. **Round 2 close-out (ED-335):** Still open (no Round 2 board).
- **Undo toast / snackbar.** Conflict Undo drawn and approved (E-G4-7-States C3, C5; ED-194); not built. Other Undo toasts still follow their own decisions. **Round 2 close-out (ED-335):** Closed: R2-7 (ED-281), medium width R2-31 (ED-334).
- **Sync banner, sync sheet and conflict state.** Only the indicator is drawn (R-08, G4-7). **Round 2 close-out (ED-335):** Closed: R2-8 (ED-283).
- **Phone Inbox screen and the one scheduling picker.** Phones have only the tab badge (G2-12). **Round 2 close-out (ED-335):** Closed: R2-13 (ED-295), no free slot R2-28 (ED-331).
- **Focus session screen.** Every board has entries; none draws the session (running, paused, overrun). **Round 2 close-out (ED-335):** Closed: R2-9 (ED-286), Mac and web R2-30 (ED-333); overrun R2-26 (ED-329); paused is not built.
- **Wake Up family.** Alarm ringing, snooze, card, Check and all missions are undrawn on every platform (G4-1). **Round 2 close-out (ED-335):** Closed: R2-19 Option B (ED-314); missions edge states R2-28 (ED-331).
- **Settings tree.** No Settings page is drawn except the wide first row. All nine sections, 13 sub-pages and minimal Settings need drawing (G2-3, G2-4). **Round 2 close-out (ED-335):** Closed except Settings › Planning, Sound and Siri & Shortcuts pages (still open): R2-11, R2-20 to R2-24, R2-29, R2-30.
- **Task editor at full size on phones.** Large detent (iPhone) and full editor (Android) are not drawn (G2-5). **Round 2 close-out (ED-335):** Closed: R2-4 and R2-27 task sheets (ED-274, ED-330).
- **Editor fields colour, icon, pin, travel, energy.** Captions only. **Round 2 close-out (ED-335):** Partly closed: colour and icon R2-15 (ED-299); pin, travel and energy still captions. **2026-11-15:** drawn and approved R2-40 (ED-346).
- **iOS Move picker.** Only the Android dial is drawn (G2-7). **Round 2 close-out (ED-335):** Closed: R2-28 Move to a day (ED-331).
- **Pick today's one thing in Minimal.** Neither EPM's nor EM's "hides, never removes" band lists it. Needs a minimal path and a screen. **Round 2 close-out (ED-335):** Still open (only the Wake Up mission is drawn).
- **Brain dump screen, Routines page, Break it down, Smallest step, Unstick, AI status.** Entries only (G2-8, G2-2). **Round 2 close-out (ED-335):** Closed: R2-22, R2-23, R2-30 (ED-322, ED-324, ED-333); spoken Brain dump still open.
- **Search screen, Past days and year strip, weekly review.** Entries only. **Round 2 close-out (ED-335):** Closed: Search R2-13, R2-28, R2-30; weekly review R2-14, R2-24, R2-28. Past days and the year strip still open.
- **Account, recovery, app lock, export/import, Trash, calendar connect.** Not drawn. Onboarding is now approved as the interactive prototype (R2-16, ED-305). **Round 2 close-out (ED-335):** Closed: R2-21, R2-24, R2-28, R2-29, R2-30. Account waits on CR-160.
- **System surfaces.** Widgets, Live Activity, Controls, Siri page, share extension, PWA install. Not drawn. **Round 2 close-out (ED-335):** Closed: R2-17 (ED-309), Android shortcuts R2-29, web install R2-24. Siri page still open.
- **Notifications.** Task alert, Start nudge, day-start summary, notification health, test alarm. Not drawn. **Round 2 close-out (ED-335):** Closed: R2-20 (ED-317).
- **Duplicate-day target picker and Copy confirmation.** Not drawn. **Round 2 close-out (ED-335):** Closed: R2-22, R2-29, R2-30 (no confirm step, as built).
- **Wide Add popover with live chips.** Not drawn on Mac or web. **Round 2 close-out (ED-335):** Still open.
- **Layouts.** iPad, Android tablet and foldable, mobile web, phone landscape, Mac 960 × 640 window, dark mode (G4-2 to G4-6). **Round 2 close-out (ED-335):** Closed: R2-1, R2-2, R2-31, R2-30; phone landscape still open. **2026-11-15:** phone landscape drawn and approved R2-41 (ED-347).
- **States.** Loading, error, offline, empty past/future day, 200 % text, reduced motion, reduced transparency (G4-7). **Round 2 close-out (ED-335):** Mostly closed: R2-8, R2-26 to R2-28; 200 % on R2-7 only, reduced motion and transparency left to device tests.
- **Register coverage.** "Cancel multi-select and drag on a mode switch" and "a mode switch is not a Back step" have no register ID (ED-072 open items). Each needs one.

## E. Rejected (must not return)

| ID | What | Status |
|---|---|---|
| ED-002 | A-Minimal board (C's Mac/web minimal cut down) as a separate E board | REJECTED |
| ED-003 | A-Wide: Mac/web thread with a three-day spread as E's wide layout | REJECTED |
| ED-010 | Solid chips for ahead tasks; chip icons that drop the outlined state | REJECTED |
| ED-014 | Floating inset sidebar drawn as a rounded card | REJECTED |
| ED-016 | Apricot accent anywhere (tags, Wake Up, Clear your head, focus rings, now caps) | REJECTED |
| ED-018 | Wind Down in C's lavender; Wake Up in apricot; different cap colours per board | REJECTED |
| ED-023 | Halos, glows, glossy gradient dots | REJECTED |
| ED-029 | iOS system colours on swipe actions | REJECTED |
| ED-030 | "done" in iOS blue on the Add keyboard | REJECTED |
| ED-036 | Floating or glass sheets on iPhone (sheets stay solid, edge to edge) | REJECTED |
| ED-037 | Pull-up Inbox tray and grab handle on phones | REJECTED |

Also excluded by later owner answers (not ED "REJECTED", but not to be built):
- A wide Focus presentation (Now + Day + inspector with the full sidebar): ED-065.
- One identical navigation set per mode at every width (register G1-5 option A): ED-068.
- Option B, timeline-led Full Mac/web (`E-FullB`): ED-073.
- E-Workspace's Running Late, Replan button, ⌘M, ⇧⌘G and `/plan/...` where FA2 differs: ED-074.
- Drag-edge resize on the day thread: ADR-0015 (resize is the duration field).


## Updates after the first pass
- **2026-11-14, ED-335 (Round 2 close-out):** the log above had no lines for R2-1 to R2-15 or R2-20 to R2-24. For the record: R2-1 navigation (ED-267), R2-2 Workspace (ED-269), R2-3 Add (ED-271), R2-4 Edit (ED-274), R2-5 complete and Day menu (ED-276), R2-6 multi-select (ED-279), R2-7 Undo (ED-281), R2-8 sync (ED-283), R2-9 Focus (ED-286), R2-10 keyboard overlays (ED-288), R2-11 Settings on tablets (ED-291), R2-12 Calendar (ED-293), R2-13 Inbox and Search (ED-295), R2-14 reviews (ED-297), R2-15 colour picker (ED-299), R2-20 notifications (ED-317), R2-21 data safety (ED-319), R2-22 planning helpers (ED-322), R2-23 proposals and learning (ED-324), R2-24 the rest of the app (ED-326). Section D now says which gaps each board closed. Nothing built.
- **2026-11-15, ED-336:** owner answers to the close-out list recorded. Nothing built.
- **2026-11-15, ED-337:** R2-32 approved with its new copy. Nothing built.
- **2026-11-15, ED-338:** R2-33 approved; Settings page title icons on every platform; Android mirrors iPhone. Nothing built.
- **2026-11-15, ED-339:** R2-34 approved (Past days, the year strip, Pick today's one thing). Nothing built.
- **2026-11-15, ED-340:** Android pull-ups are M3 modal bottom sheets, matching iPhone. Nothing built.
- **2026-11-15, ED-341:** R2-35 approved (Rebalance); Android Appearance cards and icon. Nothing built.
- **2026-11-15, ED-342:** R2-36 approved (Add popover, Go to date); Year strip option B proposed. Nothing built.
- **2026-11-15, ED-343:** R2-37 approved (spoken Brain dump, CR-083). Nothing built.
- **2026-11-15, ED-344:** R2-38 approved (the Wake Up explainer); `wakeUpExplainOff` new copy approved for the copy PR. Nothing built.
- **2026-11-15, ED-345:** R2-39 approved (the ED-246 fold on every platform, Minimal and the Mac and web Day column; CR-021 fully drawn). Nothing built.
- **2026-11-15, ED-346:** R2-40 approved (pin, travel time and energy in the editor on every platform; the last editor captions closed). Nothing built.
- **2026-11-15, ED-347:** R2-41 approved (phone landscape under H1); the last undrawn layout. Nothing built; H1 device checks pending.
- **2026-11-15, ED-348:** Year strip option B approved (R2-34); "Running late" kept as built (no-shame exception). Nothing built.
- **2026-11-15, ED-349:** R2-42 approved (Year strip option B on Mac and web). Nothing built.
- **2026-11-15, ED-350:** confirmed: the approved onboarding (ED-305) has no Layout step. No board changed.
- **2026-11-15, ED-351:** age note on Hello, "Dottoday is for people aged 13+." (new copy). Prototype updated. Nothing built.
- **2026-11-15, ED-352:** Q9 test stack approved (P1 to P4). Nothing created yet.

> **Tablets (owner sequencing, 2026-11-04).** Phone and Mac boards do not count as tablet designs. Tablet gaps listed here stay open until Prompt D Round 2. The comprehensive tablet coverage checklist is a mandatory step before Round 2 begins (`STATUS.md` Open items); until then each Group 2 decision only records its iPad and Android tablet/foldable implications.

- **2026-11-13, ED-304 to ED-314 (Round 2 stage 3 close and R2-19):** R2-16 onboarding APPROVED as the interactive “Dottoday Onboarding Prototype” (ED-305); R2-17 system surfaces APPROVED (ED-309; the interactive version ED-307 withdrawn, options ED-308); R2-18 Wake Up and Wind Down tablet re-check APPROVED (ED-311); R2-19 the Wake Up alarm APPROVED as Option B, “The thread wakes up” (ED-314), with tablet ringing, snooze and mission screens added after approval. Rows C.3 and C.5 above updated. Other Round 2 approvals (R2-1 to R2-15) are recorded in E_DESIGN_DECISIONS and the register; their C rows here are not yet refreshed. Nothing built or committed.
- **2026-11-14, ED-321 (Day shape):** the owner chose A. Settings › Your day has no Day shape row, and the two Day shape rows above are updated. Nothing built or committed.
- **2026-11-14, ED-328 and ED-329 (gap pass):** R2-25 moving tasks and R2-26 time states approved; the Drag to move row is updated. Nothing built or committed.
- **2026-11-14, ED-330 (gap pass):** R2-27 day states and task sheets approved. Nothing built or committed.
- **2026-11-14, ED-331 (gap pass):** R2-28 small states approved (move to a day, no slot, quiet week, no results, calendars, missions). Nothing built or committed.
- **2026-11-14, ED-332 (gap pass):** R2-29 Android parity approved, with the Settings icon pass across 11 boards (R-13). Nothing built or committed.
- **2026-11-14, ED-333 (gap pass):** R2-30 Mac and web parity approved (R-13); Search or run not built, minimal Inbox at wide widths a code gap. Nothing built or committed.
- **2026-11-14, ED-334 (gap pass):** R2-31 tablets approved (R-13); hinge awareness a code gap. Gap pass complete. Nothing built or committed.
- **2026-11-14, ED-335:** Round 2 close-out audit recorded; section D marked; the R2-19-B split recorded. Nothing built.

- **2026-11-04, ED-080:** G2-2 approved. The Lists sketch is removed from E-FullA-v2; read any Lists row above as REJECTED. The Routines page is APPROVED but NOT DESIGNED (to draw; route in G2-11).
- **2026-11-04, ED-079:** Calendar screens approved and drawn on E-Phones.
- **2026-11-04, ED-081 to ED-084:** these are now APPROVED and drawn:
  - Settings root and minimal Settings;
  - Mac and web Settings;
  - "Search or run" naming;
  - Wake Up and Wind Down: schedules over the built "Different days", the night dial with its layout rule, sleep target, the Wake Up alarm with every built option, reminders;
  - one alarm device ("Alarm sounds on").

  Parity rows for Wake Up, Wake Up alarm, Wake Up options, Wind Down, Different days, Sleep target and Show night now have one home: Settings › Your day › Wake Up and Wind Down (EP Wake Up rows, FA2 Mac panel).

  **New implementation requirements:**
  - a synced device list and an account alarm-device setting (Supabase migration with RLS; must ask before push);
  - an arming rule: only the alarm device arms; others disarm on sync.

  **Verification needed:**
  - AlarmKit on iPadOS 26;
  - Play full-screen-intent policy for tablets;
  - device naming (iOS entitlement).

  **Fixes today's double ring:** iPad and Android tablets count as phones in `health_providers.dart`.

  **Still NOT DESIGNED:** five group pages, the Routines page, tablet shells.
- **2026-11-04, ED-086:** G2-5 is option D. The task surface (medium detent → full editor; Android full screen; iPad beside the day; Mac/web inspector), the colour and icon picker (compact → full with sticky glass palette), in-place steps and notes, the repeat scope chooser and Create task are APPROVED and drawn on `E-G2-5-OptionD-RefinedEditor`. They are not yet merged into E-Phones and E-FullA-v2.
  - **New requirement:** Recently used icons.
  - **To verify:** scope-before-write with autosave; glass palette feasibility and contrast.
- **2026-11-04, ED-087:** option D is merged. The task editor rows are now drawn on E-Phones (F3, F6, Task editor section) and E-FullA-v2 (popover). Parity rows for task detail, editing, subtasks, notes, colour and icon, repeat scopes and delete point there. Status: APPROVED.
- **2026-11-04, ED-088 and ED-089:** G2-6 is RESOLVED. The minimal task screen is APPROVED and DRAWN on `E-PhonesMinimal` (iPhone and Android) and `E-Minimal` (Mac inset and web column): Done, Tomorrow, Later, Delete (Trash and Undo), Need more time? while running, More options → option D editor. Read the "Task screen opens in the Day column" and "Task sheet, `/task/:id`" rows above as DRAWN for minimal; Move stays OPEN under G2-7, routes under G2-11. Tablets are NOT DRAWN.
- **2026-11-04, ED-091:** G2-8 is RESOLVED. Brain dump and Routine as modes of Add are APPROVED and DRAWN on `E-Phones` (iPhone segmented control, Brain dump mode, Routine mode, the proposal, Android FAB menu and Brain dump sheet) and `E-FullA-v2` (Mac File menu, web Add ▾). Read the Brain dump and Routines rows above as DRAWN for Full phones, Mac and web; minimal stays as drawn. Built features kept: Earlier dumps, Use again, mic, routine editing (Routines page), routine preview, ProposalSheet before saving, Day menu entries. Keys: OPEN (G2-10). Tablets: NOT DRAWN (implications in the register, Round 2).
- **2026-11-05, ED-093:** G2-9 is RESOLVED (option B). The Day menu is APPROVED and DRAWN: Full Time · Plan · Day · Layout on `E-Phones` (iOS, M3) and `E-FullA-v2` (Mac menu bar, web Day ▾); minimal phones Show everything · Low-energy mode · Settings on `E-PhonesMinimal`; minimal Mac and web keep E-Minimal's richer menu, now drawn on `E-Minimal`. Parity rows for the Day menu, Need more time (+5 / +15 / +30), Low-energy mode (one name), Show less / Show everything and Plan / Reality (entry) point there. Every Day menu command was checked before and after the merge; none was lost. Keys: OPEN (G2-10). Routes: OPEN (G2-11). Tablets: NOT DRAWN (implications in the register, Round 2).
- **2026-11-05, ED-095:** G2-10 is RESOLVED (option B). The keyboard scheme is APPROVED and its labels are DRAWN on `E-FullA-v2` and `E-Minimal`. Built keys kept: ⌘1–4 in Full, ⌘D Done, ⌘↩ Inbox placement, ⇧⌘P, ⌘S, nudge. User-facing changes for implementation (minimal ⌘1/⌘3/⌘4; the web's modifier-free keys; the single-key setting) are listed in ED-095. Keyboard parity rows point there. The ⌘/ sheet and web ? overlay: NOT DRAWN. Tablets: NOT DRAWN (Round 2).
- **2026-11-05, ED-097:** G2-11 is RESOLVED (option A′). Routes are APPROVED; labels DRAWN on `E-FullA-v2`, `E-Minimal`, `E-Map`; the per-layout table is on `E-G2-11`. Implementation requirements (later, not now): the D2 guard change, new dated routes and `/now`, rule D and rule T redirects, `/task/:id` as the task over its date, history replace rules, refresh restore. Verification: routing tests per layout column, guard tests (one key, UUID v7, ownership), existing `dottoday://` / notification / sign-in link tests kept green. Tablets: NOT DRAWN (Round 2).
- **2026-11-05, ED-100 to ED-102:** the Full ↔ Minimal mid-action rule is RESOLVED (behaviour, NOT DRAWN): cancel an unfinished drag or selection, keep date, open task, saved edits and Undo, never drop unsaved text without asking. Implementation (later): drag and selection controllers cancel on the `LayoutPolicy` change; drafts live in editor state. Verification: switch during drag, during selection, with an open task, with an unsaved title, and Undo after the switch. Group 3 opened; G3-1 (scale) PRESENTED on `E-G3-1`, not approved. Two merged drawings flagged as awaiting the owner's visual review: `E-Minimal` Day review column (ED-099) and minimal web Day menu (ED-093); until reviewed they count as DRAWN, NOT VISUALLY REVIEWED.
- **2026-11-05, ED-103:** G3-1 option C revised to the owner's sizes on `E-G3-1` (45 ring, 19/700 title, 32 px gaps; six rows fit as in A); PROPOSED, not approved. Verification on the board: 13 phone frames measured for row overlap, clipped text, ring-to-thread offset (0) and target size (44 pt / 48 dp). If approved: golden for Today at 390 and 360 wide, at 1x and 200 % text, plus a widget test that the now card grows with its title. ED-100 clarifications APPROVED (proposals never accepted by a switch; resize transitions change nothing). Open item: Today opens scrolled to now (behaviour, not drawn).
- **2026-11-05, ED-104:** G3-1 RESOLVED as option C · Both, revised; merged into E-Phones Frames 1 and 5 only (DRAWN, APPROVED). Implementation (later, not now): the now card on Full phone Today uses min-height 80 / 82, ring 45, title 19/700; Minimal's Today tab unchanged. Verification: goldens for Full Today at 390 and 360 wide, 1x and 200 % text; widget test that the now card grows with a long title and the ring stays on the thread's x; semantics unchanged.
- **2026-11-05, ED-105:** G3-2 (one orb drawing) PRESENTED on `E-G3-2`, not approved. No board changed.
- **2026-11-05, ED-106:** G3-2 RESOLVED as option A; merged into E-Minimal (Mac and web orb centres). Implementation (later): one orb widget with the centre type as a proportion of its size (numeral 0.36, 800); golden at 236, 228, 280 and 240; "min left" at 200 % stays inside the inner disc. Owner's visual check of the merged orbs: "Looks right" (DRAWN, APPROVED, VISUALLY REVIEWED).
- **2026-11-05, ED-107:** visual review PRESENTED on `E-V1`: two flagged drawings (each with one proposed correction) and the G3-1 correction for six dimmed Todays. Nothing approved or merged yet.
- **2026-11-05, ED-108:** the three visual-review corrections APPROVED and MERGED (E-Minimal Day review column and minimal Day menus; E-Phones six dimmed Todays). The two ED-102 drawings are now DRAWN, APPROVED, VISUALLY REVIEWED.
- **2026-11-05, ED-109:** G3-3 (content typeface) PRESENTED on `E-G3-3`, not approved. No board changed.
- **2026-11-05, ED-110:** G3-3 RESOLVED as A · Manrope; no board changed. Rules §3.4–3.6 added (text size, implementation checks, tablets). Correction for task text in system font inside phone sheets PROPOSED (rules §3.7), not merged.
- **2026-11-05, ED-111:** G3-4 (iOS switch colour when on) PRESENTED on `E-G3-4`, not approved. No board changed.
- **2026-11-05, ED-112:** G3-4 RESOLVED as A · teal; no board changed. G3-C1 (task text in system font in phone sheets) TRACKED, direction agreed, comparison pending. A11Y-V1 / A11Y-V2 PROPOSED for accessibility verification.
- **2026-11-05, ED-113:** G3-5 (hover lift on a web block) PRESENTED on `E-G3-5`, not approved. No board changed.
- **2026-11-05, ED-114:** canvas edits saved from the page observed (E-G3-2-Size removed; E-Phones frame 8000; long titles cut); kept, awaiting owner confirmation.
- **2026-11-05, ED-115:** G3-5 REVISED with hybrid option C (A, B, C compared, drag over the overlap); recommendation C; not approved. E-Phones canvas frame height restored to 10520; board file unchanged.
- **2026-11-06, ED-121:** spike run on the owner's iPhone (separate dev.spike app ID); automated device checks PASS; hands-on checks stopped by the owner; board updated. G3-6 OPEN.
- **2026-11-09, ED-204:** cleanup 7a/7b applied (Android task text in Manrope; 14 fields, light and dark); G3-C1 closed. Snapshot v1.70.
- **2026-11-09, ED-203:** G3-C1 comparison board for cleanup 7a/7b (review only); 7a evidence corrected. Snapshot v1.69.
- **2026-11-09, ED-202:** cleanup item 6c applied (Now card radius 24 on both phones; 12 Android cards). Snapshot v1.68.
- **2026-11-09, ED-201:** cleanup item 5 applied (thread caps 34 px, icon 19; 82 caps on 16 boards, light and dark); CR-018 resolved. Snapshot v1.67.
- **2026-11-09, ED-200:** cleanup item 4 applied (calendar-event dot centre = surface, ring 2.5 / 2 px; 61 values on 8 boards, light and dark); CR-009 resolved. Snapshot v1.66.
- **2026-11-08, ED-199:** cleanup item 3 applied (ahead-ring widths by context, 82 values on 9 boards, light and dark); CR-017 resolved. Snapshot v1.65.
- **2026-11-08, ED-198:** cleanup item 2 applied (one light now-ring recipe, 105 values on 8 boards); CR-016 resolved; CR-166 (dark tracks vs ED-174) logged. Snapshot v1.64.
- **2026-11-08, ED-197:** cleanup batch reconciled read-only (A 0 · B 1 · C 13 · D 1); CR-164 and CR-165 clarified; no board changed.
- **2026-11-08, ED-196:** CR-162 (90 dark amber glyphs to ink), Q4-L1 (Keep both unavailable over 10,000, Copy on each version) and Q5 (#6A6473) applied; G4-7 closed at design level; CR-164 and CR-165 logged; E-Map updated. Snapshot v1.62.
- **2026-11-08, ED-195:** G4-7 Q4 option B approved (Keep both, notes only); linked board E-G4-7-Q4-KeepBoth; Q4-L1 limit raised; CR-162 (dark amber glyph 1.95:1) and CR-163 opened; E-Map updated. Snapshot v1.61.
- **2026-11-08, ED-194:** G4-7 Q3 option A approved as design (conflict Undo; C3 updated, C5 added); E-Map G4-7 lines updated; CR-161 opened for implementation. Snapshot v1.60.
- **2026-11-08, ED-193:** Q2 closure accepted; CR-160 escalated to CRITICAL privacy/security release blocker with 12 acceptance criteria; 06-security §9 item added; board annotations mark the storage request as not built. Snapshot v1.59.
- **2026-11-08, ED-192:** Q2-W1 option A approved; guest frames Q2e and Q2f drawn; G4-7 Q2 CLOSED at design level; CR-160 opened (guest-to-account safety). Snapshot v1.58.
- **2026-11-08, ED-191:** Q2 resolved at design level (warning frames final-approved); Q2-W1 open; CR-159 implementation open. Snapshot v1.57.
- **2026-11-08, ED-190:** Q2 frames approved with the owner's caution wording; final approval pending. Snapshot v1.56.
- **2026-11-08, ED-189:** Q2 browser-storage warning drawn in web Sync details (Q2a–Q2d, light and dark) on E-G4-7-States, now 8000 tall; awaiting approval; Q2-W1 raised. Snapshot v1.55.
- **2026-11-08, ED-188:** G4-7 Q2 option A approved as a web-only requirement (ask the browser to keep storage; "Saved in this browser" kept); CR-159 design resolved, implementation open; no board changed. Snapshot v1.54.
- **2026-11-08, ED-187:** G4-7 Q1 approved as direction (kit look, one state system, native variations); Q2–Q5 open; Undo labelled as unbuilt and unapproved on E-G4-7-States; not merged. Snapshot v1.53.
- **2026-11-08, ED-185 / ED-186:** CR-153 to CR-156 applied (light + dark); G4-7 option A approved, kit on E-G4-7-States (not merged); CR-158, CR-159 opened; E-Map 5960, E-Responsive y 18520. Snapshot v1.52.
- **2026-11-08, ED-184:** Plan panel A + B approved and merged into E-FullA-v2 (+ new row, 7400), E-G4-3-Narrow (840 auto-hidden) and their dark copies; rules §9.16; E-MobileWeb moved. Snapshot v1.50; E-Map synced after ED-184 and the five-part status added (v1.51).
- **2026-11-08, ED-183:** rule §12.3 "text always fits"; fit check on every active board; E-FullA-v2, E-G4-3-Narrow (CR-153, CR-157 resolved), their dark copies and E-PlanPanel-Options corrected. Snapshot v1.49.
- **2026-11-08, ED-182:** Plan panel options board `E-PlanPanel-Options` (A, B, C, D, A + B) from owner comments; nothing changed. Snapshot v1.48.
- **2026-11-08, ED-180 / ED-181:** Stage 2 approved; dark companions for the 10 active boards (row "E · Dark mode"); 36 thread segments on lighter surfaces at #7B7279; conversion corrections (shadows, scrims, menus, system chrome, swipe grey, custom App colour); CR-153 to CR-156 opened. E-Map 5440, E-Responsive y 17980. Snapshot v1.47.
- **2026-11-08, ED-179:** Q1-B contextual thread; placeholder and hex-prefix text fixes in light (E-Phones, E-Phones-3, E-PhonesMinimal) and dark; Stage 2 review re-exported; CR-151/152 resolved. Snapshot v1.46.
- **2026-11-07, ED-178:** I1, T1, T2-B approved; Stage 1 tokens final; Stage 2 visual review rebuilt with 19 pairs, 2× PNG and PDF exports; CR-149/150 resolved, CR-151/152 opened. Snapshot v1.45.
- **2026-11-07, ED-175 to ED-177:** dark task colours frozen; Mac D1 label approved (second native run); detail tokens derived; Stage 2 key frames presented; CR-147/148 resolved, CR-149/150 opened. Snapshot v1.44.
- **2026-11-07, ED-174:** P1 approved; switch tint and focus gap approved; ring revisions and Mac label correction presented; Mac D1 verified natively; CR-146 to CR-148. Snapshot v1.43.
- **2026-11-07, ED-173:** G4-6 option A (process) approved; Stage 1 dark tokens presented on E-G4-6-Dark-Tokens. Snapshot v1.42.
- **2026-11-07, ED-172:** G4-5 resolved A (compact mobile web, own bottom bar, routes unchanged); board E-MobileWeb; CR-145. Snapshot v1.41.
- **2026-11-07, ED-170 / ED-171:** narrow Mac refinements approved ("Day" button, no ⌘2), C1 (a); G4-4 tablet strategy approved; CR-141 and CR-144 resolved, CR-143 opened. Snapshot v1.40.
- **2026-11-07, ED-169:** G4-3 B approved (840 × 640, design only); E-G4-3-Narrow added (fold and C1 proposals); CR-141, CR-142. Snapshot v1.39.
- **2026-11-07, ED-168:** H1 and M approved (CR-139, CR-140 resolved); E-Responsive updated; E-G4-3 decision board added. Snapshot v1.38.
- **2026-11-07, ED-167:** G4-2 resolved C (600 / 840 kept; editor docks from 1160); new board E-Responsive; H and M open (CR-139, CR-140). Snapshot v1.37.
- **2026-11-07, ED-165 / ED-166:** CR-138 applied, CR-134 resolved, CR-133 verified, colour data review, cleanup batch (6 applied, 13 for the owner); G4-1 resolved A (Round 2 order). Snapshot v1.36.
- **2026-11-07, ED-164:** G3-12 resolved A: Earlier fold with no count; new board E-Earlier; E-PhonesMinimal, E-Minimal, E-FullA-v2, E-Map; doc 14 §4 amended; snapshot v1.35. Group 3 complete.
- **2026-11-07, ED-163:** G3-11 resolved A: +5 / +15 / +30 on E-Phones, E-PhonesMinimal, E-Minimal, E-Workspace, E-FullA-v2, E-Map; snapshot v1.34.
- **2026-11-07, ED-162:** G3-10 resolved A: one vocabulary on E-Phones, E-PhonesMinimal, E-FullA-v2, E-Minimal, E-Workspace, E-Map; snapshot v1.33.
- **2026-11-07, ED-161:** G3-9b approved; merged into E-Phones-3 (new), E-Phones, E-PhonesMinimal, E-FullA-v2, ring tokens and arcs on six boards, E-Map; snapshot v1.32.
- **2026-11-07, ED-160:** Android toolbar selected item covers icon and label (E-Phones, E-Phones-2, E-PhonesMinimal, G3-9b screens, E-Map); snapshot v1.31.
- **2026-11-07, ED-159:** Layout into Appearance, pinned preview with Everything/Less motion, tab bar on Settings except under sheets, Suggested removed (proposal); board 6880 px.
- **2026-11-07, ED-158 follow-up:** warm App colour suggestions (8) with the current colour always first, on all platforms.
- **2026-11-07, ED-157 / ED-158:** in-progress arc uses the ring for colours under 3:1 (approved); Appearance with theme thumbnails, App colour Edit palette half sheet and live preview on all platforms (proposed); board 6900 px.
- **2026-11-07, ED-156 follow-up 2:** in-progress dot added to every colour preview (phones, Mac, web); Q-G3-9b-1 raised; board 6560 px.
- **2026-11-07, ED-156 follow-up:** ahead/done preview dots restored in the phone half sheets (owner request); snapshot g3-9b refreshed.
- **2026-11-07, ED-156:** Mac/web custom colour picker approved; phone All colours half sheet (iPhone, Android same layout); snapshot g3-9b refreshed.
- **2026-11-07, G3-9b custom colours:** E-G3-9b-Screens updated per the owner's direction: ⋯ › All colours (iPhone, Android), Custom colour… panel (Mac, web), derived ring preview, data needs noted (still proposals).
- **2026-11-07, G3-9b screens:** board E-G3-9b-Screens published (selection flows on iPhone, Android, Mac, web for task colour and App colour; proposals only).
- **2026-11-07, G3-9b:** full palette review board E-G3-9b-Palette published (audit of the original app's 9 keys and 4 accents; proposals only); register and STATUS show IN PROGRESS.
- **2026-11-07, ED-155:** G3-9 resolved A: ring tokens on six active boards and E-Map; amber glyphs ink; CR-013 resolved; CR-133 flagged; snapshot v1.30.
- **2026-11-07, ED-154 (owner's confirming brief):** icon audit, native-styling and PENDING checks for iOS 18/26 recorded; CR-132 Mac/web secondary text measured (passes); iPad note.
- **2026-11-07, ED-154:** G3-8 resolved A: inactive iPhone tab labels #6E6E73 on E-Phones and E-Phones-2; E-Map note; CR-132; snapshot v1.29.
- **2026-11-07, ED-153:** CR-130 text fixes (E-Phones-2, E-PhonesMinimal, E-Map) and Q-A2a A (no iPhone header title on Brain dump / Routine); Q-A2 closed; snapshot v1.28.
- **2026-11-07, ED-152:** Q-A1 resolved as A (no "Add another"); owner's tab-action rules recorded; boards audited (already compliant apart from CR-130 text and Q-A2a).
- **2026-11-07, sync v1.27:** E-Map rows for full-screen Add modes (ED-147 to ED-150); rules §8.4 Surface row (iPhone and Android); CR-128, CR-129; register Q-A1 added, Q-A2 resolved.
- **2026-11-07, ED-151:** E-G3-7 Full B, C and A frames show Create task, each with its own keyboard (history board; G3-7 stays C); board 5120 px.
- **2026-11-07, ED-150:** proposal full screen on iPhone (E-G2-8 A4, E-Phones-2); new Android proposal frame; E-Phones-2 4200 px.
- **2026-11-07, ED-149:** Routine full screen on iPhone (E-G2-8 A3, E-Phones-2); new Android Routine frame on E-Phones-2. Q-A2 closed.
- **2026-11-07, ED-148:** Android Brain dump full screen (E-G2-8 A6, E-Phones-2); E-G2-8 A5 shows Android Create task.
- **2026-11-07, ED-147:** iPhone Brain dump opens full screen like Create task (E-G2-8 A2 and E-Phones-2; comment 7ac666d2).
- **2026-11-07, ED-146:** E-G2-8 A1 redrawn as the current Create task Add screen with the keyboard up (comment 0c051052).
- **2026-11-06, ED-145:** Minimal option D editor shows steps and notes; scrolled and typing-a-note frames added on E-PhonesMinimal (comment bbdf5e2f).
- **2026-11-06, ED-144:** E-Phones split into E-Phones and E-Phones-2 (canvas 8000 px cap); E-Map rows for ED-137–142; rules §8.4 and handoff updated; CR-124 to CR-127; snapshot v1.19-working.
- **2026-11-06, ED-143:** made and withdrawn at the owner's request; boards restored.
- **2026-11-06, ED-142:** Android Create task gets Task · Brain dump · Routine M3 segmented buttons.
- **2026-11-06, ED-141:** Android parity: editor shows steps and notes; Android Add = full-screen Create task with Gboard.
- **2026-11-06, ED-140:** iPhone Add screen replaced by Create task (detailed), title focused; keyboard pair updated; "Add another" open.
- **2026-11-06, ED-139:** "Create task (detailed)" gets the Task · Brain dump · Routine tabs.
- **2026-11-06, ED-138:** "Back in the editor" gets Repeat, Energy, steps and notes.
- **2026-11-06, ED-137:** full editor shows existing steps and notes; scrolled and typing-a-note frames added; auto-scroll rule recorded; E-Phones 8000 px canvas cap flagged.
- **2026-11-06, ED-136:** G3-7 follow-up: iOS 26 keyboard drawing on the three iPhone keyboard frames, step keyboard completed, keyboard-dismissal rule, open/dismissed states with the same draft, Android Gboard note; device checks PENDING.
- **2026-11-06, ED-135:** G3-7 RESOLVED as C (stock keyboard, neutral return adds) and MERGED into the two iPhone Add frames; E-Map note updated.
- **2026-11-06, ED-134:** G3-7 (iPhone keyboard and teal Add key) PRESENTED on `E-G3-7`; recommendation A; nothing merged.
- **2026-11-06, ED-133:** G3-6 RESOLVED as a design and selected architecture direction; untested behaviour PENDING; production implementation not authorised; G3-7 not started.
- **2026-11-06, ED-132:** F1 option (a) APPROVED and MERGED: iOS 26+ Minimal keeps the 6 pt gap with the native capsule width (EPM five frames).
- **2026-11-06, ED-131:** compatibility run on throwaway iOS 18.6 (F2) and 26.5 (N3) simulators: functional and accessibility-setting checks PASS on both (Simulator), two test-app defects fixed, architecture limit F1 (N3 Minimal capsule) awaiting decision; iOS 16/17, devices, VoiceOver PENDING. Board `E-G3-6-Compat`.
- **2026-11-06, ED-130:** D6 visual direction APPROVED: native NSVisualEffectView sidebar + `#EFE7DB` at 35 % (light). Reduce Transparency fallback, Increase Contrast, VoiceOver, keyboard, dark mode PENDING. D2 still NOT VERIFIED.
- **2026-11-06, ED-129:** D6 warm-tint captures (neutral, 35 %, 55 %, approximation) and D2 F2 compatibility findings PRESENTED on `E-G3-6-Remaining`. F2 not verified on iOS 16–25; D6 awaiting visual approval.
- **2026-11-06, ED-128:** G3-6 directions SELECTED: D1 N3, D3 native Day UIMenu, D4 Flutter chrome, D5 Android C in Flutter; D2 F2 and D6 warm-tinted vibrancy CONDITIONAL. Production implementation not authorised. Handoff checklist `E_IMPLEMENTATION_HANDOFF.md` created.
- **2026-11-06, ED-127:** G3-6 reopened against the approved rows on `E-G3-6-Decision`: verified vs unverified, fallbacks, choices D1–D6 PRESENTED. G3-6 OPEN.
- **2026-11-06, ED-126:** approved bottom rows MERGED into E-Phones (7 iPhone, 5 Android frames) and E-PhonesMinimal (5 + 2); Day pull-down re-anchored to the moved Day ▾ (3 EPM frames); captions and E-Map updated; coverage matrix in the inventory §4; snapshot `v1.14-working`.
- **2026-11-06, ED-125:** Android bottom row revised option C APPROVED (not A or B). Custom Material-inspired arrangement; frosted, not glass.
- **2026-11-06, ED-124:** iPhone bottom row (+ in the tab bar's line, Day ▾ right) APPROVED for Full and Minimal. N3 hands-on and accessibility checks not approved; G3-6 architecture OPEN.
- **2026-11-06, ED-123 (C revised):** Android floating-toolbar option revised: Day left, Android-native frosted blur on toolbar, + and Day. Awaiting approval.
- **2026-11-06, ED-123:** Android bottom row drawn in three arrangements with the + only (`E-G3-6-Android`); recommendation A. Not merged.
- **2026-11-06, ED-122 (position):** bottom row moved to the owner's reference position (63 pt, 21 pt from bottom and sides, 6 pt gap; Day ▾ aligned to the + and 16 pt above) in the drawing and on the owner's iPhone. Still awaiting approval.
- **2026-11-06, ED-122 (correction):** native + realigned to the iOS glass capsule on the owner's iPhone (offsets 0.00 pt in three runs); board updated. Still awaiting approval.
- **2026-11-06, ED-122:** iPhone bottom-row proposal (+ in the tab bar's line as teal glass, Day ▾ moved right) PRESENTED on `E-G3-6-BottomRow`, drawn and built natively on the owner's iPhone. Not merged.
- **2026-11-06, ED-120:** G3-6 native feasibility spikes RUN in throwaway apps (sources outside the repo); results PRESENTED on `E-G3-6-Spikes`. Nothing adopted; G3-6 OPEN.
- **2026-11-06, ED-119:** G3-6 native-first exploration on `E-G3-6-Native` (genuine iOS captures; feasibility plan not run). G3-6 still OPEN; A not approved.
- **2026-11-06, ED-118:** G3-6 (glass and vibrancy) PRESENTED on `E-G3-6`, not approved. No board changed.
- **2026-11-06, ED-117:** G3-4 verification audit: designs PASS; stale traceability rows for G3-3, G3-4 (two rows, incl. ED-028) and G3-5 corrected; ED-041 cross-referenced to ED-112; switch implementation checks and three Flutter gaps recorded (future tasks only).
- **2026-11-06, ED-116:** G3-5 RESOLVED as C · Hybrid and MERGED into E-FullA-v2 (Lunch hover). Shared hover/drag rule recorded (rules §7.4). Motion details OPEN.
- **2026-11-05, ED-099:** G2-12 is RESOLVED (option A) and **Group 2 is complete**. One Day review (phone sheet; Full Mac/web Review place with Week in Review beside it; minimal Mac/web Day column), one When picker (Inbox Schedule, Move, Move To…; sheet on phones, popover on Mac/web) and the name Week in review are APPROVED and DRAWN on `E-Phones`, `E-FullA-v2`, `E-Minimal`; captions on `E-PhonesMinimal`; rows on `E-Map`. This supersedes the OPEN G2-12 / G2-7 status in the rows "Move opens a day + time picker", "Wind Down review `/review`", "Weekly review + share", "Day review (3 forms)", "Inbox scheduling (3 sheets)" and the gap "iOS Move picker" (the table keeps its earlier wording). Every entry kept (Day menu, Wind Down prompt and notification, sidebar Review, View › Reviews, finder, ⌘K; Schedule, Move tile, swipe Move, ⇧⌘M, `m`); `/review` unchanged. Implementation requirements (later, not now): one review presenter by layout; Schedule and Move share the picker; the Move tile's month becomes Date…; `weekReviewTitle` renamed in four languages. Verification: entry-to-screen tests per layout, Undo after each placement, semantics on suggestions and the thread slider, keyboard-only on Mac and web. Still NOT DESIGNED: Week in review states (first week, no data), share image, learning reveal (G4); the picker's no-free-time state. Tablets: NOT DRAWN (Round 2).
