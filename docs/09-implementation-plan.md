# 09 — Implementation Plan

The agent works top to bottom. A milestone is done only when every task is `[x]` and `/ship-check`
passes. Each task lists the spec sections and `R-xx` IDs it must satisfy. Keep tasks small; split a
task rather than leaving it half-done. Add new tasks here when discovered — never keep them in your head.

Legend: `[ ]` todo · `[x]` done · `[~]` in progress (only one at a time).

---

## Milestone 0 — Project bootstrap (goal: `flutter run` on all four targets with a blank themed screen)

- [x] M0.1 Run `flutter create` in `app/` per `app/README.md`; restore seeded files; `flutter pub get`; commit lockfile.
- [x] M0.2 Folder layout from CLAUDE.md §3 with placeholder `README.md` in each top-level dir explaining its boundary.
- [x] M0.3 `core/env`: load `.env` via flutter_dotenv; fail fast with a clear message if `SUPABASE_URL` missing. (06 §1)
- [x] M0.4 `core/theme`: tokens from 03 §1 (colours light/dark, typography, spacing, radii, motion durations); `AppTheme.of(context)`; respects reduced motion. Golden test light/dark.
- [x] M0.5 `core/router`: go_router with routes `/today`, `/day/:date`, `/inbox`, `/week`, `/month`, `/search`, `/settings`, `/task/:id`; allow-listed deep links. (07 shared)
- [x] M0.6 `core/l10n`: ARB setup (en source), `AppLocalizations`; lint that forbids string literals in `features/**` and `shared/**` (widened from `features/**/widgets`; exceptions via `// l10n-ignore: <reason>`) (custom_lint rule or test scanning). Also an import-boundary test (scans `lib/**` imports) failing on: `features/X` → `features/Y`, `domain/` → `package:flutter`, `shared/` → `features/`. (CLAUDE.md §3)
- [x] M0.7 `core/clock`, `core/logger` (PII redaction + test that `Logger.info('title: x')` is rejected by lint/test), `core/failures` sealed class.
- [x] M0.8 CI: GitHub Actions `analyze → format → test` for the app; `supabase start && supabase test db` for RLS. gitleaks step. Golden-test job must run on a **macOS runner** (goldens are baselined on macOS, M0.4).
- [x] M0.9 Supabase project: apply `supabase/migrations/0001_init.sql`; run `supabase/tests/0001_rls.sql`; fix any dialect issues found in the `sync_push` dynamic SQL (keep allow-listing and `auth.uid()` enforcement). (05, 06 §3) **Done when** green locally (`supabase db reset && supabase test db`) and in CI; pushing to the linked project is M6.0.
- [x] M0.10 CHANGELOG.md created; `/ship-check` passes.
- [x] M0.11 Codegen/lint toolchain upgrade: move to custom_lint/riverpod_generator (or riverpod_lint 3 native analyzer plugin) that support analyzer ≥ 7.4; drop the `analyzer` pin in `pubspec.yaml` and the `analysis_options_deprecated_plugins: ignore` in `analysis_options.yaml`; `build_runner build` + `flutter analyze` clean. Discovered in M0.1.
- [x] M0.12 Release builds take `SUPABASE_URL`/`SUPABASE_ANON_KEY` from `--dart-define-from-file` (e.g. `app/.env.prod`) and do not bundle `.env` as an asset; debug builds keep reading `app/.env`. (06 §1)
- [x] M0.13 App shell: bottom `NavigationBar` (compact) / `NavigationRail` (≥ 600 dp) with the five destinations from 03 §2 (Today · Inbox · Week · Search · Settings), l10n labels, Quick Add FAB placeholder; desktop/web shortcuts ⌘/Ctrl+1 Today, +2 Inbox, +3 Week, +4 Month (pushes `/month`) per 07 macOS. (03 §2, 07)
- [x] M0.14 Automated accessibility checks per 08 §3 (found by M0 `/ship-check`): a reusable test helper running `androidTapTargetGuideline`, `iOSTapTargetGuideline`, `labeledTapTargetGuideline`, `textContrastGuideline` over every screen (shell now, each new screen later) in light + dark, compact + expanded; axe-core scan of the web build in CI. (R-12)

## Milestone 1 — Domain core (goal: pure-Dart engine fully tested before any UI)

- [x] M1.0 Block palette: the 12 names fixed in 03 §1 (coral … slate); define hex `base`/`strong` for light and dark in `assets/design/palette.json`; test that every `strong` is ≥ 3:1 against `surface` in its mode; build step generates Dart (`lib/core/theme/block_palette.gen.dart` — not `.g.dart`, which `build_runner build -d` deletes as a conflicting output). (03 §1)
- [x] M1.1 Entities with freezed: `Series`, `Occurrence`, `Subtask`, `Alert`, `CalendarAccount`, `CalendarLink`, `Profile/Settings`. Validators per 05 "Validation". Unit tests. `color_key` allowed set: `BlockColor` (M1.0) lives in `core/theme` and imports Flutter, so expose the 12 keys to `domain` without a Flutter import (e.g. generate a pure `block_color_keys.g.dart` from the same JSON).
- [x] M1.2 `RecurrenceExpander` (rrule + timezone): expand series → occurrences for a window; exceptions; tests listed in 08 §2 `recurrence_expander_test`. (ADR-0004, R-01, R-09)
- [x] M1.3 `Materialiser`: idempotent 90-day materialisation; subtask instantiation from template per occurrence; `subtask_occurrence_test`. (R-09)
- [x] M1.4 `DaySchedulerService`: `shiftFollowers`, `insert(policy)`, `runningLate`, `suggestSlots`; property tests from 08 §2. (04 §5, R-04, R-05, R-17)
- [x] M1.5 `QuickAddParser` (en, de, fr, es; 12/24 h): tests from 08 §2. (R-06, R-07, R-20)
- [x] M1.6 `NotificationPlanner`: desired-set computation; windowing (iOS 64 limit); quiet hours; tests. (R-10)
- [x] M1.7 `ConflictResolver` + HLC implementation; tests for LWW, 60-s same-field conflict. (ADR-0002)
- [x] M1.8 Export/import model (JSON v1 schema, CSV, ICS writers) with round-trip tests. (R-11)
- [x] M1.9 Coverage ≥ 90 % on `lib/domain`; `/ship-check`.
- Follow-ups from the M1 ship-check: re-run the `app` and `security` CI workflows on `main` once GitHub
  Actions billing is restored (M1.3–M1.9 were verified locally only, see CHANGELOG); M2.0 below.

## Milestone 2 — Data layer (goal: encrypted local DB + repositories, no network yet)

- [x] M2.0 Raise the Dart SDK floor to `^3.8.0` (json_serializable 6.13 warns below it; unlocks null-aware elements). Expect a repo-wide `dart format` change to the tall style in its own commit.
- [x] M2.1 Drift schema mirroring 05 + sync columns + `change_log`, `sync_cursors`; SQLCipher key from secure storage; web WASM/OPFS variant behind the same interface. (06 §4, ADR-0003) **Decide first:** `drift`/`drift_dev` ≥ 2.32 require `sqlite3` 3.x, which builds SQLite via native-assets hooks and changes how SQLCipher is bundled (affects `sqlcipher_flutter_libs`, CLAUDE.md §2). Both are capped `<2.32` in `pubspec.yaml` until this is decided (M0.11). Also: `sqlcipher_flutter_libs` is end-of-life (`0.7.0+eol`), and `drift_flutter` pulls in `sqlite3_flutter_libs`, which clashes with `sqlcipher_flutter_libs` on Apple platforms (duplicate `Sqlite3FlutterLibsPlugin` → macOS build fails; found in M0.11).
- [x] M2.2 DAOs + repository implementations (`OccurrenceRepository`, `SeriesRepository`, `SubtaskRepository`, `SettingsRepository`) with reactive streams for day/inbox/week/month queries.
- [x] M2.3 Write path: every mutation goes through a `WriteUseCase` that updates DB, appends `change_log`, triggers `Materialiser` (if series), `NotificationPlanner` diff, widget snapshot write. Tests.
- [x] M2.4 `BackupService`: daily local JSON backup (keep 7), pre-migration backup; restore. Tests. (R-08, R-11) Lost key (M2.1): opening an existing file without its key, or with a key that doesn't decrypt it, throws a typed `DatabaseUnavailable`; no key is ever minted over an existing file. Local backups share the key, so recovery is via sync or a user export (M3.11 UI).
- [x] M2.5 Trash: soft delete, 30-day restore, purge; undo token API for UI (30 s). (R-11)
- [x] M2.6 Search index (FTS5) over title/notes/subtasks incl. completed. (R-11)
- [x] M2.7 Performance test: 10 000 occurrences, day query < 16 ms, search < 50 ms. (R-15)
- [x] M2.9 Web at-rest encryption per ADR-0003 (found in M2.1: the web DB is Drift WASM/OPFS, unencrypted). Decide between `sqlite3mc.wasm` keyed by a raw key that is stored wrapped by a non-extractable WebCrypto key in IndexedDB, and a custom encrypting VFS; amend ADR-0003; test that OPFS bytes don't contain a task title.
- [x] M2.8 `/ship-check`.

## Milestone 3 — UI, Concept A (goal: every v1 screen in `10-ui-concept-a.md` §5, local only, on all four targets)

Re-planned 2026-10-21 for ADR-0007. Source of truth: `docs/10-ui-concept-a.md` (contract) + `docs/design-references/png/` (renders), CLAUDE.md §11.
Each task names its reference render (`Ref`) or `derived — §5.3/5.4` when there is none.

**Done criteria.** **§7** means all six items of `10-ui-concept-a.md` §7: (1) golden vs the reference or spec at 1×/2×, light + dark;
(2) only `DotTheme` tokens and §3 components; (3) compact / medium / expanded, Mac ≡ web at the same width; (4) 08 §3 a11y plus
a `TaskDot` state label, 44/48 px targets, 4.5:1 contrast; (5) all copy from ARB; (6) a screenshot-sweep entry in 08 §7.
`+` adds the task's own criteria. Derived screens also get a row under "derived" in `docs/design-references/README.md`.

**Pre-Concept A work (kept, superseded visually).** M3.1 shared components, M3.1a demo day, M3.2 timeline canvas and app-start wiring,
M3.3 block widget — all `[x]`. Their state, layout maths, app-start wiring, `TimeInput`, `UndoSnackbar`, `SyncPill` and the
demo-day loader are reused; the hour-gutter canvas and block visuals are replaced by `Thread`/`TaskRow` in M3b.1.
M3.4 gestures (`4938eee` on `feat/m3-4-gestures`, never merged) targets the old canvas: it is not merged as-is; its snapping and
auto-scroll logic is reused in M3b.5.

**Discrepancies between renders and the doc (the doc wins; the PRD wins over both on product questions):**
- LiveRow in `Main`/`A-android-today` shows Done · +15 min only; §3 adds "Shift the rest" → built per §3.
- `A-ios-task-sheet` shows Done · +15 min · Move · Edit; §3 says Done / +15 / Shift → all five: Done · +15 · Shift · Move · Edit (Move = R-05, Edit = E1).
- `A-android-inbox` has filter chips (All / Under 30 min / Fits today) and a mic in the quick-add field; `A-ios-inbox` has neither.
  §4 allows no such difference → chips go on every platform (they serve R-17 "fits today"); the mic is dropped (no speech dependency in §2).
- `A-android-settings` rows have subtitles and the DAY SHAPE slider shows 7:00/22:00; the iOS one shows 00/24 and no subtitles →
  one layout on both: subtitles shown, times under the handles.
- The Search header ring shows a magnifier on iOS and the result count "4" on Android → the count on both (a dot ring holding loose dots, §1).
- The Search results use people/document icons that the original 24-icon set lacked → set expanded to 26 (owner, 2026-10-21; §3 updated).
- The `A-mac-editor` Save button shows ⌘S; §6 says ⏎ saves → ⏎ saves when focus is not in Notes, and ⌘S always saves.
- §5.3 Repeat editor: "this one or all future"; PRD F4 requires this / this and following / all → three scopes (PRD wins).
- Week start: `Main` starts its strip on Sunday while `A-ios-settings` says "Week starts Monday" → the strip follows Settings › Week starts (M3b.1).
- The Today overflow (⋯) shows on Android only in the renders → one ⋯ on every platform, beside the day dot (§4 lists no such idiom; it carries the debug menu now and Running late in M3f.5).
- Palette: §2.1 has 9 task colours; 03 §1 / `palette.json` have 12 → 9 (M3a.1). The stored `color_key` stays text (no schema
  change); legacy keys map on read: tangerine→amber, lime→mint, magenta→rose.

### M3a — Theme and components

- [x] M3a.1 `DotTheme` tokens in `app/lib/core/theme/`, the only theme folder (path settled in docs 2026-10-21) (§2.1–2.4: colour light/dark, the 4 accents, 9 task colours with segment alphas, Inter type scale with `tnum`, radii, elevation, thread/dot sizes, motion 180–240 ms → 0 under reduced motion). Replace the 12-key palette (`palette.json`, gen step, `color_key` allowed set) with 9 keys + the legacy map. Retire `AppTheme` tokens that §2 supersedes; mark 03 §1 superseded. Ref `Main`, `A-android-today` (palette and type). Done: §7 + contrast test of every text/surface pair in both themes + test that no `Color(`/`BorderRadius`/`Duration(` appear outside `lib/core/theme/`.
- [x] M3a.2 `DotIcons`: the nav set (dot, tray, week bars, magnifier, gear, plus) + the 26 task icons in §3, drawn as stroke paths (2 / 2.4 active, round caps, 24-unit grid) by a `DotIcon` painter, with no new dependency. Migrate the `icon_key` set to these 26 the same way as colours. Ref `A-ios-add-what` (icon row), `A-mac-editor`. Done: §7 + one golden sheet of all icons at 2 widths × 2 themes.
- [x] M3a.3 `TaskDot`: outline / conic (live, 5 px ring sweep) / filled-check / dashed (skipped) at 36 / 42 / 26 / 22 px; animated sweep; semantic label with state ("Deep work, live, 38 minutes left"). Ref `Main`, `A-ios-future-month` (dashed). Done: §7 + a semantics test per variant (R-12).
- [x] M3a.4 `Thread` + `TaskRow` + `LiveRow`: sun cap "Wake Up · 7:00", 6 px coloured segments, 2 px dotted free line, "N h free · add here" gap rows (drop-target API only), moon cap "Bedtime · 22:00", now-marker (16 px accent dot + 4 px halo, 1-min tick); row states upcoming / live / done (struck) / missed / pinned (lock) / recurring (repeat glyph); `LiveRow` subtask ring "1 of 3", "38 min left", Done / +15 min / Shift the rest. Ref `Main`, `A-android-today`. Done: §7 + goldens with 0/1/7/30 rows and 200 % text (nothing truncates without a sheet), RTL golden.
- [x] M3a.5 `DayDot` (44 px conic Wake Up→Bedtime, 18 px variant) + `WeekStrip` (7 columns, 8 px completion dots filled / conic / outline, today raised, pull handle). Ref `Main`, `A-ios-today-month`. Done: §7 + a test that the dot fraction comes from DayShape and an injected `Clock`.
- [x] M3a.6 `DayCard` ("Wednesday · Today" + "2 of 7 · 5 h 45 planned" + `Thread`) + `DayPager` (22 px peek, 7 page dots, snap physics, opens on today). Ref `Main`, `A-android-today`. Done: §7 + a test that it always opens on today.
- [x] M3a.7 `MonthGrid`: compact cell (date + completion dot, planned/repeats legend, "N of M days planned") and expanded cell (struck done titles, "· missed", "+N more", "N of M done", "Light day", today accent-ringed). Ref `A-ios-today-month`, `A-ios-future-month`, `A-mac-month`. Done: §7 + goldens for 5- and 6-row months and week-start Sun/Mon.
- [x] M3a.8 Adaptive shells by width class (no `Platform.isX` for layout): compact = floating pill `TabBar` (iOS idiom) / M3 `NavigationBar` + rounded-square FAB (Android idiom), Today · Inbox · Search · Settings + add; medium = `NavigationRail`; expanded = rail Today · Inbox · Week · Search · Settings. Idiom chosen only for the §4 allowed list. Keep `/week` and `/month` routes. Ref `Main`, `A-android-today`, `A-mac-today-alt1-spread`. Done: §7 + a test that fails on `Platform.is` under `lib/features/**` and `lib/shared/**`; nav-order test.
- [x] M3a.9 Golden harness: a matrix helper (light/dark × compact 390 / medium 700 / expanded 1280 × 1×/2× × iOS/Android idiom), plus a reference sheet that places each component golden next to the crop of its reference PNG for review; add 08 §7 "Design-review matrix" and the "derived" section in `docs/design-references/README.md`. Ref all PNGs. Done: CI runs the matrix on the macOS runner; the sheet is produced as a CI artifact.
- [x] M3a.10 Device build: a debug-only component gallery route + "Load demo day" (M3.1a, updated to 9 colours, 26 icons, Wake Up/Bedtime, a live task, a missed task, inbox items) in the new header overflow; `flutter build` for iOS simulator, Android emulator, macOS and Chrome; release builds still contain no demo strings. Done: 4 builds launched and screenshotted; release-strings check repeated.
- [x] M3a.11 `/ship-check`.

### M3b — Today, Month, Inbox and Task sheet on phones

- [x] M3b.1 Today T1: caption "WEDNESDAY 21 OCT ⌄" (opens month), greeting, `DayDot`, `WeekStrip`, all-day chips, `DayPager`; replace the old timeline canvas (delete its widgets in the same commit). Ref `Main`, `A-android-today`. Done: §7 + empty state "Nothing planned · pull the strip to plan or tap +".
- [x] M3b.2 Month pull-open T2 (rubber-band drag on the strip handle, the caption chevron toggles it) + future-month planning T3 (month nav Nov · Dec · Jan, "Today" pill, pick a day → its card; empty day: "Add to this day", "Pull from inbox · N", "Copy a day…" = Duplicate day). Ref `A-ios-today-month`, `A-ios-future-month`. Done: §7 + reduced-motion path with no rubber band.
- [x] M3b.3 Completion and live state: tap dot = done (same-frame fill + strike + light haptic, Undo snackbar); live dot sweep and "N min left" every minute; LiveRow Done / +15 min / Shift the rest via `DaySchedulerService` (R-04). Ref `Main`. Done: §7 + tests with an injected Clock for minute ticks, undo and shift.
- [x] M3b.4a Task sheet T4 (split from M3b.4, 2026-10-21): identity row, Done · +15 · Shift · Move · Edit tiles, subtasks ticked per occurrence (R-09) and added inline, Alerts / Repeat / Colour & icon rows; `/task/:id` resolves through the repository for the current user only, otherwise "not here". Ref `A-ios-task-sheet`. Done: §7 + `subtask_occurrence_test` through the UI, a not-owned-ID test.
- [x] M3b.4b Phone editor E1 (split from M3b.4): Edit opens the E1 fields as a full sheet (title, `ColourIconBlock` replacing the old `ColorIconPicker`, when / start → end, duration chips + custom, repeat + alerts rows, subtasks, notes, delete with confirm, Move to inbox); autosave, nothing lost on dismiss; details rows open it. Ref `A-mac-editor` (fields), `A-ios-add-what` (`ColourIconBlock`). Done: §7 + autosave and dismiss tests.
- [x] M3b.5 Long-press drag to another time or day: drop onto free gaps or a `WeekStrip` day (this is the phones' "Week overview, read + drag" from PRD F8), snapping (setting), ghost + floating time label, auto-scroll, edge grip on the segment end to resize, tap-vs-scroll disambiguation, haptics, reduced motion; reuse the `4938eee` snapping and auto-scroll logic (R-05). Ref `Main` (gap targets). Done: §7 + gesture widget tests incl. a 200 % text drag. Notes: drops snap on the wall clock and are clamped inside the gap (a task longer than the gap starts at its opening; Shift the rest then offers to fix the overlap). Pinned and done tasks don't lift. Mouse also lifts after the 250 ms hold; an immediate mouse drag on Mac/web moves to M3e.1 (Draggable has no per-device recognizer, so it needs a pointer-kind switch).
- [x] M3b.6 Shift-followers during drag: chip "shift the rest", settings default ask / always / never, pinned and calendar rules, partial-shift toast (R-04, R-17). Ref derived — §5.3/5.4. Done: §7 + `day_scheduler_test` cases exercised through the widget. Notes: spec gap written into 03 §3.2 (ask = chip shown off, never = no chip; far jumps bump instead of carrying). Domain `moveWithFollowers`.
- [ ] M3b.7 Multi-select: long-press, then tap others: move, delete, duplicate, change colour; selection count announced (R-05). Ref derived — §5.3/5.4. Done: §7 + semantics test for the selection mode.
- [ ] M3b.8 Inbox I1: header with dotted ring count, "5 unscheduled · 5 h 15 of work", quick-add field (parser, R-06), filter chips All / Under 30 min / Fits today, `InboxRow` (swipe left = schedule, right = trash with Undo), `NextFreeSlot` + Place, Completed · N group. Ref `A-ios-inbox`, `A-android-inbox`. Done: §7 + empty state "Inbox is clear"; swipe alternatives reachable without gestures (R-12).
- [ ] M3b.9 Perf: 200 tasks on the thread ≥ 55 fps in a profile run on a mid-range Android; day query stays < 16 ms (R-15). Done: profile trace attached to the commit body.
- [ ] M3b.10 `/ship-check` + four-platform side-by-side diff against the §4 idiom list.

### M3c — Add flow

- [ ] M3c.1 Add step 1 What A1: title with "Type a time too: 'Go shopping 5pm 1h'" (live `QuickAddParser` fill, R-06/R-20), `ColourIconBlock` (9 colours + 3 quick icons + "…"), Suggestions "from your habits" (a domain `SuggestionService`: same title → last used time, duration, colour, icon), Continue, "Add to Inbox instead"; ≤ 2 taps + typing from any tab. Ref `A-ios-add-what`, `A-android-add-what`. Done: §7 + a tap-count test and `SuggestionService` unit tests.
- [ ] M3c.2 Add step 2 When A2: `ThreadPicker` (scrolling slice through a fixed window, neighbours shown, the new segment in its colour, "Free until 19:30 · no overlap" / overlap warning), duration chips, "Lands on … · the slot is free · Edit", Add / Add another. Ref `A-ios-add-when`, `A-android-add-when`. Done: §7 + overlap-warning tests; the picker is keyboard-operable.
- [ ] M3c.3 Duration sheet A3 (also restyles the pre-Concept A `DurationChips` the E1 editor still uses as pills, `A-ios-add-when`): hours/min wheel, live segment preview "ends 6:30 PM · Still fits before …", editable presets (add / remove / Reset, stored in settings). Ref `A-ios-add-duration`, `A-android-add-duration`. Done: §7 + a preset persistence test.
- [ ] M3c.4 Time ⋯ menu A4: Change day, Pick from the week, Make it all-day, Send to Inbox, Time zone, Type a time (`TimeInput`, R-20); iOS popover / M3 menu idiom. Ref `A-ios-add-time-menu`, `A-android-add-time-menu`. Done: §7 + `time_input_test` still green.
- [ ] M3c.5 Bulk and contextual add: pasting several lines → "Add N tasks?" confirmation (R-07); Enter = add, Shift+Enter = add another; "add here" gaps open Add prefilled with the gap's time (R-17). Ref derived — §5.3/5.4. Done: §7 + paste tests (en/de/fr/es).
- [ ] M3c.6 `/ship-check` + four-platform side-by-side diff.

### M3d — Search and Settings

- [ ] M3d.1 Search S1: field, chips All / Today / This week / Inbox / Done / colour / icon, results grouped by day with match highlight, live / done / inbox row variants (inbox → "+ Schedule"), RECENT chips; FTS from M2.6 including completed (R-11); empty and no-results states. Ref `A-ios-search`, `A-android-search`. Done: §7 + search < 50 ms on 10 000 rows through the provider.
- [ ] M3d.2 Settings P1: header with avatar + "synced just now", DAY SHAPE (sun→moon mini-thread with two drag handles, "15 h awake", Wake Up, Bedtime, Week starts, Time format), PLANNING (Default duration, Show free time, Running-late nudge, Roll unfinished to tomorrow), REMINDERS (Task starts, Bedtime reminder), LOOK (theme, accent), DATA, ABOUT, plus every PRD F8 item not in the render (per-weekday boundaries, snapping, shift default, alerts default, language, trash, feedback, changelog) (R-16, R-17, R-19). Ref `A-ios-settings`, `A-android-settings`. Done: §7 + 48/56 px rows; switches use the platform idiom only.
- [ ] M3d.3 DayShape propagation: Wake Up / Bedtime drive the day dot, thread caps, free-time maths, capacity, "Free · unplanned" and the Bedtime reminder (planner input, R-10); per-weekday overrides. Ref derived — §5.3/5.4. Done: unit tests for each consumer with an injected Clock; DST day test.
- [ ] M3d.4 `/ship-check` + four-platform side-by-side diff.

### M3e — Expanded layout (Mac and web)

- [ ] M3e.1 Today T5 three-day spread: Yesterday | Today card | Tomorrow, ‹ › day nav, "Running late" button, NOW line, "drop an inbox task here" / "drop here to plan" targets, drag between columns; a mouse drags at once, without the 250 ms hold (from M3b.5). Ref `A-mac-today-alt1-spread`. Done: §7 + golden at 1280 and 840.
- [ ] M3e.2 Inbox: 300 px sidebar on Today and Week (drag to plan); Inbox page with rows "Fits today 11:30", Sort, "Auto-plan the week ⇧⌘P" (`suggestSlots`), "Drop onto today" thread panel with fitting gaps, ⌘⏎ to place in the first slot. Ref `A-mac-inbox`, `A-mac-week-alt3-board` (sidebar). Done: §7 + keyboard-only placement test.
- [ ] M3e.3 Week W1 capacity board: hour axis, cards placed by time, `CapacityRing` per day, Busiest / Lightest tags, `WeekSummaryStrip`, Week/Month switch, ⌘← ⌘T ⌘→, "Drop a task here" targets, "Synced · just now". Ref `A-mac-week-alt3-board`. Done: §7 + capacity maths unit tests.
- [ ] M3e.4 Month M1: expanded `MonthGrid`, header "42 done · 5 missed · 23 ahead · busiest day", click a day → its Today. Ref `A-mac-month`. Done: §7.
- [ ] M3e.5 `TaskEditor` panel E1: right panel, no sheets; title, `ColourIconBlock`, When / Start → end, duration chips + custom, Repeat, Alerts chips, subtasks (tick, "now", add), Notes, delete (typed confirmation), Move to inbox, Save; esc closes, ⏎ / ⌘S save, ⌘D done; autosave. Ref `A-mac-editor`. Done: §7 + focus-trap / esc tests.
- [ ] M3e.6 Keyboard map: ⌘N add, ⌘T today, ⌘←/→ day, ⌘D done, esc, ⌘/ shortcut sheet (Ctrl on web/Windows/Linux); visible focus ring; keyboard-only pass of the core flow (R-12). Ref derived — §5.3/5.4. Done: §7 + a shortcut test per binding.
- [ ] M3e.7 Search and Settings in the main pane at expanded; medium (600–840) layout = rail + compact content in wider cards. Ref `A-ios-search`, `A-ios-settings` (content). Done: §7.
- [ ] M3e.8 Web parity: the Mac layout at expanded, Material at compact; a test that the macOS and web goldens are equal at the same width. Done: §7 + axe-core clean.
- [ ] M3e.9 `/ship-check` + four-platform side-by-side diff.

### M3f — Secondary screens and system states

- [ ] M3f.1 Repeat editor: never / daily / weekdays / weekly on … / monthly / custom (RRULE builder, every N, nth weekday), end never / after N / on date, readable summary, edit/delete scope this / this and following / all, series undo (R-01). Ref derived — §5.3/5.4. Done: §7 + scope tests against `RecurrenceExpander`.
- [ ] M3f.2 Alerts editor: at start, N min before, at end, overdue, Bedtime reminder; up to 5; defaults from settings (R-03, R-10). Ref derived — §5.3/5.4. Done: §7 + `notification_planner_test` still green.
- [ ] M3f.3 Subtask editor (inline add, reorder, rename; template vs occurrence, R-09) + full colour & icon picker sheet (26-icon grid). Ref derived — §5.3/5.4. Done: §7.
- [ ] M3f.4 Change-day picker (`MonthGrid` in a sheet), time-zone picker. Ref derived — §5.3/5.4. Done: §7.
- [ ] M3f.5 "Running late" sheet (shift the rest / skip / shorten, +5/+15/+30, R-04) + Day review at Bedtime ("3 of 7 done · move the rest to tomorrow?"). Ref derived — §5.3/5.4. Done: §7 + pinned/partial tests.
- [ ] M3f.6 Inbox swipe confirmations + Undo snackbar, Completed group expanded, Search empty / no results, Export day + Duplicate day entry points. Ref derived — §5.3/5.4. Done: §7.
- [ ] M3f.7 Settings sub-pages: Calendars (import list, static until M7), Export (static until M8.1), Help, Privacy, About, Trash (30-day restore, M2.5); Account page (sign in/out, delete with confirm — UI only, wired in M6.1/M6.5). Ref derived — §5.3/5.4. Done: §7.
- [ ] M3f.8 Sync status sheet (last synced, conflicts local vs remote, "keep mine / keep theirs" — UI on fakes, wired in M6.3), offline banner, notification-permission-denied states. Ref derived — §5.3/5.4. Done: §7.
- [ ] M3f.9 System states on every screen (§5.4): skeleton dots on a dotted thread (no spinner > 300 ms), empty, inline actionable error, offline, `DatabaseUnavailable` recovery screen (M2.4: explain, move the file aside, never delete, start fresh, point to sync / import), reduced motion, 200 % text, RTL, VoiceOver/TalkBack labels (R-12). Ref derived — §5.3/5.4. Done: §7 for every screen × state; a test that each screen has all states.
- [ ] M3f.10 `/ship-check` + the full screenshot sweep + four-platform side-by-side diff.

### M3g — Watch companion (parked)

- Parked: `02-prd.md` F9 puts the Apple Watch app in Phase 2 ("not blocking v1") and lists it under Phase 2 again. `png/Watch.png` (WA1) stays the reference for the Phase 2 backlog item. The data layer stays watch-ready (F9).

## Milestone 4 — Onboarding (goal: first run to a planned first thread in < 90 s, skippable, on all four targets)

Ref for all of M4: derived — §5.3/5.4 (§5.1 has no renders). The old M4 "Capture" tasks are delivered by M3b–M3f.

**Decided 2026-10-21 (owner), PRD F10 updated:** keep O1–O6. Only the three input screens (O2 day shape, O3 habits, O5 account) count against F10's limit, and calendar connect is an optional row on O4.

- [ ] M4.1 O1 Welcome: the dot draws itself ("Your day, as a thread."), Get started / Sign in; reduced motion = static. Done: §7.
- [ ] M4.2 O2 Day shape: "When does your day start and end?", Wake Up / Bedtime wheels + live mini-thread (the Settings DAY SHAPE component). Done: §7 + writes the profile through `SettingsRepository`.
- [ ] M4.3 O3 Habits (skippable): pick 3–5 suggestion chips via `ColourIconBlock` + suggestion rows; they land on tomorrow's thread. Done: §7 + a test that they land on tomorrow, not today.
- [ ] M4.4 O4 Reminders: explain task-start and Bedtime reminders, then the system permission prompt; optional "Connect a calendar" row (device calendar permission, M7.1 picks the calendars); denied → the M3f.8 state. Done: §7 + test both outcomes.
- [ ] M4.5 O5 Account: Apple / Google / email magic link / "Continue without an account" (UI against the auth interface; real auth in M6.1). Done: §7.
- [ ] M4.6 O6 Done: the first thread with the habits placed, "Open today". Done: §7.
- [ ] M4.7 Auth states: returning-user sign-in, magic-link "check your mail", account error, restore-from-sync progress. Done: §7 + a widget test per state.
- [ ] M4.8 Flow rules: at most 3 input screens (PRD F10), every step skippable, "Continue without an account" path, < 90 s timed in an integration test, resumes if killed mid-flow. Done: integration test.
- [ ] M4.9 Integration test onboarding → quick add → drag with shift → recurrence edit scopes; add the Android-emulator `integration_test` CI job (08 §6). `/ship-check` + four-platform side-by-side diff.

## Milestone 5 — Notifications, widgets, platform polish

- [ ] M5.0 Register `dottoday://` and universal/app links (iOS associated domains, Android App Links + intent filter, macOS URL scheme); verify a cold-start deep link to `/task/:id` opens the task on each platform. Router allow-list from M0.5. (07 shared)
- [ ] M5.1 `NotificationScheduler` diffing against OS pending set; IDs from `hash(occurrenceId, alertIndex)`; actions Done/Snooze/Open; channels (Android), interruption levels (iOS); exactness test 20/20/0 duplicates on iOS+Android. (04 §6, R-10)
- [ ] M5.2 Background refresh: iOS BGAppRefresh, Android WorkManager — re-materialise + re-plan daily. (07)
- [ ] M5.3 Web push: service worker, VAPID, `send-push` Edge Function; in-app fallback. (07 Web)
- [ ] M5.4 Widgets: iOS/Android "Next up", "Today timeline", "Inbox count" via `home_widget`; snapshot JSON updated on every write; macOS WidgetKit shares app group. (02 F9, R-08)
- [ ] M5.5 macOS: menu bar + shortcuts, window min size, sandbox entitlements; crash-free verification on Intel + Apple Silicon. (07 macOS, R-13) Verify the shell `NavigationRail` (wrapped in `SafeArea`, M0.13) against the real macOS title bar / traffic lights and full-screen mode.
- [ ] M5.6 Android: predictive back, edge-to-edge, exact-alarm rationale + inexact fallback. (07 Android)
- [ ] M5.7 Web: PWA manifest, offline page, CSP headers, keyboard-first audit, responsive 360 px. (07 Web, 06 §8)
- [ ] M5.8 App lock (biometric/passcode), blur in switcher, FLAG_SECURE. (06 §2)
- [ ] M5.9 Time-zone change banner (keep vs shift). (07 shared)
- [ ] M5.10 `/ship-check` incl. accessibility manual pass on all four.

## Milestone 6 — Accounts & sync

- [ ] M6.0 `supabase db push` to the linked project (run by the user, not the agent), then verify the RLS tests against it. (CLAUDE.md §7)
- [ ] M6.1 Auth (screens built in M4.5/M4.7, wired here): magic link, Sign in with Apple, Google (PKCE); session in secure storage; "sign out everywhere". App remains fully usable without an account. (02 F7, 06 §2)
- [ ] M6.2 `SupabaseGateway` + `SyncEngine`: push via `sync_push`, Realtime subscription, periodic `since` pull, HLC, tombstones, server-error-never-deletes-local; tests from 08 §2 `sync_engine_test`. (04 §4, ADR-0002, R-08)
- [ ] M6.3 Sync status pill + details screen (UI from M3f.8, wired here) (conflicts list with keep mine/theirs). (R-08)
- [ ] M6.4 First-sync merge for users who created local data before signing in (local wins, server rows merged by id). 
- [ ] M6.5 Account deletion Edge Function + settings flow + email confirmation; export before delete prompt. (06 §6)
- [ ] M6.6 Two-device integration test (two app instances against local Supabase): offline edit both, reconnect, no loss, conflict surfaced only for same-field-within-60 s.
- [ ] M6.7 Sentry wiring with PII scrubbing test. (04 §9)
- [ ] M6.8 `/ship-check` incl. RLS tests and security checklist.

## Milestone 7 — Calendar import & write-back

- [ ] M7.1 Device calendars (iOS/macOS EventKit, Android CalendarContract): permission flows with explain + deep link; per-calendar toggles; colour inheritance; all-day strip. (02 F5, R-02)
- [ ] M7.2 Map external events → occurrences (`source=calendar`, `calendar_links`); local-only subtasks/notes on them; links tappable. (R-02, R-09)
- [ ] M7.3 Write-back (opt-in per calendar): move/resize/rename → provider; failure banner + retry; etag conflicts. (R-02)
- [ ] M7.4 Google + Microsoft via Edge Functions (`calendar-oauth`, `calendar-sync`), tokens in Vault; web parity. (04 §7, 06 §1)
- [ ] M7.5 Travel-time buffer suggestion for events with a location. (R-17)
- [ ] M7.6 Include-calendar-in-shift option in drag chip and settings. (R-04)
- [ ] M7.7 `/ship-check`.

## Milestone 8 — Export, feedback, release hardening

- [ ] M8.1 Export JSON/CSV/ICS + Import JSON (backup before import) on all platforms; share sheet / file save. (R-11)
- [ ] M8.2 Send feedback (mail composer with redacted diagnostics opt-in); in-app What's new; changelog screen. (R-19)
- [ ] M8.3 Localisation de/fr/es complete; pseudo-locale test for truncation.
- [ ] M8.4 Generate `docs/parity-checklist.md` from PRD and verify on all four platforms. (R-13)
- [ ] M8.5 Full manual QA matrix (08 §4) + beta via TestFlight/Play internal/web staging.
- [ ] M8.6 Store assets, privacy labels, privacy policy page, age gate copy. (06 §6)
- [ ] M8.7 Release gates (08 §6) all green → tag `v1.0.0`.

---

## Phase 2 backlog (do not start before v1.0.0 is tagged)

- AI planner (brain dump → editable proposal → add all), with history. (Play complaints: no recall, no edit-before-add)
- Habit history/streaks, analytics, energy-based suggestions.
- Pro tier: themes, icon packs, AI, analytics. Core free forever; honour lifetime purchases. (R-18)
- Apple Watch app + complications (WA1, `docs/design-references/png/Watch.png`, parked M3g); Live Activities; Shortcuts/App Intents; Android Quick Settings tile.
- Shared schedules / read-only share links.
- Apple CalDAV on web; Reminders import; duplicate-day templates library.
- HttpOnly-cookie session proxy for web (ADR-0003 follow-up).
