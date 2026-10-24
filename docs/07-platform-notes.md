# 07 — Platform Notes

Parity is a release gate (R-13). Where a platform genuinely can't do something, the fallback is
specified here — never "not available on X".

## iOS (min iOS 16)
- Notifications: request permission in onboarding step 2 with a pre-prompt; use time-sensitive
  interruption level for "at start" alerts; actions Done/Snooze/Open; limit 64 pending → planner
  schedules the next 7 days only and refreshes on open/background fetch.
- Widgets: WidgetKit via `home_widget`, timelines refreshed on each write (`WidgetCenter.reloadAllTimelines`), Lock Screen widget "Next up".
- Calendar: EventKit full access (`NSCalendarsFullAccessUsageDescription`) for write-back; read-only otherwise.
- Sign in with Apple required when Google sign-in is offered.
- Background: `BGAppRefreshTask` to re-materialise occurrences and re-plan notifications daily.
- Live Activities for the current block: Phase 2.

## Android (min API 26)
- Notifications: channels (Alerts, Summary, Sync); `SCHEDULE_EXACT_ALARM` requested with rationale;
  fall back to inexact if denied and tell the user; full-screen intents not used.
- Widgets: Glance via `home_widget`; update via `WorkManager` + on write.
- Calendar: `CalendarContract` read/write with runtime permission.
- Predictive back, edge-to-edge, Material You dynamic colour as optional accent.
- Doze: use `WorkManager` periodic job (≥15 min) for materialisation; never rely on foreground service.

## macOS (min macOS 12)
- Menu bar: File (New task ⌘N, Export), Edit (Undo ⌘Z, Redo ⇧⌘Z, Delete), View (Today ⌘1, Inbox ⌘2, Week ⌘3, Month ⌘4), Go (Previous/Next day ⌘←/→, Today ⌘T).
- Menu-bar extra "Next up" (NSStatusItem) via a small Swift plugin; optional.
- Notifications via UNUserNotificationCenter; widgets via WidgetKit (share app group with iOS).
- Sandbox entitlements: calendars, network client, user-selected file read/write (export).
- Calendar: `device_calendar` has no macOS support; EventKit goes through a small method channel in the Runner (M7.1b), same `DeviceCalendarGateway` as iOS.
- Window opens at 1280×800, min 960×640 (owner, after the M4 sweep); remembers size/position; supports multiple windows (Today + Inbox) in Phase 2.
- Menu keys that text fields also use (⌘Z, ⌘←/⌘→) have no native key equivalent; Flutter handles them (M5.5).
- Crash-free target 99.5 % (R-13); run on Intel and Apple Silicon in CI.

## Web (PWA)
- Renderer: CanvasKit for desktop widths, HTML renderer under 600 px (set via `--web-renderer auto`), test both.
- Storage: drift WASM + OPFS; fallback to IndexedDB on Safari < 17.
- Push: service worker + VAPID keys; Supabase Edge Function sends; if denied, in-app banners while open.
- Keyboard-first: all timeline operations have shortcuts; focus visible; skip-to-content link.
- Install prompt after 2nd visit; offline page; manifest with maskable icon.
- Calendar: Google/Microsoft via backend OAuth only; Apple via CalDAV (app-specific password) Phase 2.
- CSP and headers per security §8; deploy behind HTTPS with HSTS.
- App lock (M5.8): a page has no device check it can rely on (WebAuthn needs an account and a server), so Settings › Privacy shows "Uses your computer's lock" instead of the switch; the database stays encrypted in the browser (06 §3).

## Shared concerns
- Deep links / universal links: `dottoday://task/<id>`, `/day/2026-10-20`, `/inbox`. Routes allow-listed; IDs resolved under the current user only.
- Localisation: en (source), de, fr, es at v1; dates via `intl` with user locale; 12/24 h follows system unless overridden.
- Text scaling tested at 100/150/200 %.
- Time zone changes while travelling: a banner "You're now in Europe/Berlin — keep times or shift?" (default keep wall-clock for user tasks; calendar events follow their own zone). Clarified in M5.9: the banner shows until one is picked (no "not now"); only planned tasks that haven't started move; repeats are split at their next instance so past ones keep their history; both choices are undoable.
