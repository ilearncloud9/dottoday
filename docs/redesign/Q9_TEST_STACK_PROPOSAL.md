# Q9 · An isolated local Supabase stack for integration tests (proposal)

**Status:** approved 2026-11-15 (ED-352): decision A (P1 to P4 as written), C at the defaults. Decision B (CLAUDE.md §7 wording) not approved; CLAUDE.md stays as it is. Nothing created yet; the PR is next.
**Scope:** local development on this Mac only. CI already runs on a fresh, throw-away runner and keeps its current setup.

## 1. What is wrong today (read from the repo, nothing run)

| # | Finding | Where | Risk |
|---|---|---|---|
| F1 | The redesign worktree and the original checkout (`/Users/ops/Documents/dottoday`, `main`) both use `project_id = "dottoday"` and the same ports (API 54321, DB 54322, shadow 54320, pooler 54329, Studio 54323, Mailpit 54324, analytics 54327). | `supabase/config.toml` in both | `supabase start` from either attaches to the **same containers and volumes**. A `supabase db reset` here wipes the original app's local users, sessions and data. |
| F2 | The Flutter integration helpers read `SUPABASE_URL` and the keys from the environment, and otherwise ask `supabase status` from the current folder. | `app/test/supabase/local_supabase.dart` | A shell with the hosted project's URL exported points the tests at the hosted project. Nothing refuses it. |
| F3 | Tests create users (`m61-…@example.com`, `m65-…`, two-device users) and only the delete-account test removes its own. | `app/test/supabase/*_test.dart` | Users pile up in whichever stack ran the tests: today, the one the original app uses. |
| F4 | `supabase test db` (pgTAP) and `supabase db reset` run against "the" local stack, chosen by the folder you are in. | `supabase/README.md`, CLAUDE.md §7 | Easy to reset the wrong stack from the wrong folder. |

CI (`.github/workflows/supabase.yml`) is already safe: each run starts its own stack on an empty runner and exports that stack's own keys.

## 2. Proposal

### P1 · A second stack with its own name, ports and data
- A small script, `tool/test_stack.sh`, builds a git-ignored folder `.test-stack/` on demand:
  - `.test-stack/supabase/config.toml` is **generated** from `supabase/config.toml`, so it never drifts: `project_id = "dottoday-test"` and every port moved up by 1000 (API 55321, DB 55322, shadow 55320, pooler 55329, Studio 55323, Mailpit 55324, analytics 55327, inspector 9083).
  - `.test-stack/supabase/migrations`, `tests` and `functions` are **symlinks** to the real folders, so the test stack always runs the repo's own schema and pgTAP tests.
- Every command goes through the CLI's `--workdir .test-stack`. A different `project_id` gives different Docker containers and volumes, so the original app's stack is never touched.
- Commands: `tool/test_stack.sh start | reset | test | env | stop`.
  - `reset` is `supabase --workdir .test-stack db reset`. It only ever resets the test stack.
  - `test` runs `supabase test db` and then `flutter test --tags supabase --concurrency=1` with the test stack's URL and keys exported.
  - `stop` uses `--no-backup`, so nothing is kept between runs.

### P2 · Tests refuse anything that is not a local stack
`local_supabase.dart` checks the URL once, before any test runs, and fails with a clear message unless:
- the host is `127.0.0.1` or `localhost`;
- the port is the test stack's (55321), or 54321 only when `CI=true`, which is the throw-away runner.

It also stops asking `supabase status` from the current folder. Keys come only from the exported environment (set by `tool/test_stack.sh env` or by CI), so a missing key fails instead of silently using the shared stack.

### P3 · Test users clean up after themselves
- Every test user gets a `@example.test` address, a reserved domain that is never deliverable.
- A shared `tearDownAll` deletes the users the file created through the local admin API. It uses the test stack's own service key, never one from the hosted project.
- `tool/test_stack.sh reset` wipes everything anyway.

### P4 · The test stack can never reach the hosted project
- `.test-stack/` is never `supabase link`ed. The script refuses to run if `.test-stack/supabase/.temp/project-ref` exists.
- The script never runs `db push`, `link`, `secrets` or `functions deploy`.
- Function secrets in `.test-stack` come from `supabase/functions/.env.example` (placeholders only), never from a real `.env`.

### P5 · Docs and habits
- `supabase/README.md` gets a short "Integration tests" section with the four script commands.
- CLAUDE.md §7's "Run `supabase db reset` locally and the RLS tests" becomes "`tool/test_stack.sh reset && tool/test_stack.sh test`". A wording change; it needs your OK because CLAUDE.md is the rulebook.

## 3. What it costs and what it does not change
- **Disk and memory:** a second set of containers while it runs (about 1.5 to 2 GB RAM). `stop` frees it; nothing runs unless you start it.
- **No new dependency:** the Supabase CLI already in use (2.121.0) and Docker. No pubspec change.
- **Unchanged:** CI, the hosted project, the original app's local stack and data, migrations, the app code.

## 4. Changes once approved (one PR on its own branch, from `main`)
1. `tool/test_stack.sh` (new), plus `.test-stack/` in `.gitignore`.
2. `app/test/supabase/local_supabase.dart`: the URL guard (P2) and the cleanup helper (P3); the tests use `@example.test`.
3. `supabase/README.md` (P5), and CLAUDE.md §7 only if you approve that wording.
4. Verified by: starting the test stack while the original stack is up and showing both run side by side; running `reset` and `test`; and checking with `supabase status` in the original checkout that its data is untouched.

## 5. Decisions for the owner
- **A.** Approve P1 to P4 as written (recommended).
- **B.** Also change CLAUDE.md §7's wording (P5, second bullet).
- **C.** The port offset (+1000) and the project name `dottoday-test`, if you prefer others.
