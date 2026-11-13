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
5. **Open decisions needing the owner:** G4-7 Q2 warning visual approval (ED-189) and Q2-W1, then Q3–Q5 (next: Q2 warning; option A ED-186, Q1 direction ED-187 and Q2 web storage ED-188 approved; the conflict Undo is not built and not approved); 13 OWNER items in `E_CLEANUP_BATCH.md`; CR-143 (Day-column key); CR-154 to CR-156; colour data choices in `E_COLOUR_DATA_REVIEW.md` (needed before build, not before design). Prompt D Round 2 not started (tablet coverage checklist first, ED-090).

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

## G4-7 Q2 · Persistent browser storage (ED-188) · approved behaviour, not built

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
- Clearing this site's data can remove work that has not synced. **Designed (ED-189, awaiting visual approval):** web Sync details, E-G4-7-States Q2a–Q2d. Strings to add (none exist in `app_en.arb` today): the "In this browser" line, the three storage lines (kept / isn't kept / can't be asked) and the caution card heading and body, exactly as in ED-189.
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
