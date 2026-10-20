# ADR-0004: Recurrence stored as RFC 5545 RRULE with materialised occurrences

**Status**: accepted · **Date**: 2026-10-20

## Context
Recurring subtasks resetting incorrectly (R-09) and timezone/DST bugs are classic failure modes of ad-hoc recurrence schemes.

## Decision
Series store `RRULE` + local `DTSTART` + IANA zone. Occurrences are materialised 90 days ahead and stored as real rows (unique on series_id + original_start_utc). Subtasks live on occurrences only. Edit scopes: this / this-and-following (series split) / all (re-materialise untouched rows).

## Consequences
+ Timeline, widgets and notifications work offline from plain rows; ICS export is trivial.
− Materialisation job must run daily (background task) and on app open; series edits touch many rows (batched in a transaction).
