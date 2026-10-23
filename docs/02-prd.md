# 02 — Product Requirements (v1, core planner)

Format: feature → user stories → acceptance criteria (AC). `R-xx` links to `01-research-complaints.md`.
Everything here is **free tier** unless marked *Phase 2*.

## F1. Timeline (day view) — the home screen

**Stories**
- As a user I see today as a vertical timeline from my day start to day end, with a "now" line, so I know what's next.
- As a user I drag a block to a new time, or drag its top/bottom edge to change duration. (R-05)
- As a user I move one block and choose whether everything after it shifts too. (R-04)
- As a user I tap "Running late" and push all remaining unpinned blocks by +5/+15/+30 min. (R-04)
- As a user I pin a block so nothing ever moves it. (R-17)
- As a user I long-press to multi-select blocks and move/delete/duplicate them together. (R-05)
- As a user I see free gaps and can tap a gap to add a task there. (R-17)
- As a user I swipe left/right (or ←/→ keys) to move between days; a header date picker jumps anywhere.
- As a user I can check a block done from the timeline; past undone blocks are visually "overdue" but never nag.

**AC**
- Blocks render start–end time, title, icon, colour, subtask progress (3/5), and a calendar badge for imported events. (R-16)
- Drag: long-press 250 ms to pick up (haptic), snap to configured increment (default 5 min), live ghost preview, auto-scroll near edges. Vertical scroll never starts a drag. (R-05)
- Shift-followers: default from settings (`shiftFollowers: ask | always | never`), with an in-gesture toggle chip. Pinned blocks and imported calendar events are never shifted unless the user chooses "include calendar events". (R-04, R-17)
- Overlaps allowed; overlapping blocks render side-by-side (max 3 columns, then "+n").
- Timeline builds lazily; 200 blocks in a day scroll at ≥ 55 fps on a Pixel 6a / iPhone 12 class device. (R-15)
- Day boundaries: per-weekday start/end; blocks outside boundaries still render in a collapsed "outside hours" zone. (R-17)
- Full 24 h renders — golden test for the bottom of the day. (R-14)
- Keyboard (desktop/web): ↑↓ select, Enter open, Space complete, ⌘/Ctrl+↑↓ move 5 min, Shift for 15, Delete → trash with undo.
- Undo snackbar (30 s) for every move/delete/complete. (R-11)

## F2. Quick Add & Task Editor

**Stories**
- As a user I type "Gym 7am 45m" and get a block at 07:00 for 45 min. (R-06)
- As a user I paste five lines and get five inbox tasks. (R-07)
- As a user I open the full editor only when I want details (notes, subtasks, colour, icon, alerts, recurrence).

**AC**
- Quick Add field is reachable from any screen (FAB on mobile, ⌘/Ctrl+N on desktop/web).
- Parser handles: times (7am, 19:00, noon), relative days (today, tomorrow, Friday, next Mon), durations (45m, 1.5h, 2 hours), "every day/week/Mon,Wed" → recurrence prefill, "@inbox" → no time. Unparsed text stays as title. Parsed tokens are highlighted and removable with one tap. Unit-tested in en, de, fr, es with 24-h/12-h locales. (R-06, R-20)
  Clarified in M1.5 (`domain/quick_add/`): a time with no date means *today*, even if already past (the
  date never jumps on its own, R-20); "Friday" is the next Friday on or after today, "next Friday" strictly
  after; `HH:MM` and `7pm` parse in every language and the 12/24-h setting only changes chip display;
  French `15h`/`15h30` is a clock time (durations use `min`/`heures`); one token per kind, later ones stay
  title; two-letter German weekday abbreviations and es `mar` are not recognised (everyday words);
  input over 10 000 chars is rejected (06 §7).
- Time entry is always typeable; wheel/picker optional. One shared `TimeInput` component. (R-20)
- Duration chips 15/30/45/60/90 + custom; range 5 min–24 h. (R-16)
- "Add another" keeps the sheet open; multi-line paste → one task per non-empty line. (R-07)
- Editor fields: title (required, ≤ 200 chars), notes (markdown-lite, links tappable, ≤ 10 000 chars), start, duration, colour, icon, subtasks (≤ 50), alerts (≤ 5), recurrence, pinned, travel-time buffer (0–180 min), energy level (optional, low/med/high). (R-02, R-17)
- Saving is optimistic; the sheet closes immediately.

## F3. Inbox

- Unscheduled tasks live in the inbox; drag from inbox onto the timeline, or tap → "Schedule" with smart suggestions (next free gap today, tomorrow morning, pick time).
- Inbox supports reorder, swipe-to-schedule, swipe-to-trash, bulk select.
- An inbox badge shows count; an optional "plan your inbox" nudge appears once per day at day start (dismissible, off by default).

## F4. Recurrence

- RRULE-based: daily, weekdays, weekly on chosen days, every N days/weeks/months, monthly by day-of-month or nth weekday, yearly; end never / after N / on date. (R-01)
- Edit scope dialog: this occurrence / this and following / all.
- Exceptions: skip, reschedule, or modify a single occurrence without breaking the series.
- Subtasks are defined on the series template and instantiated per occurrence; completion is per occurrence. (R-09)
- DST and month-end rules follow RFC 5545; tests cover 31st-of-month, Feb 29, DST spring/fall in Europe/Berlin and America/New_York.
- Occurrences are materialised 90 days ahead on device (rolling), so the timeline and widgets work offline.

## F5. Calendar import & write-back

- Connect Apple Calendar (iOS/macOS via EventKit), Google Calendar, Microsoft 365 (OAuth via backend), device calendars on Android. (R-02)
- Per-calendar toggle, colour inheritance, all-day events shown in a header strip (editable). (R-02)
- Imported events are first-class blocks: draggable, resizable, can have subtasks/notes stored locally (never written to the external calendar unless the user enables write-back for that calendar). (R-02, R-09)
- Write-back (optional per calendar): move/resize/rename syncs to the source calendar; failures surface as a non-blocking banner with retry.
- Travel time: if the event has a location and the user enables it, a buffer block is suggested before it. (R-17)
- Links in event descriptions open in the browser. (R-02)

## F6. Notifications & alerts

- Per task up to 5 alerts: at start, N minutes before (1–1440), at end, when overdue by N minutes. (R-03, R-10)
- Default alert set configurable in settings. Quiet hours. Per-weekday day start summary ("Your day: 6 blocks, first at 08:00") optional.
- Scheduling is idempotent: notification IDs derive from `occurrenceId + alertIndex`; re-scheduling after edits cancels stale IDs first. Property test: no occurrence ever has >1 pending notification per alert. (R-10)
- Clarified in M1.6 (`domain/notifications/`): alerts inside quiet hours are still delivered, but silently
  (no sound/banner, not time-sensitive), so nothing is lost; done/skipped/deleted/inbox tasks never alert;
  a snooze replaces every alert before the snooze time with one reminder (slot 5, after the 5 alert
  slots); the planner keeps the earliest 64 on iOS and plans 7 days ahead. Payloads carry the occurrence
  ID only (06 §1).
- Actions on the notification: Done, Snooze 10 min (shifts followers per setting), Open. (R-04)
- Clarified in M5.1: the actions bring Dottoday forward and are handled in the app (one database
  connection, no background isolate); Done ticks that occurrence only (R-09). Snooze re-reminds in 10
  minutes and moves nothing: a notification can't ask "shift the rest?", so shifting later tasks is
  offered in the app (Running late nudge/sheet) under the shift-followers setting. Tapping the body = Open.
- Notification text is the task title over when ("Starts in 10 minutes", "Starting now", "Ending now",
  "Ended 15 minutes ago. Done?", "Snoozed reminder"); Bedtime reads "Tomorrow starts with … at …".
  A renamed task's pending alerts are re-posted (the payload keeps a short hash of the shown text).
- Custom sound from a bundled set; respects system Focus/DND. (R-10)
- Web: Web Push via service worker when granted; fallback to in-app banner.

## F7. Sync, accounts, backup

- The app is fully usable without an account (local only). Creating an account enables sync. (R-08)
- Auth: email magic link, Sign in with Apple, Google. No passwords stored by us.
- Sync engine: local DB is the source of truth; change log pushed; Realtime subscription pulls; per-field last-writer-wins with vector of `updatedAt`; tombstones for deletes; conflicts logged and surfaced only if both sides changed the same field within 60 s (then "keep mine / keep theirs"). (R-08)
- Sync status pill: synced / syncing / offline / error (tap for details). (R-08)
- Automatic daily local backup (last 7 kept) + manual export JSON/CSV/ICS from any platform. Import from JSON. (R-11)
- Trash with 30-day restore; permanent delete requires confirmation. (R-11)
- Account deletion: one tap in settings, deletes server data within 24 h, confirmed by email (GDPR).

## F8. Views & navigation

- Today (timeline), Inbox, Week overview (compact, read + drag), Month (dots per day, tap to open day) — all free. (R-03, R-14)
- Search across titles/notes/subtasks including completed history. (R-11)
- Settings: day boundaries, snapping, shift-followers default, alerts default, theme (system/light/dark), accent colour, 12/24 h, first day of week, language, calendars, account, export, trash, feedback, changelog, about. (R-19)

## F9. Home-screen widgets & watch (mobile/desktop)

- iOS/Android widgets: "Next up" (small), "Today timeline" (medium/large), "Inbox count". macOS: menu-bar "next up". Data comes from the local DB via an app-group/shared file; refresh on every write. (R-08)
- Apple Watch complication and glance: Phase 2 (not blocking v1), but data layer designed for it.

## F10. Onboarding

- At most 3 input screens: pick day start/end (O2), pick first tasks (O3, skippable; suggestion chips or Quick Add), account (O5, optional). Optional calendar connect is a row on the Reminders screen (O4). Welcome (O1), Reminders (O4) and Done (O6) ask for nothing beyond the permission prompt. Skippable. Finishes in under 90 s. Screens: `10-ui-concept-a.md` §5.1.

## F11. Feedback & changelog

- Settings → Send feedback (opens mail composer with app version, platform, redacted diagnostics opt-in). In-app "What's new" after updates. (R-19)

## Phase 2 (spec later; do not build in v1)

- AI planning (natural-language brain dump → scheduled day, editable before accepting, "add all", conversation history retained).
- Habit streaks and analytics, energy-based planning.
- Pro tier (themes, icon packs, AI, analytics). Core stays free. (R-18)
- Shared schedules, watch app, Shortcuts/Intents, Siri/Assistant.
