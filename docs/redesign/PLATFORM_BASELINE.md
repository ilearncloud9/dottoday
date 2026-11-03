# Platform baseline (Prompt B)

**Status:** audit only, 2026-11-03, on `redesign/design-lab` at `f449aa76` (`main` merged up to PR #74). No app code was changed.

**What it checks:** how each platform behaves today, measured against `DESIGN_PRINCIPLES.md` and the guide (`references/platform-guidelines/premium-native-experience.md`, cited as "guide §").

**Labels:**
- *VERIFIED*: the code was read at the cited line.
- *INFERRED*: reasoned from constants or code, not run.
- *OBSERVED*: seen at runtime (§9).

All paths are under `app/`.

## 1. Summary

| Target | What it gets today | Feels ported from | Biggest gaps (guide §) |
|---|---|---|---|
| **iPhone** | Floating pill tab bar, round add button, Cupertino switch, iOS page slide with swipe-back, haptics | Partly Android: Material ripples on every tap (45 `InkWell`), Material `showMenu` on long-press, Material dialogs and buttons | No iOS context menus or large titles; no native sheets (Material bottom sheet with drag handle) (§3.1–3.3) |
| **iPad** | iPhone idiom; rail at ≥ 600; dialogs instead of sheets; the task sheet stays a **bottom sheet** at medium width | A large iPhone | No sidebar, list-detail or inspector at medium width; no pointer hover or cursors; Siri treats it as an iPhone (§4.1–4.3, §18 P1) |
| **Mac** | Material idiom ("Mac ≡ web"); rail; three-day spread; 420 px editor panel; `PlatformMenuBar`; ⌘ shortcuts; menu-bar status item | Android/web: M3 controls, Material switch, and an **iOS** page slide with swipe-back | No Cut/Copy/Paste/Select All/Find in the Edit menu; no Help or ⌘W; **no hover or cursor anywhere**; right-click only on Inbox rows; Ctrl-click treated as select; no speech/thinking/haptics channel (§5.1–5.4) |
| **Android phone** | M3 `NavigationBar` + FAB, predictive Back, edge-to-edge | Native enough; closest to its guide | System-bar overlay style never set; the iOS time wheel is used on every platform (§6.1–6.4) |
| **Android tablet / foldable** | Rail at ≥ 600; same as Mac at ≥ 840 | Big phone at medium width | No hinge/`displayFeatures` handling; no list-detail at medium (§7) |
| **Web desktop** | Mac layout with Material idiom; hash URLs; skip link; axe in CI | — | Hash (`#/`) URLs; editor panel, selection and proposals lost on refresh; no hover or cursors; Safari on Mac/iPhone gets the Cupertino page slide (§8.1–8.5) |
| **Web mobile** | Android chrome (M3 bar + FAB) on every host, including iPhone Safari | Android app in a browser | Browser conventions not considered separately (§8.3) |

**Verification level:** the summary comes from reading the code. Runtime checks (§9) used simulators and emulators only, with no real devices. **macOS, iPad landscape and foldables are NOT VERIFIED at runtime**: the Mac rows describe code, not a running app.

## 2. How the code adapts today (VERIFIED)

### 2.1 Layout follows width

- `WidthClass` (`lib/core/theme/dot_metrics.dart:231-250`) has three classes: compact < 600, medium 600–839, expanded ≥ 840. There is no large (≥ 1200) class.
- Layout reads no platform: `test/policy/no_platform_layout_test.dart:9-31` bans `Platform.isX` and `kIsWeb` in `lib/features` and `lib/shared`. One stale allow-list entry remains: `data_about_groups.dart` no longer uses `kIsWeb`.
- Two width sources are mixed:
  - The shell, Today, Inbox and Back-to-Today use `LayoutBuilder` (box width).
  - The editor panel, `openTask`, Focus, Month, the proposal panel and sheet subtasks use `MediaQuery.sizeOf` (window width): `editor_panel.dart:35`, `core/editing/editing_task.dart:33`, `focus_task.dart:45`, `proposal_host.dart:44`.

### 2.2 Conventions follow `DotIdiom`, which has two values

`lib/core/theme/dot_idiom.dart:20-21`: `cupertino` = iOS and not web (iPhone **and iPad**); `material` = everything else (Android, web, **Mac**).

**Every platform read in `lib/` (75 sites):**

| Category | Sites | What |
|---|---|---|
| Layout | **0** | Enforced by the policy test |
| Chrome | **9** | `DotIdiom.of`, `dotChipShape`, theme cache key, shell choice at compact, settings row height, `DotSwitch`, menu radius, menu-bar gate, Android edge-to-edge |
| Behaviour | **17** | Page transitions map (`dot_theme.dart:121-127`) + 16 ⌘/Ctrl sites, all through `AppShortcuts.usesMeta` (`app_shortcuts.dart:112`) |
| Integration | **49** | Capability gates in `lib/data/` and the app root: calendar, notifications, speech, thinking, widgets, Live Activity, Siri, export, auth redirect, DB connection, … |

**Indirect idiom call sites: 30** (`dotChipShape` 20, `DotSwitch` 7, `dotMenuStyle` 2, `settingsRowHeight` 1).

**Hidden platform readers** bypass `DotIdiom` through `Switch.adaptive`, so the Mac and Apple-hosted web show an iOS switch:
- `focus_parts.dart:270`
- `week_review_sheet.dart:185`
- `low_energy_parts.dart:256`
- `editor_duration.dart:105`

Ordinary Material widgets (scroll physics, text-selection toolbar) also follow `Theme.platform` silently.

**Size of the K13 work (per-platform idioms):**
- 1 enum, 4 direct consumers and about 30 call sites;
- the page-transitions map and the menu-bar gate;
- the 4 adaptive switches;
- `usesMeta`, which covers all keyboard sites in one helper.

The 49 integration gates are capability checks, not idioms, and should stay separate.

**INFERRED estimate:** small and contained, about 40 files. The work is in deciding the per-platform designs, not in the wiring.

## 3. Width probes: does expanded fit just over 840? (INFERRED arithmetic, VERIFIED constants)

**Fixed widths:**
- rail 80 (`dot_rail.dart:15`);
- Inbox sidebar 300 + 1 px divider (`inbox_sidebar.dart:43,62`);
- editor panel 420 + 1 (`dot_metrics.dart:56`);
- three-day spread: flexible 5:8:5 + 128 px fixed steppers, chosen only when its box is ≥ 840 (`today_spread.dart:136-150`);
- Week board minimum 840 + 56 page padding (`week_board.dart:36-46`, `week_view.dart:87-92`);
- Mac window minimum 960×640, default 1280×800 (`macos/Runner/MainFlutterWindow.swift:11-12`).

| Window | Today (no editor) | Week board | Editor open: content | Note |
|---|---|---|---|---|
| 840 | 760 → **one-day pager** | **scrolls sideways** | **339 px** | "Expanded" here is the rail plus a phone pager |
| 900 | 820 → pager | scrolls | 399 | |
| 960 (Mac min) | 880 → spread | **scrolls** | 459 | The Mac minimum window has a sideways-scrolling Week |
| 1024 | spread | fits | 523 | |
| 1280 (Mac default) | spread + sidebar | fits | 779 → pager, **sidebar gone** | Opening a task turns the spread back into a pager |

**Thresholds:**
- spread from 920;
- Week fits from 976;
- sidebar from 1220;
- Week with the sidebar from 1277;
- **rail + sidebar + spread + editor need 1642**.

Nothing hard-overflows (every pane falls back), but the expanded class doesn't mean one composition. Smaller defects:
- off-by-one: the sidebar check subtracts 300 but takes 301 (`inbox_sidebar.dart:50`);
- the sidebar comment's promise about Week ignores the 56 px padding.

**Tests:** no test covers 840–960 with the editor or sidebar open (`today_spread_test.dart:40`, `pane_layout_test.dart:57`, `app_shell_a11y_test.dart:16` use 839, 700, 1000 and 1280).

## 4. Text scaling (VERIFIED)

- No clamping anywhere. Layouts re-stack by measuring text (`core/utils/text_fit.dart`; `sounds_page.dart:73`, `focus_view.dart:231`, `duration_chips.dart:63`, …).
- One `FittedBox`, on a share image (not a label). Five ellipses (Week cards, Brain dump list).
- **Risk (INFERRED):** the rail tile (fixed 64 px, `dot_rail.dart:78,110`) and the pill bar (fixed 60, `pill_tab_bar.dart:15,122`) clip `maxLines: 1` labels. The shell goldens have no 200 % text variant.
- 26 golden call sites run `_t2` (200 %) and RTL variants (332 each); `integration_test/scale_test.dart` exists.

## 5. Per-platform detail (VERIFIED unless marked)

### iPhone and iPad
- **Cupertino use:** only `CupertinoSwitch` (iPhone), `CupertinoDatePicker` and `CupertinoTimerPicker`. The pickers are used on **every** platform by design (`duration_sheet.dart:138`).
- **Missing iOS idioms:** no Cupertino nav bars, action sheets, context menus or large titles.
- **Haptics:** custom `dottoday/haptics` channel on iOS and Android, about 12 meaningful call sites (lift, drop, done, hover-switch, mic).
- **Sheets:** Material `showModalBottomSheet` with a drag handle (`app_sheet.dart:75`). At ≥ 600, a centred `Dialog`.
- **iPad:**
  - all four orientations;
  - Split View eligible (no `UIRequiresFullScreen`);
  - `UIApplicationSupportsMultipleScenes = false`, so one window;
  - store screenshots exist at 1032×1376.

### Mac
- **`PlatformMenuBar`** (`app_menu.dart:40-169`):
  - App: About, Settings ⌘,, Services, Hide, Quit.
  - File: New Task ⌘N, Export.
  - Edit: Undo, Redo, Delete; **no Cut/Copy/Paste/Select All/Find**.
  - View: Today ⌘1 … Month ⌘4, Shortcuts ⌘/, Full Screen.
  - Go: Previous/Next/Today, without key equivalents.
  - Window menu; **no Help**, **no ⌘W**, **no ⌘F**.
- **Pointer:** **0** `MouseRegion` and **0** `SystemMouseCursors` in `lib/`. Hover is only Material ink and 51 tooltips.
- **Right-click:** Inbox rows only (`inbox_row.dart:163`).
- **Multi-select:** Shift, ⌘ or Ctrl all toggle (`thread_select.dart:11-14`). There is no Shift range select, and Ctrl-click (right-click on Mac) selects.
- **Transitions:** Mac uses the **iOS** `CupertinoPageTransitionsBuilder` (`dot_theme.dart:124-125`).
- **Missing native channels:** the Mac Runner has `calendars`, `deep_links`, `intents`, `sound`, `status_item`, `system_events`, but **no `speech`, `thinking` or `haptics`**. VERIFIED by grep: `macos/` has no such bridge, while `thinking_providers.dart:58` maps macOS to `appleMac` and speech uses the channel recognizer. INFERRED effect: dictation and on-device thinking fail silently on the Mac. **This is a functional finding for `main`, not a redesign item.**

### Android
- Predictive back: manifest flag (`AndroidManifest.xml:40`), `PredictiveBackPageTransitionsBuilder`, and `PopScope` in 2 places.
- Edge-to-edge (`bootstrap.dart:60`); no `SystemUiOverlayStyle`.
- M3: `useMaterial3`, hand-built `ColorScheme`, 48 dp buttons.
- `configChanges` covers resize, so no restart on split-screen.
- FAB only in `MaterialBarShell`.

### Web
- **URLs:** hash URL strategy (no `usePathUrlStrategy`); manifest shortcuts use `./#/today`.
- **Refresh:** keeps the route but not the editor panel, selection, Focus-in-content or proposals (no restoration).
- **Skip link** on all platforms (`skip_link.dart`).
- **Accessibility:** semantics not force-enabled; CI runs axe at two widths plus keyboard and popover-focus checks (`.github/workflows/app.yml:217-260`).
- **PWA:** standalone, `orientation: any`, service worker, offline page.

### Tablets and foldables
- No tablet-specific Dart. Medium is the rail plus the phone pager plus dialogs.
- **0** `displayFeatures` reads. No orientation locks anywhere.

## 6. Accessibility baseline (VERIFIED)

- **Semantics counts:** `Semantics(` 199, `ExcludeSemantics` 31, `MergeSemantics` 14, tooltips 51, live announcements 5. `OrdinalSortKey` 0.
- **Targets:** global 48 minimum, `padded` tap targets; `DotTouch.android` (48) used 85 times.
- **Reduced motion:** central (`dot_theme.dart:50-52`), with `DotMotion.reduced` set to zero. Bold text and high contrast: **0** reads.
- **Tests:**
  - `expectA11yGuidelines` (44 pt, 48 dp, labelled, contrast) in 81 test files;
  - `ensureSemantics` in 41 files;
  - device a11y-tree checks in the sweep;
  - axe on web.
- **Gaps:**
  - thread rows have no "Move to…" semantics action (moving goes through selection and keys);
  - no hover or focus cursor on desktop;
  - glass/translucency contrast is untestable today (there is none).

## 7. Integrations (VERIFIED)

| Integration | iOS | macOS | Android | Web |
|---|---|---|---|---|
| Home widgets | Next Up, Today, Inbox | — | Next Up, Today, Inbox | — |
| Controls / tiles | Control Center add/focus | — | Quick Settings tiles | — |
| Live surface | Live Activity | Menu-bar status item | Ongoing notification | Tab title + favicon dot |
| Intents / Siri | 6 App Intents + shortcuts | Intent queue only | Launcher shortcuts | Action queue |
| Share intake | Extension | Extension | SEND intent | — |
| Wake Up alarm | AlarmKit | — | `setAlarmClock` + full-screen | — |
| Background refresh | BGTask | — | WorkManager | — |
| Speech / thinking | Channels | **Missing channels** | Channels | Web Speech / Prompt API |

## 8. What this means for the redesign

1. **Per-platform idioms are cheap to wire, expensive to design.** The plumbing is about 40 files (§2.2); the cost is in deciding the Mac, iPad and web treatments.
2. **The expanded class needs more than one composition.** Today it ranges from a 339 px pager (840 + editor) to a four-pane layout (≥ 1642). Concepts should design at least 840–1000, 1000–1300 and > 1300. A *large* class (≥ 1200) is worth proposing.
3. **iPad and Android tablet need their own medium layout.** Today they get a phone pager with a rail (guide §18 P1, "stretched phone").
4. **Mac needs desktop basics regardless of concept:** hover and cursors, right-click everywhere, a full Edit menu, ⌘W/⌘F/Help, range select, and Mac-appropriate transitions.
5. **Web needs browser conventions:** path URLs (a deploy change; needs a fallback route on the host), restorable panel state in the URL, and its own idiom instead of Android chrome.
6. **Found on the way (for `main`, not the redesign):**
   - missing Mac speech/thinking channels;
   - the `inbox_sidebar` off-by-one;
   - the stale policy allow-list entry;
   - 4 `Switch.adaptive` that bypass `DotSwitch`.

## 9. Runtime evidence

Captured 2026-11-03 on `redesign/design-lab` at `f449aa76`. The screenshots and logs are kept **locally only** (not in Git); `references/baseline/PROMPT_B_EVIDENCE.md` lists every file, the device configurations and the findings in words. Every build used a scratch defines file pointing Supabase at `http://localhost:9` with a dummy key, so nothing could sign in or sync. No Mac build (owner decision 14). The matrix's `B:` cells come from this section and the code audits.

### 9.1 Device sweeps (OBSERVED, simulator/emulator only)

`tool/device_tests.sh <platform> <device> sweep` on dedicated devices: "Redesign iPhone" (iPhone 17, iOS 26.5), "Redesign iPad" (iPad Pro 11-inch M5, iOS 26.5), `Redesign_Phone` (Pixel 9 profile, API 37) and `Redesign_Tablet` (Pixel Tablet profile, 2560×1600, landscape).

| Run | Result | Shots | a11y-tree checks (44 pt, 48 dp, labelled) | Overflow / exceptions |
|---|---|---|---|---|
| iPhone light | PASS, 11:45 | 55 | 39 screens, all pass | none |
| iPhone dark | PASS, 9:20 | 55 | 39 screens, all pass | none |
| iPad portrait | PASS, 9:27 | 55 | 39 screens, all pass | none |
| Android phone | PASS, 10:55 | 54 | 38 screens, all pass | none |
| Android tablet (landscape) | PASS, 6:35 | 54 | 38 screens, all pass | none |

- Screenshots (local only): `references/baseline/prompt-b/{iphone,ipad,android,android_tablet}/`; logs in `references/baseline/prompt-b/logs/`. The one-shot difference is platform branching (`brain_dump_mic` and `siri_page` on iOS, `brain_dump_no_mic` on Android).
- **NOT VERIFIED:** iPad landscape (the simulator couldn't be rotated without device access), macOS (no Mac build), foldables, any real device. **Not captured:** Android dark, text scale 200 % on device, and the golden journey as one recorded flow.

### 9.2 Web build at the probe widths (OBSERVED, local browser with viewport emulation, no sign-in, not saved as files)

Release build served on `127.0.0.1:8097` in the Claude in-app browser (Chromium), widths set by viewport emulation, so phone widths are not a real mobile browser; onboarding completed with "Continue without an account"; one synthetic task added with quick add (2 taps, verified). No request reached the dummy Supabase address.

| Width | Shell | What I saw |
|---|---|---|
| 320 | Tab bar + floating + | Renders; the date title wraps to two lines; the Undo toast covers Wind Down and sits beside the + |
| 390 | Tab bar + floating + | Clean |
| 599 | Tab bar + floating + | Time and title columns drift far apart: no reading-width cap on the compact row |
| 600 | Rail with + | Rail appears; the Undo toast covers the rail's Settings gear |
| 839 | Rail with + | Same as 600, one Today column |
| 840 | Rail, **no +** | Week tab appears and the + button disappears (confirms `UX_AUDIT.md` §2) |
| 1024 | Rail, spread | Yesterday · Today · Tomorrow; no + |
| 1280 | Rail, Inbox sidebar, spread | Inbox sidebar appears; side-day columns are cramped and wrap "Wind Down · 11:00 PM" |
| 1440 | Same | Clean |

700 and 900 were not separately captured (they fall inside the 600–839 and 840–1023 bands seen above).

### 9.3 Runtime findings (new or confirmed)

| # | Finding | Where (verification level) | Evidence |
|---|---|---|---|
| R1 | Side-day columns in the three-day spread clip "Wind Down · 11:00 PM" (the "PM" line is cut off) | Android tablet (emulator); web 1280 wraps the same label in cramped columns (browser) | `android_tablet/android_today.png` (local); web observed, not saved |
| R2 | Toasts span the bottom of the window and cover the rail's Settings gear; on web the "added… Undo" toast stayed up for over 40 s | iPad portrait (simulator), Android tablet (emulator), web 600–1280 (browser) | `ipad/ios_today.png`, `android_tablet/android_today.png` (both show the sweep's "M11 sample loaded" toast; local); web observed, not saved |
| R3 | iPad portrait is a stretched phone: a Siri card, a "New" banner and "See how it works" push the thread to mid-screen, and the thread sits in a sheet-style card with a drag handle | iPad 834 pt, medium (simulator) | `ipad/ios_today.png` (local) |
| R4 | No add button at expanded width in the full layout (minimal mode keeps it) | Android tablet (emulator), web ≥ 840 (browser); iPad landscape inferred, NOT VERIFIED | `android_tablet/android_today.png` (local); `app/lib/shared/navigation/dot_shell.dart:113-115`, `app/lib/app_shell.dart:71` |
| R5 | No reading-width cap on compact rows near 599 | Web 599 (browser) | Observed, not saved |
| R6 | The web build needs `tool/web_db_assets.sh` first; without `sqlite3mc.wasm` (404) the encrypted DB can't open and Today shows "This didn't load". A documented release step (`docs/release-beta.md` §5), not an app defect; the Design Lab's web run includes it (`DESIGN_LAB_PLAN.md`) | Web (browser) | Network log, observed; `tool/web_db_assets.sh` |

The build's "CupertinoIcons not bundled" warning is harmless: the app uses no `CupertinoIcons`.

