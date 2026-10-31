# ADR-0017 · The Wake Up alarm rings through its own AlarmGateway

Status: Accepted · Date: 2026-10-31 · Spec docs/15-wake-up.md (§2–§4, owner decisions in §13) ·
Audit docs/audits/m17-wake-up-inventory.md · Built in M17.1 (W1a) and M17.2 (W1b)

## Context
A planner whose first dot never arrives has failed before the day starts. Until M17 the Wake Up
time was only a notification. On iPhone the Silent switch mutes it; on Android a dead app or an
OEM battery killer can lose or delay it. iOS 26 brings AlarmKit, a real alarm for third-party apps.
Android has had the parts for years: `setAlarmClock`, the alarm audio stream and full-screen
intents. From Android 14, though, Play revokes the full-screen intent from apps without an alarm
feature. Two 0.x Flutter plugins wrap AlarmKit. Neither documents a snooze limit, and one generates
a second widget extension, which is a CLAUDE.md §11 must-ask.

## Decision
- **Two ports, two jobs.** `NotificationGateway` keeps every ping. `AlarmGateway`
  (`lib/domain/notifications/alarm_capabilities.dart`) holds only the Wake Up alarm:
  - `capabilities()` and `fix()`;
  - `requestAuthorization()`;
  - `sync(alarms)`, which makes the given list the armed set;
  - `disarmAll()` and `test()`.

  `capabilities()` is the one answer every screen reads: a tier (alarm, time-sensitive, heads-up or
  none) plus blockers. No screen checks an OS version.
- **No new dependency, no new target.** AlarmKit is reached through an in-house bridge:
  - `ios/Runner/AlarmBridge.swift` handles the `dottoday/alarm` channel.
  - `ios/Shared/WakeUpAlarmKit.swift` holds the scheduling, the snooze intent and the metadata.
  - The countdown view is `WakeUpAlarmActivity`, inside the existing `DottodayWidgets` extension.

  The bridge sits behind `#available(iOS 26.0, *)`, and the framework is weak-linked, so iOS 16–25
  launch and keep W1a's time-sensitive notification unchanged. Android is in-house Kotlin under
  `alarms/`:
  - `setAlarmClock`;
  - a receiver;
  - `WakeUpRingService`, a `mediaPlayback` foreground service;
  - `WakeUpAlarmActivity`, shown over the lock screen.
- **Exactly once (R-10).** `NotificationSync` asks the planner for the week's Wake Ups and hands
  them to `WakeUpArming` → `AlarmGateway.sync`. The instants it armed come back, and
  `NotificationPlanner.plan(armedWakeUps:)` leaves those out, so a device that arms nothing rings
  everything on the notification path. Arming nothing happens:
  - below iOS 26;
  - when alarms are not allowed;
  - when Android's exact alarms are off;
  - on the Mac and the web.

  The armed instants are also kept per device in `local_meta`. Android registers the channel on
  the activity, so the background refresh cannot reach it. It then keeps the last armed set and
  rings anything new on the notification path, rather than ringing twice or not at all.
- **One alarm per day.** The alarm id is `wakeup:<civil date>`. On iOS the AlarmKit UUID is a hash
  of that id. `sync` cancels every scheduled alarm that is no longer wanted unchanged, but never
  touches one that is ringing or counting down a snooze; only "I'm up" or the 10-minute cap ends
  those. Turning the switch off calls `disarmAll`.
- **Snooze is a fresh arm.**
  - **iOS:** Snooze is a `LiveActivityIntent` (`.custom` behaviour). It stops the ring and arms a
    countdown of `snoozeMin` with the count raised, so once the limit is reached the next alert
    carries no Snooze. AlarmKit's own `.countdown` behaviour cannot limit the count.
  - **Android:** Snooze re-arms through `setAlarmClock` and shows a countdown notification.
- **Words travel with the alarm.** The title, the body, "I'm up" and "Snooze" are composed in Dart
  from the ARB files (`composeWakeUpAlarm`). The native screens show them with the app closed.
  Only Android's channel name and its "Snoozed until" line are Android resources.
- **Sound.** The alarm uses the Start sounds as they are: bundled `.caf` on iOS, `res/raw` on
  Android. The cue for a date is a pure function (`wakeUpSound`), so a test can say which cue a
  given day gets.

## Consequences
- Play's full-screen-intent declaration is required: docs/08 §6.1 C, an owner gate. The manifest
  policy test allows exactly one activity over the lock screen, the ringing screen.
- The real-device checks remain manual release gates (docs/15 §13):
  - iOS 26, app force-quit, Silent on;
  - Android 14 in Doze;
  - no AlarmKit alarm left after uninstall.
- Signing out keeps the local day (local-first), so the alarms keep ringing like every reminder.
  The switch, not the account, is what disarms them.
- The `wake_up_days` state table and the alarm event log (dismissed at, snoozes) are not built
  here. They come with the Wake Up card (W2), their first reader.

## Alternatives
- `alarm_kit` 0.1.1 or `flutter_alarmkit` 0.5.0. Rejected as new 0.x dependencies with a bus
  factor of 1, with no documented snooze limit, and (for the second) a second widget target.
- AlarmKit's `.countdown` snooze. Rejected because it cannot drop Snooze at the limit.
- Keeping the Android Wake Up on flutter_local_notifications. Rejected because it gives no
  ringing service: the sound is a notification sound, there is no 10-minute cap and no ramp.
