# Platform quality matrix

This file tracks how native and how good each platform is, under `DESIGN_PRINCIPLES.md` and the guide `references/platform-guidelines/premium-native-experience.md` (§ numbers below refer to the guide). Nothing has been assessed yet:
- Prompt B fills the baseline.
- Prompts D, F and H update it for the concepts, the first slice and final QA.

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
| Primary navigation shell matches platform expectation (§9) | — | — | — | — | — | — | — |
| Back/dismiss correct at every depth: edge-swipe · predictive Back · Esc/⌘W · browser Back/Forward (§13.3) | — | — | — | — | — | — | — |
| Sheets/popovers/dialogs use the platform's temporary-flow form (§9) | — | — | — | — | — | — | — |
| Controls (switch, picker, menu, context menu, time picking) feel native (§3.3, §5.1, §6.2) | — | — | — | — | — | — | — |
| No foreign idiom by accident: ripple/FAB on iOS, iOS swipe-back on Android, mobile sheet on Mac (§3.5, §6.1, §5.1) | — | — | — | — | — | — | — |
| Text selection, editing, keyboard type/action, IME insets (§3.4, §6.3) | — | — | — | — | — | — | — |
| Keyboard shortcuts with platform modifiers; browser shortcuts not hijacked (§5.2, §8.1) | N/A | — | — | N/A | — | — | N/A |
| Mac menu bar with live enabled state (§5.2) | N/A | N/A | — | N/A | N/A | N/A | N/A |
| Pointer: hover, cursor, right-click, ⌘/Ctrl/Shift multi-select (§5.3, §11.3) | N/A | — | — | N/A | — | — | N/A |
| Haptics on meaningful events only, honouring settings (§3.3) | — | — | N/A | — | — | N/A | N/A |
| URLs: deep link, refresh, new tab, bookmark (§8.1) | N/A | N/A | N/A | N/A | N/A | — | — |
| OS integration: notifications, Wake Up alarm, share, widgets, menu-bar extra, Siri/App Intents (§16) | — | — | — | — | — | — | — |
| Lifecycle: background/resume, process death, state restoration (§6.3, §11.4) | — | — | — | — | — | — | — |

## 2. Responsive layout

| Check (guide §) | iPh | iPad | Mac | AndP | AndT | WebD | WebM |
|---|---|---|---|---|---|---|---|
| Layout chosen by available window width, not device label (§12.1) | — | — | — | — | — | — | — |
| Probe widths 320 · 390 · 599 · 600 · 700 · 839 · 840 · 900 · 1024 · 1280 · 1440: no clipping or overflow (playbook Step 14) | — | — | — | — | — | — | — |
| Large window gains capability: rail/sidebar, list-detail, inspector; no stretched phone (§4.1, §7.1, §18 P1) | N/A | — | — | N/A | — | — | N/A |
| Resize, split-screen, rotation and fold keep selection, scroll, drafts (§4.2, §7.2) | — | — | — | — | — | — | — |
| Safe areas, cutouts, home indicator, hinge, keyboard never cover content (§3.2, §7.2) | — | — | N/A | — | — | N/A | — |
| Reading widths capped; no unreadably wide rows (§10.4) | — | — | — | — | — | — | — |

## 3. Visual precision

| Check (guide §) | iPh | iPad | Mac | AndP | AndT | WebD | WebM |
|---|---|---|---|---|---|---|---|
| Recognisably Dottoday (identity row of the §21 scorecard) | — | — | — | — | — | — | — |
| Typography roles mapped per platform; baselines aligned (§10.3, §14.2) | — | — | — | — | — | — | — |
| Icons: one meaning, right platform form; no mixed packs; crisp at 1×/2×/3× (§10.6, §14.1) | — | — | — | — | — | — | — |
| Surfaces and depth: Apple materials real or labelled approximated; Android tonal elevation; restrained shadows (§3.2, §10.5) | — | — | — | — | — | — | — |
| No 1–2 px misalignment in bars, badges, rows; hairlines sharp (§14.1, §14.3) | — | — | — | — | — | — | — |
| Light and dark designed separately, no flash on mode switch (§10.5, §14.3) | — | — | — | — | — | — | — |
| Empty, loading, error, offline, dense states composed (§14.3) | — | — | — | — | — | — | — |
| Motion: relationships, not decoration; platform transitions (§11.2) | — | — | — | — | — | — | — |
| Per-platform goldens exist; no cross-platform pixel comparison (§17.2) | — | — | — | — | — | — | — |

## 4. Accessibility

| Check (guide §, brief §17) | iPh | iPad | Mac | AndP | AndT | WebD | WebM |
|---|---|---|---|---|---|---|---|
| Screen reader completes the golden journey: VoiceOver · TalkBack · browser SR (§15) | — | — | — | — | — | — | — |
| Text scale to 200 % / max supported without loss (§15) | — | — | — | — | — | — | — |
| Targets ≥ 44 pt (Apple) / 48 dp (Android) (§15) | — | — | — | — | — | — | — |
| WCAG 2.2 AA contrast, including on glass/translucent surfaces as rendered (brief §17) | — | — | — | — | — | — | — |
| Keyboard-only operation with visible focus and sane order (§15) | N/A | — | — | N/A | — | — | — |
| Reduced motion and reduced transparency honoured (§11.2, §3.2) | — | — | — | — | — | — | — |
| State never shown by colour alone; no-shame copy (§15, CLAUDE.md §11) | — | — | — | — | — | — | — |
| Drag-and-drop and gestures have non-gesture alternatives (§15) | — | — | — | — | — | — | — |

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
| B baseline | — | — | — | — | — | — | — |
| F slice | — | — | — | — | — | — | — |
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
| Mac | **Real device** (this Mac) | Same bundle ID as the original app: plan before installing side by side |
| Android phone | **Real device** (owner) + emulators | Same application ID caveat as iPhone. Device model and class (mid-range?) still to note for performance cells |
| Android tablet | **Real device** (owner) + emulators | Foldable: emulator only, so fold/hinge cells say `NV (emulator only)` |
| Web | Local browsers on this Mac | Chrome, Safari, Firefox, Edge as supported. Mobile web runs on the real iPhone and Android phone browsers |

Confirmed by the owner 2026-11-03. Where redesign builds may run is owner decision 14 (`STATUS.md`): simulators and emulators for iOS and Android, Mac only after asking (its sandbox container is shared with the original app), and web in a local browser with no sign-in. Until a dev flavour exists, real-device cells for the redesign build read `NV (no dev flavour yet)`.
