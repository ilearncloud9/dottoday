# AGENTS.md — Dottoday (Codex / any AGENTS.md-aware agent)

You are building **Dottoday**, a visual, timeline-based daily planner (Structured-style) for iPhone,
Android, macOS and Web. Read this file fully before touching code. It mirrors CLAUDE.md; keep both in sync (CLAUDE.md is canonical). It is the source of truth for
*how* to work; the `docs/` folder is the source of truth for *what* to build.

## 1. Read order (every new session)

1. This file.
2. `docs/09-implementation-plan.md` — find the first milestone/task not marked `[x]`.
3. The docs that task references (PRD section, UX section, data model, security).
4. `docs/01-research-complaints.md` when a task carries an `R-xx` tag — the tag is the reason the task exists.

Never start coding from memory of the product. Always open the spec for the feature you touch.

## 2. Stack (fixed — do not substitute)

| Concern | Choice |
|---|---|
| UI | Flutter 3.x stable, Dart 3.x, Material 3 with custom theme (see UX spec) |
| State | Riverpod 3 (code-gen, `riverpod_annotation`/`riverpod_generator`; `riverpod_lint` native analyzer plugin — run `dart analyze`). Root `ProviderScope` disables auto-retry; providers opt in |
| Navigation | `go_router` |
| Local DB | Drift (SQLite) via `sqlcipher_flutter_libs` for encryption at rest |
| Backend | Supabase (Postgres, Auth, Realtime) — schema in `supabase/migrations` |
| Sync | Offline-first, local DB is source of truth, see `docs/04-architecture.md` §4 |
| Models | `freezed` + `json_serializable` |
| Dates | `timezone` + `rrule` packages; store UTC + IANA zone, render local |
| IDs | UUID v7 (`uuid` package, `Uuid().v7()`) |
| Notifications | `flutter_local_notifications` (mobile/desktop), Web Push via service worker |
| Calendar | `device_calendar` (iOS/Android/macOS), CalDAV/Google/Microsoft via backend functions (web) |
| Secrets | `flutter_secure_storage` on device; public config (Supabase URL + anon key) compiled in via `--dart-define-from-file=.env` / `.env.prod` (ADR-0005) |
| i18n | `flutter_localizations` + ARB files; every user-facing string goes through `AppLocalizations` |
| Tests | `flutter_test`, `mocktail`, `integration_test`, `golden_toolkit` |

Adding any other dependency requires a one-line justification in the PR/commit body and an entry in
`docs/adr/` if it changes architecture.

## 3. Project layout (feature-first, boundaries are sacred)

```
app/
  lib/
    main.dart, app.dart, bootstrap.dart
    core/            # theme, router, l10n, logging, errors, env, utils (no feature imports)
    data/            # drift db, DAOs, supabase client, sync engine, repositories' impls
    domain/          # entities (freezed), repository interfaces, pure services (scheduler, recurrence)
    features/
      timeline/      # day view, drag/resize, now-marker, bump/shift
      inbox/
      task_editor/
      recurrence/
      calendar_import/
      notifications/
      settings/
      onboarding/
      auth/
      sync_status/
      export/
      widgets_home/  # home-screen widgets glue (platform channels)
    shared/          # reusable UI components (buttons, sheets, pickers) — no business logic
  test/              # mirrors lib/
  integration_test/
```

Rules: `features/*` may import `domain`, `data` (via interfaces), `shared`, `core`. `domain` imports
nothing from Flutter UI. `shared` never imports `features`. Cross-feature calls go through `domain`
interfaces or Riverpod providers, never direct widget imports.

## 4. Engineering rules

- Clarity over cleverness. Small files (≤300 lines), small functions (≤40 lines), early returns.
- Search before creating: `grep -r "class .*Repository"`, `lib/shared/`, `lib/core/utils/` first. No duplicate helpers.
- Immutable models. No `setState` outside leaf widgets; state lives in Riverpod notifiers.
- All times: `DateTime.utc` in storage, `TZDateTime` for display/arithmetic. Never `DateTime.now()` in domain code — inject a `Clock`.
- Money (phase 2): integer minor units + ISO currency code.
- Errors: typed (`sealed class AppFailure`), never swallowed; user-facing messages via l10n, no stack traces.
- Logging: structured, redact PII (titles/notes are PII — log IDs only).
- No hardcoded strings in UI. No hardcoded colors/sizes — use `AppTheme` tokens from the UX spec.
- Comments explain *why*. Link to `docs/` sections or `R-xx` IDs.
- Each public domain function gets a doc comment with an example when non-obvious.

## 5. Definition of done (every task)

- [ ] Acceptance criteria from the PRD/plan met, including the linked `R-xx` improvements.
- [ ] `flutter analyze` clean (no suppressed warnings without a comment).
- [ ] `dart format` applied.
- [ ] Unit tests for domain logic; widget tests for new screens; golden tests for timeline changes.
- [ ] Works on all four targets or the task explicitly lists platform exceptions with a follow-up task.
- [ ] Accessibility: semantics labels, 44pt touch targets, Dynamic Type up to 200%, reduced-motion respected, keyboard operable on desktop/web.
- [ ] Security checklist in `docs/06-security.md` §9 re-checked if the task touches auth, storage, sync, or input.
- [ ] `docs/09-implementation-plan.md` checkbox ticked; CHANGELOG entry added.

## 6. Workflow

1. Restate the task in one sentence. Confirm scope against the plan.
2. Explore existing code for patterns.
3. Plan the smallest change; for >50 lines or schema/dependency changes, write the plan in your reply first.
4. Implement.
5. Verify: `flutter analyze && flutter test` (and `flutter test integration_test` for flows).
6. Report: short changelog (what/why/follow-ups).

Git: branch `type/short-desc`, Conventional Commits, one logical change per commit, never commit to `main`.
Never run destructive git commands or delete >30 lines without saying so first.

## 7. Supabase rules

- Every table has RLS enabled with policies in the same migration. Never ship a table without a policy.
- Client uses the **anon** key only. Service-role key lives only in Edge Functions / CI secrets.
- Schema changes = new migration file (`supabase/migrations/NNNN_name.sql`), never edit old ones.
- Run `supabase db reset` locally and the RLS tests in `supabase/tests` before marking a schema task done.

## 8. Things that are non-negotiable (from user research)

These exist because real users complained about the original app. Do not cut them for time:

- Recurring tasks, calendar import, custom notifications, export: **free tier**. (R-01, R-02, R-03, R-11)
- Drag to move, drag edges to resize, long-press multi-select, and **shift everything after this** in one gesture. (R-04, R-05)
- Quick add: a task is creatable in ≤ 2 taps + typing; natural-language time parsing; paste a list → multiple tasks. (R-06, R-07)
- Sync is conflict-safe and visible: a sync status indicator, never silent data loss, local backups + export. (R-08, R-11)
- Recurring subtasks reset correctly per occurrence (occurrence-scoped completion). (R-09)
- Notifications fire exactly once, support lead time ("10 min before") and multiple alerts. (R-10)
- Screen reader support is tested in CI with semantics tests. (R-12)
- All four platforms get the same features in the same release. (R-13)

## 9. Equivalent prompts (no slash commands in Codex)

- "Next task": open docs/09-implementation-plan.md, pick the first unchecked item, follow §6.
- "Review": self-review the diff against §4–§7 before finishing.
- "Ship check": run `flutter analyze && flutter test`, walk docs/06-security.md §9 and docs/08-testing-qa.md release gates.
