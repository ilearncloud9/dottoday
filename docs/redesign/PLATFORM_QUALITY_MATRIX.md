# Platform quality matrix

This file tracks how native and how good each platform is, under `DESIGN_PRINCIPLES.md` and the guide `references/platform-guidelines/premium-native-experience.md` (§ numbers below refer to the guide). Nothing has been assessed yet:
- Prompt B fills the baseline: only cells with evidence are filled (2026-11-03). Evidence and the reason for each `B: FAIL` are in `PLATFORM_BASELINE.md` §9, `UX_AUDIT.md` and `ARCHITECTURE_AUDIT.md`. The §7 scorecard stays empty until Prompt D scores the concepts against it.
- **Prompt B verification levels:** every iPh and iPad runtime value is **simulator only**, every AndP and AndT value **emulator only**, and WebM is desktop-browser emulation at phone widths. No real device ran the redesign build. A FAIL marked `(code)` comes from reading the code. **Mac, iPad landscape and foldables are NOT VERIFIED (`NV`), never PASS.** Evidence list: `references/baseline/PROMPT_B_EVIDENCE.md` (screenshots local only).
- Prompts D, F and H update it for the concepts, the first slice and final QA.
- **Prompt F (M19.7, 2026-11-20):** `F:` values come from the first slice: the journey Today (Now in Minimal) → Add → Edit/reschedule → Complete → Change day → Reopen in Full and Minimal (`test/acceptance/`, widget level on every target; `integration_test/slice_journey_test.dart` on the iPhone and iPad simulators, the Android phone and tablet emulators, Chromium and WebKit, and the real Mac app), the six cases at three widths, and the device shots beside the boards. Simulator, emulator and widget evidence is marked as such; no real iPhone, iPad or Android device ran it (no dev flavour). The journey walked the six core steps only: an invalid entry, a mid-flow theme or text-scale switch and background/resume were not walked. `FAIL → fixed` names what the slice found and fixed (ED-417).

**Targets:** iPh = iPhone · iPad · Mac · AndP = Android phone · AndT = Android tablet/foldable · WebD = desktop web · WebM = mobile web.

**Cell values:**
- `—` not assessed yet
- `PASS`
- `FAIL` (link the evidence)
- `NV` not verified (say why: no device, simulator only, …)
- `N/A`

Each cell is `phase: value`, e.g. `B: FAIL`, `H: PASS`. A finding means a real screenshot, recording, test or device note under `references/`. Simulator-only evidence is marked as such.

**Rule:** a platform's score is never averaged away (guide §21). One P0/P1 on one platform blocks the release.

## 1. Native behaviour

| Check (guide §) | iPh | iPad | Mac | AndP | AndT | WebD | WebM |
|---|---|---|---|---|---|---|---|
| Primary navigation shell matches platform expectation (§9) | B: FAIL · F: PASS (sim; UIKit tab bar) | B: FAIL · F: PASS (sim; top tabs) | B: FAIL (code) · F: PASS (real app) | B: PASS · F: PASS (emu) | B: PASS · F: PASS (emu) | B: PASS · F: PASS (Chromium, WebKit) | B: NV (browser emulation) · F: PASS (Chromium, WebKit) |
| Back/dismiss correct at every depth: edge-swipe · predictive Back · Esc/⌘W · browser Back/Forward (§13.3) | F: NV (not walked in the slice; M21) | F: NV (not walked in the slice; M21) | F: NV (not walked in the slice; M21) | F: NV (not walked in the slice; M21) | F: NV (not walked in the slice; M21) | F: NV (not walked in the slice; M21) | F: NV (not walked in the slice; M21) |
| Sheets/popovers/dialogs use the platform's temporary-flow form (§9) | B: FAIL · F: PASS (sim) | B: FAIL · F: PASS (sim) | B: NV (no Mac build) · F: PASS (real app) | B: PASS · F: PASS (emu) | F: PASS (emu) | F: PASS (Chromium, WebKit) | F: PASS (Chromium, WebKit) |
| Controls (switch, picker, menu, context menu, time picking) feel native (§3.3, §5.1, §6.2) | B: FAIL | B: FAIL | B: NV (no Mac build) | B: FAIL | B: FAIL | B: FAIL | B: FAIL |
| No foreign idiom by accident: ripple/FAB on iOS, iOS swipe-back on Android, mobile sheet on Mac (§3.5, §6.1, §5.1) | B: FAIL | B: FAIL | B: NV (no Mac build) | B: FAIL | B: FAIL | B: FAIL | B: FAIL |
| Text selection, editing, keyboard type/action, IME insets (§3.4, §6.3) | F: PASS (sim; Add, title focused) | F: PASS (sim) | F: PASS (real app) | F: PASS (emu) | F: FAIL → fixed in 7a (Minimal Add under the keyboard, ED-417); PASS (emu) | F: PASS (Chromium, WebKit) | F: PASS (Chromium, WebKit) |
| Keyboard shortcuts with platform modifiers; browser shortcuts not hijacked (§5.2, §8.1) | N/A | F: PASS (sim; ⇧⌘M, ⇧⌘T simulated) | F: FAIL → fixed in 7a (⇧⌘M after a click; ⇧⌘T on Now, ED-417); PASS real app, 2 of 3 runs | N/A | F: PASS (emu) (Ctrl+⇧ simulated) | F: FAIL → fixed in 7a (g on Now); PASS m, g (Chromium, WebKit) | N/A |
| Mac menu bar with live enabled state (§5.2) | N/A | N/A | — | N/A | N/A | N/A | N/A |
| Pointer: hover, cursor, right-click, ⌘/Ctrl/Shift multi-select (§5.3, §11.3) | N/A | — | B: NV (no Mac build) · F: PASS (click picks into the inspector; real app) | N/A | — | B: FAIL · F: PASS (Chromium, WebKit) | N/A |
| Haptics on meaningful events only, honouring settings (§3.3) | — | — | N/A | — | — | N/A | N/A |
| URLs: deep link, refresh, new tab, bookmark (§8.1) | N/A | N/A | N/A | N/A | N/A | B: FAIL | B: FAIL |
| OS integration: notifications, Wake Up alarm, share, widgets, menu-bar extra, Siri/App Intents (§16) | — | — | B: FAIL (code, A2) | — | — | — | — |
| Lifecycle: background/resume, process death, state restoration (§6.3, §11.4) | F: NV (not walked in the slice; M21) | F: NV (not walked in the slice; M21) | F: NV (not walked in the slice; M21) | F: NV (not walked in the slice; M21) | F: NV (not walked in the slice; M21) | F: NV (not walked in the slice; M21) | F: NV (not walked in the slice; M21) |

## 2. Responsive layout

| Check (guide §) | iPh | iPad | Mac | AndP | AndT | WebD | WebM |
|---|---|---|---|---|---|---|---|
| Layout chosen by available window width, not device label (§12.1) | B: PASS · F: PASS | B: PASS · F: PASS | B: NV (no Mac build; policy test passes) · F: PASS | B: PASS · F: PASS | B: PASS · F: PASS | B: PASS · F: PASS | B: PASS · F: PASS |
| Probe widths 320 · 390 · 599 · 600 · 700 · 839 · 840 · 900 · 1024 · 1280 · 1440: no clipping or overflow (playbook Step 14) | B: PASS · F: NV (slice checked at 390 / 820 / 1180 / 1280 only) | B: FAIL (portrait; landscape NV) · F: NV (slice checked at 390 / 820 / 1180 / 1280 only) | B: NV (no Mac build) · F: NV (slice checked at 390 / 820 / 1180 / 1280 only) | B: PASS · F: NV (slice checked at 390 / 820 / 1180 / 1280 only) | B: FAIL · F: NV (slice checked at 390 / 820 / 1180 / 1280 only) | B: FAIL · F: NV (slice checked at 390 / 820 / 1180 / 1280 only) | B: PASS · F: NV (slice checked at 390 / 820 / 1180 / 1280 only) |
| Large window gains capability: rail/sidebar, list-detail, inspector; no stretched phone (§4.1, §7.1, §18 P1) | N/A | B: FAIL (portrait; landscape NV) · F: PASS (sim, portrait; landscape widget only) | B: NV (no Mac build) · F: PASS (real app) | N/A | B: PASS · F: PASS (emu) | B: PASS · F: PASS (Chromium, WebKit) | N/A |
| Resize, split-screen, rotation and fold keep selection, scroll, drafts (§4.2, §7.2) | F: NV (not run: rotation needs the simulator panel or a device setting) | F: NV (not run: rotation needs the simulator panel or a device setting) | F: NV (not run: rotation needs the simulator panel or a device setting) | F: NV (not run: rotation needs the simulator panel or a device setting) | F: NV (not run: rotation needs the simulator panel or a device setting) | F: NV (not run: rotation needs the simulator panel or a device setting) | F: NV (not run: rotation needs the simulator panel or a device setting) |
| Safe areas, cutouts, home indicator, hinge, keyboard never cover content (§3.2, §7.2) | F: PASS (sim) | F: PASS (sim) | N/A | F: PASS (emu) | F: FAIL → fixed in 7a (Add under the keyboard); PASS (emu) | N/A | F: PASS (Chromium, WebKit) |
| Reading widths capped; no unreadably wide rows (§10.4) | — | — | — | — | — | — | — |

## 3. Visual precision

| Check (guide §) | iPh | iPad | Mac | AndP | AndT | WebD | WebM |
|---|---|---|---|---|---|---|---|
| Recognisably Dottoday (identity row of the §21 scorecard) | F: PASS (beside E-Phones 1, E-PhonesMinimal 1) | F: PASS (beside E-R2-1 1b, 2b) | F: PASS (beside E-FullA-v2 1, E-Minimal 1) | F: PASS (beside E-Phones 5, E-PhonesMinimal 5) | F: PASS (beside E-R2-1 3a, 4a) | F: PASS (beside E-FullA-v2 2, E-Minimal 2) | F: PASS (beside E-MobileWeb 1) |
| Typography roles mapped per platform; baselines aligned (§10.3, §14.2) | — | — | — | — | — | — | — |
| Icons: one meaning, right platform form; no mixed packs; crisp at 1×/2×/3× (§10.6, §14.1) | — | — | — | — | — | — | — |
| Surfaces and depth: Apple materials real or labelled approximated; Android tonal elevation; restrained shadows (§3.2, §10.5) | — | — | — | — | — | — | — |
| No 1–2 px misalignment in bars, badges, rows; hairlines sharp (§14.1, §14.3) | — | — | — | — | — | — | — |
| Light and dark designed separately, no flash on mode switch (§10.5, §14.3) | B: PASS | — | — | — | — | — | — |
| Empty, loading, error, offline, dense states composed (§14.3) | B: FAIL · F: FAIL → fixed in 7a (Now blank while loading or failed); PASS (goldens; offline not drawn) | B: FAIL · F: PASS (goldens, portrait; offline not drawn) | B: FAIL (code) · F: PASS (goldens; offline not drawn) | B: FAIL · F: NV (same code; goldens drawn on iPh, iPad, Mac) | B: FAIL · F: NV (same code; goldens drawn on iPh, iPad, Mac) | B: FAIL · F: NV (same code; goldens drawn on iPh, iPad, Mac) | B: FAIL · F: NV (same code; goldens drawn on iPh, iPad, Mac) |
| Motion: relationships, not decoration; platform transitions (§11.2) | — | — | — | — | — | — | — |
| Per-platform goldens exist; no cross-platform pixel comparison (§17.2) | F: PASS | F: PASS | F: PASS | F: PASS | F: PASS | F: PASS | F: PASS |

## 4. Accessibility

| Check (guide §, brief §17) | iPh | iPad | Mac | AndP | AndT | WebD | WebM |
|---|---|---|---|---|---|---|---|
| Screen reader completes the golden journey: VoiceOver · TalkBack · browser SR (§15) | F: NV (semantics tests only; VoiceOver, TalkBack, browser SR in M21) | F: NV (semantics tests only; VoiceOver, TalkBack, browser SR in M21) | F: NV (semantics tests only; VoiceOver, TalkBack, browser SR in M21) | F: NV (semantics tests only; VoiceOver, TalkBack, browser SR in M21) | F: NV (semantics tests only; VoiceOver, TalkBack, browser SR in M21) | F: NV (semantics tests only; VoiceOver, TalkBack, browser SR in M21) | F: NV (semantics tests only; VoiceOver, TalkBack, browser SR in M21) |
| Text scale to 200 % / max supported without loss (§15) | F: FAIL → fixed in 7a (Now rows, horizon labels); PASS (widget) | F: FAIL → fixed in 7a (top tabs); PASS (widget) | F: FAIL → fixed in 7a (Plan panel); PASS (widget) | F: NV (widget cases drawn on iPh, iPad, Mac) | F: NV (widget cases drawn on iPh, iPad, Mac) | F: NV (widget cases drawn on iPh, iPad, Mac) | F: NV (widget cases drawn on iPh, iPad, Mac) |
| Targets ≥ 44 pt (Apple) / 48 dp (Android) (§15) | B: PASS (sim) · F: PASS (widget cases) | B: PASS (sim) · F: FAIL → fixed in 7a (top tabs 38 → 44 to touch); PASS | F: PASS (24 px pointer floor) | B: PASS (emu) · F: FAIL → fixed in 7a (empty-day pills 46 → 48); PASS | B: PASS (emu) · F: PASS (6e-2 test) | — | — |
| WCAG 2.2 AA contrast, including on glass/translucent surfaces as rendered (brief §17) | F: PASS (text, widget cases) | F: PASS (text, widget cases) | F: PASS (text, widget cases) | — | — | — | — |
| Keyboard-only operation with visible focus and sane order (§15) | N/A | — | F: PASS (keyboard_flow_test; journey keys) | N/A | — | F: PASS (journey keys) | — |
| Reduced motion and reduced transparency honoured (§11.2, §3.2) | — | — | — | — | — | — | — |
| State never shown by colour alone; no-shame copy (§15, CLAUDE.md §11) | — | — | — | — | — | — | — |
| Drag-and-drop and gestures have non-gesture alternatives (§15) | B: FAIL | B: FAIL | — | B: FAIL | B: FAIL | — | — |

## 5. Performance

Measured in profile/release builds only; never claimed from debug.

| Check (guide §) | iPh | iPad | Mac | AndP | AndT | WebD | WebM |
|---|---|---|---|---|---|---|---|
| Cold start to usable Today (time recorded) (§14.4, §8.4) | — | — | — | — | — | — | — |
| Timeline scroll and drag without jank on a mid-range/older device (§14.4) | — | — | — | — | — | — | — |
| Route and sheet transitions smooth (§14.4) | — | — | — | — | — | — | — |
| Blur/saveLayer/painter cost profiled where effects are used (§14.4) | — | — | — | — | — | — | — |
| Web download size and first paint on a slow network; deferred loading considered (§8.4) | N/A | N/A | N/A | N/A | N/A | — | — |

## 6. Golden journey per platform (guide §17.1 + playbook core journey)

Today → Add → Edit/reschedule → Complete → Change day → Reopen, plus: an invalid entry and recovery, Back/dismiss, a dark-mode/text-scale switch mid-flow, then background/resume (or refresh).

| Phase | iPh | iPad | Mac | AndP | AndT | WebD | WebM |
|---|---|---|---|---|---|---|---|
| B baseline | NV (sweep covers screens, not the journey) | NV (same) | NV (no Mac build) | NV (same as iPhone) | NV (same) | NV (Today + quick add only) | NV (browser emulation, Today + quick add only) |
| F slice (M19.7, ED-417/418) | PASS (real iPhone 17 Pro, iOS 27.2.1, debug, and sim; core six steps, Full and Minimal) | PASS (sim, portrait; landscape widget only) | PASS (real app, 2 of 3 runs) | PASS (emu) | PASS (emu, landscape; portrait widget only) | PASS (Chromium, WebKit) | PASS (Chromium, WebKit) |
| H final | — | — | — | — | — | — | — |

## 7. Scorecard (guide §21, 0–5 per platform)

| Dimension | iPh | iPad | Mac | AndP | AndT | WebD | WebM |
|---|---|---|---|---|---|---|---|
| Product identity | — | — | — | — | — | — | — |
| Platform familiarity | — | — | — | — | — | — | — |
| Interaction correctness | — | — | — | — | — | — | — |
| Input adaptability | — | — | — | — | — | — | — |
| Responsive composition | — | — | — | — | — | — | — |
| OS integration | — | — | — | — | — | — | — |
| Crisp visual finish | — | — | — | — | — | — | — |
| Performance | — | — | — | — | — | — | — |
| Accessibility | — | — | — | — | — | — | — |
| Reliability | — | — | — | — | — | — | — |

## 8. Test environments

| Target | Available now | Notes |
|---|---|---|
| iPhone | **Real device** (owner) + simulators | Same bundle ID as the installed app: use simulators until a dev flavour exists (owner decision 6); real-device checks on the existing install only with owner approval |
| iPad | **Simulator only** | iPad cells say `NV (simulator only)` for touch feel, Pencil, real multitasking and performance |
| Mac | **Real device** (this Mac) | Same bundle ID as the original app: plan before installing side by side. Not run in Prompt B (owner decision 14) |
| Android phone | **Real device** (owner) + emulators | Same application ID caveat as iPhone. Device model and class (mid-range?) still to note for performance cells |
| Android tablet | **Real device** (owner) + emulators | Foldable: emulator only, so fold/hinge cells say `NV (emulator only)` |
| Web | Local browsers on this Mac | Chrome, Safari, Firefox, Edge as supported. Mobile web runs on the real iPhone and Android phone browsers |

Confirmed by the owner 2026-11-03. Where redesign builds may run is owner decision 14 (`STATUS.md`): simulators and emulators for iOS and Android, Mac only after asking (its sandbox container is shared with the original app), and web in a local browser with no sign-in. Until a dev flavour exists, real-device cells for the redesign build read `NV (no dev flavour yet)`.
