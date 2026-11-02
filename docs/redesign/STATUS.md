# Redesign status

Worktree `/Users/ops/Documents/dottoday-redesign`, branch `redesign/design-lab`. Phases follow `MASTER_PLAYBOOK.md`; each needs owner approval before the next.

| Step | Phase | State | Evidence |
|---|---|---|---|
| 1.1–1.2 | Protect original, create worktree | Done | `BASELINE.md` § Location |
| 1.3 | Baseline | **Done, approved 2026-11-02** (with exclusions below) | `BASELINE.md` |
| 2 | Configure Claude Code | Done for now (dart-flutter plugin loaded, existing `CLAUDE.md` kept). A redesign note in `CLAUDE.md` is pending, with the ADR below | — |
| 3 | Capture baseline screenshots | Started: 5 owner iPhone screenshots (dark) | `references/baseline/owner-ios-2026-11-02/` |
| 4 | Product Brief | **Done, approved 2026-11-02** | `PRODUCT_BRIEF.md` |
| 5 | Prompt A: feature-readiness audit | Next; waiting for owner go-ahead | — |
| 6+ | Prompt B onward | Not started; not authorised | — |

## Step 1.3 baseline (approved)

- `flutter pub get`: pass; `pubspec.lock` unchanged.
- `flutter analyze` and `dart analyze --fatal-infos`: no issues.
- `flutter test --exclude-tags supabase`: 6,021 passed, 21 skipped (env-gated reference-sheet and store-screenshot tests), 0 failed.
- **NOT RUN, by owner decision:** the four `test/supabase/` files (`auth_flow_test.dart`, `sync_roundtrip_test.dart`, `delete_account_test.dart`, `two_devices_test.dart`). The only local Supabase stack (`127.0.0.1:54321`) is shared with the original worktree. Do not run them against it.
- Also not run: browser tests (`--platform chrome --tags web`), `integration_test/`, the codegen freshness check, platform builds. See `BASELINE.md` § Not run.

## Owner decisions (2026-11-02)

1. **Platforms:** iOS (iPhone and iPad), Android (phones and tablets), macOS, web. All are considered in the redesign.
2. **Design source of truth (redesign branch only):** Concept A (`docs/10-ui-concept-a.md`) and ADR-0007 are historical, not binding. Concepts A Refined Timeline, B Productivity Workspace and C Focus-First Planner are all open. Propose a redesign ADR in the next documentation phase; never rewrite existing ADRs.
3. **One UI in the end:** temporary parallel components are allowed during exploration and migration. Obsolete UI is removed once parity is verified.
4. **Git:** stay on `redesign/design-lab`. PRs go to `main`. Approved `main` changes are merged in deliberately and logged in `SYNC_LOG.md`.
5. **Existing components:** keep the Dot design system and CustomPainters for now. Reuse, refactor or replace them according to the approved direction.
6. **App identity:** no change to bundle/application IDs, signing, backend credentials or live data. Use separate simulators and test environments until a dev flavour is planned.

## Owner decisions (2026-11-02, second set)

7. **Feature completeness:** ticked plan checkboxes are not verified functionality. Prompt A inspects the code and classifies each feature as completed, partially implemented, unverified or planned.
8. **Brand per concept:** dot and thread are the current identity, not a constraint. Concept A keeps and refines it; Concept B may evolve it substantially; Concept C may explore a completely different identity. Name, icon, timeline artwork and design system are all open.
9. **Navigation and layout:** all navigation, menus, Settings placement, task-editing flows and screen arrangements are open. Access to existing functionality must be kept; existing structure need not be.
10. **Platforms:** iPhone, iPad, Mac, Android phones, Android tablets, web. One brand across all of them, with each platform's own interaction conventions.
11. **Scope:** every existing feature stays accounted for. Phase 2 ideas are future possibilities unless approved. Free/Pro entitlement logic and pricing are unchanged without separate approval.
12. **Docs:** unrelated documentation is not changed now.

## Documentation inconsistencies (for Prompt A)

- `docs/15-wake-up.md` §0 says "Status: proposed (needs ADR-0017)", but `docs/adr/0017-wake-up-alarm-gateway.md` exists and plan M17 is ticked. Check which is current; don't edit either now.

## Open items

- **Isolated local Supabase for integration tests:** propose a setup that can't touch the original app's users, sessions, database or services *before* any future integration test run. Don't create or change it until approved.
- **Redesign ADR:** record decision 2, plus a short redesign note in `CLAUDE.md` so §11 doesn't block exploration.
- **Baseline screenshot privacy:** `04-today.webp` and `03-today-more-menu.webp` show a personal task title. Ask the owner before committing them.
- **`DECISIONS.md` / `SYNC_LOG.md`:** create them at the first decision or merge that needs a log. Decisions are kept above until then.
