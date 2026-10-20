# Supabase

```
supabase init            # once, in repo root (creates supabase/config.toml)
supabase start           # local stack
supabase db reset        # applies migrations/*.sql
supabase test db         # runs tests/*.sql (pgTAP)
supabase db push         # to the linked remote project
```

- Migrations are append-only. Never edit `0001_init.sql`; add `0002_...sql`.
- Edge Functions (create under `supabase/functions/`): `calendar-oauth` (Google/Microsoft code
  exchange, token in Vault), `calendar-sync` (scheduled pull), `delete-account`, `send-push` (web VAPID).
- Enable providers in the dashboard: Email (OTP/magic link), Apple, Google. Turn on PKCE.
- Enable `pg_cron` and schedule `purge_old_tombstones` nightly (see end of 0001).
- Vault: `select vault.create_secret(token, 'calendar_account:<id>')` from Edge Functions only.
