# Supabase

```
supabase init            # once, in repo root (creates supabase/config.toml)
supabase start           # local stack
supabase db reset        # applies migrations/*.sql
supabase test db         # runs tests/*.sql (pgTAP)
supabase db push         # to the linked remote project
```

- Migrations are append-only. Never edit `0001_init.sql`; add `0002_...sql`.
- Edge Functions (`supabase/functions/`): `calendar-oauth` (Google/Microsoft code exchange with PKCE,
  token in Vault; `verify_jwt = false`, it checks the JWT itself), `calendar-sync` (calendars, events,
  write-back with If-Match, disconnect — read on request, nothing stored), `delete-account`,
  `send-push` (web VAPID). Shared code in `functions/_shared/`.
- Enable providers in the dashboard: Email (OTP/magic link), Apple, Google. Turn on PKCE.
- Enable `pg_cron` and schedule `purge_old_tombstones` nightly (see end of 0001).
- Vault: calendar OAuth tokens live in `vault.secrets` named `calendar_account:<id>`, written and read only
  through the service-role functions of `0005_calendar_oauth.sql` (`calendar_account_connect`,
  `calendar_token_get/put`); deleting the account row deletes the token (M7.4, ADR-0011).
- Function secrets: copy `functions/.env.example` to `functions/.env` (git-ignored) for local
  `supabase start` / `supabase functions serve`; hosted values are set with `supabase secrets set`
  (owner, docs/08 §6.1). Values starting with `placeholder` count as unset.
- Function tests (no Deno needed): `node --experimental-strip-types --test functions/**/*_test.ts`.

## Integration tests

Run the RLS (pgTAP) and client tests on the isolated test stack, never on the app's own local stack
(`project_id = "dottoday"`, 54321), which `db reset` would wipe:

```
tool/test_stack.sh start   # second stack "dottoday-test", every port +1000 (API 55321)
tool/test_stack.sh reset   # db reset of the test stack only
tool/test_stack.sh test    # supabase test db, then flutter test --tags supabase
tool/test_stack.sh stop    # stop, keep nothing (--no-backup)
```

- `tool/test_stack.sh env` prints the test stack's exports, for running one client test file by hand.
- `.test-stack/` (git-ignored) is regenerated each run from `config.toml`: `migrations` and `tests`
  are symlinks, the functions a fresh copy (the edge runtime cannot follow host symlinks), their
  secrets from `functions/.env.example`. It is never linked: the script refuses to run if it is, and
  never pushes, links, sets secrets or deploys.
- The client tests refuse any URL but `127.0.0.1`/`localhost` on 55321 (54321 only with `CI=true`),
  take keys only from the environment, use `@example.test` addresses and delete their users at the end.
