# ADR-0011 · Google and Microsoft calendars are read on request, never stored on the server

Status: Accepted · Date: 2026-10-24 · Task: M7.4 · Amends docs/04 §7

## Context
docs/04 §7 sketched Google/Microsoft calendars as Edge Functions that pull events into a
server table (`calendar_events`), which every client then syncs like any other table. Since then,
M7.2 built the import for device calendars as a pure, tested plan (`planCalendarImport`) with
fingerprints, held links and Trash rules, and M7.3 built write-back on a `CalendarWriter` seam.
Doing the same work a second time on the server would mean a TypeScript copy of that logic, a new
synced table, and every user's calendars stored on our server.

## Decision
- `calendar-oauth` runs the OAuth code flow (PKCE, single-use `state` in `calendar_oauth_states`,
  10 minutes). The refresh token is stored in Supabase Vault (`vault.secrets` named
  `calendar_account:<id>`), reachable only through service-role functions. The app never sees a
  client secret or a provider token.
- `calendar-sync` is a request-driven proxy: `calendars`, `events`, `event`, `update` (with
  `If-Match`) and `disconnect`, for the caller's own accounts only. It refreshes access tokens and
  stores rotated ones, and it stores no calendar content.
- The app treats connected accounts as one more event source: `FunctionCloudCalendars` implements
  the same `CalendarEventReader` as the device gateway, and a second `CalendarImporter` (owning
  only the `google`/`microsoft` links) runs the M7.2 plan unchanged. The same class is the
  `CalendarWriter` for write-back, with the HTTP etag as its version.
- Imported cloud events stay **device-only**, like device imports: the account is connected once
  (server side), and every signed-in device imports it, so every device shows the same events.
  Subtasks, notes, and moves without write-back stay on the device where they were made.

## Alternatives
- **Server pull into `calendar_events` plus sync** (the original sketch): it would allow background
  refresh and webhooks. Rejected: it stores calendar content on our server (06 §6 minimisation), it
  needs a second implementation of the import rules and a new synced table, and the offline timeline
  already comes from the local import.
- **Syncing cloud imports between devices**: one device's subtasks on a meeting would then show
  on the others. Rejected for now: every device imports too, so the rows would duplicate unless
  occurrence ids were deterministic and `calendar_links` gained sync columns (schema and sync engine
  change). It is a possible follow-up if people ask for it.
- **The OAuth flow in the app** (provider SDKs, tokens in secure storage): rejected by 06 §1. Each
  platform would hold a client secret or a long-lived token.

## Consequences
- An account that can't be read (revoked, provider down) holds the whole cloud import, so its
  events never look removed (R-08). Settings shows Reconnect.
- Imports refresh on the app's own schedule (start, resume, every 6 h, after a switch), not in
  real time. Push notifications from the providers are a possible later addition.
- Owner gates: the Google Cloud and Microsoft Entra apps, the function secrets, and the function
  deploy (docs/08 §6.1).
