Run the milestone exit gate. Do not skip steps; report each with PASS/FAIL and evidence.

1. `cd app && dart analyze --fatal-infos` — must be clean (`dart`, not `flutter analyze`: only `dart analyze` runs the riverpod_lint plugin).
2. `dart format --set-exit-if-changed lib test` — must pass.
3. `flutter test --coverage` — all green; report coverage for `lib/domain` (target ≥90%) and overall (target ≥70%).
4. `flutter test integration_test` on at least one mobile target if a simulator/emulator is available; otherwise state that it was skipped and why.
5. Walk `docs/06-security.md` §9 checklist line by line; quote the line and say how it is satisfied.
6. Walk `docs/08-testing-qa.md` §6 release gates (platform parity, accessibility, offline, sync conflict, notifications).
7. Confirm every task in the current milestone of `docs/09-implementation-plan.md` is `[x]` and CHANGELOG is updated.
8. All four targets build: the latest `app` CI run on this branch has `build (web|android|macos|ios)` green (`gh run list --workflow app`, `gh run view <id>`); if CI hasn't run, build locally: `flutter build web`, `flutter build apk --debug`, `flutter build macos --debug`, `flutter build ios --simulator --debug`, each with `--dart-define-from-file=.env.example`. Report each target PASS/FAIL.
9. Summarize: ready to merge? If not, list the exact follow-up tasks and add them to the plan.

$ARGUMENTS
