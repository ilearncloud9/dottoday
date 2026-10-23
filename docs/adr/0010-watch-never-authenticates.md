# ADR-0010 · The watch never authenticates

Status: Accepted · Date: 2026-10-23 · Filed as 0010 (drafted as 0009) · Applies when the watch app is built (Phase 2)

## Context
Watch companions that hold their own session log users out mid-routine (a recurring Tiimo complaint) and put an auth token on the least secure device the user owns.

## Decision
The watch app (native Swift on watchOS, Compose on Wear OS; not Flutter) holds **no account, no network access and no Supabase token**. The phone pushes a day snapshot (the same `DaySnapshot` record widgets use). Check-offs and +15 actions queue on the watch and are applied through the phone when reachable. The complication is the day dot; the app is "Now / Next / Done / +15" only; no editing.

## Consequences
- Watch works offline and never shows a sign-in screen.
- Snapshot push and the action queue are part of the M9 shared-store contract so the watch is a pure consumer later.
