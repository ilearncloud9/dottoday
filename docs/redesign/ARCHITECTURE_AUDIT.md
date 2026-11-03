# Architecture audit (Prompt B)

**Status:** audit only. 2026-11-03, `redesign/design-lab` at `f449aa76`. No app code changed.

**Labels:**
- *VERIFIED*: read in code at the cited line.
- *INFERRED*: reasoned, not run.

Paths are under `app/lib/` unless noted. Platform detail is in `PLATFORM_BASELINE.md`, usability in `UX_AUDIT.md`.

## 1. Shape of the app

| Layer | What's there | Health for the redesign |
|---|---|---|
| `domain/` | Entities, ports, pure services (scheduler, recurrence, layout policy with 130 `FeatureId`s) | Reusable as-is. Imports no Flutter UI (CLAUDE.md §3) |
| `data/` | Drift + SQLCipher, sync, gateways (notifications, `AlarmGateway`, calendar, speech, thinking, widgets, Live Activity), repositories | Reusable as-is. All platform integration is here (49 capability gates) |
| `core/` | Router, theme (`DotTheme`), shortcuts, editing state (`openTask`, `focus_task`), l10n, env | Router and editing state need work (§3). Theme is the re-skin seam (§4) |
| `shared/` | 104 public widgets (173 with private), 45 of them in `shared/dot` | Mixed: logic-free building blocks, but the visual grammar is hard-coded (§4) |
| `features/` | 19 feature folders | Views over providers. Layout by `WidthClass` only, enforced by policy test |
| Root | `app.dart`, `app_shell.dart`, `app_menu.dart`, `app_shortcut_groups.dart`, `app_commands.dart`, `bootstrap.dart` | The shell is where the redesign's per-platform shells will plug in |

**Composition root:** `bootstrap()` (`bootstrap.dart:34`) builds the infrastructure and passes it to an `UncontrolledProviderScope` with overrides (`:70-88`). The database provider is designed to be overridden with `AppDatabase(NativeDatabase.memory())` (`data/db/database_providers.dart:30`). That makes an isolated Design Lab possible without new architecture (see `DESIGN_LAB_PLAN.md`).

## 2. Navigation and routes (VERIFIED)

The router (`core/router/app_router.dart:75-150`) uses a `StatefulShellRoute.indexedStack` with 5 branches: Today, Inbox, Week, Search, Settings. Each tab keeps its own stack, and tapping the active tab returns it to its root.

| Route | In shell | Problem |
|---|---|---|
| `/today` | yes | The day shown is in `todaySelectionProvider`, not the URL. Paging days doesn't change history |
| `/inbox`, `/week`, `/search`, `/settings` | yes | The week, filter and query aren't in the URL. The guard rejects every query string (`deep_link_guard.dart:37`) |
| `/settings/:page` (13 pages) | yes (child) | Pushed with `context.push`. With go_router 18.1.1 defaults, a push isn't reflected in the web URL (INFERRED). Routines' `extra` (drop day) is lost on refresh |
| `/month` | **no** | No tab bar, rail or sync banner. ⌘4 uses `push` while ⌘1–3 use `go` |
| `/day/:date` | **no** | No navigation chrome and no Back affordance. The editor panel, Focus frame and proposal host are mounted only in `AppShell` (`app_shell.dart:101-116`). At expanded width `openTask` only sets a provider (`core/editing/editing_task.dart:27-37`), so **tapping a task on `/day/:date` at expanded width probably shows nothing** (INFERRED, high confidence; not run) |
| `/task/:id`, `/focus/:id`, `/wake-up`, `/wake-up/mission/…`, `/review` | no | Fine as full pages. At expanded width Focus is provider-only and never in the URL |
| Past days | not a route | Imperative `MaterialPageRoute` push (`search/widgets/past_days_page.dart:171`) |

**Web specifics:**
- Hash URL strategy (default).
- No `restorationScopeId` anywhere.
- The editor panel, selection, Focus-in-content and proposals are lost on refresh.

**Redesign consequence.** Guide §13 requires that a route names the same thing on every platform, with the shell deciding how it's shown. Today, important state (selected day, week, month, task in the panel) lives in providers, not routes. Each concept should name its routes, and Prompt E should move the selected day and task into the URL. That's a router change, not a data change.

## 3. Presentation state that needs a home

- **Editing:** `editingTaskProvider` / `focusTaskProvider` decide panel vs sheet vs page from `MediaQuery` window width (`editing_task.dart:33`, `focus_task.dart:45`). Other places use `LayoutBuilder` box width. Mixing the two produces the 339 px Today at 840 + editor (`PLATFORM_BASELINE.md` §3).
- **Sheets:** `showAppSheet` (`shared/sheets/app_sheet.dart:34-83`) is the single switch: bottom sheet below 600, centred `Dialog` from 600. Three callers bypass it with raw `showModalBottomSheet`, so they stay bottom sheets on wide screens:
  - task sheet / editor (`timeline/widgets/task_sheet.dart:28-56`);
  - Inbox schedule (`inbox/widgets/schedule_sheet.dart:31`);
  - colour choice (`shared/selection/selection_bar_frame.dart:146`).
- **Drag state:** global static `ValueNotifier`s (`TaskDragging.current/.hint`, `shared/dot/thread_drag.dart:17-23`) outside Riverpod. Tolerable, but it's shared mutable state a new shell must respect.
- **Selected-day selection:** `todaySelectionProvider` resets when the screen is left (`today_selection.dart:12-29`).

## 4. Design-system seams (VERIFIED)

- **Tokens:** `DotPrimitives` (15 hex) → `DotColors` (12 roles, contrast-derived accent ink) → hand-built M3 `ColorScheme`, all in `DotTheme` (`ThemeExtension`, 427 read sites).
  - `DotType`: 19 Inter roles.
  - `DotMotion`: 180/200/240 ms, zero under reduced motion.
- **Static metrics:** spacing, radii, sizes and touch values (`DotSpace` 890 uses, `DotSize` 352, `DotRadii` 104) are compile-time statics, not part of the theme extension, so they can't vary per platform or theme without a refactor.
- **Enforcement:** policy tests ban raw style values (`test/policy/no_raw_style_values_test.dart`) and platform-based layout (`no_platform_layout_test.dart`). Leakage is near zero: 0 `Color(0x`, 0 `Curves.`, 0 font sizes outside theme.
- **Not covered by the gate:** 57 local numeric consts. Examples: pill height 60, rail 80/64, thread axis 56, picker 236, Inbox 300, sheet widths 560/760, painter ratios.
- **Material reach:** about 360 stock Material widgets (TextButton 82, FilledButton 61, SnackBar 47, …) are styled centrally by `dot_theme.dart` `_build()`. A change to `_build()` reaches them all.
- **Shapes:** no shape token. `StadiumBorder`/`CircleBorder` are used directly; `DotRadii.pill = 999`.
- **Icons:** `DotIcon` is a `CustomPaint` of SVG paths (155 call sites, 50 glyphs) plus 524 generated task icons. Material `Icons.` appears in 2 places.

## 5. Custom painting and timeline rendering (VERIFIED)

- **17 `CustomPainter`s** (not 16): 13 in `shared/`, 1 in `core/theme`, 3 in `features/`.
  - None draws text, and none has a `semanticsBuilder`. Labels come from `Semantics` wrappers.
  - All colours are passed in from `DotTheme`. Geometry is mostly `DotSize`, but the visual grammar lives in Dart: dash rhythm, knot curve constant, day-dot ratios, ring strokes.
- **Timeline:** `DayPager` (`PageView`) → `DayCard` → `CustomScrollView` → `Thread.sliver` (`SliverList.builder`, lazy). Each row is a `Stack` with one small `ThreadAxisPainter` in a 56 px axis column. It's not one big painter, which makes it easier to re-skin per row.
- **Gestures:** two drag recognisers split by pointer kind (`shared/dot/pointer_draggable.dart:101,127`): immediate for mouse, 250 ms hold for touch. Drops use `DragTarget` per row with a fraction-to-time mapping (`thread_drop_target.dart:55-59`). Multi-select uses Shift/⌘/Ctrl. Keyboard alternatives: ↑↓, ⌘↑↓, Delete, ↩, Space, Esc (`task_keys.dart:50-115`).
- **Performance risks** (INFERRED; nothing measured):
  1. `DayPage` watches `minuteTickProvider` (`day_page.dart:74`), so the whole day page rebuilds every minute.
  2. `ThreadAxisPainter.shouldRepaint` compares `AxisPiece` by identity (`thread_axis.dart:241`), and pieces are recreated each build, so every visible axis repaints each minute and on every drag-hover `setState`.
  3. `_RingPainter` in `week_day_dot.dart:45` gets a new list each build and always repaints. `_SketchPainter` omits fields from `shouldRepaint`.
  4. Only 2 `RepaintBoundary`s exist (both for share images). Nothing isolates the live row or rings.
  5. Every painter allocates `Paint` in `paint()`; two dashed painters run `computeMetrics` per paint.

  None of these is a visible problem yet. They matter if the redesign adds richer motion (brief P7). Prompt H must profile before claiming smoothness.

## 6. Tests and goldens (VERIFIED)

- **Goldens:** 2,203 golden PNGs from 61 test files.
  - `goldenMatrix`: light/dark × 390/700/1280 (optionally 840) × 1x/2x, plus `_t2`/`_rtl` on 26 call sites.
  - Default platform iOS; Android ×10 and macOS ×2 overrides.
  - Baselined on macOS only, 0.1 % tolerance, verify-only in CI.
- **Accessibility:** `expectA11yGuidelines` in 81 test files; `ensureSemantics` in 41; device a11y-tree checks in the sweep; axe on web.
- **Integration:** 32 `integration_test/` files, including the design sweep (`sweep_test.dart`) and `tool/device_tests.sh`.
- **Baseline (2026-11-03, after merge 1):** 6,029 passed, 21 skipped.

**Redesign consequence:**
- Almost any token change re-baselines most goldens. A new design system should start with its own golden set, and old goldens retire with the screens they cover.
- Per-platform goldens already work (`TargetPlatform` override), which matches RD-0001 §4.

## 7. Findings to fix on `main`, not in the redesign

| # | Finding | Evidence | Confidence |
|---|---|---|---|
| A1 | `/day/:date` at expanded width: tapping a task, Focus or a proposal shows nothing (the panel hosts are only in `AppShell`) | `app_shell.dart:101-116`, `editing_task.dart:27-37`, `app_screens.dart:35` | INFERRED, high. A widget test would confirm |
| A2 | Mac has no `speech`, `thinking` or `haptics` channel, but Dart maps macOS to channel-based dictation and on-device thinking | `grep` of `macos/` (none), `thinking_providers.dart:58`, `speech_providers.dart:13` | VERIFIED absence; INFERRED effect (silent failure) |
| A3 | Inbox sidebar width check subtracts 300 but takes 301 (1 px window where Today drops to the pager) | `inbox_sidebar.dart:43,50,62` | VERIFIED |
| A4 | 4 `Switch.adaptive` bypass `DotSwitch`, so Mac and Apple-hosted web show an iOS switch | `focus_parts.dart:270`, `week_review_sheet.dart:185`, `low_energy_parts.dart:256`, `editor_duration.dart:105` | VERIFIED |
| A5 | Minimal mode declares Routines, dictation, Inbox extras and Past days hidden, but nothing enforces it | §8 of `UX_AUDIT.md` | VERIFIED |
| A6 | Stale allow-list entry in the platform-layout policy test | `test/policy/no_platform_layout_test.dart` (`data_about_groups.dart`) | VERIFIED |

## 8. What the architecture means for the redesign

1. **Domain and data are a stable base.** No concept needs to touch the schema, sync, gateways or the 130 `FeatureId`s. Per-platform presentation sits entirely in `features/`, `shared/`, `core/theme` and the shell.
2. **Two structural changes are worth planning whichever concept wins:**
   - (a) routes own the selected day/week/month and the open task, so URLs, Back and restoration work (guide §13);
   - (b) one width source and one "panel vs sheet vs page" decision, so the expanded compositions behave predictably (`PLATFORM_BASELINE.md` §3).
3. **The shell is the swap point.** `DotShell` already chooses by (width, idiom). Per-platform shells (K13) extend that switch; they don't replace the router.
4. **Static metrics would become per-platform tokens.** Spacing, radii and sizes that should differ by platform (row heights, control sizes) must move from statics into the theme. That's a Prompt E design decision, with an ADR if it changes `core/theme` structure (K10).
