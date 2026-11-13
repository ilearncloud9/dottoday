# Concept E — implementation handoff checklist

**Status:** design-phase record. G3-6 resolved as a design and selected architecture direction (ED-133); every box below is PENDING until run. **Production implementation is not authorised** by anything in this file. It lists what an implementation task must satisfy and verify once the owner authorises it. Created 2026-11-06 (ED-128); add a section per decision group as decisions land.

Status words (ED-128), used in every row:
- **Approved visual design**: the owner approved how it looks.
- **Selected architecture direction**: the owner chose how it should be built.
- **Feasibility demonstrated**: a spike showed it can work (where, on what).
- **Tests still outstanding**: not verified; never marked passed without a recorded run.
- **Production implementation not authorised**: true for every row below.

## Current state at a glance (2026-11-08, after ED-184)

1. **Approved visual design:** Groups 1–3 complete (to ED-165). G4-1 to G4-6 resolved (ED-166 to ED-181): Round 2 order, breakpoints and docked editor, Mac minimum 840 × 640, tablet navigation strategy, compact mobile web, dark mode (P1 tokens, 12 dark task colours, Mac D1 sidebar, dark companions of every active board). Plan panel A + B (ED-184). Text always fits (ED-183). Boards: E-Phones, -2, -3, E-PhonesMinimal, E-FullA-v2, E-Minimal, E-Earlier, E-Responsive, E-MobileWeb, E-G4-3-Narrow and each `-Dark` copy.
2. **Selected architecture:** native-first glass and bars (ED-128, ED-133: iOS N3 native bar, native Day menu, Flutter chrome elsewhere, Android C in Flutter, Mac native vibrancy with warm tint); width classes 600 / 840 and editor docking from 1160 (ED-167); platform-native tablet navigation (ED-171).
3. **Verified behaviour:** only the spikes and captures recorded in this file (iOS 18.6 / 26.5 Simulators, the owner's iPhone, the native Mac vibrancy sample on the tested backdrops). Everything else is a drawing.
4. **Pending implementation tests:** all boxes below; device glass/blur/vibrancy, Reduce Transparency, Increase Contrast, VoiceOver, TalkBack, Dynamic Type / font scale 200 %, keyboard order, theme switching, Plan panel resizing and focus, web first-paint theme.
5. **Open decisions needing the owner:** G4-7 closed at design level (ED-196); next: cleanup items reconciled in `E_CLEANUP_BATCH.md` (ED-197), CR-143 and CR-165; implementation open: CR-159, CR-160, CR-161, CR-163, CR-164; Q2 closed at design level ED-192; CR-159 open; **CR-160 CRITICAL release blocker, ED-193**; option A ED-186, Q1 direction ED-187 and Q2 web storage ED-188 approved; the conflict Undo is not built and not approved); 13 OWNER items in `E_CLEANUP_BATCH.md`; CR-143 (Day-column key); CR-154 to CR-156; colour data choices in `E_COLOUR_DATA_REVIEW.md` (needed before build, not before design). Prompt D Round 2 not started (tablet coverage checklist first, ED-090).

## G3-6 · Glass, vibrancy and the phone bottom rows

### iPhone bottom row (ED-124, ED-128 D1–D3)
- **Approved visual design:** rules §9.15; source `E-G3-6-BottomRow`; active boards `E-Phones`, `E-PhonesMinimal`.
- **Selected architecture direction:** N3 native composition: UIKit root, standalone UITabBar, native teal glass + (UIButton prominent glass), native Day ▾ (UIButton glass) with a native UIMenu, one Flutter view behind. iOS 16–25: F2 (same composition, pre-26 native styles), **conditional** on tests. Minimum iOS stays 16.
- **Feasibility demonstrated:** N3 arrangement and alignment on the owner's iPhone 17 Pro, iOS 27.0.1, three runs (ED-122); glass over Flutter, selection, badge and 120 Hz Flutter timings (N1/N2, ED-121); F2 builds with an iOS 16 deployment target and keeps the geometry, tab switch, badge, hold menu and Day menu in iOS 26.5 compatibility mode (ED-129).
- **Must hold in the build:**
  - [ ] ED-124 geometry; + aligned to the measured glass capsule, re-aligned on every layout change.
  - [ ] Full tabs Today · Inbox · Calendar · Search; Minimal Now · Today · Inbox; Search a regular tab.
  - [ ] + tap opens Add on Task with the title focused; hold gives Brain dump, Routine, Paste a list (G2-8), also as accessibility actions.
  - [ ] Day ▾ native UIMenu with every G2-9 command, group, label and availability rule, in fixed order; no entry point removed.
  - [ ] Inbox badge, selected tab, routes and deep links stay in sync between UIKit and go_router; selected tab restored after relaunch.
  - [ ] Safe-area insets passed to Flutter; row behaviour with the keyboard open.
  - [ ] Calendar tab without a Day control.
  - [ ] Inactive tab labels and icons `#6E6E73` (ED-154), selected teal unchanged, set through the native UITabBar appearance for unselected items (N3 iOS 26+, F2 iOS 16–25). Never replace the native bar with Flutter to get this colour.
  - [ ] PENDING (device): iOS 18 and iOS 26 both show `#6E6E73` for unselected items; record whether Liquid Glass adapts or overrides it.
  - [ ] PENDING (device): contrast of inactive labels over the real content scrolling beneath the glass (light and busy rows), not only cream; ≥ 4.5:1 target.
  - [ ] PENDING: Increase Contrast, Bold Text, Reduce Transparency and Dynamic Type with the custom colour. Dark-mode colour decided in G4-6, not here.
- **Simulator results (ED-131, `E-G3-6-Compat`):** PASS on iOS 18.6 (F2) and 26.5 (N3) for the functional checks, safe areas, keyboard, taps while scrolling, Increase Contrast, largest text and touch targets; Reduce Transparency PASS (F2 after its fix). These are Simulator results, not device results.
- **Rules from the run:**
  - [ ] Fixed element order on the Day ▾ and + menus.
  - [ ] Disabled "Need more time" item (not a submenu) on days other than today.
  - [ ] F2 solid bar and Day ▾ when Reduce Transparency is on.
  - [ ] N3 Minimal (ED-132): + 21 / 21; native three-tab capsule at Apple's width, 6 pt from the +, centres level; computed from the rendered capsule bounds on every layout pass (never a hardcoded 274); F2 keeps 21 / 6 / 21.
  - [ ] Same relation verified on other iPhone sizes, rotation, larger text and accessibility settings.
- **Tests still outstanding (PENDING; none passed on a device):**
  - [ ] Retest on iOS 26.5: other-day Day menu after the fix; + menu fixed order.
  - [ ] VoiceOver order and announcements on both versions, on a device; resolve the duplicate native tab elements and the missing Inbox badge announcement seen on iOS 26.5.
  - [ ] Reduce Transparency and Increase Contrast on a physical device.
  - [ ] Full Keyboard Access; Large Content Viewer.
  - [ ] Deep links and selected-tab restoration.
  - [ ] N3 taps on +, Day ▾ and tabs, including while scrolling; hold actions; badge; deep links; safe areas; rotation.
  - [ ] VoiceOver order (Day ▾, tabs, +), Full Keyboard Access, largest text and Large Content Viewer, Bold Text, Reduce Transparency, Increase Contrast.
  - [ ] Quick tap opens the Day menu (only press was shown in the simulator, ED-129).
  - [ ] F2 on iOS 16 and 17 — PENDING (iOS 18.6 Simulator PASS, ED-131); no runtime downloads without the owner's authorisation; standalone bar item layout with its 13 pt safe-area inset.
  - [ ] Instruments trace of iOS glass compositing.

### Other iPhone chrome (ED-128 D4)
- **Selected architecture direction:** top capsule, ‹ Today / back, Close stay Flutter approximations; no further native integration without a new decision.
- **Tests still outstanding:** [ ] Reduce Transparency solid fallbacks; [ ] contrast on glass.

### Android bottom row (ED-125, ED-128 D5)
- **Approved visual design:** rules §9.15; source `E-G3-6-Android` (revised C).
- **Selected architecture direction:** Flutter widget (BackdropFilter + clipped shapes); no platform view, no new dependency. Custom Material-inspired arrangement; never called Liquid Glass.
- **Feasibility demonstrated:** none (drawn only).
- **Must hold in the build:**
  - [ ] Frosted on Android 12+; solid tonal on 11 and older; solid when high-contrast text is on.
  - [ ] Insets: 24 dp above the edge with gesture navigation, 16 dp above the system bar with 3-button navigation; hidden with the keyboard; edge to edge.
  - [ ] + opens the M3 FAB menu (Task, Brain dump, Routine); one + label per platform (CR-117).
  - [ ] Selected destination: one rounded highlight behind icon and label (ED-160), not the icon-only M3 indicator.
- **Tests still outstanding:** [ ] blur performance on a low-end Android 12+ phone; [ ] TalkBack (navigation role, selected state, "Inbox, 3 new"; order Day, destinations, +); [ ] keyboard and D-pad focus; [ ] 48 dp targets; [ ] font scale 200 %; [ ] responsive widths (compact only; rail at medium/expanded is Round 2).

### Mac sidebar (ED-130; D6 approved)
- **Approved visual design:** native sidebar vibrancy with Concept E's `#EFE7DB` warm tint at 35 % (light mode); layout, rows, navigation, selection colours, typography and interaction as drawn on E-Minimal and E-FullA-v2.
- **Selected architecture direction:** `NSVisualEffectView` (sidebar material, behind-window blending) with a 35 % `#EFE7DB` layer inside it, under a transparent Flutter view. No permanent replacement with a flat Flutter blur.
- **Feasibility demonstrated:** genuine captures on this Mac, light mode, synthetic backdrop (ED-129): ≈ 60 % of the neutral show-through kept; worst-case ink 12.1 : 1, selected teal 5.5 : 1; average sidebar colour 230, 227, 221.
- **Must hold in the build:**
  - [ ] Appearance as close to capture 2 on `E-G3-6-Remaining` as native rendering allows.
  - [ ] Reduce Transparency: solid fallback (proposed solid `#EFE7DB`, contrast re-measured).
- **Tests still outstanding (PENDING, none passed):**
  - [ ] Increase Contrast.
  - [ ] VoiceOver (rows announced with selected state).
  - [ ] Keyboard navigation (Tab traversal, focus ring).
  - [ ] Dark mode treatment designed and measured in G4-6 (not the light tint reused).
  - [ ] Other wallpapers and windows behind; full screen and resizing with the tint.
  - [ ] Sidebar secondary text `#6A6273` stays ≥ 4.5:1 over vibrancy with other wallpapers (4.55:1 on the measured average; CR-132).

### Tablets and web
- [ ] iPad and Android tablet/foldable navigation reviewed in Prompt D Round 2 (G4-4); the phone rows are not assumed to apply. iPad inactive tab / sidebar labels follow `#6E6E73` (ED-154).
- Web: approved navigation and solid surfaces unchanged.

## G3-7 · iPhone keyboard (ED-135)
- **Approved visual design:** stock iOS keyboard; neutral "return" key; teal Create task in the header (Full, ED-140) / Add in the nav bar (Minimal); no custom key, no accessory bar.
- **Selected direction:** Flutter TextField, `TextInputAction.unspecified` on iOS so the return key stays neutral; `onSubmitted` creates the task and closes Create task on success (no "Add another", ED-152). Never `TextInputAction.done` on Add (ED-030). Android keeps the IME check action; Mac Return, web Enter.
- **Tests still outstanding (PENDING):**
  - [ ] Return key neutral (not blue) on iOS 16, 17, 18 and 26, on a device.
  - [ ] Return creates the task and closes Create task on success; on failure nothing is cleared or closed; pasted list goes to the proposal (full screen, ED-150).
  - [ ] VoiceOver announces the return key and the Add button; hardware keyboard Return adds on iPad.
  - [ ] The system keyboard of each iOS version is used as is (16–18 and 26 look different); no custom keyboard.
  - [ ] Dismissal (ED-136): swipe down / drag content hides the keyboard first and keeps the sheet and draft; tap outside the field hides it; Return adds; VoiceOver scrub; Esc on hardware keyboards; Android Back hides the keyboard before closing the sheet. Flutter: `keyboardDismissBehavior: onDrag` on the sheet's scroll view and a tap-outside handler; draft kept in the field's controller.
  - [ ] Steps: Return on a step with text adds and focuses the next step; Return on an empty new step drops it and hides the keyboard (no blank steps).
  - [ ] Active field stays above the keyboard on every iPhone size, with larger text, on iOS 16–18 and 26 (device).

## Full editor steps and notes (ED-137)
- [ ] Existing steps and notes render in the full editor below Repeat/Energy, in Full and Minimal (ED-145).
- [ ] Focusing or typing in a step or note scrolls that line above the keyboard (Flutter: `Scrollable.ensureVisible` / scroll padding from the keyboard inset); manual scrolling keeps working with the keyboard up.
- [ ] Verified on device: small iPhones, larger text, iOS 16–18 and 26, Android (PENDING).


## Create task as the Add screen (ED-139 to ED-142)
- **Approved visual design:** iPhone + opens Create task (detailed) with the title focused and the keyboard up; Task · Brain dump · Routine tabs; teal Create task in the header. Android FAB › Task opens a full-screen Create task with M3 segmented buttons. Minimal keeps its own Add sheet.
- **Brain dump and Routine (ED-147 to ED-149):** open full screen like Create task on iPhone and Android, same tabs / segmented buttons; Plan it and routine taps still go through the proposal, which also opens full screen (ED-150); nothing written before Accept.
- **Tab actions (ED-152, owner rules):**
  - [ ] Create task action exists only while the Task tab is selected (iPhone header button, Android top-bar Create); never visible, disabled, floating or duplicated on Brain dump or Routine.
  - [ ] Brain dump shows Plan it; Plan it builds a proposal and writes nothing; tasks are written only on Accept (Add to day), with the conflict, no-free-time and Inbox fallback rules. Test: nothing written before Accept.
  - [ ] Routine shows its own controls (Drop on, routines, preview, Edit routines…); nothing written before its confirm.
  - [ ] Switching tabs never writes, accepts or discards; each tab keeps its draft; unsaved-change safeguard on close.
  - [ ] No "Add another" control anywhere in Create task.
  - [ ] iPhone Brain dump / Routine header: Cancel only, no title (ED-153); Android keeps New task / Brain dump / Routine titles.
- **Tests still outstanding (PENDING):**
  - [ ] + to typing in ≤ 2 taps on iPhone and Android (R-06); natural-language time fills the time row.
  - [ ] Paste a list still goes to the proposal (R-07).
  - [ ] Tablets: Create task presentation decided in Round 2 (CR-127); not the phone screen by default.

## G3-9 · Task colour tokens (ED-155)
- **Approved visual design:** each task colour has `fill` and `ring` tokens. Ahead ring (and the icon inside it) = `ring`; done fill, past thread, overlap knot, now progress ring, Wake Up / Wind Down = `fill`. Ring ≠ fill for coral `#DF6147`, amber `#AF7E22`, sky `#338ED1`, green `#469763`; others ring = fill. Glyphs on an amber fill are ink `#241F2B`.
- [ ] `DotTheme` exposes `taskFill(colour)` and `taskRing(colour)` (and `onTaskFill(colour)` = ink for amber, white otherwise); no widget reads a raw hex.
- [ ] Golden: ahead rings ≥ 3:1 against `#FFFDF9` and `#FBF7F1`; amber done dot shows an ink check.
- [ ] State not by colour alone: hollow ring (ahead), filled + check (done), progress ring + "Now" (current) kept; semantics labels unchanged.
- [ ] PENDING: dark-mode `fill` / `ring` values (G4-6); user-selectable colour list (any new colour needs its own ring token ≥ 3:1).
- [ ] Owner decision pending on CR-133 contexts (faded preview, scrim, selected-swatch halo).
- [ ] ED-157: the in-progress arc and its icon use `taskRing(colour)`, not `taskFill`.

## G3-9b · Colour selection and Appearance (ED-161)
- **Approved visual design:** E-Phones-3, E-Phones (Colour and icon, Settings), E-FullA-v2 (Mac/web Settings Appearance, inspector popover).
- **Must ask before building (data):** `color_hex` (custom task colour) + `color_key = custom`; settings `accent_hex` and a synced "Your colours" list; extend allowed `color_key` with brown, plum, olive (existing keys and legacy mapping unchanged).
- [ ] `TaskPalette` with 12 colours + custom; `taskRing` / `onTaskFill` derived for custom colours; saved values never rewritten.
- [ ] All colours half sheet at the medium detent (iPhone `UISheetPresentationController` medium, Android partial bottom sheet); the screen above stays visible and re-themes live.
- [ ] App colour: derived button/link shade ≥ 4.5:1; existing tasks unaffected.
- [ ] Appearance: preview pinned; Layout switch animates Everything ↔ Less (reduced motion: instant); tab bar hidden only while a sheet is up.
- [ ] Mac: Custom colour… popover; eyedropper via the native colour sampler; "Show Colours…" opens NSColorPanel. Web: EyeDropper API only where supported.
- [ ] PENDING: VoiceOver / TalkBack names for every swatch and custom colour ("Custom colour, peach"), contrast of derived shades on device, dark mode (G4-6), tablets (Round 2).

## G3-10 · One vocabulary (ED-162)
- **Approved copy:** Low-energy mode · Brain dump · Review · Today (screen) / Day (menu) · Need more time? (question) / Need More Time… (opens +5 / +15 / +30) · Delete (phones, web) / Move to Trash ⌘⌫ (Mac menus). Mac application menus in Title Case (Low-Energy Mode, Brain Dump…, New Brain Dump…).
- **Do not rename internals:** l10n keys `runningLate`, `runningLateBy`, `snackRunningLate`, `snackRunningLatePartial` keep their names; their English values change to the approved wording (other locales follow translation). Command identifiers, routes (`/review`), database fields and persisted values unchanged.
- **Verified in the original app (read-only, 2026-11-07):** Trash keeps deleted tasks 30 days (`docs/05-data-model.md` trash view, PRD F7.6, `trashServiceProvider.purgeExpired`), Undo for 30 s (M2.5); copy "It goes to Trash for 30 days. You can undo right after." Delete and Move to Trash use this one workflow.
- [ ] String audit: no "Running late", "Reviews", "Gentle Day", "Low-energy day" in any locale's visible strings (de/fr/es translations of `runningLate` currently say "I'm late" equivalents: retranslate).
- [ ] Mac menu titles use Title Case; phones and web use sentence case.

## G3-11 · Need more time amounts (ED-163)
- Exactly +5, +15, +30 minutes on every platform and mode; reuse the built extension path (`runningLate*` l10n keys and the existing extend/shift logic). No new amounts, no auto-apply.
- [ ] Widget test per platform shell: three choices present, each with semantics label "Extend task by N minutes".
- [ ] Test the chosen amount is applied exactly once (double tap does not extend twice) and keeps the task's date.
- [ ] Phone chips ≥ 44 pt; golden at 200 % text shows the chips wrapping, not clipped.
- [ ] ⌘K: one "+15 min" quick command; the others via Need More Time….
- [ ] Tablets: covered by Prompt D Round 2.

## G3-12 · Earlier fold (ED-164) · design requirement, not built
- Minimal Today (phones), Minimal Day column (Mac, web) and the Full Mac/web Day column: done tasks before now fold into one "Earlier" disclosure row; no count. Replaces today's built minimal behaviour (done tasks in place, struck) for those surfaces; Full phone threads unchanged.
- Presentation only: derive the group from existing completion and time; no new stored field. Expanded/collapsed is view state for the day (not synced, not persisted across launches).
- [ ] Widget tests: open past tasks never fold; no Earlier row when nothing is done before now; reopening moves the task back to its time and keeps date, current task and scroll.
- [ ] Semantics tests: "Earlier, done tasks" + expanded/collapsed; no number in the label; reopen announcement.
- [ ] Keyboard (Mac, web): Tab reaches it, Space/Return toggle, Mac → / ←; focus ring.
- [ ] Reduced motion: rows appear without sliding. Goldens: collapsed, expanded, reopened, none, at 200 % text.
- [ ] Policy: the `FeatureId`/doc 14 §3 row for Today is unchanged (still Shown/Simplified); add the fold to the minimal Today widget test that enumerates controls (doc 14 §7).
- [ ] Tablets: Prompt D Round 2.

## Group 3 follow-ups (ED-165) · design requirements, not built
- [ ] Minimal accessible names: no done or ahead counts, totals or percentages (horizon, now-dot, headers); a semantics test asserts there is no number-of-tasks wording in Minimal.
- [ ] Every sheet drawn over a dimmed backdrop is modal: the background is excluded from touch and from screen readers (iOS `accessibilityViewIsModal`, Android dialog semantics, web `aria-modal` and inert).
- [ ] A selected colour swatch shows a check glyph at 3:1 or better (white or ink per ED-161), as well as the halo; golden for coral and the pale colours.
- [ ] Hit areas 44 pt / 48 dp for tip dismiss, the Android Day button and date chips, with drawn sizes unchanged; check native toolbar buttons on a device.
- [ ] Colour data: no change authorised; see `E_COLOUR_DATA_REVIEW.md` before any palette or key work.

## G4-1 · Round 2 order (ED-166)
- Planning only. Round 2 draws: core journey → interaction and recovery → supporting experiences. Nothing is built from this decision.

## G4-2 · Breakpoints and the docked editor (ED-167) · approved strategy, not built
- Keep `WidthClass` 600 / 840. Change the editor panel to dock only from 1160 window width, and only when the minimum widths hold (values pending M). Below that it floats over Today.
- [ ] Widget tests: resizing across 1160 (both directions) keeps the same editor state (text, fields, steps, notes, focus, scroll); nothing is saved; an open proposal is not committed; the selected task and date are unchanged; no second editor.
- [ ] Goldens at 599/600, 839/840, 960, 1099/1100, 1159/1160 and 1280, plus 200 % text.
- [ ] H1 (ED-168): a layout decision from usable height (after safe areas, ignoring the keyboard's `viewInsets`) under 480 → compact; never dock. Tests at 874 × 402, 915 × 412, 667 × 375, 1280 × 460 (web keeps web chrome), a foldable tabletop half, and Split View; check the keyboard opening and closing causes no class change and no editor reset.
- [ ] M (ED-168): docking predicate = width ≥ 1160 AND width − sidebar − dividers − gutters − editor ≥ Today minimum (480, or 600 when text scale > 1.3). Unit-test the predicate at 100 / 130 / 200 % on both sides of each boundary; no hardcoded 1236.
- [ ] Mode safety: class or presentation changes never switch Full/Minimal.
- [ ] Tablets: G4-4 / Round 2.

## G4-3 · Mac minimum window (ED-169) · design only, not built
- When implementation is authorised: `contentMinSize` 840 × 640 (today 960 × 640); keep the 1280 × 800 opening size.
- [ ] At 840–1159 the editor and inspector float; check the week grid keeps Today in view.
- [ ] Minimal Day-column fold (ED-170): compute the fold point from the measured Now minimum + Day column 290 + sidebar 200 + dividers at the current text scale (not a constant). Folded: a 44 px "Day" edge button (`Semantics(button, expanded)`, tooltip, no shortcut) toggles one Day-column instance shown as a non-modal panel; Esc and ✕ close it; focus returns to the button. ⌘1–⌘4 and ⌘K unchanged.
- [ ] Narrow toolbar: hide the status text below ≈ 1000; the "Search or run" icon keeps ⌘K and its accessible name; the Search screen stays ⌘4.
- [ ] Short window: under 720 tall, the now-dot at ≈ 72 %; above 130 % text keep full size, no numeral growth, the pane scrolls.
- [ ] C1 (a): `WorkspaceInspector` (248) and `TaskEditorPanel` (420) are separate widgets with separate docking predicates; the inspector docks at ≥ 1160 when grid ≥ 476 (3 days).
- [ ] Resizing with unsaved edits: no save, no loss, no mode change. VoiceOver order and Tab order at 840 and 1042.

## G4-4 · Tablet navigation (ED-171) · strategy only
- Shell by window width class plus H1. iPad: iPadOS adaptive tab bar → sidebar and split views (no Material rail). Android: `NavigationRail` at medium, sidebar at expanded, the approved compact bar at compact; hinge-aware (`displayFeatures`).
- [ ] Not buildable until Round 2 draws the tablet screens and they are approved.

## G4-5 · Mobile web (ED-172) · approved strategy, not built
- Compact web shell: its own bottom bar (no `CupertinoTabBar` look, no Material frosted toolbar). Full: Today · Inbox · Calendar · Search; Minimal: Now · Today · Inbox; Add above it.
- Routes unchanged (ED-097, hash). `?task=` guard per D2 when built.
- [ ] Tests (web): Back/Forward/refresh restore view, date and task; closing a task removes `?task=` (Back step or replace as ED-097); resizing across 600 replaces the entry; unsaved edits survive reflow.
- [ ] The bottom bar hides when the keyboard is open (`visualViewport`); fields, Add and actions never covered; safe-area insets; screen-reader landmarks; single-key shortcuts can be turned off.
- [ ] No custom edge-swipe; the browser's Back gesture works.

## G4-6 · Dark mode (ED-173 to ED-181) · approved design, not built · also ED-183 (text fit) and ED-184 (Plan panel)
- Approved P1 tokens (rules §10): add a Concept E dark `DotColors` alongside light; do not recolour the old dark theme.
- Task colours (ED-175, frozen): dark values per the rules §10 table, used for the ahead ring, now arc and done fill; checks in ground ink. Persisted keys unchanged; brown, plum and olive keys unapproved.
- iOS switch on tint: #2A8C83 dark, #11615C light. Focus ring with a 2 px gap.
- Mac (ED-176): NSVisualEffectView `.sidebar` dark + #3B2F2A at 30 %; selected row label #F3ECE4, teal pill, selected icon #A3E2D9 (I1). Light keeps #EFE7DB at 35 %.
- Detail tokens (ED-177, ED-178 final): caps, now-dot (no shadow), thread #6B6369 dotted, knot and now-bead as in rules §10.
- [ ] Golden pairs light/dark for every screen, using the `-Dark` boards as references.
- [ ] Theme switching (Light · Dark · Auto) keeps editor state, proposals, task, date, navigation and mode; widget tests switch theme with an open editor.
- [ ] Device: glass dark, Reduce Transparency, Increase Contrast, VoiceOver and TalkBack. Web: `color-scheme` and `theme-color` set before first paint.
- [ ] ED-186 / rules §12.4 (pending visual approval): one state kit; sync status from `SyncStatus` (state, pending, conflicts, clockSkew) shown as icon + words; map expired session during sync to "Sign in again" (CR-158); request persistent web storage on sign-in (CR-159); keep the draft open on StorageFailure and retry the same write; conflict cards as drawn; optional Undo after resolving (Q3). Tests: announcements (polite/assertive), largest text without truncation, Reduce Transparency/Increase Contrast swaps, offline web after first visit.
- [ ] ED-184 / rules §9.16: Plan panel as a collapsible split pane (Mac NSSplitViewItem-style behaviour in Flutter: toolbar toggle, View menu ⌥⌘P, drag to collapse, auto-hide below 3 visible days, overlay when hidden with pin/Esc), folding Inbox/Routines/Brain dump sections with remembered state; web ⌘K command. Widget tests: toggle, auto-hide at 840, overlay focus return, persisted state.
- [ ] ED-183 / rules §12.3: controls never wrap or clip (single-line labels, controls size to them); toolbars collapse items into pop-ups/menus when short of room; fixed-size blocks end titles with an ellipsis and keep the full text in the semantics label and tooltip; menus stay inside the window. Add golden and widget tests at the narrowest width and at 200 % text that fail on overflow (Flutter overflow errors, no clipped text).
- [x] Stage 2 screens approved (ED-180); dark companions of every active board drawn (ED-181). Build dark from the `-Dark` boards and rules §10.
- [ ] ED-181: blurred shadows stay dark (no light glow); scrims black; custom colours get a derived dark shade at draw time (≥ 4.5:1 text, ≥ 3:1 rings), never stored; system chrome follows the platform dark appearance.
- [ ] ED-179: the dotted ahead thread picks #6B6369 on the ground and #7B7279 on lighter surfaces (surface, raised, sheet, tinted rows); add a test that every thread colour reaches ≥ 3:1 on its parent surface. Placeholder text token #6F6978 (light) / #A0999F (dark); hex-field "#" prefix uses secondary text.

## G4-7 Q2 · Persistent browser storage (ED-188 to ED-192) · design CLOSED, not built

- **Status:** approved behaviour specification (web only). **Implementation not done** and not authorised by this file. CR-159 stays OPEN · implementation. No design change: no board, layout, wording or component changes; no custom permission screen.
- **Where it fits (read-only audit, 2026-11-08):** web keeps tasks in an encrypted SQLite database over drift's IndexedDB file system (`app/lib/data/db/connection/connection_web.dart`, key in `data/db/web/key_vault.dart`, one tab at a time via `tab_lock.dart`). Nothing calls `navigator.storage` today. The request belongs in the web data layer behind a small interface so tests can fake it; exact file layout is an implementation choice.

### Behaviour
1. **When:** after sign-in succeeds and the local database has opened, off the first-paint path. Never before sign-in, never as a gate.
2. **Check first:** call `navigator.storage.persisted()`. If it returns true, stop; do not request.
3. **Request once:** otherwise call `navigator.storage.persist()` at most once per browser profile per signed-in account. Record that the request was made (and the answer) locally, so it is not repeated on every launch.
4. **Later launches:** `persisted()` may be re-checked silently on launch (it never prompts). `persist()` is not called again, except once after the web app is installed to the home screen or dock (installation can change the browser's answer). Any other re-ask needs an owner decision and a user action; none is designed.
5. **Answers:**
   - Granted: nothing visible changes. Wording stays "Saved in this browser".
   - Denied: nothing visible changes; Dottoday works normally. No retry prompt, no nag.
   - Unsupported (`navigator.storage` or `persist` missing, insecure context, older browser): skip silently; works normally.
   - The call throws or never resolves: treat as unsupported; log the outcome code only (no task text).
6. **Never:** block any screen on the answer; describe it as a guarantee against data loss, as sync or as a backup; change "Saved in this browser" to "Saved on this device".

### Truthful states (unchanged wording, rules §12.4)
- Saved locally → "Saved in this browser" only after the local write succeeded.
- Waiting to sync → the existing waiting count ("2 changes waiting to sync").
- Synced → only after the server confirms.
- Couldn't save / storage unavailable → the existing "couldn't save" error (`failureStorage`), draft kept; never a saved message.
- Clearing this site's data can remove work that has not synced. **Designed (ED-189, awaiting visual approval):** web Sync details, E-G4-7-States Q2a–Q2d. Strings to add (none exist in `app_en.arb` today): the "In this browser" line, the three storage lines (kept / isn't kept / can't be asked) and the caution card heading and body exactly as in ED-190 (the ED-189 caution text is superseded).
- Tests for the warning: the caution card shows only while changes wait to sync; the storage line matches the stored browser answer; the trigger and dialog have the screen-reader names in the board notes; 200 % text wraps with Sync now reachable.

### Browser support (to confirm at implementation time against current browser docs)
- **Chrome, Edge and other Chromium browsers:** support both calls. No prompt; the browser decides from its own signals (for example an installed app, a bookmark, site engagement), so "denied" is common for a new site.
- **Firefox:** supports both calls and may show its own permission prompt. That prompt is the only UI.
- **Safari (macOS, iOS, iPadOS):** supports both calls in recent versions; decides without a prompt. Safari can still remove data for sites not used for a while unless the web app is added to the Home Screen or Dock; persistence lowers but does not remove this risk.
- **Private / incognito windows:** storage is cleared when the window closes regardless of the answer.

### Tests required (none run yet)
- Unit tests with a fake storage interface: already persisted (no request), granted, denied, unsupported, throws, never resolves (timeout).
- No-repeat test: after one request, later launches do not call `persist()` again (except once after install).
- Status tests: web shows "Saved in this browser" for granted, denied and unsupported; "Synced" only after server confirmation; a failed local write shows the couldn't-save error, never a saved message.
- No-blocking test: sign-in and Today render with the request pending, denied or failing.
- Logging test: only outcome codes are logged.
- Manual browser matrix: Chrome, Edge, Firefox (allow and block the prompt), Safari on macOS, Safari on iOS (in the browser and added to the Home Screen), and a private window. In each: sign in, add a task offline, reload, confirm the task and wording; confirm no repeated prompt across reloads.

### Not signed in (Q2-W1, ED-192) · requirement, not built
- **Status:** "Not signed in · saved in this browser" only after the browser save succeeded; never "Synced", "Saved to your account" or "Saved on this device". A failed save shows the existing "Couldn't save".
- **Warning:** Sync details card "Only saved in this browser" (E-G4-7-States Q2e, Q2f) and a Sign in button using the existing sign-in flow. New strings needed (none exist today).
- **Persistence:** also request after the first successfully saved guest change: check `persisted()` first; call `persist()` once, at a user-action moment (the save); handle granted / denied / unsupported; never block or retry-prompt; the storage line says "Asked after your first saved change". Private / incognito windows lose data on close regardless.
- **Guest-to-account (CR-160), must hold before the copy "Sign in to keep a copy on your account." is added:** signing in never discards, duplicates or overwrites guest work. Today: adoption works and is unit-tested; untested when the account already has data; the guest's profile settings overwrite the account's; seeded tasks and routines can duplicate; after sign-out a different account receives the previous account's rows.
- **Tests required (none run):** guest save → status wording; failed save → error; first-save persistence request once (granted, denied, unsupported, throws); sign-in with an empty account; sign-in with an account that has data on another device (no lost, duplicated or overwritten tasks; settings choice explicit); sign-out then a different account (no upload of the previous account's data); web end-to-end on Chrome, Firefox and Safari, plus a private window.

## CR-160 · Account ownership and switching · CRITICAL privacy/security · RELEASE BLOCKER (ED-193)

- **Status:** OPEN · not fixed, not verified. Raised by the read-only audit of 2026-11-08 (ED-192), escalated by the owner (ED-193). The account-switching flow is **not safe** until every criterion below passes with recorded runs. Production implementation still needs separate authorisation.
- **The defect:** sign-out keeps local rows under the old account id. When a different account signs in on the same device, `adoptAccount` (`app/lib/data/sync/account_adoption.dart`) re-keys the device profile and, through the cascade, every row to the new account; because the device previously synced with another account it also runs `requeueAll`, so the first person's tasks are uploaded into the second person's account.
- **What existing tests prove, and do not:** `sync_engine_test.dart` "signing in re-keys the device profile, its rows and outbox" proves the simple guest → new account path re-keys rows. "another account: everything on the device goes up again" asserts the leaking behaviour as intended. Neither proves any scenario below is safe.
- **Never as a workaround:** silently deleting unsynced work (on sign-out, on switch, or on failed migration).

### Acceptance criteria (all must pass before account switching is considered safe)
1. **Strict ownership.** Every locally stored record and every pending outbox entry belongs to exactly one owner (guest profile or one account). Nothing is re-keyed from one account to another; only an explicit guest → account migration may change an owner, and only from a guest owner.
2. **Safe sign-out.** Signing out stops sync for that account; its local rows and pending changes stay attributed to it and are not visible to, editable by, or uploadable for anyone else. If unsynced changes exist at sign-out, the person is told and offered to sync first or keep them on this device for that account (wording to be designed when implemented; no silent loss).
3. **Safe account switching.** Signing in as account B on a device that holds account A's data never uploads, shows or merges A's records or outbox into B. A's data stays attributed to A and syncs only when A signs in again (or is removed only through an explicit, confirmed, recoverable action by A).
4. **Unsynced data preserved without leaking.** A's unsynced changes survive B's session intact and upload to A when A signs back in, with no loss and no exposure to B.
5. **Guest → new account.** All guest tasks, steps, routines and settings move to the new account exactly once; nothing lost, nothing duplicated.
6. **Guest → existing account.** Guest work is added to the existing account without overwriting the account's tasks; field-level conflicts follow the normal conflict flow (G4-7 C), never "local wins" silently.
7. **No silent settings replacement.** The account's existing profile settings (time zone, language, preferences) are never replaced by the guest's without the person choosing; the choice is explicit and the default keeps the account's settings.
8. **No duplicate starter content.** Onboarding seeds, starter routines and reveal hints are not duplicated by migration or by signing in on a second device (stable ids or de-duplication).
9. **Interrupted or failed migration.** A crash, network loss or error mid-migration leaves a consistent, resumable state: the migration is transactional or idempotent, retries do not duplicate, no record ends up with no owner or the wrong owner, and the person sees an honest status (existing error state) with Try again.
10. **Web end-to-end.** On web (encrypted IndexedDB, one tab), the full guest → new account, guest → existing account, sign-out → other account, and interrupted-migration flows pass end to end, including reload mid-migration and a second tab.
11. **Shared-device tests.** iPhone, Android, Mac and web each run: A signs in, adds tasks offline, signs out; B signs in; verify server side (RLS-scoped queries) that B's account contains none of A's data and A's account receives A's pending changes after A signs back in.
12. **Server-side guard.** Supabase rejects or quarantines writes whose rows were created under a different owner than the authenticated user (RLS and/or an Edge check), covered by pgTAP tests, so a client defect cannot leak data.

### Required tests (none run)
- Unit: ownership on every write path; adoption only from guest owner; requeue never crosses owners; migration idempotency and resume.
- Integration: each criterion above, including existing-account merge, settings choice and seed de-duplication.
- Web end-to-end and shared-device runs on all four platforms, with server-side verification.
- Security checklist `docs/06-security.md` §9 item "Signing out and in as another account never uploads or shows the previous account's data" must pass at `/ship-check`.

## G4-7 Q3 · Undo after resolving a sync conflict (ED-194) · approved design, not built

- **Status:** design APPROVED. Implementation and real-device testing PENDING (CR-161). Production implementation not authorised by this file.
- **Today (read-only audit, ED-186):** conflicts are last-write-wins per field within 60 s, recorded in a conflicts table; Keep mine / Keep theirs is final; no Undo.
- **Behaviour:**
  - After the choice, a confirmation names what was kept ("Kept this device's time") with Undo for about 10 s.
  - Undo writes the replaced value as a new ordinary edit (new HLC clock, normal outbox) for that one field only.
  - Before writing, compare the field's current version with the version at resolve time; if another device changed it since, do not write: open the normal conflict review.
  - Keep both values (and task id, field and versions) until the Undo window closes.
  - Show success only after the local write commits.
- **Platforms:** phones: bottom confirmation (C3). Mac/web: Sync popover (C5) with ⌘Z / Ctrl+Z registered only while this Undo applies; never when a text field, editor or another Undo context has focus; native Undo menu item on Mac reflects it.
- **Accessibility:** pause on focus or hover; dismiss by Close, Escape, swipe or screen-reader dismiss; when VoiceOver or TalkBack is on, no auto-dismiss; announce the confirmation politely once; Undo reachable at 200 % text; no visible countdown or ticking animation; Reduced Motion honoured.
- **Data safety:** idempotent resolve and Undo (same operation id; a repeated tap or retry applies once); no duplicate tasks or repeated edits; never overwrite newer remote values; offline Undo saves locally and syncs later; if the save fails, say "Couldn't undo" with the existing error pattern and keep both values; if sync later fails, the edit stays queued with the existing status; records stay with their owner (CR-160 rules apply).
- **Tests required (none run):** unit (version check, idempotency, field isolation); integration (Undo offline, Undo after remote change → conflict review, double tap, app killed mid-Undo); widget and semantics tests for the confirmation (focus pause, screen-reader persistence, 200 % text, Reduced Motion); keyboard tests for ⌘Z / Ctrl+Z precedence; device runs on iPhone, Android, Mac and web.

## G4-7 Q4 · Keep both for conflicting notes (ED-195) · approved design, not built

- **Status:** design APPROVED; implementation and tests PENDING (CR-163). Board E-G4-7-Q4-KeepBoth. Production implementation not authorised by this file.
- **Scope:** only when the conflicting field is `notes`. Titles keep two choices; never create a second task. No other field gets Keep both.
- **Data (read-only check):** notes are plain text with a 10,000-character limit locally and on the server; conflict rows store `mine`, `theirs` and `created_at` only. No schema change needed. Do not add a timestamp or device name to the label: the app does not store them.
- **Combination:** `mine + "\n\n— From your other device —\n" + theirs`, exact text otherwise (line breaks kept; no trimming, de-duplication or reordering). If `mine` is empty, the result is the label line and `theirs`; if `theirs` is empty, Keep both is the same as Keep mine (still allowed, no label added). Label string goes through l10n.
- **Limit (Q4-L1, approved ED-196):** compute the full combined text and validate it with `checkOptionalText(ValidationField.notes, …, max: maxNotesLength)` (Dart `String.length`, UTF-16 units). UTF-16 length ≥ code points, so passing it guarantees the SQLite `length()` and Postgres `char_length` checks. If it fails: Keep both disabled with `aria-describedby` / semantics hint pointing at "Keep both isn't available · Together, these notes exceed the 10,000-character limit. You can copy either version before choosing which one to keep."; Copy on each version (system clipboard, announces "Copied"); both versions fully readable and scrollable; Keep mine / Keep theirs stay enabled; conflict stays open; never trim. Tests: exactly at and one over the limit, with emoji, ZWJ sequences and flags (UTF-16 vs code points vs graphemes).
- **Write path:** one ordinary notes edit (new HLC, normal outbox) with an operation id so repeated taps or retries apply once. Before writing, check both versions are still the ones shown; if either changed, re-open conflict review. Mark the conflict resolved only after the local write commits. Offline: commit locally, sync later. On failure: existing "Couldn't save", conflict stays open, both values kept.
- **Undo (Q3):** restores `mine` only if the note still equals the combined text; otherwise conflict review. Only the notes field changes.
- **Accessibility:** each version is a labelled group read in full; Keep both has the hint "Adds the other device's notes below yours"; focus order Keep mine → Keep theirs → Keep both; phones stack; Mac/web row stacks at narrow widths and 200 %; Return activates the focused choice.
- **Ownership:** records stay with their owner (CR-160, not yet verified).
- **Tests required (none run):** combination format (empty, multi-line, Unicode, exactly 10,000 and 10,001 characters); idempotency; changed-version re-review; offline and failed save; Undo with and without a later edit; title conflicts never show Keep both; widget and semantics tests for the three platforms' cards at 200 %; device runs.

## ED-196 · Colour corrections and a counting finding · approved design, not built

- **CR-162:** in dark, task-type icons and done checks inside amber #D9A23A dots use ink #171416 (8.0:1). In code: wherever the dot glyph colour is chosen, amber takes ink in both themes. Device accessibility tests PENDING.
- **Q5:** light Android "What is it?" placeholder #6A6473 (dark #A0999F). Applies to the Android Create task title field only.
- **CR-164 (implementation):** notes length is counted three ways (editor graphemes, validator UTF-16, databases code points). Make the editor and every write path use the validator's rule so the editor never accepts a note the database rejects. Not a design change. If a save is still rejected, never discard text: keep the whole draft in the editor and show the existing truthful error. Regression tests: emoji, ZWJ sequences, flags and combining marks at 9,999 / 10,000 / 10,001 by each count.
- **Cleanup 9b (ED-197):** Mac context menus are native NSMenu; the drawn 8 / 10 px radius is not a build value.

## Cleanup item 2 · Now-ring recipe (ED-198) · approved design, not built
- Draw the now-ring from one function: track = task colour at 20 % (light) / the dark arc colour at 25 % (dark, ED-174, boards aligned ED-212); arc = the task family's ring token (e.g. teal #289588 light); cut-out 5 px on phone layouts, 4.5 px on wide; 4 px for legend, horizon and "Also now" sizes. No fixed lavender track. Tests: golden per width class and theme; every task colour; arc ≥ 3:1 on the surface.

## Cleanup item 3 · Ahead-ring width (ED-199) · approved design, not built
- One dot function takes the layout class: phone 4 px, wide 3.5 px; any dot ≤ 16 px uses 2.5 px. Drawn as an inset stroke so the diameter never changes. Goldens per width class, theme and size.

## Cleanup item 4 · Calendar-event dot (ED-200) · approved design, not built
- The calendar dot paints its centre with the colour of the surface it sits on (row, column or grid block; never a fixed white) so it stays opaque over the thread; ring `tertiary` (#7A7280 / dark #8C838A) 2.5 px standard, 2 px when ≤ 16 px. Goldens in light and dark on each surface.

## Cleanup item 5 · Thread caps (ED-201) · approved design, not built
- The Wake Up and Wind Down caps on the thread use the task-dot diameter of that thread (34 px) with a 19 px icon; settings and schedule-row caps are separate widgets with their own sizes.

## Cleanup item 6c · Now card radius (ED-202) · approved design, not built
- One Now card shape: radius 24 on every platform; min height 80 (iPhone) / 82 (Android). Goldens on both phones, light and dark.

## Cleanup 7a and 7b · Task text font in phone editors (ED-204) · approved design, not built
- Android: Minimal Add input Manrope 600 20; Edit task title and Create task title Manrope 700 24/30 (as iPhone). Native TextField / EditText behaviour stays: Gboard, selection handles, cursor, IME actions, autofill and TalkBack are the platform's; only the text style changes.
- Large text: the title field scrolls within the editor header with the cursor in view, or the header grows and pushes content; never clipped. Tests at 100 / 130 / 200 % on both phones with a long title.

## Cleanup item 8c · Device status tag "Alarms off" (ED-205) · approved design, not built
- The alarm device picker's "Alarms off on the chosen device" status is a neutral tag (surface `#F1ECE4`, text `#4E4757`; dark `#2F2A30` / `#C7BEC4`) with a bell-off icon (light `#986C1C`, ED-213 refinement; dark `#D9A441`), placed before the unchanged text "Alarms off for Dottoday · fix it on the iPad". No new warning token.
- The icon scales with the text and sits on the first line when the tag wraps; the tag wraps within the row at large text and never clips. The icon is excluded from semantics; the row's label includes the status text, so state never depends on colour.
- Tests: golden in light and dark at 100 % and 200 %; semantics test for the row label; VoiceOver and TalkBack device runs PENDING. Light icon refined to `#986C1C` (ED-213).

## Cleanup item 10 · Mac and web Day button font (ED-206) · approved design, not built
- The Day ▾ button in the Mac toolbar / Day column and the web toolbar uses the platform's interface font at 13 / 500: on macOS the system font (or the native NSToolbar pull-down item, whose own text style is used); on web `system-ui, -apple-system, 'Segoe UI', sans-serif`. Not Manrope. Colours, surface, border, radius, chevron, padding and heights (30 Mac, 32 web) unchanged.
- The mobile-web Day chip (Manrope 14/700) is a separate component and keeps its style.
- The label scales with text size; the button grows rather than clipping. Tests: golden per theme on Mac and web at 100 % and 200 %; keyboard focus and the menu's accessible name ("Day menu") unchanged.
- Separate, still pending: the E-Minimal web primary Add uses the accent teal `#11615C` (CR-010).

## Cleanup item 11 · Minimal sidebar width (ED-207) · approved design, not built
- One sidebar width constant per mode, shared by Mac and web: Full 216, Minimal 200. No platform branch; layout follows the width class (CLAUDE.md §11). Row heights stay platform chrome (Mac 32, web 36).
- In the Minimal web layout the Now pane takes the remaining width before the Day column (Day column 510 at 1280). Tests: goldens of the Minimal Mac and web shells at 1280 and the G4-3 narrow widths, light and dark; sidebar labels and the keyboard hint at 200 % text wrap without clipping.

## Cleanup item 12 · Repeat marker (ED-208) · approved design, not built
- One `RepeatMarker` widget: the repeat icon in the current text colour, 12 px after the time in timeline rows and lists, 10 px after the title in week/month blocks; scales with text. Never the ↻ character or a "· repeats" suffix.
- Semantics: rows and blocks whose label already says "repeats" exclude the icon from semantics; a standalone marker has the label "repeats" (localised). Schedule text ("repeats on weekdays") is separate content.
- Tests: semantics test that "repeats" is announced exactly once per row/block; goldens of a row and a week block in light and dark at 100 % and 200 %.

## Cleanup item 14 · Wide Now card (ED-209) · approved design, not built
- The Minimal Day-column Now card is one component on Mac and web: min height 68, radius 18, time and "Now, N min left" in the 12.5 px numeric style, title Manrope 16/700. It grows with text size instead of clipping. Phones keep their own Now card (ED-104, ED-202).
- Tests: goldens of the Day column on Mac and web at 1280, light and dark, 100 % and 200 %.

## Cleanup item 15 · iPhone glass elevation (ED-210) · approved design, not built
- One `GlassElevation` token set with five tiers (sheet, topRow, dayChip, floatingBar, overlay) and the values in rules (ED-210), per theme. Native controls (tab bar, Day ▾, system menus) keep the system shadow and are not drawn by Flutter. Reduce Transparency: solid surface, same tier shadow.
- Tests: goldens per tier, light and dark; Reduce Transparency variants.

## Cleanup 9c and 10 (Add) · Web focus ring and primary Add (ED-211) · approved design, not built
- Focus ring on web (and keyboard focus on Mac where Flutter draws it): one `FocusRing` decoration, 2 px solid `accent` ring (dark `#7FD6CB`) after a 2 px gap of the surface behind; shown on keyboard focus only (`:focus-visible` semantics). Never an alpha ring.
- The primary Add button uses the `accent` token on every platform (light `#11615C` + white; dark `#5BC4B8` + `#171416`).
- Tests: keyboard-focus goldens on web and Mac for a pill button, a menu button and a timeline block, light and dark; contrast check ring vs surface ≥ 3:1.

## CR-165 (2) · Selected sidebar row secondary text (ED-214) · approved design, not built
- In the Mac/web sidebar, a selected row's trailing secondary text (shortcut hints such as ⌘3) uses `textSecondaryStrong` `#4E4757` in light; unselected rows keep `#6A6273`. Contrast test on the selection tint ≥ 4.5:1. The Week Today column header's secondary label uses the same colour (ED-215).

## Minimal task sheet title (ED-216) · approved design, not built
- The Minimal task sheet header shows the task name in Manrope 800 21/26 beside the 44 px dot on both phones (read-only; editing uses the 700 24/30 field). It wraps to more lines at large text instead of truncating, keeping Close reachable.

