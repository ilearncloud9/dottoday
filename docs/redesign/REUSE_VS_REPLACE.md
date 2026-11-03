# Reuse vs replace (Prompt B)

**Status:** audit only, 2026-11-03.

This is a starting position for the concepts, not a decision. "Replace" means the chosen concept rebuilds the piece in the new design system. Old code is removed only after parity is verified (owner decision 3). Concept A (refine the dot/thread) would reuse more of the Visual group than B or C.

| Piece | Where | Reuse / Refactor / Replace | Why |
|---|---|---|---|
| **Domain** (entities, scheduler, recurrence, layout policy, `FeatureId`) | `domain/` | **Reuse as-is** | Feature meaning is shared on every platform (RD-0001). No UI dependency |
| **Data** (Drift/SQLCipher, sync, gateways, repositories, integrations) | `data/` | **Reuse as-is** | Fix the `main` findings A2/A5 there, not in the redesign |
| **Riverpod providers and commands** (day actions, inbox commands, rebalance, proposals) | `features/*/state`, `core/editing` | **Reuse; refactor the editing/presentation state** | Logic is sound. Panel-vs-sheet, selected day and open task should move into routes or one width source (`ARCHITECTURE_AUDIT.md` §3) |
| **Router** | `core/router/` | **Refactor** | Keep go_router and the guard. Bring `/month` and `/day` into the shell. Put the selected day/week/month and open task in the URL. Consider the path URL strategy for web |
| **Policy tests** (no raw style values, no platform layout, golden tags) | `test/policy/` | **Reuse; extend** | Add an idiom policy when per-platform idioms land (K13) |
| **`DotTheme` colour pipeline** (primitives → contrast-derived roles → `ColorScheme`) | `core/theme/` | **Reuse the mechanism** | Concepts change the values; the contrast derivation already serves WCAG 2.2 AA |
| **`DotType`** | `core/theme/dot_type.dart` | **Refactor** | System fonts for OS chrome (K6); the content face per concept |
| **`DotMotion`** | `core/theme/dot_motion.dart` | **Reuse; extend** | Central reduced-motion is right. Concepts add a richer, per-platform motion scale (P7) |
| **Static metrics** (`DotSpace`, `DotSize`, `DotRadii`, `DotTouch`) | `core/theme/dot_metrics.dart` | **Refactor** | Per-platform density and control sizes need them in the theme, not as statics |
| **`DotIdiom` / `WidthClass`** | `core/theme/` | **Refactor** | Per-platform idioms (K13); add a large class or composition tiers at expanded width |
| **`DotIcon` / glyph parser** | `core/theme/dot_icon.dart`, `svg_path.dart` | **Reuse for task icons; decide for chrome** | Task icons stay one library (K9). Chrome icons may follow the platform |
| **Task icon library** (524) | `task_icons.gen.dart` | **Reuse as-is** | Content and brand (ADR-0013) |
| **Thread, rows, dots, painters** (17) | `shared/dot/` | **A: refactor · B/C: replace or re-skin** | Painters take colours from the theme but hard-code the visual grammar. Fix the `shouldRepaint` identity issues whatever happens |
| **Drag, drop, select gestures** | `shared/dot/pointer_draggable.dart`, `thread_drop_target.dart`, `thread_select.dart` | **Reuse the mechanics** | Pointer-kind split, 250 ms hold, keyboard alternatives are good. Add Shift range select and Mac Ctrl-click = right-click |
| **Overlap knot** | `shared/dot/overlap_knot.dart` | **Keep the behaviour** (must-keep, owner) | The look may evolve per concept; overlap-on-add stays (Q2) |
| **Navigation shells** (`DotShell`, `PillTabShell`, `MaterialBarShell`, `DotRailShell`) | `shared/navigation/` | **Replace** | Per-platform shells (RD-0001). Keep `DotShell`'s (width, idiom) switch pattern |
| **`showAppSheet`** | `shared/sheets/app_sheet.dart` | **Refactor** | Keep the single switch, add per-platform presentations (sheet, popover, inspector, dialog). Remove the three raw `showModalBottomSheet` bypasses |
| **Settings widgets** (`SettingsGroup`, `SettingsRow`, `DotSwitch`) | `shared/settings/` | **Replace** | Concepts regroup Settings (P1); switches per platform; two-pane on wide windows |
| **States** (`screen_states.dart`) | `shared/states/` | **Reuse; extend** | Add shared empty and offline states, and use them on the 9 blank screens |
| **`ProposalSheet` / `ProposalHost`** | `features/proposals/` | **Reuse the contract, re-skin** | The proposal rule (nothing written before Accept) is must-keep |
| **Wake Up card, missions** | `features/wake_up/` | **Replace the presentation** | P7: motion and full-screen graphics. Keep `AlarmGateway`, tiers and mission logic |
| **Day-shape slider** | `shared/dot/day_shape_slider.dart` | **Replace** | P5: circular dial; after-midnight needs the Q8 domain change |
| **Material widgets** (about 360 sites) | everywhere | **Keep, styled per idiom** | Fine on Android and web. On Apple, the shell and controls swap per idiom |
| **2,203 goldens** | `test/**/goldens` | **Retire with their screens** | The new system gets a fresh per-platform golden set |
| **Design sweep, device tests, reference sheet** | `integration_test/sweep_test.dart`, `tool/` | **Reuse** | Already capture every main screen per platform, with a11y-tree checks |

## Quick wins (on `main`, no redesign needed)

- A1: mount the panel hosts for `/day/:date` (or move it into the shell).
- A2: Mac speech/thinking/haptics bridges or capability gates.
- A3: sidebar off-by-one.
- A4: replace the 4 `Switch.adaptive` with `DotSwitch`.
- A5: enforce the minimal-mode `FeatureId`s that are declared hidden.
- A6: stale policy allow-list entry.
- `shouldRepaint` identity in `ThreadAxisPainter` and `week_day_dot`.
- Loading/error states on the 9 blank screens.

Each is its own small PR on `main` if you want them before Prompt F. None blocks Prompt C.
