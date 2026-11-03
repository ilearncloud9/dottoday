# Sync log: `main` → `redesign/design-lab`

Each time `main` is merged in deliberately (owner decision 4, playbook Step 13), record what came in, the conflicts, and the checks.

## 2026-11-03 · merge 1 (`79435423`)

- **Approved by:** the owner ("merge main into this branch"), 2026-11-03.
- **Range:** `1f913069..origin/main` at `3a3517f2`. 21 commits, 82 files.
- **Came in:**
  - Q7 stabilise-first fixes:
    - #71 sync pull by an `(updated_at, id)` keyset. Local Drift schema 16 → 17: two nullable `sync_cursors` columns; no server change.
    - #72 task sheet Move tile wired.
    - #73 `/day/:date` parsed as a local date within the pager's reach.
    - #74 taps on a vanished task are no-ops.
  - Q14 docs PR: #70 D1–D7 plus the Q1/Q2/Q5 corrections. ADR-0015 *reminder sounds* is renumbered **ADR-0018**.
  - Wake Up: #68 iPhone Wake Up armed in AlarmKit (rings through Silent and Focus); #69 mission re-ring survives a locked Stop.
- **Conflicts:** none. Git merged automatically; no redesign file was touched by `main`.
- **Effect on redesign docs:**
  - `FEATURE_READINESS.md` "stabilise first" items 1–4 and D1–D7 are now fixed on this branch. Prompt B re-verifies them; the audit text is kept as a record of 2026-11-02.
  - Anything citing ADR-0015 *reminder sounds* now means ADR-0018.
- **Checks after merge:**
  - `flutter pub get` passes, and `pubspec.lock` is unchanged.
  - `flutter analyze` and `dart analyze --fatal-infos` report no issues.
  - `flutter test --exclude-tags supabase`: **6,029 passed, 21 skipped, 0 failed** (baseline was 6,021 / 21; the new tests came from `main`).
  - Not run, as at baseline: `test/supabase/`, web tests, `integration_test/`, builds.
- **Still open on `main`:** Android Wake Up double ring after a background sync. A fix session is waiting for the owner's approval of an in-repo plugin package.
