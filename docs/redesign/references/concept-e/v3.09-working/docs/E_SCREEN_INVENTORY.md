# Concept E — Refined Focus: screen inventory

**Status: LEADING CANDIDATE — NOT APPROVED FOR PRODUCTION IMPLEMENTATION.** Every structural change listed here is a hypothesis until the owner approves it.

> **Change note — v1.1, 2026-11-04 (live canvas `1793767935-3ecd`).**
> - The owner removed `E-Focus` from the canvas (ED-062) and stated: "I have completed the redesign and replacement of Concept E's Mac and Web Minimal Layout." `E-Minimal` (new) is therefore E's Mac/web minimal layout (ED-063, ED-064).
> - `E-Focus` rows below now read **"v1.0 archive only (removed from canvas)"**; its copy is `references/concept-e/v1.0/E-Focus.dc.html`.
> - The wide **Focus presentation** (C's Now + Day + inspector with the full sidebar) has no v1.1 board: **"Not designed in v1.1 (owner decision)"**. **Focus the feature** (task Focus action, focus session, ⌘F, big-dot click, Now mini window) is not removed.
> - `E-Phones`, `E-PhonesMinimal`, `E-Workspace` are byte-identical to v1.0. Rows that cite them are unchanged except where E-Minimal adds coverage.
> - Rules and tokens: `E_DESIGN_RULES.md` §0 and §9.

- **Concept E v1.0, 2026-11-04.** E is an exact copy of the owner's latest modified Concept A boards (byte-identical to `A-Phones`, `A-PhonesMinimal`, `A-Workspace`, `A-Focus`). `A-Wide` (Mac/web thread with three-day spread) and `A-Minimal` (Mac/web minimal) were deleted from the canvas by the owner, so they are not part of E.
- **Concept E v1.1, 2026-11-04.** v1.0 minus `E-Focus`, plus `E-Minimal`.
- **E boards (design-r1 canvas, v1.1):** `E-Phones` (6 frames + 6 insets), `E-PhonesMinimal` (6 frames + end-of-day inset + "Minimal hides, never removes" table), `E-Workspace` (Mac Week + web Day at 1280 × 800, menu bar and ⌘K insets), **`E-Minimal`** (Mac + web minimal at 1280 × 800; insets: menu bar with View menu + status item, task screen in the right column, Now mini window, Everything else finder; "Minimal hides, never removes" band; board title "minimal look, Mac and web (C's layout, E's look)"). `E-Map` is the working map; `E-Map-v1.0` is A's original map, kept as history.
- **Removed from the canvas (v1.0 archive only):** `E-Focus` (Mac + web Now + Day + inspector at 1280 × 800, menu bar + status item inset; board title "minimal look, Mac and Web (C's full layout, A's look)").
- **References, historical only (never override E's visuals):** `B-Map`, `C-Map`, B-/C- boards (E-Minimal is built from `C-Minimal`); decision boards `D1-Settings`, `D2-TaskSurface`, `D3-Duplicates` (recommendations, not approved).
- **Feature list:** `FEATURE_PARITY_MATRIX.md` (authoritative). Also `PLATFORM_QUALITY_MATRIX.md`, `PLATFORM_BASELINE.md`, `DESIGN_PRINCIPLES.md`, `UX_AUDIT.md`, `docs/14-minimal-mode.md`.
- **Chrome as drawn:** iPhone Liquid Glass tab bar with the teal glass + in its line and the Day chip above on the right (ED-124), top buttons (approximated); Android floating frosted navigation toolbar, icon-only + beside it, Day button left above (ED-125; blur on Android 12+, solid tonal below; not glass; custom Material-inspired arrangement); Mac sidebar vibrancy (approximated; no blur on E-Minimal, blur on E-Workspace) + menu bar; web solid surfaces. Phones reach the Inbox through a tab with a count badge (the Inbox tray button was removed).

**Codes.** Platforms: iPh = iPhone · iPad · AndP = Android phone · AndT = Android tablet/foldable · Mac · WebD = web desktop · WebM = mobile web. Variants: **Std** = Standard (Timeline) · **Min** = Minimal (ADR-0016; on Mac/web drawn by `E-Minimal`) · **Wksp** = Workspace (`E-Workspace`) · **Focus†** = the v1.0 wide Focus presentation (`E-Focus`, archive only). Frame refs: `EP` = E-Phones, `EPM` = E-PhonesMinimal, `EW` = E-Workspace, **`EM` = E-Minimal** (`EM Mac`, `EM web`, `EM I-menu` menu bar + status item, `EM I-task` task screen in the column, `EM I-mini` Now mini window, `EM I-finder` Everything else, `EM band` Minimal hides, never removes), `EF†` = E-Focus (v1.0 archive only); F = frame, I = inset.
**Design status:** *Designed* = drawn for every platform that has the screen today, in the variants it needs · *Partly designed* = drawn somewhere, gaps listed · *Not designed* = no frame (an entry point or caption at most). Coverage that existed only on `EF†` no longer counts as designed.
**Shared states (ED-186):** E-G4-7-States holds the review kit (light and dark): 21 state frames plus the status vocabulary and accessibility examples; not merged into active boards. Q1 direction approved (ED-187); Q2 behaviour approved (ED-188); web Sync details with the browser-storage warning, Q2a–Q2d (ED-189 to ED-191, approved); not signed in, Q2e and Q2f (ED-192); Q2 closed at design level; conflict Undo C3 and C5 approved (ED-194). **E-G4-7-Q4-KeepBoth** (ED-195): Keep both for notes on iPhone, Android, Mac and web, combined note, Undo, title conflict, 200 %, length limit (Q4-L1 approved, ED-196); light and dark; not merged. G4-7 closed at design level (ED-196). **E-G3-C1-Font-Comparison** (ED-203): Android task text font comparison for cleanup 7a/7b, review only; Q3–Q5 open.

**Consistency (ED-185):** CR-153 to CR-156 applied on E-G4-3-Narrow, E-Phones, E-Phones-2, E-Phones-3, E-FullA-v2 and dark copies.

**Plan panel (ED-184):** E-FullA-v2 Mac and web Workspace windows have the Plan panel button and folding sections, plus a row with hidden and brought-out states (Mac, web); E-G4-3-Narrow 840 shows it hidden automatically; dark copies match.

**Dark mode (ED-174 to ED-179):** tokens FINAL (Q1-B thread, text corrections also on the light editors and hex fields); Stage 2 approved (ED-180); every active board now has a dark companion (ED-181): E-Phones-Dark, E-Phones-2-Dark, E-Phones-3-Dark, E-PhonesMinimal-Dark, E-FullA-v2-Dark, E-Minimal-Dark, E-Earlier-Dark, E-Responsive-Dark, E-MobileWeb-Dark, E-G4-3-Narrow-Dark (same frames, same order as the light boards). Tablet dark screens come with Round 2 (G4-4).

**Mobile web (ED-172):** compact Full and Minimal, Add with keyboard, task link and Back, landscape on E-MobileWeb; browser behaviour PENDING.

**Mac narrow (ED-169, ED-170):** Full and Minimal from 840 on E-G4-3-Narrow (approved). **Tablets (ED-171):** strategy approved; iPad and Android tablet and foldable screens not drawn (Round 2).

**Responsive (ED-167, ED-168):** every screen is checked against 600 / 840 classes, H1 (usable height under 480 → compact) and the editor docking minimums; board E-Responsive. Tablets and mobile web: G4-4, G4-5.

**Round 2 drawing order (G4-1, ED-166; planning only):** stage 1, core journey: Today → Add → Edit → Complete → Change day → Reopen; stage 2, interaction and recovery: multi-select and selection bar → Undo → sync conflict → Focus session; stage 3, supporting experiences: Wake Up and Wind Down → Settings → onboarding → system surfaces. Every undrawn row below stays in scope and is drawn after these stages if it is not in them; tablets and foldables follow G4-4.

**States every screen still needs unless the row says otherwise** (none are drawn in E): light **and** dark, 200 % text, reduced motion, reduced transparency (glass/translucent chrome), screen-reader order, keyboard focus on Mac/web. Rows list only the extra states that matter for that screen.

> **Group 1 answers (2026-11-04, ED-065 to ED-070).** Two modes, Full and Minimal. Focus is a feature in both; there is no wide Focus presentation, so the "wide Focus presentation" note below is closed. Workspace is planning inside Full. Minimal navigation is as drawn: phones Now · Today · Inbox, Mac/web Now · Inbox · Calendar · Search. **Task editor (ED-086, ED-087):**
- **`E-Phones` F3:** option D's medium detent.
- **`E-Phones` F6:** option D's Android editor.
- **`E-Phones` Task editor section:** full editor, steps and notes, repeat scope, large text, colour and icon (compact and full), Create task.
- **`E-FullA-v2`:** colour and icon popover.
- **iPad:** reference on `E-G2-5-OptionD-RefinedEditor`.

**Settings and Wake Up and Wind Down (ED-084):**
- **`E-Phones`:** Settings row (iPhone home, Your day, Android Settings, Android Wake Up and Wind Down overview and edit) and Wake Up and Wind Down rows (overview, alarm on and off, Alarm sounds on, large text, edit, Weekend, new-schedule checks, two devices).
- **`E-PhonesMinimal`:** minimal Settings.
- **`E-FullA-v2`:** Mac Settings window, Mac Wake Up and Wind Down panel, web Settings.
- **Tablet references:** on `E-WakeWindDown-Settings-Candidate`.
- **Still to draw:** the other five group pages (Planning, Reminders, Appearance, Data and privacy, Help), the Routines page, and the tablet shells (G4-4).

**Phone bottom row (ED-124, ED-125, merged ED-126, 2026-11-06):**
- **`E-Phones` and `E-PhonesMinimal`:** every iPhone frame with the tab bar (12) uses the approved iPhone row; every Android frame with navigation (7) uses revised option C. Coverage, frame by frame: §4.
- **Source boards:** `E-G3-6-BottomRow` (iPhone) and `E-G3-6-Android` (C); rules §9.15.
- **Minimal exception (ED-132):** the five iPhone Minimal frames draw the iOS 26+ native three-tab capsule at its measured width (274) with the 6 pt gap to the +; Full frames and Android unchanged.
- **Tablets:** not covered by these rows; iPad and Android tablet/foldable navigation stay with Prompt D Round 2 (G4-4).

**Colour selection and Appearance (G3-9b, ED-161):** `E-Phones-3` (iPhone: Create task › Colour and icon › ⋯ All colours half sheet › custom › back; Settings › Appearance · Everything / Less / scrolled / motion / Edit palette; Android equivalents); `E-Phones` Colour and icon sheet (12 + ⋯) and Settings roots; `E-FullA-v2` Mac/web Appearance panes and inspector popover. Not drawn: Minimal-mode Appearance page (its list keeps Layout), tablets.

**Task rings (G3-9, ED-155):** every ahead ring of coral, amber, sky and green uses its ring token on E-Phones, E-Phones-2, E-PhonesMinimal, E-FullA-v2, E-Minimal and E-Workspace; amber glyphs are ink. E-PhonesCalendar (reference) unchanged.

**Tab bar labels (G3-8, ED-154):** inactive iPhone tab labels and icons `#6E6E73` on every Full frame of `E-Phones` and `E-Phones-2`, as on `E-PhonesMinimal`; `E-PhonesCalendar` (reference) keeps its original drawing.

**Create task and the full editor (ED-137 to ED-142, 2026-11-06):**
- **`E-Phones`, Task editor row:** iPhone full editor with existing steps and notes; scrolled to steps and notes; typing a note (auto-scroll above the keyboard); Back in the editor with Repeat, Energy, steps, notes; Create task (detailed) with Task · Brain dump · Routine tabs; Android editor with steps and notes; Android Create task (full screen, M3 segmented buttons, Gboard).
- **`E-PhonesMinimal`, Task sheet (minimal) row (ED-145):** option D editor with steps and notes; scrolled; typing a note.
- **`E-Phones`, first row:** iPhone Add = Create task, title focused, keyboard up (ED-140).
- **`E-Phones-2`:** Add › Brain dump and Add › Routine open full screen like Create task on iPhone (Cancel only, no title, ED-153) and Android (ED-147 to ED-149; Android Routine frame new). The proposal also opens full screen on both phones (ED-150; Android proposal frame new).
- **Not drawn:** Create task on iPad / Android tablet (CR-127, Round 2). "Add another" is dropped (ED-152).

**Keyboard states (ED-135, ED-136):**
- **`E-Phones-2`** (moved from E-Phones, ED-144): section "Keyboard open and dismissed": iPhone Add (Full) open and dismissed; steps typing and dismissed. iPhone keyboards drawn in iOS 26 style (Add, typing a step).
- **`E-PhonesMinimal`:** section "Keyboard open and dismissed (minimal)": iPhone Add open and dismissed. Android Add note: Gboard sets its action-key colour.
- **Not drawn:** iOS 16–18 keyboard look (the app shows each version's own); iPad hardware-keyboard states (Round 2).

**Duplicate screens (ED-099):**
- **`E-Phones-2`** (moved from E-Phones, ED-144): row "Day review and the When picker": iPhone and Android Day review sheets, Week in review (pushed in the sheet), iPhone Move and Android Inbox Schedule in the one When picker; Day ▾ insets read Week in review.
- **`E-FullA-v2`:** row "Review and the When popover": the Workspace's Review place (Day review and Week in Review side by side) and the Mac/web popover; Mac and web Day menus read Week in Review.
- **`E-Minimal`:** row "Day review (minimal, Mac and web)": the review in the Day column. Reviewed and corrected (ED-108: no Week in review row in minimal), as is E-Minimal's web Day menu (minimal) from ED-093 (key hints added).
- **`E-PhonesMinimal`:** captions only (Move "a time" opens the picker; the Wind Down card opens the review sheet).
- **Still to draw:** Week in review empty and first-week states, share image, learning reveal (G4); the picker's Date… month and its no-free-time state; tablets (Round 2).
- **Rows below that this supersedes:** "Move picker (day + time)" (iOS and Mac/web pickers now drawn), "Wind Down / day review" (full form, Android and wide now drawn), "Weekly review ("This week")" (now Week in review; drawn on phones and wide, states still open). The table keeps its v1.1 wording.

**Routes (ED-097):** `E-FullA-v2` address bars, captions and route table on `/#/`; `E-Minimal` web address `/#/now` and route line; `E-Map` Routes line. Labels only. The corrected per-layout table is on `E-G2-11`. Not drawn: minimal phone month sheet opened from a link, minimal Mac/web Day column revealed by `/today` (both reuse drawn screens). Tablets: Round 2.

**Keyboard (ED-095):** `E-FullA-v2` View, Go, Day, File and context menus, sidebar hints, web hint bar and key tables; `E-Minimal` View and context menus, captions, finder. Labels only. The ⌘/ sheet and the web ? overlay are not drawn. Tablets: not drawn (Round 2).

**Day menu (ED-093):** `E-Phones` insets 3 (iOS pull-down) and 6 (M3 menu) with Time · Plan · Day · Layout; `E-FullA-v2` Mac menu bar Day (today and an empty other day) and web Day ▾ with Drop a routine… and Plan / Reality; `E-PhonesMinimal` Day ▾ with Show everything · Low-energy mode · Settings; `E-Minimal` new "Day menu (minimal, Mac and web)" section (menu bar Day and web Day menu). Keys are G2-10, routes G2-11. Tablets: not drawn (Round 2).

**Add modes (ED-091):** `E-Phones` F2 (Task · Brain dump · Routine), Add modes row (iPhone Brain dump, iPhone Routine, the proposal, Android Brain dump sheet) and the FAB-menu inset; `E-FullA-v2` Mac File menu and web Add ▾. Minimal unchanged. Keys are G2-10. Tablets: not drawn (Round 2).

**Minimal task screen (ED-089):** `E-PhonesMinimal` Task sheet row (iPhone ahead, iPhone running, Android running, More options → option D editor); `E-Minimal` Mac inset task column and the new web column section. Tablets: not drawn.

**Phone Calendar (ED-075, ED-079):** `E-Phones` Calendar row: iPhone and Android Calendar Month, the pull-down month on Today, and the Android title month sheet.

**G1-1 resolved (ED-073): Full on Mac and web is the Workspace** — candidate board **`E-FullA-v2`** (E-Workspace's frames plus Day menu, View/Go menus, palette, Settings row 1, Full ↔ Minimal flow). `E-FullA` (earlier revision) and `E-FullB` (option B, not chosen) stay as history. Still to draw for Full wide: 960 window, dark mode, iPad and Android tablet, mobile web.

> **Owner decision needed — wide Standard layout.** After the `A-Wide` deletion E has **no Mac/web Standard (thread-only) layout and no three-day spread**. The remaining wide boards are `E-Workspace` (B's grid layout, A cards with a thread behind) and `E-Minimal` (minimal only). Which one is the wide Standard / full presentation, whether a thread-only wide Standard is still wanted, and what replaces today's three-day spread are **not assumed** here.
>
> **Answered in v1.1 — wide Minimal layout.** `E-Minimal` is E's Mac/web minimal layout, replacing `E-Focus` (owner statement, ED-064). Still open inside it (tagged "Hypothesis · not approved" on the board): the four-row sidebar kept in minimal (doc 14 §3 shows no sidebar), Now as the wide entry and `/now`, the task screen in the Day column, Inbox as a row (doc 14 §3: a "Later" row), the Earlier fold. The board's own header still says it "replaces neither" E-Focus nor E-Workspace, and its band says Show everything "Opens E-Focus".
>
> **Owner decision needed — wide Focus presentation and the Show-everything target.** With `E-Focus` gone, no board shows a full wide Now + Day + inspector layout, and E-Minimal's "Show everything" points at a removed board. Whether E keeps a wide Focus presentation, or Show everything opens `E-Workspace` or something new, is **Not designed in v1.1 (owner decision)**.

## 1. Inventory

> **Reconciled 2026-11-13 (ED-315).** Rows marked “Since” are covered by a later approval; the status before it is the v1.1 audit and is kept as history. Rows without “Since” were not re-checked one by one: where they disagree with `E_DESIGN_DECISIONS.md`, the decisions file wins.

### 1.1 Shell, Today and the timeline

| Screen / surface | E board + frame | Platforms drawn | Variants drawn | Required interaction states | Design status |
|---|---|---|---|---|---|
| App shell / primary navigation | EP F1, F5 (Today · Inbox 3 · Calendar · Search); EPM F1, F5 (Now · Today · Inbox 3); EW sidebar (Today, Plan, Inbox, Routines, Brain dump, Calendar views, Review, Search); **EM Mac / EM web sidebar (Now · Inbox 3 · Calendar · Search; web adds Everything else `k`, Settings, Synced)**. EF† sidebar (Now, Day, Calendar, Inbox, Search, Reviews, Routines) — v1.0 archive only | iPh, AndP, Mac, WebD | Std, Min, Wksp | badge counts, selected tab, 200 % labels (no clipping), keyboard-only sidebar, signed-out avatar, sync error badge | Partly designed — wide full shell is only EW; EM and EW use different sidebars and ⌘K meanings; no iPad/AndT/WebM shell; no rail · **Since (2026-11-13):** tablet shell approved R2-1 (ED-267) |
| Today (thread, day paging ±365) | EP F1 (iPh), F5 (AndP); EW web Day canvas; **EM right column 290 on Mac and web (ED-232; web was 510)** (minimal); EF† Day column — v1.0 archive only | iPh, AndP, Mac, WebD | Std, Min, Wksp | now/past/future day, scrolled to now, dense day, overlaps, all-day events, loading skeleton, error, offline, dragging, selected | Partly designed — no wide Standard thread; no past/future day, no iPad/AndT/WebM, no dark · **Since (2026-11-13):** expanded tablets approved R2-2 (ED-269) · **Since (2026-11-14):** past day and all-day chips approved R2-27 (ED-330); dense days are not compacted (built) |
| Day column on wide minimal (Day by default; task screen replaces it; ✕/Esc returns; ⌥⌘I / "Hide the Day column" folds it; ED-218, ED-233) | EM Mac (column), EM I-task, EM web (Day column with "Day menu" and the ✕ "Hide the Day column"); EM I-menu (View › Show Day Column ⌥⌘I) | Mac, WebD | Min | Day shown, task open, column hidden, Esc focus return, ⌘2 while hidden, web `?task=` refresh/Back | Partly designed — hidden state and web task screen not drawn |
| Today — empty day | EP F4 (iPh); EPM F4 (iPh) | iPh | Std, Min | empty today, empty future day, empty past day, with/without Inbox items | Partly designed — no Android, no wide (EM has no empty frame) · **Since (2026-11-14):** empty today on Android and the empty Wake Up card approved R2-27 (ED-330) |
| Today — minimal "rest of today" | EPM F2 (iPh); EM Day column (Mac, web); **E-Earlier (ED-164): Earlier collapsed, expanded, reopened, nothing done yet on iPhone; collapsed and expanded on Android; Mac and web collapsed, expanded, reopened** | iPh, AndP, Mac, WebD | Min | Earlier fold open/closed (drawn, ED-164), swipe open, all done, evening | Partly designed — Earlier states drawn on all four; all done and evening not drawn · **Since (2026-11-14):** not built on Android; the approved iPhone frame is the reference (ED-330) |
| Week strip + month peek | EP F1, F4 (strip); EP I4 (title ▾ month sheet) | iPh, AndP (strip only) | Std | selected day, today marker, swipe weeks, month pull-open (kept per E-Map-v1.0, not drawn) | Partly designed — pull-open not drawn; Android date picker not drawn |
| Go to a date | EP I4 (iPh month sheet); EW menu caption "Go to Date… ⇧⌘G"; EM toolbar date button + ‹ › (Mac), EM I-menu caption "Go to Date… ⇧⌘G", EM I-finder "Go to date…"; EW web URL `/plan/day/2026-11-03` | iPh (Mac/web entries only) | Std, Min | out-of-range date, far date, keyboard entry, `/day/:date` deep link | Partly designed — AndP M3 date picker, Mac/web date popover not drawn |
| Now marker, live dot, done + Undo | all thread frames (now-bead, ring dot); EM horizon + Day column | iPh, AndP, Mac, WebD | Std, Min, Wksp | live tick (polite announce), task ends, overrun, Undo toast/snackbar, ⌘Z | Partly designed — Undo toast/snackbar not drawn anywhere · **Since (2026-11-13):** Undo toast and ⌘Z / Ctrl+Z approved R2-7 (ED-281) · **Since (2026-11-14):** overrun as built (“· not done”, Need more time?, Running late) approved R2-26 (ED-329) |
| Overlap knot | EP F1, F5; EPM F2; EW Tue column; EM Day column + "Also now" (Mac, web) | iPh, AndP, Mac, WebD | Std, Min, Wksp | 2 and 3+ overlaps, overlap while dragging | Designed (tablets inherit) · **Since (2026-11-14):** three or more overlaps as a chain of knots approved R2-27 (ED-330) |
| Drag to move | EW Mac (Inbox → Wed grid, drop target, landing time); EM web "drag to move" hover hint on Lunch | Mac, WebD (hint) | Wksp, Min | lift, dragging, drop preview, invalid drop, cross-day, auto-scroll, cancel | Partly designed — phone and thread drag not drawn (built today) · **Since (2026-11-14):** phone and tablet touch drag, drop targets, cancel and auto-scroll approved R2-25 (ED-328); no overlap preview or Esc cancel (not built) |
| Multi-select + selection bar (incl. Save as routine) | EP F1 tip only ("Hold a dot to select several tasks") | — | — | selecting, n selected, bar actions, Save as routine, ⇧/⌘-click, screen-reader "Select" | Not designed · **Since (2026-11-13):** approved on every platform R2-6 (ED-279) |
| Swipe actions on a row | EP I1; EPM F2 | iPh | Std, Min | leading Done, trailing Move/Delete, partial swipe, Undo | Partly designed — Android not drawn · **Since (2026-11-14):** built swipes (phone Inbox rows only, iPhone and Android) approved R2-25 (ED-328) |
| Day menu (replaces ⋯) | EP I3 (iOS pull-down), I6 (M3 menu); EPM F2 (minimal pull-down); EW Mac menu bar Day menu; EM I-menu caption (Mac Day menu items) + EM Day-column Day button (Mac) + "Day menu" button (web, contents not drawn). EF† Mac menu bar + web button — v1.0 archive only | iPh, AndP, Mac | Std, Min, Wksp | today vs other day (Need more time? today only; "Running late" superseded by ED-162), disabled items, section headers announced | Partly designed — web popover contents not drawn; Mac Day menu differs between EW and EM; EM Day menu not drawn open · **Since (2026-11-13):** expanded tablets approved R2-5 (ED-276) |
| Need more time (formerly also "Running late", superseded by ED-162) / Shift the rest / shift followers / pin / Rebalance | EP F3 ("Need more time? +5 +15 +30" since ED-163, Shift the rest); EW inspector + menu bar (+5/+15/+30, Rebalance…); EM Now "Need more time?" (web popover open: +15 min, +30 min, Shift the rest from here), EM I-menu "Need More Time…", "Shift the Rest ⇧⌘→" | iPh, AndP, Mac, WebD | Std, Min, Wksp | before/after preview, > 2 followers → Rebalance, pinned task, conflicts, Accept/Discard | Partly designed — +5 missing on phones and EM; Rebalance, drag chip, pin not drawn |
| Reality thread (Plan / Reality) | Day menu item only (EP I3, I6) | — | — | not learned yet, toggled, empty reality | Not designed · **Since (2026-11-14):** approved as R2-23 (ED-324) · **Since (2026-11-14):** Android Reality on, the caption before the reveal and Settings › Learning approved R2-29 (ED-332) |
| Tasks before Wake Up fold | — (Morning run drawn unfolded before Wake Up in EP F1) | — | — | folded, open | Not designed · **Since (2026-11-13):** approved E-DF2 (ED-246) |
| Duplicate day, Copy day as text | Day menu items (EP I3, I6; EW menu bar; EM I-menu caption "Duplicate Day", "Copy Day as Text ⇧⌘C"; EM right-click "Duplicate ⌘D", "Copy as Text"; EM I-finder) | — | — | target-day picker, copied confirmation | Not designed (entries only) · **Since (2026-11-13):** approved as R2-22 (ED-322) · **Since (2026-11-14):** Android Day menu, Copy to which day? and the Copied snackbar approved R2-29 (ED-332) |
| Minimal switch (Show less / Show everything) | Day menu "Show less" (EP I3, I6), "Show everything" (EPM F2); EM I-menu View › Show Less ✓ / Show Everything; EM I-finder "Show everything"; EM band | iPh (minimal), Mac (menu) | Std, Min | switch transition, first-time explanation, **wide full-mode target (EM says "Opens E-Focus", removed)** | Partly designed — Settings Layout row and onboarding step 0 not drawn; wide Show-everything target: Not designed in v1.1 (owner decision) |

### 1.2 Capture and editing

| Screen / surface | E board + frame | Platforms drawn | Variants drawn | Required interaction states | Design status |
|---|---|---|---|---|---|
| Quick Add (NL time, duration chips; no "Add another", ED-152) | EP F2 (iPh, segmented Task · Brain dump · Routine); EPM F3 (iPh), F6 (AndP); EW Inbox "Capture a task ⌘N"; EM Mac toolbar + and Now-pane field "Add a task · paste several lines for many ⌘N"; EM web ink "Add" (`n`) | iPh, AndP, Mac, WebD | Std, Min, Wksp | typing, parsed chips, invalid time, overlap warning, keyboard up, offline, Add another | Partly designed — Android full Add sheet and Mac/web Add popover / live chips not drawn · **Since (2026-11-13):** tablets approved R2-3 (ED-271) |
| Add modes menu | EP I5 (Android FAB menu); EP F2 caption "hold on +" (iOS) | AndP | Std | open, close, Back | Partly designed — iOS hold menu not drawn |
| Paste a list → tasks | EP I2; EM Add field placeholder + band ("paste several lines into Add") | iPh | Std | 1 line vs many, mixed times, edit before add, minimal route to Brain dump | Partly designed |
| Brain dump (typed + spoken) | EP F2 segment; EW Brain dump block with Dictate mic + "Plan it"; EM I-menu "Brain Dump… ⇧⌘N", EM I-finder. (EF† "Clear your head ⇧⌘N" — v1.0 archive only) | iPh, Mac, WebD | Std, Wksp, Min (entry) | listening, permission denied, web non-Chrome fallback, AI unavailable → rules, proposal | Partly designed — Brain dump screen and Android not drawn |
| Proposal sheet (nothing written before Accept) | EP I2 ("Add 4 tasks") only | iPh | Std | per-item edit/remove, Accept, Discard, partial accept, AI vs rules source | Partly designed — generic sheet not drawn |
| Break it down | EM I-task "More details" list; (EF† inspector link — v1.0 archive only) | — | — | thinking, proposal, AI unavailable | Not designed · **Since (2026-11-14):** approved as R2-23 (ED-324) |
| Smallest step, Unstick (automatic) | — | — | — | trigger, dismiss | Not designed · **Since (2026-11-14):** approved as R2-23 (ED-324); built has no dismiss |
| On-device AI status | — | — | — | available, downloading, unsupported, off | Not designed · **Since (2026-11-14):** approved as R2-23 (ED-324), in Settings › Data and privacy › Privacy |
| Task surface — summary (medium detent / bottom sheet) | EP F3 (iPh), F6 (AndP behind dialog) | iPh, AndP | Std | live task, future, past, done, repeating, calendar event (read-only), overlaps, 200 % (opens at large detent) | Partly designed — minimal 4-tile sheet described, not drawn · **Since (2026-11-14):** done, past and calendar-event sheets approved R2-27 (ED-330) |
| Task screen in the right column (wide minimal) | EM I-task (Mac, 290): Task header + Close (Esc), now dot + title, Starts, Duration − +, Tomorrow / Later / Move…, More details. Web: caption only ("opens it in the Day column, as on Mac") | Mac | Min | open from Day / horizon / ↩, close back to Day, focus return, More details expanded, calendar event, done task, repeat scope | Partly designed — web and "More details" expanded not drawn |
| Task editor (large detent / full screen / inspector) | EW inspector (Mac, web); EF† inspector — v1.0 archive only | Mac, WebD | Wksp | editing, autosave + Undo, repeat "this one / all future", delete + Undo, validation | Partly designed — phone large detent and Android full screen not drawn · **Since (2026-11-13):** tablets approved R2-4 (ED-274) |
| Move picker (day + time) | EP F6 (M3 dial); EW "Move to… ⌘M"; EW web "m to move"; EM right-click "Move To… ⌘M", EM I-task "Move…" | AndP | Std | other day, overlap result, keyboard input, Cancel | Partly designed — iOS picker and Mac/web picker not drawn · **Since (2026-11-14):** "Move to" with the month view marking days that have tasks approved R2-28 (ED-331) |
| Editor fields: colour, icon, notes/links, repeat, alerts (≤ 5), pin, travel, energy, subtasks | EW inspector (time, repeat, alerts, subtasks, notes); EM I-task fields (Starts, Duration) + "More details" list; colour/icon/pin/travel/energy only as "More" captions | Mac, WebD | Wksp, Min | 5-alert limit, per-occurrence subtasks (R-09), empty notes | Partly designed · **Since (2026-11-14):** the 5-alert limit approved R2-27 (ED-330) |
| Context menu on a task | EW Mac right-click; EM Mac right-click on a horizon dot (Open, Mark Done, Move To…, Shift the Rest From Here, Focus ⌘F, Duplicate, Copy as Text, Delete ⌫); EM web hover actions button (Lunch). EF† — v1.0 archive only | Mac, WebD | Wksp, Min | disabled items, past task, calendar event | Partly designed — two different item sets (EW vs EM) |
| Inbox | Phone tab badge only (EP F1, F5; EPM F1, F5); EW Inbox column (Mac, web); EM sidebar row "Inbox 3" (⌘4) | Mac, WebD | Wksp | empty, many, filters, completed group, drag source, keyboard move | Partly designed — phone Inbox screen and minimal wide Inbox screen not drawn · **Since (2026-11-13):** approved on every platform R2-13 (ED-295) · **Since (2026-11-14):** the Inbox schedule sheet with no free slot approved R2-28 (ED-331) |
| Inbox scheduling (≤ 2 taps) | EW drag + drop target (Mac); web "focus a row and press m" | Mac | Wksp | one picker (D3), free slots, drop on today | Partly designed — phones not drawn |
| Routines (list, save, drop on a day) | EW Inbox column + sidebar; EP F2 Routine segment, F4 "Drop a routine"; EM I-menu View › Routines, "Drop a Routine", EM I-finder | iPh, Mac, WebD | Std, Wksp, Min (entry) | empty, preview proposal, Accept, edit routine | Partly designed — Routines page and Android not drawn · **Since (2026-11-13):** approved as R2-22 (ED-322) |
| Pick today's one thing | Day menu item; Mac "Pick One Thing…" (EW) | — | — | none picked, picked, change | Not designed |
| Low-energy mode | Now one name (ED-162): "Low-energy mode", "Low-Energy Mode" in Mac menus. Superseded variants: minimal "Low-energy day", EM "Gentle Day" / "Gentle day", EW "Low-Energy Mode" | — | — | on, off, header switch while on | Not designed (entries only, three names) · **Since (2026-11-13):** approved as R2-22 (ED-322) |
| Focus `/focus/:id` (the feature) | entries only: EP F3 Focus tile; EPM big-dot tap; EM Now "Focus" button, big-dot click ("Opens Focus"), right-click "Focus ⌘F"; (EF† inspector, orb tap — v1.0 archive only) | — | — | running, paused, ended, overrun, deep work (Android) | Not designed · **Since (2026-11-13):** approved on every platform R2-9 (ED-286) · **Since (2026-11-14):** past its end approved R2-26 (ED-329); pause is not built |
| Now (big now-dot, horizon, also now / next) | EPM F1 (iPh), F5 (AndP); **EM Mac Now pane (790), EM web Now pane (560)**. EF† Now panel — v1.0 archive only | iPh, AndP, Mac, WebD | Min | free time, two tasks at once, overrun, morning, evening, all done, empty day (EPM F4), no current task | Partly designed — morning/evening/overrun/no-task not drawn; no wide empty day · **Since (2026-11-14):** morning, between tasks and overrun approved R2-26 (ED-329), Now / Next up / Nothing else today |
| Horizon (day laid flat, 7 AM–11 PM) | EPM F1, F3, F4, F5; EM Mac (700 px), EM web (496 px) | iPh, AndP, Mac, WebD | Min | click dot → opens in column, right-click menu, keyboard traversal, screen-reader summary, dense day | Partly designed — keyboard traversal not drawn |
| Mac Now mini window + menu bar status item | EM I-mini (Window › Show Now ⌥⌘0), EM I-menu status item and its menu (Mark Done, Need More Time?, Show Now Window). EF† — v1.0 archive only | Mac | Min | no live task, overrun, Done from window | Partly designed — feasibility check needed · **Since (2026-11-14):** menu bar after the end approved R2-26 (ED-329); the mini window is not built |
| Everything else finder (⌘K Mac, `k` web; also searches tasks) | EM I-finder (Places · Plan the day · Reflect and settings) + EM toolbar button (Mac) + sidebar row (web) | Mac, WebD | Min | empty query, typing, task results, no results, keyboard (↑↓ ↩ esc) | Partly designed — results state not drawn |
| ⌘K command palette | EW inset (Mac); web "Ctrl K" in EW sidebar | Mac | Wksp | empty query, no results, task vs command results | Partly designed — conflicts with EM's ⌘K finder |
| Wide Focus presentation (Now + Day + inspector, full sidebar) | EF† Mac + web — **v1.0 archive only (removed from canvas)** | — | — | — | **Not designed in v1.1 (owner decision)** |

### 1.3 Mornings, nights, alerts

| Screen / surface | E board + frame | Platforms drawn | Variants drawn | Required interaction states | Design status |
|---|---|---|---|---|---|
| Wake Up / Wind Down caps on the thread | EP F1, F4; EPM F2, F4; EM horizon ends (plain discs) + Day column Wind Down cap. EF† Day — v1.0 archive only | iPh, AndP, Mac, WebD | Std, Min | tap to change (full), plain (minimal), night on day dot | Partly designed |
| Day shape + sleep target + night editor | — | — | — | crossing midnight (Q8), different days | Not designed · **Since (2026-11-13):** sleep target and night dial approved (ED-084, R2-18); Day shape row removed, owner chose A (ED-321); there is no Day shape page |
| Wake Up alarm ringing (AlarmKit / Android full screen / Mac+web notification) | — | — | — | ringing, snoozed, permission missing, iOS 16–25 fallback | Approved: E-R2-19-B (ED-314) |
| Wake Up card, Wake Up Check, snooze | — | — | — | late start, "Show my day" | Approved: E-R2-19-B (ED-314) |
| Missions (stand up, walk, light, breathe, catch the dot, one thing; hold to skip) | — | — | — | sensor unavailable, Mac/web skip, "Can't right now" | Not designed · **Since (2026-11-13):** approved E-R2-19-B (ED-314); also drawn for tablets · **Since (2026-11-14):** sensor missing, access blocked, "Needs at least two dots that day." and backup mission None approved R2-28 (ED-331) |
| Wind Down / day review | EPM end-of-day inset (iPh, minimal card); EM I-menu "Review the Day", EM I-finder | iPh | Min | items left, all done, Tomorrow/Later, review page | Partly designed — full form, Android, wide not drawn · **Since (2026-11-13):** tablets approved R2-14 (ED-297) |
| Weekly review ("This week") + share + learning reveal | Day menu "This week"; EW "Review"; EM View › Review, EM finder "Review" (singular since ED-162). (EF† "Reviews" row — v1.0 archive only) | — | — | first week, no data, share image | Not designed · **Since (2026-11-13):** Week in review on tablets approved R2-14 (ED-297); share and learning reveal still not drawn · **Since (2026-11-14):** phone sheet, carry and share approved as R2-24 (ED-326); the learning reveal is on Today and Learn my day (R2-23, ED-324) · **Since (2026-11-14):** the quiet week (nothing planned, 0 of 0 done, share card) approved R2-28 (ED-331) |
| Notifications: task alert, Start nudge, day-start summary, Wind Down reminder | — | — | — | actions (Done, Start, Snooze), web push partial | Not designed · **Since (2026-11-13):** approved R2-20 (ED-317) |
| Notification health + test alarm | — | — | — | all good, blocked, exact alarm off | Not designed · **Since (2026-11-13):** approved R2-20 (ED-317) |

### 1.4 Settings, data, accounts

| Screen / surface | E board + frame | Platforms drawn | Variants drawn | Required interaction states | Design status |
|---|---|---|---|---|---|
| Settings entry | avatar "Settings and account" (EP, EPM top bars); Mac ⌘, captions (EW, EM sidebar footer "Settings: ⌘, (own window)"); web sidebar footer (EW, EM) | iPh, AndP, Mac, WebD (entry only) | Std, Min, Wksp | signed out glyph, sync badge | Partly designed (entry only) |
| Settings root (six groups per D1) | — (D1 reference only) | — | — | search settings, two panes wide | Not designed · **Since (2026-11-13):** approved G2-4 (ED-084), Settings place ED-238; tablets R2-11 (ED-291) · **Since (2026-11-14):** every Settings row has the same icon and colour on every platform, Mac and web lists included (ED-332) |
| Settings › Your day / Planning / Reminders / Sounds / Appearance / Data & privacy / Help & about | — | — | — | per row | Not designed · **Since (2026-11-13):** Your day and Appearance approved (ED-084, ED-161), Your day without the Day shape row (ED-321); tablets R2-11 (ED-291); Reminders approved R2-20 (ED-317); Planning, Data and privacy, Help and about still to draw · **Since (2026-11-14):** icons on every row, the same on iPhone, Android, iPad, Mac and web (ED-332) |
| Minimal Settings (9 rows) + Everything else | referenced by EPM band table; wide minimal uses the EM I-finder instead | — | — | — | Not designed (phones); wide finder Partly designed (above) · **Since (2026-11-14):** Android minimal Settings and Everything else… approved R2-29 (ED-332) |
| Mac Settings window | captions "⌘, own window" | — | — | toolbar panes | Not designed · **Since (2026-11-13):** approved (ED-081, ED-084) |
| Account: sign in (Apple, Google, email), sign out everywhere, delete | — | — | — | provider missing, error, confirm delete | Not designed · **Since (2026-11-13):** E-CR160 screens drawn (ED-222 to ED-231); Round 2 account screens wait for CR-160 |
| Onboarding O1–O6 incl. step 0 (Show less / everything) | — | — | — | skip, permissions denied, test alarm | Not designed · **Since (2026-11-13):** approved as the interactive prototype R2-16 (ED-305); steps changed (no layout step) |
| Sync status: indicator, banner, sheet | EW "Synced · 10:42" footer; EM Mac toolbar "● Synced", EM web sidebar footer "● Synced"; EM band ("a banner appears when something needs you"); phone top-bar sync capsule | iPh, AndP, Mac, WebD (indicator only) | all | syncing, offline, error, conflict, signed out | Partly designed — banner and sheet not drawn · **Since (2026-11-13):** banner, sheet and conflicts approved G4-7 (ED-196); tablets R2-8 (ED-283) |
| Encrypted DB recovery screen | — | — | — | — | Not designed · **Since (2026-11-13):** approved R2-21 (ED-319) |
| App lock | — | — | — | locked, biometric fail | Not designed · **Since (2026-11-14):** approved as R2-24 (ED-326) · **Since (2026-11-14):** Android Privacy, the system unlock sheet and a blank Recents card approved R2-29 (ED-332) |
| Export / backups / restore / import | Mac "File › Export…" caption (EW, EM); EM I-finder "Export…", "Backups and Trash" | — | — | progress, success, invalid file, newer-version refusal | Not designed · **Since (2026-11-13):** approved R2-21 (ED-319) |
| Trash (30 days) | EW "Move to Trash ⌘⌫" menu item; EM I-finder "Backups and Trash" | — | — | empty, restore, purge date | Not designed · **Since (2026-11-13):** approved R2-21 (ED-319); permanent delete not built |
| Calendars: device + Google/Microsoft, write-back | event row "Dentist · Calendar, read-only"; EM horizon + Day column (Dentist) | iPh, AndP, Mac, WebD (event only) | Std, Min, Wksp | permission denied, connecting, error | Partly designed (event row only) · **Since (2026-11-14):** Calendars page, write-back strips and Disconnect approved as R2-24 (ED-326) · **Since (2026-11-14):** the iOS permission alert and the load error ("This didn't load", Try again) approved R2-28 (ED-331) · **Since (2026-11-14):** Android Calendars, access off (with where-to-go line) and Disconnect approved R2-29 (ED-332) |
| Search with history | tab / sidebar entries only (EM: sidebar row, `/`, and the finder "typing a task name finds it on any day") | — | — | empty, typing, no results, history | Not designed · **Since (2026-11-13):** approved on every platform R2-13 (ED-295) · **Since (2026-11-14):** no results (Try fewer words, or another filter.) approved R2-28 (ED-331) |
| Past days + year strip | EM I-finder "Past days" entry only | — | — | — | Not designed |
| Feedback, What's new, Help, Siri & Shortcuts page | — | — | — | — | Not designed · **Since (2026-11-14):** Help, Send feedback, About and What's new approved as R2-24 (ED-326); the Siri & Shortcuts page is not drawn · **Since (2026-11-14):** Android Help and about, Help and About approved R2-29 (ED-332); no Siri row on Android |
| Shared loading / error / empty / offline states | — | — | — | skeleton thread, Try again, offline outside shell | Not designed |

### 1.5 System surfaces

| Surface | E board + frame | Platforms drawn | Variants | Required states | Design status |
|---|---|---|---|---|---|
| Mac menu bar (File, Edit, View, Go, Day, Window) | EW inset; EM I-menu (View menu open; Day/File/Go in a caption). EF† inset — v1.0 archive only | Mac | Wksp, Min | live enabled state | Partly designed (two different maps: EW vs EM) |
| Mac status item | EM I-menu (ring + "18 min" and its menu). EF† — v1.0 archive only | Mac | Min | no task, overrun | Partly designed · **Since (2026-11-13):** approved R2-17 (ED-309) |
| Home/lock-screen widgets | — | — | — | — | Not designed · **Since (2026-11-13):** approved R2-17 (ED-309) |
| Live Activity / Android ongoing notification / web tab live dot | — | — | — | — | Not designed · **Since (2026-11-13):** approved R2-17 (ED-309); no Live Activity on iPad |
| Controls (iOS 18) / Quick Settings tiles | — | — | — | — | Not designed · **Since (2026-11-13):** approved R2-17 (ED-309) |
| App Intents, Siri, Android static shortcuts | — | — | — | — | Not designed · **Since (2026-11-14):** Android static shortcuts (Add task, What’s next) approved R2-29 (ED-332) |
| Share into Inbox | — | — | — | — | Not designed · **Since (2026-11-13):** approved R2-17 (ED-309) |
| Keyboard shortcuts / hint bar | EW web hint bar; EM web sidebar hint (`n` `/` `t` `[ ]` `k` `?`); Mac captions (EW, EM). EF† web hint — v1.0 archive only | Mac, WebD | Wksp, Min | iPad/Android hardware keyboard | Partly designed · **Since (2026-11-13):** tablet overlays approved R2-10 (ED-288) |
| Deep links / web URLs | EW `/plan/day/…?task=`; EM `/now`, `?task=` | WebD | Wksp, Min | refresh, Back, new tab, `/task/:id` | Partly designed |
| PWA install, offline web | — | — | — | — | Not designed · **Since (2026-11-14):** the install strip approved as R2-24 (ED-326) |

## 2. Still to design, by platform

**iPhone**
- Inbox screen and its scheduling picker; Calendar tab (Month) as a screen; Search and Past days; Focus session screen.
- Task surface large detent (full editor), iOS Move picker, repeat scope prompt, alerts editor.
- Selection bar and Save as routine; Undo toast; Reality thread; before-Wake-Up fold.
- Proposal sheet, Brain dump screen (spoken input), Break it down, Routines page, Pick one thing, Low-energy header switch.
- Wake Up alarm, card, Check, snooze, missions; full day review; This week.
- Settings root and all groups, minimal Settings, Account, onboarding, sync banner/sheet, recovery, app lock, export/import, Trash, calendars, feedback/What's new, Siri & Shortcuts page.
- Widgets, Live Activity, Controls, share extension; hardware-keyboard behaviour.
- Now morning/evening/overrun states. (Minimal task sheet: drawn, ED-089.)

**iPad** — nothing drawn (see §3).

**Android phone**
- Everything in the iPhone list, plus: full Add sheet (non-minimal), Today minimal (rest of today), empty day (full and minimal), swipe actions, M3 date picker for Go to date, task surface full-screen editor with predictive Back, Day review card, ongoing notification, Quick Settings tiles, static shortcuts, full-screen alarm.

**Android tablet / foldable** — nothing drawn (see §3).

**Mac**
- One reconciled shell (EW vs EM sidebars, ⌘1–4, ⌘K palette vs finder, ⌥⌘I vs ⌥⌘D, Day menu, context menu) — owner decision first.
- Standard (thread) wide layout and the full-mode / Show-everything target — owner decision (A-Wide deleted; E-Focus removed; E-Minimal's "Opens E-Focus" is stale). Wide Focus presentation: **Not designed in v1.1 (owner decision)**.
- Minimal (E-Minimal) gaps: empty day, morning / evening / overrun / no current task, Day column hidden, Day menu open, task screen "More details" expanded, Inbox / Calendar / Search screens in minimal, finder results, minimum window 960 × 640 layout.
- Add popover, Day/3-day/Month canvases, Search, Review (day + week), Routines page, Focus session screen, Settings window and panes, Export/Import panels, Trash, onboarding, Account, notification/alarm fallbacks.

**Web desktop**
- Same as Mac, plus: Day menu popover contents, task screen in the Day column (only described), Settings routes (`/settings/...`), download/export, web push permission flow, PWA install, `/task/:id` full page at narrow width, Ctrl K palette vs `k` finder.

**Mobile web** — nothing drawn (see §3).

**All platforms** — dark mode, 200 % text, reduced motion, reduced transparency, loading/error/offline/empty states, screen-reader order per screen.

## 3. Platform layouts not designed
> **Tablets (owner sequencing, 2026-11-04).** Phone and Mac boards do not count as tablet designs. Tablet gaps listed here stay open until Prompt D Round 2. The comprehensive tablet coverage checklist is a mandatory step before Round 2 begins (`STATUS.md` Open items); until then each Group 2 decision only records its iPad and Android tablet/foldable implications.


- **iPad (all widths):** compact split/Slide Over, portrait (medium), landscape (expanded), Stage Manager windows; pointer and hardware keyboard; sidebar vs tab bar; popover task surface (D2 recommends).
- **Android tablet and foldable:** medium (rail) and expanded; folded/unfolded continuity; hinge-aware panes (never split a pane across the hinge); tabletop posture.
- **Mobile web:** phone-width browser layout (bottom bar, no edge swipe, browser Back), URL behaviour, install prompt.
- **Narrow Mac/web window:** anything below 1280 — Mac minimum is 960 × 640 today; E-Minimal needs 1280 as drawn (Mac 200 + 790 + 290, web 210 + 560 + 510) and how it gives way is not drawn; Week shows only four days at 1280. (v1.0: the E-Focus four-column layout needed about 1160+.)
- **Phone landscape** (iPhone and Android): not drawn; short height needs its own rule.
- **Wide Standard (thread) layout:** gone with A-Wide. **Owner decision needed.**
- **Wide Minimal layout:** **designed in v1.1** as `E-Minimal` (owner statement, ED-064). Its hypothesis-tagged internals still need owner decisions (see the box at the top).
- **Wide Focus presentation:** `E-Focus` removed from the canvas (v1.0 archive only). **Not designed in v1.1 (owner decision).**
- **Full-mode Now on phones:** E phones open on Today; Now exists only in minimal. Whether full phones get a Now view is open.
- **Dark mode** on every board; **200 % text** on every board; **reduced transparency** fallbacks for Liquid Glass and Android translucent tonal chrome; **RTL** is not required (no RTL languages ship) but layouts should not preclude it.

## 4. Phone bottom row coverage (ED-126, 2026-11-06)

Every phone frame on the active phone boards, checked against the approved rows (ED-124 iPhone, ED-125 Android C). "Updated" frames carry the approved geometry exactly (the 8 frames that appear on the approval boards are byte-identical). Frames under a sheet keep the sheet as approved; the row underneath now has the new geometry, so closing the sheet cannot bring the old row back.

| # | Board | Platform | Frame (caption) | Bottom row before | Result |
|---|---|---|---|---|---|
| 1 | E-Phones | iPhone | iPhone · Today (compact, 390 pt) | tab bar, Day ▾, 52 pt + | UPDATED |
| 2 | E-Phones | iPhone | iPhone · Add a task (sheet, grows with keyboard) | none drawn | EXEMPT · sheet, dialog or full-screen editor covers the screen |
| 3 | E-Phones | iPhone | iPhone · Task sheet (medium detent) · option D | none drawn | EXEMPT · sheet, dialog or full-screen editor covers the screen |
| 4 | E-Phones | iPhone | iPhone · Empty day (Wed 4 Nov) | tab bar, Day ▾, 52 pt + | UPDATED |
| 5 | E-Phones | Android | Android · Today (compact, 412 dp) | NavigationBar, Day, extended Add | UPDATED |
| 6 | E-Phones | Android | Android · Task editor (full screen) · option D | none drawn | EXEMPT · pushed page or Settings screen |
| 7 | E-Phones | iPhone | iPhone · Calendar tab · Month (new) | tab bar, 52 pt + | UPDATED |
| 8 | E-Phones | iPhone | iPhone · Today · pull-down month (built, kept) | tab bar, Day ▾, 52 pt + | UPDATED |
| 9 | E-Phones | Android | Android · Calendar destination · Month (new) | NavigationBar, extended Add | UPDATED |
| 10 | E-Phones | Android | Android · Today · title opens the month (new) | none drawn | EXEMPT · sheet, dialog or full-screen editor covers the screen |
| 11 | E-Phones | iPhone | iPhone · Settings | none drawn | EXEMPT · pushed page or Settings screen |
| 12 | E-Phones | iPhone | iPhone · Your day | none drawn | EXEMPT · pushed page or Settings screen |
| 13 | E-Phones | Android | Android · Settings | none drawn | EXEMPT · pushed page or Settings screen |
| 14 | E-Phones | Android | Android · Wake Up and Wind Down | none drawn | EXEMPT · pushed page or Settings screen |
| 15 | E-Phones | Android | Android · Edit Weekdays | none drawn | EXEMPT · pushed page or Settings screen |
| 16 | E-Phones | iPhone | iPhone · Wake Up and Wind Down | none drawn | EXEMPT · pushed page or Settings screen |
| 17 | E-Phones | iPhone | iPhone · alarm on | none drawn | EXEMPT · pushed page or Settings screen |
| 18 | E-Phones | iPhone | iPhone · alarm off | none drawn | EXEMPT · pushed page or Settings screen |
| 19 | E-Phones | iPhone | iPhone · Alarm sounds on | none drawn | EXEMPT · pushed page or Settings screen |
| 20 | E-Phones | iPhone | iPhone · large text | none drawn | EXEMPT · sheet, dialog or full-screen editor covers the screen |
| 21 | E-Phones | iPhone | iPhone · Edit Weekdays | none drawn | EXEMPT · sheet, dialog or full-screen editor covers the screen |
| 22 | E-Phones | iPhone | iPhone · Edit Weekdays, lower | none drawn | EXEMPT · sheet, dialog or full-screen editor covers the screen |
| 23 | E-Phones | iPhone | iPhone · Weekend | none drawn | EXEMPT · sheet, dialog or full-screen editor covers the screen |
| 24 | E-Phones | iPhone | iPhone · New schedule checks | none drawn | EXEMPT · sheet, dialog or full-screen editor covers the screen |
| 25 | E-Phones | iPhone | iPhone · Full editor (pulled up from F3) | none drawn | EXEMPT · sheet, dialog or full-screen editor covers the screen |
| 26 | E-Phones | iPhone | iPhone · Empty steps and notes | none drawn | EXEMPT · sheet, dialog or full-screen editor covers the screen |
| 27 | E-Phones | iPhone | iPhone · Typing a step | none drawn | EXEMPT · sheet, dialog or full-screen editor covers the screen |
| 28 | E-Phones | iPhone | iPhone · Repeating task: which ones? | none drawn | EXEMPT · sheet, dialog or full-screen editor covers the screen |
| 29 | E-Phones | iPhone | iPhone · Long title, large text | none drawn | EXEMPT · sheet, dialog or full-screen editor covers the screen |
| 30 | E-Phones | iPhone | iPhone · Colour and icon, compact | none drawn | EXEMPT · sheet, dialog or full-screen editor covers the screen |
| 31 | E-Phones | iPhone | iPhone · All icons, pinned palette | none drawn | EXEMPT · sheet, dialog or full-screen editor covers the screen |
| 32 | E-Phones | iPhone | iPhone · Back in the editor | none drawn | EXEMPT · sheet, dialog or full-screen editor covers the screen |
| 33 | E-Phones | iPhone | iPhone · Create task (detailed) | none drawn | EXEMPT · sheet, dialog or full-screen editor covers the screen |
| 34 | E-Phones | iPhone | iPhone · Add › Brain dump | none drawn | EXEMPT · sheet, dialog or full-screen editor covers the screen |
| 35 | E-Phones | iPhone | iPhone · Add › Routine | none drawn | EXEMPT · sheet, dialog or full-screen editor covers the screen |
| 36 | E-Phones | iPhone | iPhone · the proposal (both modes) | tab bar, Day ▾, 52 pt + | UPDATED under the sheet (sheet unchanged) |
| 37 | E-Phones | Android | Android · FAB menu › Brain dump | NavigationBar, Day, extended Add | UPDATED under the sheet (sheet unchanged) |
| 38 | E-Phones | iPhone | iPhone · Day review sheet | tab bar, Day ▾, 52 pt + | UPDATED under the sheet (sheet unchanged) |
| 39 | E-Phones | Android | Android · Day review (M3 sheet) | NavigationBar, Day, extended Add | UPDATED under the sheet (sheet unchanged) |
| 40 | E-Phones | iPhone | iPhone · Move (the When picker) | tab bar, Day ▾, 52 pt + | UPDATED under the sheet (sheet unchanged) |
| 41 | E-Phones | Android | Android · Schedule from the Inbox | NavigationBar, Day, extended Add | UPDATED under the sheet (sheet unchanged) |
| 42 | E-PhonesMinimal | iPhone | 1 · iPhone · Now, minimal (compact, 390 pt) | tab bar, Day ▾, 52 pt + | UPDATED |
| 43 | E-PhonesMinimal | iPhone | 2 · iPhone · Rest of today, minimal (Today tab) | tab bar, Day ▾, 52 pt + | UPDATED; Day menu re-anchored right |
| 44 | E-PhonesMinimal | iPhone | 3 · iPhone · Add, minimal (sheet over the keyboard) | none drawn | EXEMPT · sheet, dialog or full-screen editor covers the screen |
| 45 | E-PhonesMinimal | iPhone | 4 · iPhone · Empty day, minimal (Wed 4 Nov) | tab bar, Day ▾, 52 pt + | UPDATED |
| 46 | E-PhonesMinimal | Android | 5 · Android · Now, minimal (compact, 412 dp) | NavigationBar, Day, + | UPDATED |
| 47 | E-PhonesMinimal | Android | 6 · Android · Add, minimal (M3 modal bottom sheet) | none drawn | EXEMPT · sheet, dialog or full-screen editor covers the screen |
| 48 | E-PhonesMinimal | iPhone | iPhone · task sheet, a task ahead | tab bar, Day ▾, 52 pt + | UPDATED under the sheet (sheet unchanged); Day menu re-anchored right |
| 49 | E-PhonesMinimal | iPhone | iPhone · task sheet, running now | tab bar, Day ▾, 52 pt + | UPDATED under the sheet (sheet unchanged); Day menu re-anchored right |
| 50 | E-PhonesMinimal | Android | Android · task sheet, running now | NavigationBar, Day, + | UPDATED under the sheet (sheet unchanged) |
| 51 | E-PhonesMinimal | iPhone | iPhone · More options → option D editor | none drawn | EXEMPT · sheet, dialog or full-screen editor covers the screen |
| 52 | E-PhonesMinimal | iPhone | iPhone · minimal Settings | none drawn | EXEMPT · pushed page or Settings screen |
| 53 | E-PhonesMinimal | iPhone | Inset · iPhone · end of day, minimal (10:05 PM) | none drawn | EXEMPT · pushed page or Settings screen |

Totals: 19 updated, 34 exempt, 53 phone frames.

**Other boards checked, not changed (documented reason):**

| Board | Phone frames with a bottom row | Why unchanged |
|---|---|---|
| `E-PhonesCalendar` | 2 iPhone, 1 Android | G2-1 review board, "approved and now in E-Phones": history. The active Calendar frames are E-Phones #7 and #9 (updated) |
| `E-G2-6-Review`, `E-G2-8`, `E-G2-12` | 2+1, 1+1, 2+2 | Approved-and-merged review boards kept as history; their active copies are on E-Phones / E-PhonesMinimal (updated) |
| `E-G3-1`, `E-G3-3`, `E-V1` | 7+6, 3+3, 6+6 | Decision and visual-review boards kept as history |
| `E-G3-6`, `E-G3-6-Native`, `E-G3-6-Spikes` | 4+4, 2, (captures) | G3-6 history: the old row is what those boards compared |
| `E-G3-6-BottomRow`, `E-G3-6-Android` | 14, 8 | The approval sources themselves (before/after pairs; options A and B kept as history) |
| `E-G2-4`, `E-G2-5*`, `E-G2-6`, `E-SettingsReview`, `E-WakeWindDown-Settings-Candidate`, `E-G3-4` | none | No bottom row drawn (sheets, editors, Settings) |
| `E-Map` | no phone frames | Text updated (quick add, compact presentation, familiarity, native chrome, Decided since v1.1) |
| `E-Minimal`, `E-FullA-v2`, `E-Workspace` | none | Mac and web only |
| A-, B-, C-, D- boards | — | Other concepts; not modified |

