# Redesign status

Worktree `/Users/ops/Documents/dottoday-redesign`, branch `redesign/design-lab`. Phases follow `MASTER_PLAYBOOK.md`; each needs owner approval before the next.

| Step | Phase | State | Evidence |
|---|---|---|---|
| 1.1–1.2 | Protect original, create worktree | Done | `BASELINE.md` § Location |
| 1.3 | Baseline | **Done, approved 2026-11-02** (with exclusions below) | `BASELINE.md` |
| 2 | Configure Claude Code | Done for now (dart-flutter plugin loaded, existing `CLAUDE.md` kept). A redesign note in `CLAUDE.md` is pending, with the ADR below | — |
| 3 | Capture baseline screenshots | Started: 5 owner iPhone screenshots (dark) | `references/baseline/owner-ios-2026-11-02/` |
| 4 | Product Brief | **Done, approved 2026-11-02** | `PRODUCT_BRIEF.md` |
| 5 | Prompt A: feature-readiness audit | **Done; decisions Q1–Q9 answered 2026-11-02** | `FEATURE_READINESS.md`, `FEATURE_PARITY_MATRIX.md`, `OPEN_PRODUCT_DECISIONS.md` |
| — | Design principle: one identity, native presentations | **Approved 2026-11-03**; ADR RD-0001 accepted (also records decision 2) | `DESIGN_PRINCIPLES.md`, `adr/RD-0001-…`, `PLATFORM_QUALITY_MATRIX.md` |
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

## Owner decision 13 (2026-11-03): design principle

13. **One product identity, multiple native presentations.** "Dottoday should feel like Dottoday on every platform, but it should never feel like an iPhone app ported to Android, or an Android app ported to iPhone."
    - **What's required:** one recognisable identity and one consistent feature experience.
    - **What may differ:** iOS, iPadOS, macOS, Android and web may differ where that improves native usability, familiarity, accessibility or quality. No pixel-identical screens.
    - **Who approves what:** platform adaptations are proposed and shown at review without separate approval. Changes that materially affect brand, core workflows or product behaviour need approval.
    - **References:** the primary one is `references/platform-guidelines/premium-native-experience.md` (renamed from `flutter_premium_native_cross_platform_design_guide.md`). The supplementary ones are the playbook's Step 3/14 checklists and the `apple-design` skill.
    - **Stages affected:** Prompts B, C, D, E, F and H (`MASTER_PLAYBOOK.md` rule 11 and each prompt).
    - **Scope:** this branch only. It supersedes conflicting redesign rules (CLAUDE.md §11 "differ only in chrome", doc 10 §4, ADR-0007 decisions 3 and 6, doc 03 §6 macOS sheets) without editing them.
    - **Conflicts:** listed in `DESIGN_PRINCIPLES.md` §7 (K1–K13). Owner decisions taken 2026-11-03:
      - **K1:** the redesign-branch note is added to `CLAUDE.md` §11.
      - **K6:** OS chrome uses system typography. The content typeface is chosen per concept and fixed at Step 9.
      - **K9:** task icons stay one library. Chrome/nav icons may follow the platform; concepts show this and Step 9 fixes it.
      - **K13:** `DotIdiom` has only cupertino and material, and Mac is on material. Prompt B sizes the work; Prompt E proposes per-platform idioms.
    - **Test devices:** real iPhone, Mac, Android phone and Android tablet; iPad on simulator only (`PLATFORM_QUALITY_MATRIX.md` §8).

## Owner decision 14 (2026-11-03): where redesign builds may run

Until a separate dev flavour exists (decision 6):
- **iPhone and iPad:** simulators only. The real iPhone is used only for screenshots the owner takes of the current app.
- **Android phone and tablet:** emulators only. The real devices are kept for later phases.
- **Mac:** run only if the original Dottoday isn't installed here; otherwise ask first. *Fact (2026-11-03):* no app is in `/Applications`, but the sandbox container `~/Library/Containers/app.dottoday.planner` exists, along with a debug build in DerivedData. So a redesign macOS build would share that data, and the owner is asked first.
- **Web:** a local browser with no sign-in, so nothing reaches the local Supabase stack the original app uses.

## Documentation inconsistencies (for Prompt A)

- `docs/15-wake-up.md` §0 says "Status: proposed (needs ADR-0017)", but `docs/adr/0017-wake-up-alarm-gateway.md` exists and plan M17 is ticked. **Investigated in Prompt A:** doc 15 is stale (ADR-0017 is Accepted 2026-10-31). Suggested wording and six more inconsistencies (D2–D7) are in `FEATURE_READINESS.md`. Nothing edited.

## Prompt A decisions (2026-11-02)

Q1–Q9 are recorded in `OPEN_PRODUCT_DECISIONS.md` § Owner answers. The follow-ups are:
- **Fix the stabilise-first defects on `main`** (Q7): the sync pull stall, the dead Move tile, the `/day` date mismatch, stale-ID taps, and a check of the Android time-zone re-plan. Merge here afterwards.
- **One docs PR on `main`** (Q14): D1–D7 plus the snooze, insert-bump and Week-scope corrections from Q1, Q2 and Q5.
- **A dial that crosses midnight** (Q8) needs a separate domain-change approval before it is built.

## Open items

- **Isolated local Supabase for integration tests:** propose a setup that can't touch the original app's users, sessions, database or services *before* any future integration test run. Don't create or change it until approved.
- **Android Wake Up double ring:** if background sync changes or turns off Wake Up while the app is closed, the old native alarm can't be cancelled (R-10). A fix is in progress on `main` (branch `fix/wake-up-background-bridge`). The native half waits for owner approval of an in-repo plugin package.
- **`DECISIONS.md`:** create it at the first decision that needs a log. Decisions are kept above until then. `SYNC_LOG.md` was started with merge 1 (2026-11-03).
