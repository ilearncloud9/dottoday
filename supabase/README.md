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
