import 'package:dottoday/core/clock/clock_provider.dart';
import 'package:dottoday/core/ids/id_generator.dart';
import 'package:dottoday/core/logging/logger_provider.dart';
import 'package:dottoday/data/db/database_providers.dart';
import 'package:dottoday/data/notifications/notification_providers.dart';
import 'package:dottoday/data/notifications/notification_sync.dart';
import 'package:dottoday/data/notifications/os_notification_gateway.dart';
import 'package:dottoday/data/notifications/pending_notification_gateways.dart';
import 'package:dottoday/data/repositories/repository_providers.dart';
import 'package:dottoday/data/widgets/widget_snapshot_writer.dart';
import 'package:dottoday/data/writes/after_write_effects.dart';
import 'package:dottoday/data/writes/drift_write_use_case.dart';
import 'package:dottoday/domain/notifications/notification_gateway.dart';
import 'package:dottoday/domain/notifications/notification_planner.dart';
import 'package:dottoday/domain/recurrence/materialiser.dart';
import 'package:dottoday/domain/widgets/widget_snapshot.dart';
import 'package:dottoday/domain/writes/write_use_case.dart';
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
  );
}

/// Home-screen widget snapshot target; replaced in M5.4.
@Riverpod(keepAlive: true)
WidgetSnapshotSink widgetSnapshotSink(Ref ref) =>
    const UnwiredWidgetSnapshotSink();

@Riverpod(keepAlive: true)
NotificationSync notificationSync(Ref ref) => NotificationSync(
  clock: ref.watch(clockProvider),
  planner: NotificationPlanner(clock: ref.watch(clockProvider)),
  gateway: ref.watch(notificationGatewayProvider),
  occurrences: ref.watch(occurrenceRepositoryProvider),
  series: ref.watch(seriesRepositoryProvider),
  settings: ref.watch(settingsRepositoryProvider),
);

@Riverpod(keepAlive: true)
AfterWriteEffects afterWriteEffects(Ref ref) => AfterWriteEffects(
  notifications: ref.watch(notificationSyncProvider),
  snapshot: WidgetSnapshotWriter(
    clock: ref.watch(clockProvider),
    occurrences: ref.watch(occurrenceRepositoryProvider),
    sink: ref.watch(widgetSnapshotSinkProvider),
  ),
  logger: ref.watch(loggerProvider),
);

/// The single write path (docs/09 M2.3).
@Riverpod(keepAlive: true)
WriteUseCase writeUseCase(Ref ref) => DriftWriteUseCase(
  db: ref.watch(appDatabaseProvider),
  clock: ref.watch(clockProvider),
  materialiser: Materialiser(
    clock: ref.watch(clockProvider),
    ids: const UuidV7Generator(),
  ),
  effects: ref.watch(afterWriteEffectsProvider),
  logger: ref.watch(loggerProvider),
);
