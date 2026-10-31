import 'package:dottoday/core/clock/clock_provider.dart';
import 'package:dottoday/core/logging/logger_provider.dart';
import 'package:dottoday/data/db/database_providers.dart';
import 'package:dottoday/data/live_activity/live_activity_sink.dart';
import 'package:dottoday/data/live_activity/web_live_dot_providers.dart';
import 'package:dottoday/data/notifications/health_providers.dart';
import 'package:dottoday/data/notifications/notification_providers.dart';
import 'package:dottoday/data/notifications/notification_sync.dart';
import 'package:dottoday/data/notifications/os_notification_gateway.dart';
import 'package:dottoday/data/notifications/pending_notification_gateways.dart';
import 'package:dottoday/data/notifications/test_alarm.dart';
import 'package:dottoday/data/repositories/repository_providers.dart';
import 'package:dottoday/data/snapshot/composite_snapshot_sink.dart';
import 'package:dottoday/data/snapshot/day_snapshot_writer.dart';
import 'package:dottoday/data/snapshot/web_snapshot_sink.dart';
import 'package:dottoday/data/sync/shared_hlc.dart';
import 'package:dottoday/data/widgets/home_widget_sink.dart';
import 'package:dottoday/data/widgets/mac_status_item_sink.dart';
import 'package:dottoday/data/writes/after_write_effects.dart';
import 'package:dottoday/data/writes/drift_write_use_case.dart';
import 'package:dottoday/domain/notifications/notification_gateway.dart';
import 'package:dottoday/domain/notifications/notification_planner.dart';
import 'package:dottoday/domain/recurrence/materialiser.dart';
import 'package:dottoday/domain/snapshot/day_snapshot.dart';
import 'package:dottoday/domain/writes/write_use_case.dart';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'write_providers.g.dart';

/// The notification scheduler (M5.1, M5.3): the OS on iOS, Android and
/// macOS, timers + service worker on the web.
@Riverpod(keepAlive: true)
NotificationGateway notificationGateway(Ref ref) {
  return OsNotificationGateway(
    // Read lazily: starting the platform wires the tap handler, which
    // writes through this provider's own dependants.
    platform: () => ref.read(notificationsStartedProvider.future),
    occurrences: ref.watch(occurrenceRepositoryProvider),
    profile: () => latestProfile(ref),
    subtasks: ref.watch(subtaskRepositoryProvider),
  );
}

/// Where the widget snapshot goes (M5.4, M5.5): home-screen widgets on
/// iOS and Android (plus the Live Activity / ongoing notification, M9.3,
/// M9.4), the menu-bar "Next up"
/// on the Mac, Cache Storage on the web.
@Riverpod(keepAlive: true)
DaySnapshotSink daySnapshotSink(Ref ref) {
  if (HomeWidgetSink.supported) {
    final widgets = HomeWidgetSink(profile: () => latestProfile(ref));
    if (!LiveActivitySink.supported) return widgets;
    return CompositeSnapshotSink([
      widgets,
      LiveActivitySink(
        clock: ref.watch(clockProvider),
        profile: () => latestProfile(ref),
        channel: LiveActivitySink.platformChannel!,
      ),
    ]);
  }
  if (MacStatusItemSink.supported) {
    return MacStatusItemSink(profile: () => latestProfile(ref));
  }
  if (WebSnapshotSink.supported) {
    return WebSnapshotSink(
      profile: () => latestProfile(ref),
      onWrite: (s) => ref.read(lastDaySnapshotProvider.notifier).set(s),
    );
  }
  return const UnwiredDaySnapshotSink();
}

@Riverpod(keepAlive: true)
NotificationSync notificationSync(Ref ref) => NotificationSync(
  clock: ref.watch(clockProvider),
  planner: NotificationPlanner(
    clock: ref.watch(clockProvider),
    // iOS drops pending notifications past 64 without a word; keep the
    // nearest 50 there and on macOS (M6.5 rule, enforced in M8.4d once a
    // default set can hold 5 alerts per task).
    maxPending: _apple ? NotificationPlanner.applePendingBudget : null,
  ),
  gateway: ref.watch(notificationGatewayProvider),
  occurrences: ref.watch(occurrenceRepositoryProvider),
  series: ref.watch(seriesRepositoryProvider),
  settings: ref.watch(settingsRepositoryProvider),
  testAlarmAt: () => TestAlarmStore(ref.read(appDatabaseProvider)).at(),
  subtasks: ref.watch(subtaskRepositoryProvider),
  ringsWakeUp: currentHealthPlatform().isPhone,
);

@Riverpod(keepAlive: true)
DaySnapshotWriter daySnapshotWriter(Ref ref) => DaySnapshotWriter(
  clock: ref.watch(clockProvider),
  occurrences: ref.watch(occurrenceRepositoryProvider),
  profile: () => latestProfile(ref),
  sink: ref.watch(daySnapshotSinkProvider),
);

@Riverpod(keepAlive: true)
AfterWriteEffects afterWriteEffects(Ref ref) => AfterWriteEffects(
  notifications: ref.watch(notificationSyncProvider),
  snapshot: ref.watch(daySnapshotWriterProvider),
  logger: ref.watch(loggerProvider),
);

/// This device's one HLC, shared by the write path and sync (M6.2).
@Riverpod(keepAlive: true)
SharedHlc sharedHlc(Ref ref) =>
    SharedHlc(ref.watch(appDatabaseProvider), ref.watch(clockProvider));

/// The single write path (docs/09 M2.3).
@Riverpod(keepAlive: true)
WriteUseCase writeUseCase(Ref ref) => DriftWriteUseCase(
  db: ref.watch(appDatabaseProvider),
  clock: ref.watch(clockProvider),
  materialiser: Materialiser(clock: ref.watch(clockProvider)),
  effects: ref.watch(afterWriteEffectsProvider),
  logger: ref.watch(loggerProvider),
  hlc: ref.watch(sharedHlcProvider),
);

/// Whether this build runs on iOS or macOS (scheduling budget, not layout).
bool get _apple =>
    !kIsWeb &&
    (defaultTargetPlatform == TargetPlatform.iOS ||
        defaultTargetPlatform == TargetPlatform.macOS);
