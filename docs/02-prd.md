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
- Subtasks gain an optional duration each and an order; a task's duration may be the sum of its steps.
  Occurrences record actual start and actual end timestamps when the user starts/completes them
  (`11-standout-roadmap.md` B1, B2).

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
  Clarified in M7.1: connecting turns every calendar on (switch off the ones you don't want; a
  calendar added to the device later comes in too). An event takes the task colour nearest to its
  calendar's colour. A multi-day all-day event shows in the strip on each of its days; tapping a strip
  item opens it to edit.
- Imported events are first-class blocks: draggable, resizable, can have subtasks/notes stored locally (never written to the external calendar unless the user enables write-back for that calendar). (R-02, R-09)
  Clarified in M7.2: events from yesterday to 90 days ahead come in on start, on resume, every
  6 hours and right after a calendar is switched or connected. An event's description and link
  become its notes. Subtasks, notes, moves and renames made in Dottoday stay on this device (each
  device imports its own calendars) and stay put until the calendar changes that same thing; notes
  edited here are never overwritten. An event deleted from its calendar disappears here too —
  into Trash if it had subtasks, notes or a tick. Deleting an imported event in Dottoday hides it
  (it doesn't come back). Imported events don't remind in Dottoday unless you add alerts (the
  calendar app reminds already).
- Write-back (optional per calendar): move/resize/rename syncs to the source calendar; failures surface as a non-blocking banner with retry.
  Clarified in M7.3: Settings › Calendars › Send changes back, one switch per writable calendar,
  off until chosen; turning it on also sends moves made before. Only timed, non-repeating events
  write back (repeating instances and all-day items change here only, and the editor says so).
  Notes and subtasks never go back. A change made in the calendar meanwhile is combined with the
  one made here field by field; the same field changed in both places asks once (banner: Keep
  mine / Use calendar's). An event gone from the calendar keeps the edit here until the next
  import removes it.
- Travel time: if the event has a location and the user enables it, a buffer block is suggested before it. (R-17)
- Links in event descriptions open in the browser. (R-02)
  Clarified in M7.2: the task sheet and editor list the web links (http/https, up to 5) found in
  the notes under LINKS; a tap opens the browser. Links typed into a task's notes work the same.

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
- Delivery guarantees (`11-standout-roadmap.md` A0, milestone M6.5): dot-start notifications use the
  time-sensitive interruption level on iOS and a dedicated alarm channel with exact alarms on Android;
  the first dot of the day and routine-start dots are alarm-loud by default; onboarding includes a test
  alarm; Settings › Reminders has a notification-health panel reading the real OS state (permission,
  exact alarms, battery exemption, Focus/DND, device clock).
  Clarified in M6.5.3 (`domain/notifications/alarm_policy.dart`): "first dot of the day" is the earliest
  scheduled task starting on that local day, whatever its state — if it is already done or skipped, no
  later dot becomes that day's alarm; only the at-start alert rings loud (not "before"/end/snooze);
  days follow the user's current zone, so travel re-plans them.

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
- iOS Live Activity / Dynamic Island and an Android ongoing notification for the live dot; interactive
  widget actions; Control Center / Action button controls. All surfaces read the day snapshot and call
  the five App Intents only; none talk to Supabase (`11-standout-roadmap.md` A1, B5, B6).
- Apple Watch complication and glance: Phase 2 (not blocking v1), but data layer designed for it.
  Watch rule (ADR-0010): the watch never authenticates — no account, network or token on the wrist; the
  phone pushes the day snapshot; check-offs and +15 queue on the watch; native app (Swift / Compose).

## F10. Onboarding

- At most 3 input screens: pick day start/end (O2), pick first tasks (O3, skippable; suggestion chips or Quick Add), account (O5, optional). Optional calendar connect is a row on the Reminders screen (O4). Welcome (O1), Reminders (O4) and Done (O6) ask for nothing beyond the permission prompt. O4 Reminders gains "Send me a test alarm" (`11-standout-roadmap.md` A0). Skippable. Finishes in under 90 s. Screens: `10-ui-concept-a.md` §5.1.

## F11. Feedback & changelog

- Settings → Send feedback (opens mail composer with app version, platform, redacted diagnostics opt-in). In-app "What's new" after updates. (R-19)

## Beyond v1 — standout roadmap and Phase 2

The milestones after v1's core (M7 calendars, M8 export/l10n/device QA) come from `11-standout-roadmap.md`:

| Milestone | Contents |
|---|---|
| M6.5 Delivery guarantees (before M7) | A0 alarms that fire, notification health, test alarm, background sync; B1 actual timestamps; B2 subtask durations |
| M9 See time | A1 Live Activity, ongoing notification, interactive widgets, controls, menu bar; B5 day snapshot; B6 App Intents |
| M10 Start | B4 ThinkingService (on-device first), B3 ProposalSheet, B1 Break it down, B2 Smallest step, B3 Unstick, A3 Focus |
| M11 Control | C1 Rebalance proposal, C3 Reality thread, C2 Routines, C4 energy suggestions (behind a switch) |
| M12 Reflect + capture | D1 weekly review + share, D2 low-energy mode, D3 thread journal, B6 capture anywhere, B4 brain-dump |

Phase 2 (ideas, not committed — the owner decides later): F1 Windows/Linux, F2 integrations (Reminders,
Google Tasks, Todoist, Notion), E1 body double, A2 wallpaper / watch face, the watch app (F3, ADR-0010),
B5 paper plan, shared/household threads.

Pricing principle: core free forever (R-18). The free/Pro split in `11-standout-roadmap.md` is a **draft
for the owner's review**; until it is signed off every feature is built ungated, and the only pricing
code is one `entitlements` service with a single `isPro` flag, true in all builds — no paywall, purchase
flow or store products.
