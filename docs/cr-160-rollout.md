# CR-160: rolling out the server guard (migration 0014)

Status: **Direction approved by the owner (2026-11-08): single-step 0014, beta-only.** Not deployed. Nothing is deployed. The hosted project is untouched; no
`supabase db push` has run. Deploying needs the owner's separate authorisation.

## What 0014 changes

`sync_push` refuses the whole call (SQLSTATE 42501) when any change names no `owner`, or an owner that
is not `auth.uid()`. Builds from this branch always send `owner`. **Every older build sends none, so
once 0014 is live every push from an older build is refused.**

## Who is affected

- The app has not shipped publicly; older builds exist only as betas (TestFlight, Play internal, web
  staging; `docs/release-beta.md`). The app has **no minimum-version check** today, so an older build
  cannot be told "update required" by the server.
- An older build that is refused shows the existing sync error ("Couldn't sync… it will try again",
  R-08) and keeps retrying. Its unsynced work stays in its local outbox: the engine never deletes
  outbox rows on a server error (`sync_engine_test.dart` "a server error never deletes local data or
  the outbox").
- When it updates, local schema 18 gives every pending change its owner (the device's one profile,
  `migration_test.dart` v17 → v18) and the next sync sends it. Nothing is lost.
- **Residual risk:** an older build that already switched accounts on a shared device has already
  re-keyed the first account's rows to the second, locally. The update cannot tell them apart, so they
  would go to the second account. Only a device that switched accounts on an old build is exposed.

## What an older build does once 0014 is live

1. Its push is refused (SQLSTATE 42501, "names no owner"). The engine treats it as a server error:
   the round stops, the status shows the existing "Couldn't sync" error, and it retries with backoff
   up to every 5 minutes. Pulls before the push still work, so changes from other devices arrive.
2. Nothing is deleted. Unsynced changes stay in the local outbox, however many times it retries.
3. After updating, schema 18 gives each pending change its owner and the next push succeeds.
4. To verify before production (step 3 below): install the previous beta build on a test device,
   make offline changes, apply 0014 on staging, confirm the refusal and that the changes stay, update
   to the new build, and confirm they arrive once (RLS-scoped query, ids only).

## Order (approved)

1. **Ship the client first.** Builds from this branch work against the current server: the old
   `sync_push` ignores the extra `owner` key. Release them to every beta channel.
2. **Tell beta testers** (release notes, feedback channel): update before signing into a different
   account on a shared device; work made offline is kept and syncs after updating.
3. **Confirm, don't assume, that testers updated.** Check TestFlight and Play console install
   counts per build, and the web deploy. Run the older-build check above on staging.
4. **Deploy 0014** to staging first: `supabase db push` to staging only, run `supabase test db`
   there, run the shared-device checks (`docs/cr-160-verification.md` criterion 11) against staging.
5. **Then production, only with the owner's separate authorisation**, in a quiet window. Watch the Postgres logs
   for `sync_push: change … names no owner` (older builds still syncing) for a week.
6. **Rollback:** a new migration restoring the 0010 `sync_push` body (never editing 0014). Data is
   unaffected either way; refused changes are still on the devices.

## Option for the owner: staged guard

If older builds must keep syncing for longer, 0014 can be split before anything is deployed:
**0014** refuses only a change whose `owner` is present and wrong (older builds keep syncing; every
new build is fully guarded), and **0015**, later, refuses a missing `owner`. The cost: older builds
keep the CR-160 leak until 0015. Recommendation: the single-step 0014 as built, because no public
users are on older builds.

## Before production also needs

- A minimum-version mechanism (an app-config row read at start, "Update Dottoday to keep syncing")
  is the long-term way to tell older builds; it is new user-facing work and needs its own design
  approval. Not part of this branch.
