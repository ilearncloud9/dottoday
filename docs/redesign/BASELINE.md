# Redesign baseline (Playbook Step 1.3)

Recorded 2026-11-02 in the redesign worktree before any redesign work. Nothing in `app/` was edited.

## Location

| Item | Value |
|---|---|
| Worktree | `/Users/ops/Documents/dottoday-redesign` (linked worktree of `/Users/ops/Documents/dottoday`) |
| Branch | `redesign/design-lab` |
| Baseline commit | `4dd92b35fbe417ff35cc7746ac7203d9583f64b4` (same as `main` at the time) |
| Original worktree | `/Users/ops/Documents/dottoday` on `main`, not touched. Its only pending change is a pre-existing untracked `tool/a11y/build/` |

## Environment

| Item | Value |
|---|---|
| Host | macOS 26.6.2 (25G83), Apple Silicon (`macos_arm64`) |
| Flutter | 3.47.8 stable, framework `737ba8f885` (2026-10-22), engine `dfd2e6cb7d` |
| Dart | 3.13.7 stable |
| DevTools | 2.60.0 |
| Xcode | 27.1 (27A9275) |
| `.env` in this worktree | None (it is gitignored and is not copied into a worktree). None of the commands below needed one |
| `SUPABASE_URL` in shell | Not set |

## Results

All commands were run from `app/`.

| Command | Result | Time |
|---|---|---|
| `flutter pub get` | PASS. `pubspec.lock` unchanged. Notes: 1 discontinued package (`golden_toolkit` 0.15.0), 44 packages have newer versions blocked by constraints | ~1 min |
| `flutter analyze` | PASS: "No issues found!" | 25 s |
| `dart analyze --fatal-infos` (the CI gate; runs `riverpod_lint`) | PASS: "No issues found!" | 20 s |
| `flutter test --exclude-tags supabase` | PASS: 6,021 passed, 21 skipped, 0 failed | 4 min 36 s |

### Tests in that run

- 495 `*_test.dart` files under `test/`.
- Included `golden` tests (baselined on macOS, so this host matches) and `perf` tests. CI runs `perf` with `--concurrency=1`; here they ran concurrently with the rest and still passed.
- **21 skipped (inferred):** the only skip switches in `test/` are `skip: !enabled` in `test/reference_sheet/reference_sheet_test.dart` and `test/store/store_screenshots_test.dart`. They are env-gated by `REFERENCE_SHEET` / `STORE_SCREENSHOTS`, and `dart_test.yaml` says they are never pass/fail gates. I did not match the skips one by one because the expanded reporter interleaves concurrent files.

### Not run

| Suite | Why | How to run it |
|---|---|---|
| `test/supabase/` (4 files, tag `supabase`) | A local Supabase stack was up at `127.0.0.1:54321` (HTTP 200). It is shared with the original worktree. These tests create, sync and delete accounts there. They use local defaults (`test/supabase/local_supabase.dart`) and need no production credentials, but running them changes shared local state. Held for owner approval | `flutter test --tags supabase` with the local stack up |
| `flutter test --platform chrome --tags web test/web` | The plain run doesn't cover browser-only tests; CI runs them as a separate step | As shown |
| `integration_test/` | Needs simulators or emulators. The playbook says to use dedicated devices because both builds share bundle and app IDs | Per device, on a dedicated simulator or emulator |
| `build_runner` / `gen-l10n` freshness | Generated files (`*.g.dart`, `*.freezed.dart`) are committed and CI checks they are fresh. Not re-run here so nothing gets rewritten | `dart run build_runner build -d && flutter gen-l10n`, then `git diff` |
| Platform builds (`flutter build ios/macos/apk/web`) | Not part of Step 1.3 | Step 3 / Step 14 |

## Pre-existing failures

None in the suites that ran.

## Blockers

None for the audit phases. The main open item is the shared local Supabase stack above. Before Step 3 (device screenshots), both worktrees must use separate simulators or emulators because the app identity is shared (owner decision 6).

## Git state after the baseline

- No tracked file changed (`git diff --stat` is empty). `pubspec.lock` is unchanged.
- Untracked: `docs/redesign/` only (this file plus `MASTER_PLAYBOOK.md`, renamed from `Flutter_Redesign_Master_Playbook_v3_Claude_Code.md`).
- New ignored output from `pub get` / `test`: `app/.dart_tool/`, `app/build/`, `.flutter-plugins-dependencies`, `android/local.properties`, the iOS/macOS `Flutter/ephemeral/` and `Generated.xcconfig` files, and the generated plugin registrants. All are covered by `app/.gitignore`.
- Nothing committed.
