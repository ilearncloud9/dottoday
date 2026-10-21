Review the current uncommitted diff (`git diff` and `git diff --cached`) as a strict senior reviewer.

Check, in order, and report findings with file:line:

1. Correctness: timezone handling (UTC stored, TZDateTime displayed, no `DateTime.now()` in domain), recurrence edge cases (DST, month-end, exceptions), occurrence-scoped completion.
2. Boundaries: no `features/*` importing another feature's widgets; `domain` has no Flutter imports; `shared` has no business logic.
3. Duplication: any new helper that already exists under `lib/core/utils` or `lib/shared`.
4. Security: input validated, no secrets, no PII in logs, RLS policy present for any new table, no raw SQL string concatenation.
5. Accessibility: Semantics labels, touch targets ≥44pt, text scaling, focus order, reduced motion.
   Every new or changed screen has a widget test that calls `await expectA11yGuidelines(tester);`
   (`test/support/a11y.dart`) for each state it renders — light + dark, compact + expanded. Missing
   call = BLOCKER.
6. i18n: no hardcoded user-facing strings.
7. Tests: domain logic unit-tested, screens widget-tested, timeline changes golden-tested.
8. Style: file ≤300 lines, functions ≤40 lines, naming per CLAUDE.md §4, comments explain why.

Finish with: BLOCKERS (must fix), SHOULD-FIX, NITS. If there are no blockers say so explicitly.

$ARGUMENTS
