# Privacy answers — App Store "App Privacy" and Play "Data safety"

Written in M8.6 (2026-10-24) from what the code does, not from intent.
**For owner/legal review before submission** — the consoles' answers are a
legal statement. Each row names the code it rests on; if that code changes,
this file and `app/web/privacy.html` change in the same commit.

## 1. What leaves the device (the facts the answers rest on)

| Data | When | Where to | Code |
|---|---|---|---|
| Email address | only if the person signs in (magic link, Sign in with Apple — possibly a relay address — or Google) | Supabase Auth (our project) | `app/lib/data/auth/`, `supabase/migrations/0001_init.sql` |
| User id (random UUID from Supabase) | signed in | Supabase | every synced row's `user_id` |
| Display name (optional, typed by the person) | signed in | Supabase `profiles` | 0001 |
| Tasks: titles, notes, times, colours, icons, repeat rules, alerts, subtasks, energy, settings | only when signed in (sync) | Supabase Postgres, TLS, RLS to the owner's rows | `app/lib/data/sync/server_columns.dart` (`syncedEntities`) |
| Device-calendar events (Apple/Android/macOS) | never | stay on the device; `isDeviceOnly` keeps them out of sync | `app/lib/domain/calendar/calendar_import_rules.dart`, `app/lib/data/sync/requeue.dart` |
| Google / Microsoft calendar: refresh token | when the person connects that calendar | Supabase Vault (service role only) | `supabase/migrations/0005_calendar_oauth.sql` |
| Google / Microsoft calendar: account email (row label) | connected | `calendar_accounts.label` | 0005, `calendar-oauth` |
| Google / Microsoft calendar events | on each refresh / write-back | pass through the `calendar-sync` Edge Function to the app; **not stored** on our server; write-back sends start, end and title | `supabase/functions/calendar-sync/` |
| Crash reports | only when the build has `SENTRY_DSN` | Sentry: error type, stack trace, log event names and counts, OS/device model, app version, a random install id; no user, no messages, no screenshots, no view hierarchy, no task text | `app/lib/data/observability/sentry_reporting.dart` |
| Web push (web only) | person turns on browser notifications | the push body is encrypted in the browser to its own keys; our server stores the endpoint, ciphertext, fire time and task ids | `app/web/push_crypto.js`, `supabase/migrations/0003_web_push.sql` |
| Account deletion email | person deletes the account | Resend (email delivery) | `supabase/functions/delete-account/` |
| Feedback | person taps Send feedback and sends the draft from their own mail app | our feedback inbox; optional diagnostics block: version, platform, counts, random sync node id, no task text | `app/lib/data/feedback/` |
| Web fonts (web only) | glyph fallback for characters Inter lacks | fonts.gstatic.com (font files only; the request carries the IP address) | 06 §8 |

Nothing else: no analytics or advertising SDKs, no advertising identifiers,
no location, no contacts, no photos, no health data, no tracking across apps
or websites (06 §6).

## 2. App Store Connect — App Privacy

**Tracking:** No. (No data is linked with third-party data for advertising
or shared with data brokers; no ATT prompt.)

**Data collected** (Apple counts data as collected when it is sent off the
device and kept longer than needed to serve the request in real time — so
device calendars, and Google/Microsoft events passing through the function,
are *not* collected):

| Apple category › type | Collected | Linked to the user | Purpose | Notes |
|---|---|---|---|---|
| Contact Info › Email Address | Yes | Yes | App Functionality | sign-in; calendar account label; deletion confirmation |
| Contact Info › Name | Yes | Yes | App Functionality | optional display name |
| User Content › Other User Content | Yes | Yes | App Functionality | tasks synced when signed in |
| User Content › Customer Support | Yes | Yes | App Functionality | only feedback the person emails us (owner/legal: may qualify for the optional-disclosure exemption; disclosing is the safe choice) |
| Identifiers › User ID | Yes | Yes | App Functionality | Supabase account id |
| Diagnostics › Crash Data | Yes | **No** | App Functionality | Sentry, no user attached |
| Diagnostics › Other Diagnostic Data | Yes | **No** | App Functionality | Sentry session/release health, random install id |

Everything else: **Not collected** (Location, Contacts, Health & Fitness,
Financial Info, Sensitive Info, Browsing/Search History — recent searches
stay on the device —, Purchases, Usage Data, Device ID, Audio/Photos).

If the release is built **without** `SENTRY_DSN`, remove both Diagnostics rows.

**Privacy policy URL:** the published `web/privacy.html` (owner gate, 08 §6.1).

## 3. Google Play — Data safety

**Does your app collect or share any of the required user data types?** Yes.
**Is all user data encrypted in transit?** Yes (TLS 1.2+; 06 §5).
**Do you provide a way for users to request that their data is deleted?**
Yes — Settings › Account › Delete account in the app, and the web page
`privacy.html#delete` (Play requires a web link for account deletion; owner
gate 08 §6.1).
**Shared with third parties?** No. Supabase, Sentry and Resend process data
on our behalf as service providers, which Play does not count as sharing.

| Play category › type | Collected | Shared | Ephemeral | Required / optional | Purposes |
|---|---|---|---|---|---|
| Personal info › Email address | Yes | No | No | Optional (sign-in is optional) | Account management, App functionality |
| Personal info › Name | Yes | No | No | Optional | App functionality |
| Personal info › User IDs | Yes | No | No | Optional | Account management |
| App activity › Other user-generated content | Yes | No | No | Optional (sync only) | App functionality |
| Calendar › Calendar events | Yes | No | **Yes** (Google/Microsoft events pass through the function, not stored) | Optional | App functionality |
| App info and performance › Crash logs | Yes | No | No | Required in builds with `SENTRY_DSN` (no in-app switch today) | App functionality (used only to fix crashes; owner/legal confirm it is not "Analytics") |
| App info and performance › Diagnostics | Yes | No | No | as above | App functionality |
| Messages › Other in-app messages | No | — | — | — | feedback goes through the person's own mail app |
| Device or other IDs | No | — | — | — | the Sentry install id is random and app-scoped (owner/legal: some reviewers want it declared here; declaring it is harmless) |

Location, contacts, photos, files, health, financial, web history, audio:
not collected. Device calendars on Android are read on the device only.

## 4. Owner actions these answers depend on (08 §6.1)

1. Sentry project: **Data Scrubbing on**, **"Prevent Storing of IP
   Addresses" on**, region chosen (EU recommended for the EU audience) —
   the "not linked" answer assumes Sentry keeps no IP.
2. Supabase project region and the processor list in the policy (§ "Who
   processes it") filled in.
3. The policy published and its URL set as `PRIVACY_POLICY_URL` in
   `.env.prod` and in both consoles.
4. Fill both consoles from §2 and §3; record the date here.

| Console | Filled on | By |
|---|---|---|
| App Store Connect — App Privacy | | |
| Play Console — Data safety | | |
