# 05 — Data Model

All IDs are UUID v7 (time-ordered, client-generated). All timestamps are UTC epoch ms (`*_utc`).
Server and local schemas are identical in meaning; local adds sync columns. SQL in
`supabase/migrations/0001_init.sql`.

## Entities

### `profiles`
One per auth user. `id (= auth.users.id)`, `display_name`, `tz_id`, `locale`, `settings jsonb`
(day boundaries per weekday, snapping, shift policy, default alerts, theme…), `created_at`, `updated_at`.

### `series`  (a recurring task template)
`id, user_id, title, notes, color_key, icon_key, duration_min, rrule text, dtstart_local text
(ISO without zone), tz_id, until_utc?, count?, pinned bool, travel_buffer_min int, energy smallint?,
alerts jsonb [ {offsetMin:int, kind:'before'|'at_start'|'at_end'|'overdue', sound?} ],
subtask_template jsonb [ {id, title, sortOrder, durationMin?} ], duration_from_steps bool, archived_at?, created_at, updated_at, deleted_at?`

### `occurrences`  (every block on the timeline, scheduled or not)
`id, user_id, series_id? (null = one-off), original_start_utc? (for series exceptions),
title, notes, color_key, icon_key, start_utc? (null = inbox), tz_id, duration_min, pinned,
travel_buffer_min, energy?, alerts jsonb (overrides series when non-null), status
('planned'|'done'|'skipped'), completed_at_utc?, sort_order (inbox ordering), source
('user'|'calendar'), calendar_link_id?, snoozed_until_utc?, actual_start_utc?, actual_end_utc?,
duration_from_steps bool, move_count int (0–1000, M10.7), routine_start bool (M11.4), created_at,
updated_at, deleted_at?`

`routine_start` (M11.4, migration 0007, Drift schema 6): the first step of a dropped routine; its
at-start alert rings loud like an alarm (11 A0, `NotificationPlanner`).

`actual_start_utc` / `actual_end_utc` (M6.5.1, `11-standout-roadmap.md` B1) record when the user really
started (first tap of the live dot, Start, opening Focus) and finished (Done); never inferred from the
clock. `duration_from_steps` (B2): the length follows the sum of the subtasks' durations.

Rules
- A series row never appears on the timeline itself; the client materialises occurrences 90 days
  ahead (`materialised_through_utc` on series). Materialised rows for an unchanged series are
  idempotent (`unique(series_id, original_start_utc)`).
- Editing "this occurrence" writes the occurrence row (keeps `series_id`, `original_start_utc`).
  "This and following" splits the series (`until` on old, new series from that date). "All" edits the
  series and re-materialises untouched occurrences (occurrences with user edits are preserved).
- Completion is **per occurrence** (R-09). Subtask state too (below).

### `routines`  (saved slices of thread, M11.4, `11-standout-roadmap.md` C2)
`id, user_id, title (1–200, trimmed), anchor ('wake'|'bed'|'time'), anchor_minute? (0–1439, set
exactly when anchor = 'time'), items jsonb [ {id, title, colorKey, iconKey, offsetMin (0–1440, from
the first step's start), durationMin (5–1440)} ] (1–30 steps; the server allows 0–30 so a placeholder
row can exist mid-push), sort_order double, created_at, updated_at, deleted_at?`

One table, not `routines` + `routine_items` as first planned: a routine is edited as a whole and
rarely, and `items` mirrors `series.subtask_template` (one sync entity, one RLS policy, one export
list). A drop writes ordinary occurrences (one per step, the first with `routine_start`); nothing on
the timeline points back at the routine, so editing or deleting a routine never touches a day.
Placement: `wake` — the first step at that day's Wake Up; `bed` — the last step ends at Wind Down;
`time` — the first step at `anchor_minute` local wall clock (DST-true). RLS: own rows only; synced
through `sync_push` (0007 adds the entity); purged like other tombstones after 30 days.

### `subtasks`
`id, user_id, occurrence_id, title, done bool, sort_order, duration_min? (1–1440, B2), done_at?
(ADR-0012), created_at, updated_at, deleted_at?` — `sort_order` is the step order B2 asks for (no
separate `sort_index`). `done_at` is when the step was ticked, set and cleared with `done` in the same
write, never backfilled; no CHECK ties the two (field-level sync), so readers use `done and done_at`.
Created from `series.subtask_template` when an occurrence is materialised; never shared across
occurrences.

### `calendar_accounts`
`id, user_id, provider ('apple_device'|'android_device'|'google'|'microsoft'|'caldav'), label,
external_account_id, write_back bool, enabled bool, created_at, updated_at`
OAuth refresh tokens are **not** in this table — they live in `vault.secrets` (Supabase Vault), keyed
by `calendar_accounts.id`, accessible only from Edge Functions.
Device calendars (M7.1): one **local** row per device calendar the person has switched in Settings ›
Calendars — `provider` `apple_device` / `android_device`, `external_account_id` = the device's calendar
id, `label` = its name (clipped to 80), `enabled` = the switch, `write_back` = M7.3's per-calendar
opt-in (off until chosen; never for a read-only calendar). A calendar with no row is on. These rows never sync (device ids mean nothing elsewhere).
Google/Microsoft (M7.4, ADR-0011): on the **server**, one row per connected account (`provider`
`google` / `microsoft`, `external_account_id` = the provider's stable account id: Google `sub`,
Microsoft `oid`; `label` = its email), unique per `(user_id, provider, external_account_id)`, created
only by `calendar-oauth` (clients may read and delete their own rows, nothing else; deleting one
deletes its Vault token by trigger). On the **device**, each of its calendars gets a local row like a
device calendar's: `provider` google/microsoft, `external_account_id` = `<server account id>/<provider
calendar id>`, so the switches and write-back opt-ins are per device. `calendar_oauth_states` (server
only, no client access): a connect in progress, with its PKCE verifier and where the browser goes
back; single use, 10 minutes.

### `calendar_links`
`id, user_id, account_id, external_calendar_id, external_event_id, etag, last_synced_utc,
read_only bool`. Joined to `occurrences.calendar_link_id`.
Device calendars (M7.2): one **local** link per imported item. `external_event_id` is
`<event id>@<epoch ms>` — the instance's start, or for an all-day event the UTC midnight of each
day it covers (one item per day) — because EventKit gives every instance of a repeating event the
same id. `etag` holds the import fingerprint `v1;<start ms>;<duration min>;<title hash>;<notes
hash>` (12-hex SHA-256 prefixes, never the text): a re-import changes only what changed in the
calendar since, so a local move or rename stays until the calendar changes that same field, and
notes edited in Dottoday are never replaced. `last_synced_utc` = when calendar changes were last
applied. Imported occurrences (`source = 'calendar'`) and their subtasks are **device-only**: the
write path upserts them without `change_log` rows and `requeueAll` skips them (each device imports
its own calendars, so a synced copy would show twice elsewhere). Google/Microsoft imports (M7.4) are
device-only too: every signed-in device imports the connected account itself, so all show the same
events, and subtasks and notes stay where they were made (ADR-0011). Their links key each instance
by the provider's own instance id (a repeating event's instances differ there), so an instance can
be written back. An event gone from the calendar (or a calendar switched off or removed) removes its
occurrence outright when nothing of the person's is on it, else soft-deletes it detached
(`calendar_link_id` null) so Trash keeps the subtasks/notes; an imported occurrence the person
deleted keeps its link, so the event is not brought back. Imported events carry no Dottoday alerts
(`alerts` null; the calendar app reminds) until the person adds some.
Write-back (M7.3): `read_only` is true when nothing may go back to the event — the calendar is
read-only, or the item is all-day or an instance of a repeating event (refreshed by every import;
also set when a write finds the event gone or no longer writable). The `etag` fingerprint is the
base of write-back's three-way merge: after a successful write it holds the merged start, length and
title (notes hash unchanged, notes never go back) and `external_event_id` the moved instance's key,
so the next import sees nothing new.
Travel time (M7.5, local schema 4): `location` (nullable, ≤ 200 chars, control characters
removed, blank → null) is the event's place as its calendar gave it (device `location`, Google
`location`, Microsoft `location.displayName`), refreshed by every import. Device-only like the link
itself: the server's `calendar_links` has no such column and never receives one (links don't sync),
so no Supabase migration. It is PII like a title — never logged, never sent anywhere. It feeds only
the travel time suggestion; an accepted suggestion is the occurrence's `travel_buffer_min`.
Series (docs/02 F5.7, local schema 12): `series_key` (nullable, ≤ 512) names the repeating event an
instance belongs to — the shared event id on iOS/macOS/Android, Google `recurringEventId`, Microsoft
`seriesMasterId` — and is null for a one-off event. Instances of one account sharing it are one
series here. Device-only like the rest of the link; refreshed by every import (null on upgrade until
the next import). A key too long to store is left null, never cut (a cut key could join two series).

### `conflicts`
`id, user_id, entity ('series'|'occurrences'|'subtasks'|'profiles'|'routines'), entity_id, field,
mine jsonb, theirs jsonb, created_at, resolved_at?`

### `change_log` (local only) and `sync_cursors` (local only)
See architecture §4. `change_log (seq autoincrement, entity, entity_id, field, value json, hlc)` is
the push outbox (rows deleted on ack; its `entity` CHECK names the five synced tables — schema 6
rebuilt it to add `routines`, keeping pending rows); `sync_cursors (entity pk, since_utc)` holds the highest server
`updated_at` pulled per table.

### Local schema (Drift, `app/lib/data/db`, M2.1)
- Same tables and checks as the server, `STRICT`, plus `dirty` / `version` on the tables pushed via `sync_push` (profiles, series, occurrences,
  subtasks, routines). Calendar tables have none: they sync through their provider (M7).
- Instants are `INTEGER` UTC epoch ms (not Drift `DateTime`); enums are `TEXT` with `CHECK (… IN …)`;
  `jsonb` columns are `TEXT` with `CHECK (json_valid(…))`; booleans are `INTEGER` 0/1.
- Before sign-in the single local `profiles.id` is a client UUID v7. Every `user_id` references it
  with `ON UPDATE CASCADE`, so first sync (M6.4) re-owns all rows by updating one id.
- Search (M2.6): FTS5 `search_index` (`app/lib/data/db/search.drift`), one document per live
  occurrence (`rowid` = occurrence rowid; title, notes, live subtask titles; `unicode61` with
  diacritics removed), maintained by triggers on `occurrences`/`subtasks`. Done tasks stay indexed;
  Trash doesn't. Queries are built by `ftsQuery` (quoted prefix terms, ≤ 8, ≤ 200 chars).
- Local adds the docs §Indexes set plus partial indexes on `dirty = 1` (push) and the inbox
  (`start_utc IS NULL`). The local unique key is `(user_id, series_id, original_start_utc)`.

### `trash` is a view: rows where `deleted_at is not null and deleted_at > now() - 30 days`.
A nightly job purges older tombstones.
Locally (M2.5) the purge never removes a tombstone that is still `dirty` (the server hasn't seen the
delete) or a series-instance tombstone with `original_start_utc` at or after `now − 1 day` (the
Materialiser reads it as "skip this instance"). Trashing a task trashes its live subtasks with the
same `deleted_at`; restore brings back only those. Undo tokens (30 s) live in memory.

## Settings JSON (profiles.settings) — validated with a schema on both sides
```json
{
  "dayBoundaries": {"mon": {"start": "07:00", "end": "22:00"}, "...": {}},
  "snapMinutes": 5,
  "shiftFollowers": "ask",
  "includeCalendarInShift": false,
  "defaultDurationMin": 30,
  "durationPresets": [15, 30, 45, 60, 90, 120],
  "defaultAlerts": [{"kind": "before", "offsetMin": 10}],
  "quietHours": {"start": "22:00", "end": "07:00"},
  "use24h": null,
  "firstDayOfWeek": 1,
  "theme": "system",
  "accent": "indigo",
  "reduceMotion": null,
  "showFreeTime": true,
  "runningLateNudge": true,
  "rollUnfinished": false,
  "windDownReminder": true,
  "wakeUpAlarm": false,
  "wakeUpSoundId": null,
  "wakeUpVarySound": false,
  "wakeUpRampSec": 30,
  "wakeUpSnooze": true,
  "wakeUpSnoozeMin": 9,
  "wakeUpSnoozeMax": 3,
  "wakeUpCard": null,
  "wakeUpCardOnOpen": true,
  "wakeUpCardCalendar": true,
  "wakeUpCardInbox": true,
  "wakeUpLateOffer": true,
  "wakeUpLateMin": 10,
  "wakeUpCheck": true,
  "wakeUpCheckMin": 10,
  "wakeUpCheckLoud": false,
  "sleepTargetMin": null,
  "showNightArc": true,
  "sleepOfferAnswered": false,
  "inboxNudge": false,
  "daySummaryDays": [],
  "reminderSound": null,
  "suggestTravelTime": false,
  "travelTimeMin": 15
}
```

## Validation (client and server)
- `title` 1–200 chars, trimmed; `notes` ≤ 10 000; `duration_min` 5–1440; `alerts` ≤ 5 with
  `offsetMin` 0–1440; `subtasks` ≤ 50 per occurrence; a subtask's or template step's `duration_min` is null or 1–1440; `rrule` must parse and have `FREQ` (HOURLY or coarser — M1.2); `tz_id`
  must be a known IANA id; `color_key`/`icon_key` from the allowed sets.
- Clarified in M1.1: `icon_key` is a lowercase snake_case token ≤ 48 chars (default `circle`) until
  the picker set is the 26 `TaskIcon`s (M3a.2; older keys map to the nearest icon); the UI draws a plain dot for `circle` and for keys it does not know. `color_key` must be
  one of the 9 Concept A task colour keys or a retired 12-palette key kept for sync
  (`task_color_keys.gen.dart`, ADR-0007, M3a.1); `settings.accent` is one of the 4 accents. Day boundaries are `HH:mm` with
  start < end (no wrap); quiet hours may wrap past midnight. `quietHours: null` means off and is the
  default for new profiles (the example above shows the suggested window once enabled). Validation
  checks `tz_id` against the bundled IANA database, which `bootstrap()` loads before `runApp`.
- Clarified in M3c.3: `durationPresets` are the Add flow's duration chips — 1–12 distinct lengths of
  5–1440 min, sorted; absent means the default list. Checked by the client validator; the server's
  `validate_settings()` ignores keys it doesn't know, so older rows stay valid.
- Clarified in M7.5: `suggestTravelTime` (off until chosen) and `travelTimeMin`, one of 5, 10, 15,
  20, 30, 45, 60, 90, 120 (`Settings.travelChoices`, checked by the client validator; the server
  ignores both keys, as for `durationPresets`).
- Clarified in M3d.2: `showFreeTime` (the "N free · add here" gaps on the thread), `runningLateNudge`
  (M3f.5 offers to shift the rest), `rollUnfinished` (Day review moves unfinished tasks to tomorrow
  instead of the Inbox, M3f.5) and `windDownReminder` (M3d.3/M5) are plain booleans; absent keys take
  the defaults above, so older rows stay valid and the server check is unchanged.
- Clarified in M17.1: `wakeUpAlarm` (docs/15 W1, Settings › Day shape › Wake Up alarm) is a plain
  boolean, off by default, so an upgrade rings nothing new; onboarding offers it on for a new user. It
  rings only on phones. `windDownReminder` is the Wind Down reminder's key: it was `bedtimeReminder` until
  schema 11 and Supabase 0011 moved the value (owner, 2026-11-01: Wind Down everywhere). The server ignores both keys.
- Clarified in M17.5: the night (docs/15 W4, W6). `sleepTargetMin` is null (off) or 360–600 in 15-minute steps; onboarding starts a new account at 480. With it, Wind Down is derived (`effectiveDayShape`) and never stored. `showNightArc` (on) shows the night on every day dot. `sleepOfferAnswered` is set by the review's one-time offer and by onboarding, so the offer never returns. The B5 snapshot gains `tomorrow_wake_ms` (null without the night) and the derived `night_start`.
- Clarified in M17.4: the Wake Up Check (docs/15 W3). `wakeUpCheck` is on, `wakeUpCheckMin` is 5, 10, 15, 20 or 30, and `wakeUpCheckLoud` (off) makes it ring like the alarm once instead of a gentle ping. Nothing new is stored: the OS holds the armed check until it fires or a start calls it off.
- Clarified in M17.3: the Wake Up card (docs/15 §5, §9).
  - `wakeUpCard` is nullable: null follows `wakeUpAlarm` (15 §11), and a switch flip stores the choice.
  - `wakeUpCardOnOpen`, `wakeUpCardCalendar` and `wakeUpCardInbox` are its switches.
  - `wakeUpLateOffer` and `wakeUpLateMin` (5, 10, 15 or 30) control the shift offer.
  - Local only (schema 10): `wake_up_days` has `date` (`yyyy-MM-dd`, PK) and `rang_at_utc`, `stopped_at_utc`, `snoozes`, `card_shown_at_utc` and `started_at_utc` (epoch ms). It is STRICT, with CHECKs on the date shape and `snoozes >= 0`. It is never synced: each phone rings and opens its own card.
- Clarified in M17.2: the Wake Up alarm's options (docs/15 §9) are flat keys beside it.
  - `wakeUpSoundId`: a Start sound id; null follows `startSoundId`.
  - `wakeUpVarySound`: a different start-tier cue each day, the same cue for a given date.
  - `wakeUpRampSec`: 0, 15, 30 or 60; Android only, because AlarmKit sets the iPhone's volume.
  - `wakeUpSnooze`, `wakeUpSnoozeMin` (5, 9, 10 or 15) and `wakeUpSnoozeMax` (1–5; 0 = no limit).

  All are synced, and a missing key reads as the default. What the alarm did on this device stays
  local. In `local_meta`, `armed_wake_ups` holds the instants `AlarmGateway` armed (ADR-0017). The
  OS keeps the rest in its own store: AlarmKit, or Android's `dottoday_wake_up` preferences.
- Clarified in M8.4c: `inboxNudge` (PRD F3.3, the once-a-day "Plan your inbox" card on Today) is a
  plain boolean, off by default; the day it was last put away is per device in `local_meta`
  (`inbox_nudge_day`, never synced — a nudge is a suggestion, like the Day review's "Not now").
- Clarified in M8.4d: `daySummaryDays` (weekday keys with a day-start summary; empty = off) and
  `reminderSound` (a bundled sound key, `dot`/`chime`/`bell`/`ripple`; null = the system sound).
  Absent keys take the defaults; the server ignores both. `reminderSound` isn't rejected when
  unknown (a newer device may know more sounds): the app resolves it against its own set before it
  names a file, so a stored string never reaches a file name.
- Clarified in M11.5: `energySuggestions` (Settings › Planning, 11 C4) is `true`/`false` when the
  user chose, absent/null for the default — off until 20 finished high-energy tasks with real times
  exist, then on. The server ignores the key, as for `durationPresets`.
- Clarified in M11.4: a routine needs a title and 1–30 steps, each with a title, a length of 5–1440
  min, an offset of 0–1440 min and allowed colour/icon keys; `anchor_minute` is set exactly when the
  anchor is `time` (`validateRoutine`).
- Server enforces with CHECK constraints and a `validate_settings()` function; client with a Zod-like
  Dart validator in `domain/validation`.

## Indexes
`occurrences (user_id, start_utc)`, `occurrences (user_id, series_id, original_start_utc) unique`,
`occurrences (user_id, deleted_at)`, `subtasks (occurrence_id)`, `series (user_id)`,
`calendar_links (user_id, external_event_id)`, `routines (user_id)`. All tables `(user_id, updated_at)` for sync pulls.

## Export format
JSON v1: `{version:1, exportedAt, profile, series[], occurrences[], subtasks[], routines[]}` (M11.4:
`routines` added; a file without the key imports with none, so older backups still restore); CSV per entity;
ICS of occurrences with `start_utc` (VEVENT, RRULE for series). Import accepts JSON v1 only and runs in
a transaction with a pre-import backup.

Clarified in M1.8 (`domain/export/`): JSON v1 values use storage form (snake_case rows, UTC epoch ms)
and include trash rows, so a restore keeps the trash; CSV and ICS are human reports of live rows only
(CSV: RFC 4180, CRLF, ISO-8601 UTC instants, nested values as JSON, cells starting `= + - @ tab CR`
prefixed with `'`; ICS: one VEVENT per one-off, one per series with `DTSTART;TZID=<IANA>` + `RRULE`,
skipped/deleted instances as `EXDATE`, moved/renamed ones as `RECURRENCE-ID` overrides, no VTIMEZONE,
inbox items omitted). Import rejects files > 25 MB, any version other than 1, wrong shapes, rows failing
validation, duplicate ids, dangling `series_id`/`occurrence_id` and rows of more than one owner; it
clears `calendar_link_id` (links are not exported) and the caller re-owns rows to the signed-in user.

Clarified in M8.1: imported calendar events (`source = 'calendar'`) and their subtasks are **never in
a backup or an export** (JSON, CSV or ICS), and an import drops any an older file still holds. They
are device-only and keyed to this device's calendars (`calendar_links`, not exported), so a copy in a
file could only come back unlinked beside the importer's fresh one; the calendar stays their source
and each device re-imports them. The current state a restore compares against is read the same way,
so a restore or import never moves this device's imports to Trash either: they keep their links and
the next import pairs them as before. Rejected: exporting the link keys so the importer re-pairs
restored rows (links are per device and per calendar account — an EventKit id from another device
pairs with nothing — and it would put calendar ids into user files). Cost: subtasks or notes added to
an imported event stay on the device that has the event (as ADR-0011 already says for sync). Files:
`dottoday-backup-<yyyy-MM-dd>.json`, `dottoday-<yyyy-MM-dd>.ics`, `dottoday-{tasks,repeats,subtasks,routines}-
<yyyy-MM-dd>.csv` (empty tables left out), dated in the profile's zone, never named after content.
Restore/import policy is **replace**, said in the confirmation in those words ("Anything here that
isn't in it moves to Trash"): it runs through the write path in one transaction after a pre-import
(or pre-restore) backup, and Undo restores that backup. Rejected: a staging database swapped in by
rename (the data-export skill's default) — the restore must flow through the write path so it is
change-logged and syncs to the person's other devices like any edit, and one transaction already
leaves nothing half-applied; and a payload checksum in the envelope (v1 stays as it is: a truncated
or edited file already fails JSON parsing or row validation, and a newer `version` is refused).
