# Dottoday — agent-ready build kit (Structured-style daily planner)

App name: **Dottoday** (Dart package / bundle id slug: `dottoday`).

Targets: iPhone, Android, macOS, Web. Stack: **Flutter + Supabase**, offline-first.

## What this folder is

Everything a coding agent (Claude Code or OpenAI Codex) needs to build the app to completion
without you re-explaining the product every session:

| Path | Purpose |
|---|---|
| `CLAUDE.md` | Instructions Claude Code reads automatically. |
| `AGENTS.md` | Same instructions for Codex (and any AGENTS.md-aware tool). |
| `.claude/commands/*.md` | Slash commands: `/next-task`, `/review`, `/ship-check`. |
| `.claude/settings.json` | Safe default permissions for Claude Code. |
| `docs/00-vision.md` | Product principles and who it is for. |
| `docs/01-research-complaints.md` | What Structured users complain about → the requirements that fix them. |
| `docs/02-prd.md` | Feature spec with user stories and acceptance criteria. |
| `docs/03-ux-spec.md` | Screens, flows, interaction rules, design tokens, accessibility. |
| `docs/04-architecture.md` | Flutter architecture, folder layout, offline-first sync design. |
| `docs/05-data-model.md` | Entities, recurrence and timezone semantics. |
| `docs/06-security.md` | Threat model, auth, RLS, storage encryption, privacy. |
| `docs/07-platform-notes.md` | iOS / Android / macOS / Web specifics: widgets, notifications, calendar. |
| `docs/08-testing-qa.md` | Test strategy, QA checklist, release gates. |
| `docs/09-implementation-plan.md` | Ordered milestones with definition of done — the agent works through this. |
| `docs/adr/` | Architecture decision records. |
| `supabase/migrations/0001_init.sql` | Postgres schema + row-level security. |
| `app/` | Flutter project seeds: `pubspec.yaml`, `analysis_options.yaml`, `.env.example`, `.gitignore`. |

## How to start

1. Create an empty git repo and copy this folder's contents into its root.
2. Create a Supabase project; copy URL + anon key into `app/.env` (never commit it); run with `flutter run --dart-define-from-file=.env` (ADR-0005).
3. Open the repo in Claude Code (`claude`) or Codex (`codex`).
4. First prompt: **"Read CLAUDE.md and docs/09-implementation-plan.md, then start Milestone 0."**
   Or in Claude Code: `/next-task`.
5. Each milestone ends with `/ship-check` (lint, tests, security checklist) before moving on.

## Ground rules baked into the kit

- Every complaint in `docs/01-research-complaints.md` maps to a requirement ID (`R-xx`) that the PRD and plan reference.
- Core planner features (recurrence, calendar import, notifications, sync, export) are **free** — the paywall is the number-one complaint.
- Feature parity across all four platforms is a release gate, not a nice-to-have.
- Accessibility (screen readers, Dynamic Type, reduced motion, keyboard) is part of every milestone's definition of done.
- Security is designed in: Supabase RLS on every table, encrypted local DB, no secrets in the repo.
