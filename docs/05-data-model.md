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
subtask_template jsonb [ {id, title, sortOrder} ], archived_at?, created_at, updated_at, deleted_at?`

### `occurrences`  (every block on the timeline, scheduled or not)
`id, user_id, series_id? (null = one-off), original_start_utc? (for series exceptions),
title, notes, color_key, icon_key, start_utc? (null = inbox), tz_id, duration_min, pinned,
travel_buffer_min, energy?, alerts jsonb (overrides series when non-null), status
('planned'|'done'|'skipped'), completed_at_utc?, sort_order (inbox ordering), source
('user'|'calendar'), calendar_link_id?, snoozed_until_utc?, created_at, updated_at, deleted_at?`

Rules
- A series row never appears on the timeline itself; the client materialises occurrences 90 days
  ahead (`materialised_through_utc` on series). Materialised rows for an unchanged series are
  idempotent (`unique(series_id, original_start_utc)`).
- Editing "this occurrence" writes the occurrence row (keeps `series_id`, `original_start_utc`).
  "This and following" splits the series (`until` on old, new series from that date). "All" edits the
  series and re-materialises untouched occurrences (occurrences with user edits are preserved).
- Completion is **per occurrence** (R-09). Subtask state too (below).

### `subtasks`
`id, user_id, occurrence_id, title, done bool, sort_order, created_at, updated_at, deleted_at?`
Created from `series.subtask_template` when an occurrence is materialised; never shared across
occurrences.

### `calendar_accounts`
`id, user_id, provider ('apple_device'|'android_device'|'google'|'microsoft'|'caldav'), label,
external_account_id, write_back bool, enabled bool, created_at, updated_at`
OAuth refresh tokens are **not** in this table — they live in `vault.secrets` (Supabase Vault), keyed
by `calendar_accounts.id`, accessible only from Edge Functions.

### `calendar_links`
`id, user_id, account_id, external_calendar_id, external_event_id, etag, last_synced_utc,
read_only bool`. Joined to `occurrences.calendar_link_id`.

### `conflicts`
`id, user_id, entity, entity_id, field, mine jsonb, theirs jsonb, created_at, resolved_at?`

### `change_log` (local only) and `sync_cursors` (local only)
See architecture §4. `change_log (seq autoincrement, entity, entity_id, field, value json, hlc)` is
the push outbox (rows deleted on ack); `sync_cursors (entity pk, since_utc)` holds the highest server
`updated_at` pulled per table.

### Local schema (Drift, `app/lib/data/db`, M2.1)
- Same tables and checks as the server, `STRICT`, plus `dirty` / `version` on the tables pushed via `sync_push` (profiles, series, occurrences,
  subtasks). Calendar tables have none: they sync through their provider (M7).
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
  "reduceMotion": null
}
```

## Validation (client and server)
- `title` 1–200 chars, trimmed; `notes` ≤ 10 000; `duration_min` 5–1440; `alerts` ≤ 5 with
  `offsetMin` 0–1440; `subtasks` ≤ 50 per occurrence; `rrule` must parse and have `FREQ` (HOURLY or coarser — M1.2); `tz_id`
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
- Server enforces with CHECK constraints and a `validate_settings()` function; client with a Zod-like
  Dart validator in `domain/validation`.

## Indexes
`occurrences (user_id, start_utc)`, `occurrences (user_id, series_id, original_start_utc) unique`,
`occurrences (user_id, deleted_at)`, `subtasks (occurrence_id)`, `series (user_id)`,
`calendar_links (user_id, external_event_id)`. All tables `(user_id, updated_at)` for sync pulls.

## Export format
JSON v1: `{version:1, exportedAt, profile, series[], occurrences[], subtasks[]}`; CSV per entity;
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
