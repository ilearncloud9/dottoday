# 07 — Platform Notes

Parity is a release gate (R-13). Where a platform genuinely can't do something, the fallback is
specified here — never "not available on X".

## iOS (min iOS 16)
- Notifications: request permission in onboarding step 2 with a pre-prompt; use time-sensitive
  interruption level for "at start" alerts; actions Done/Snooze/Open; limit 64 pending → planner
  schedules the next 7 days only, keeps the nearest 50 (macOS too, M8.4d) and refreshes on
  open/background fetch. Reminder sounds are WAV files copied to `Library/Sounds` at start.
- Widgets: WidgetKit via `home_widget`, timelines refreshed on each write (`WidgetCenter.reloadAllTimelines`), Lock Screen widget "Next up".
- Calendar: EventKit full access (`NSCalendarsFullAccessUsageDescription`) for write-back; read-only otherwise.
- Sign in with Apple required when Google sign-in is offered.
- Background: `BGAppRefreshTask` to re-materialise occurrences and re-plan notifications daily.
- Live Activity / Dynamic Island for the live dot: M9.3 (was Phase 2; moved by the standout roadmap, ADR-0009).
- Share extension `DottodayShare` (M12.4, B6): the system compose sheet; Post appends a `shared` add_task entry to the App Group queue (`ShareQueue`, ios/Shared/DotStore.swift); the app drains it into the Inbox. Needs the App Group on device (paid account).

## Android (min API 26)
- Notifications: channels (Alerts, Summary, Sync); `SCHEDULE_EXACT_ALARM` requested with rationale;
  fall back to inexact if denied and tell the user; full-screen intents only for the alarm-loud
  dots (M6.5.5). A channel's sound is fixed, so each bundled reminder sound has its own
  `alerts_<sound>` channel (M8.4d); `res/raw/keep.xml` keeps the sounds through resource shrinking.
- Widgets: Glance via `home_widget`; update via `WorkManager` + on write.
- Calendar: `CalendarContract` read/write with runtime permission.
- Predictive back, edge-to-edge. No Material You dynamic accent: the accent is one of Concept A's
  four on every platform (PRD F8.3, decided in M8.4c).
- Doze: use `WorkManager` periodic job (≥15 min) for materialisation; never rely on foreground service.
- Share target (M12.4, B6): `ACTION_SEND` text/plain on MainActivity; `ShareIntake` queues it in the `home_widget` prefs before Flutter starts and opens `dottoday://inbox`.

## macOS (min macOS 12)
- Menu bar: File (New task ⌘N, Export), Edit (Undo ⌘Z, Redo ⇧⌘Z, Delete), View (Today ⌘1, Inbox ⌘2, Week ⌘3, Month ⌘4), Go (Previous/Next day ⌘←/→, Today ⌘T). Edit's items carry no native key equivalents (a field needs ⌘Z, ⇧⌘Z and ⌫); with a text field focused they act on the field (its undo/redo; Delete removes a selection, never a single letter), otherwise Undo/Redo are the app-level undo (one level of redo, 30 s, ended by any new change) and Delete moves the tasks picked on Today to Trash with Undo. The same ⌘Z / ⇧⌘Z (Ctrl+Z / Ctrl+Shift+Z) work on the web and Windows/Linux outside fields (M8.6b).
- Menu-bar extra "Next up" (NSStatusItem) via a small Swift plugin; optional.
- Notifications via UNUserNotificationCenter. "Next up" is the menu-bar item (M5.4/M5.5 decision, PRD F9), not a WidgetKit widget; it becomes the day dot in M9.6.
- Sandbox entitlements: calendars, network client, user-selected file read/write (export), and the team-prefixed App Group `$(TeamIdentifierPrefix)app.dottoday.planner` (M12.4: no provisioning profile needed; Info.plist's `DotAppGroup` names it for `DotStore`).
- Share menu `DottodayShare` (M12.4, B6): as on iOS; `IntentQueueBridge.swift` serves `dottoday/intents` so the Mac drains the queue too.
- Calendar: `device_calendar` has no macOS support; EventKit goes through a small method channel in the Runner (M7.1b), same `DeviceCalendarGateway` as iOS.
- Window opens at 1280×800, min 960×640 (owner, after the M4 sweep); remembers size/position; supports multiple windows (Today + Inbox) in Phase 2.
- Menu keys that text fields also use (⌘Z, ⌘←/⌘→) have no native key equivalent; Flutter handles them (M5.5).
- Crash-free target 99.5 % (R-13); run on Intel and Apple Silicon in CI.

## Web (PWA)
- Renderer: CanvasKit for desktop widths, HTML renderer under 600 px (set via `--web-renderer auto`), test both.
- Storage: drift WASM + OPFS; fallback to IndexedDB on Safari < 17.
- Push: service worker + VAPID keys; Supabase Edge Function sends; if denied, in-app banners while open.
  The in-app strip offers Done and Snooze 10 min and plays the picked reminder sound (a browser
  notification can't carry one; M8.4d).
- Keyboard-first: all timeline operations have shortcuts; focus visible; skip-to-content link.
- Install prompt after 2nd visit; offline page; manifest with maskable icon.
- Capture (M12.4, B6): paste into Add — a pasted line with a link becomes an Inbox task titled like a share with the line as its note. No Web Share Target (owner, 2026-10-25).
- Calendar: Google/Microsoft via backend OAuth only; Apple via CalDAV (app-specific password) Phase 2.
- CSP and headers per security §8; deploy behind HTTPS with HSTS.
- App lock (M5.8): a page has no device check it can rely on (WebAuthn needs an account and a server), so Settings › Privacy shows "Uses your computer's lock" instead of the switch; the database stays encrypted in the browser (06 §3).

## Shared concerns
- Deep links / universal links: `dottoday://task/<id>`, `/day/2026-10-20`, `/inbox`. Routes allow-listed; IDs resolved under the current user only.
- Localisation: en (source), de, fr, es at v1; dates via `intl` with user locale; 12/24 h follows system unless overridden.
- Text scaling tested at 100/150/200 %.
- Time zone changes while travelling: a banner "You're now in Europe/Berlin — keep times or shift?" (default keep wall-clock for user tasks; calendar events follow their own zone). Clarified in M5.9: the banner shows until one is picked (no "not now"); only planned tasks that haven't started move; repeats are split at their next instance so past ones keep their history; both choices are undoable.
