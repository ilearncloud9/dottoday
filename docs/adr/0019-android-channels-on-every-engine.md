# ADR-0019 · Android: the Wake Up alarm channel on every Flutter engine

Status: Accepted · Date: 2026-11-15 · Owner approval 2026-11-15 (in-repo plugin package) ·
Amends ADR-0017 (where `dottoday/alarm` is registered) · R-10 "notifications fire exactly once"

## Context
The daily refresh and the clock/zone re-arm run in WorkManager's background engine
(`lib/background_refresh.dart`). workmanager_android 0.10.9 builds that engine with
`FlutterEngine(applicationContext)`, which attaches only the plugins in `pubspec.yaml` (through
`GeneratedPluginRegistrant`) and offers no callback for the app's own channels. `dottoday/alarm` was
registered in `MainActivity.configureFlutterEngine`, so the background resync got
`MissingPluginException`. When a sync pull moved Wake Up, turned it off, or changed a day's first
dot or mission flag:
- the old native alarm kept ringing;
- the new time rang as a notification as well, until the app was opened;
- a failed `disarmAll` still forgot `armed_wake_ups`.

## Decision
- **An in-repo plugin package, `app/packages/dottoday_engine_hooks`.** It is Android only, has no
  third-party code and is about 30 lines. Being a plugin is what gets it attached to every engine,
  including workmanager's. Its `onAttachedToEngine` calls one hook.
- **`DottodayApp` (the `Application`) installs that hook in `onCreate`.** `onCreate` runs before
  any engine in the process starts, and the hook attaches `AlarmBridge`. `MainActivity` no longer
  attaches it: the same hook covers the activity's engine.
- **Java, not Kotlin, in the package.** A Java library module needs no Kotlin plugin to keep in
  step with AGP 9's built-in Kotlin switch.
- **A disarm that can't reach the OS keeps `armed_wake_ups`.** `AlarmGateway.disarmAll` returns
  false when the OS side can't be reached. `WakeUpArming` then keeps the armed instants, so the
  notification path still leaves them out and the next reachable sync disarms them. This covers
  any engine that still can't reach the channel.

## Consequences
- Other background engines also get `dottoday/alarm`, for example `flutter_local_notifications`'
  action isolate. It is harmless there: nothing in them calls it.
- Only `AlarmBridge` moved. The other app channels stay activity-only until a background caller
  needs one, which then goes through the same hook.
- Device check: `integration_test/wake_up_background_test.dart`, part of
  `tool/device_tests.sh android`.

## Alternatives
- Swapping in a custom `FlutterJNI` through `FlutterInjector` to catch every engine's messenger.
  Rejected: it depends on embedding internals.
- Wrapping workmanager's `BackgroundWorker` in a custom `WorkerFactory`. Rejected: the class and
  its engine are private.
- Leaving the new Wake Up instants out of the notification path while the channel can't be reached.
  Rejected: it trades a double ring for a missed one.
