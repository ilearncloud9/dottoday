# 01 — User research: what Structured users complain about, and what we do about it

Collected October 2026 from App Store and Google Play reviews, review aggregators, and third-party
reviews. Frequencies are rough (review pages show a sample, not the full set). Each theme becomes a
numbered requirement `R-xx`; the PRD and implementation plan reference these IDs.

| ID | Theme (what users say) | Evidence | Our requirement |
|---|---|---|---|
| **R-01** | **Recurring tasks are paywalled.** "Locking the ability to make a task repeat completely ruins it." Most-cited complaint. Weekly reminders also prompt payment. | App Store, Play, habitbox review | Recurrence (daily/weekly/monthly/custom RRULE, end conditions, exceptions) is free, unlimited. |
| **R-02** | **Calendar import / editing is paywalled or one-way.** Users can't edit imported events, can't drag them, all-day events locked, links in events are plain text, sync *to* Google is missing. | justuseapp, appsupports | Calendar import free. Imported events are draggable within the app (writes back if the calendar is writable; otherwise creates a local override and says so). All-day events editable. URLs in notes are tappable. Two-way sync for Google/Apple/Microsoft where the platform API allows it. |
| **R-03** | **Custom notifications are Pro-only; monthly view is paywalled.** | habitbox, App Store | Lead-time alerts, multiple alerts per task, and month view are free. |
| **R-04** | **Rescheduling is one-by-one.** "If something takes longer you have to reschedule everything after it one by one." Want "move all my events down an hour", snooze that shifts followers, auto-bump on insert. | Play (top review), justuseapp, App Store | **Shift-rest-of-day**: drag one block and everything after it moves (toggleable per gesture). "Running late" button: +5/+15/+30 min for all remaining blocks. Snooze a task → followers shift. Insert into a full slot → later blocks bump unless pinned. |
| **R-05** | **Drag/drop unreliable or missing; can't resize by dragging edges; tap vs scroll confusion; time slider gesture conflicts with sheet dismiss.** | App Store, Play, appsupports | Timeline supports drag-to-move with 5-min snapping, drag-edge resize, long-press multi-select, haptics; gestures tuned so vertical scroll and drag never conflict (long-press to pick up). Pinned/locked blocks never move. |
| **R-06** | **Creating a task is slow.** "Takes about a minute", "too many clicks", scroll-wheel time input, forced times. | justuseapp, App Store | **Quick Add**: one text field with natural-language parsing ("Gym 7am 45m", "Call mom tomorrow 3pm"). Typed time entry everywhere; duration chips (15/30/45/60/90/custom); tasks may have no time (inbox) — never forced. |
| **R-07** | **Brain-dump is slow; no bulk paste; no quick multi-add.** | Play | Paste a multi-line list → one task per line. "Add another" keeps the sheet open. |
| **R-08** | **Sync is slow, flaky, or loses data.** "All of my events are gone", Mac changes take ages to reach iPhone, widgets/complications stale for hours. | appsupports, justuseapp | Offline-first local DB as source of truth; Supabase Realtime push; visible sync status; conflict resolution by per-field last-writer-wins with tombstones; automatic daily local backup; never delete locally on a server error. Widgets read from the local DB and refresh on every write. |
| **R-09** | **Recurring subtasks reset wrongly** — randomly checked off at day start; subtasks on imported recurring events don't carry over. | appsupports, justuseapp | Subtask completion is stored per **occurrence**, never on the series. Templates define subtasks; occurrences materialise their own checklist. |
| **R-10** | **Notification bugs**: duplicates (4 for one task), fires at start not before, only one alert, indistinct sound. | justuseapp | Idempotent scheduling keyed by occurrence ID; lead-time offsets; up to 5 alerts per task; custom sound option; "notify when overdue" option. |
| **R-11** | **No export (Android), no history control, no recovery of lost work.** | Play, justuseapp | Export JSON + CSV + ICS on every platform, free. Undo for 30 s on every destructive action; trash with 30-day restore. Completed history retained and searchable. |
| **R-12** | **VoiceOver broke after an update.** Accessibility regressions. | appsupports | Semantics tests in CI; accessibility audit in each milestone's definition of done. |
| **R-13** | **Android and Web are second-class**: missing Reminders import, Replan, duplicate day, custom icons; web lacks features; Mac app crashes / won't open; old Macs unsupported. | habitbox, getinflow, appsupports | Single Flutter codebase; feature-parity checklist is a release gate; crash-free sessions ≥ 99.5% target with Sentry; min macOS 12. |
| **R-14** | **Cluttered UI / week view too busy; wants simpler look; only first part of day renders (blank area below).** | justuseapp, appsupports | Calm visual system (UX spec); week view as an opt-in overview; timeline renders full 24 h lazily; golden tests catch layout truncation. |
| **R-15** | **Performance degrades with 30+ items/day.** | appsupports | Timeline is a lazily built sliver list; 200 blocks/day must scroll at 60 fps on a mid-range Android (perf test in plan). |
| **R-16** | **Wants end time visible, more duration options, finer start increments, longer tasks.** | justuseapp, App Store | Blocks show start–end; durations from 5 min to 24 h; 1-min typed precision, 5-min drag snapping (configurable to 1/5/10/15). |
| **R-17** | **Wants locked/fixed events, travel time, day-specific wake times, current-time insertion marker.** | App Store | Pin a block (R-04 respects it). Travel-time buffer field. Per-weekday day start/end. Draggable "insert here" marker + "now" line. |
| **R-18** | **Price tripled; lifetime buyers feel burned.** | habitbox | Phase 2 pricing principle: core free forever; Pro adds extras only; honour lifetime. |
| **R-19** | **Support unresponsive; no in-app feedback channel.** | justuseapp | In-app "Send feedback" with optional diagnostics (redacted) → email/issue tracker. Public changelog screen. |
| **R-20** | **Time picker bugs (AM/PM flipping, adding days).** | appsupports | Single tested `TimeInput` component with 12/24-h handling and unit tests across locales and DST. |

## Things users love (keep them)

- Timeline that fills as the day passes, colour + icon per block, "what's next" at a glance.
- Inbox for unscheduled items; subtasks and notes on blocks.
- Free tier that is useful; one-time purchase option.
- Clean, friendly aesthetic; widgets; wake/sleep boundaries.

## Sources

- https://appsupports.co/1499198946/structured-day-planner/negative-reviews
- https://justuseapp.com/en/app/1499198946/structured-day-planner/reviews
- https://apps.apple.com/us/app/structured-daily-planner-todo/id1499198946?see-all=reviews
- https://play.google.com/store/apps/details?id=io.unorderly.structured&hl=en
- https://habitbox.app/blog/structured-app-review
- https://www.getinflow.io/post/best-alternatives-structured-app-adhd (competitor-authored, treated with caution)
- https://appleinsider.com/articles/23/01/09/structured-301-review-no-frills-attractive-daily-planner
