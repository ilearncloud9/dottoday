import 'package:dottoday/core/clock/clock_provider.dart';
import 'package:dottoday/core/logging/logger.dart';
import 'package:dottoday/core/logging/logger_provider.dart';
import 'package:dottoday/data/backup/backup_database.dart';
import 'package:dottoday/data/backup/backup_providers.dart';
import 'package:dottoday/data/db/app_database.dart';
import 'package:dottoday/data/db/database_providers.dart';
import 'package:dottoday/data/intents/intent_providers.dart';
import 'package:dottoday/data/notifications/notification_providers.dart';
import 'package:dottoday/data/notifications/permission_providers.dart';
import 'package:dottoday/data/owners/owner_switch.dart';
import 'package:dottoday/data/profile/profile_providers.dart';
import 'package:dottoday/data/sync/account_owners.dart';
import 'package:dottoday/data/sync/shared_hlc.dart';
import 'package:dottoday/data/wake_up/wake_up_providers.dart';
import 'package:dottoday/data/writes/write_providers.dart';
import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:dottoday/domain/notifications/notification_payload.dart';
import 'package:dottoday/domain/profile/local_profile_service.dart';
import 'package:dottoday/domain/writes/write_batch.dart';
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;

import '../data/writes/write_harness.dart';
import 'fake_clock.dart';
import 'fake_notification_platform.dart';
import 'memory_log_sink.dart';
import 'shared_action_queue.dart';
import 'timeline_fakes.dart';

// One app run for the CR-160 owner tests (I3, I6, I7, I8): the real
// OwnerSwitch, write path, drainer and providers on an in-memory database,
// with fakes for the OS.

/// The tests' "now".
final ownerAppNow = DateTime.utc(2026, 10, 23, 9);

/// One app run on [db]: the OS ([platform], [alarms]) and the snapshot
/// store ([sink]) outlive it, as they do on a device.
final ownerAppLogs = MemoryLogSink();

final class OwnerApp {
  OwnerApp(
    this.db,
    this.platform,
    this.sink,
    this.alarms,
    this.queue, {
    List<Override> extra = const [],
  }) : container = ProviderContainer(
         overrides: [
           ...extra,
           appDatabaseProvider.overrideWithValue(db),
           backupDatabaseProvider.overrideWithValue(
             BackupDatabase(NativeDatabase.memory()),
           ),
           clockProvider.overrideWithValue(FakeClock(ownerAppNow)),
           deviceTimeZoneProvider.overrideWith((ref) async => 'UTC'),
           deviceLanguageProvider.overrideWithValue('en'),
           notificationPlatformProvider.overrideWith((ref) async => platform),
           daySnapshotSinkProvider.overrideWithValue(sink),
           alarmGatewayProvider.overrideWithValue(alarms),
           missionSensorsProvider.overrideWithValue(FakeMissionSensors()),
           actionQueueStoreProvider.overrideWithValue(queue),
           loggerProvider.overrideWithValue(
             Logger(ownerAppLogs, FakeClock(ownerAppNow)),
           ),
         ],
       );

  final AppDatabase db;
  final FakeNotificationPlatform platform;
  final FakeSink sink;
  final FakeAlarmGateway alarms;
  final SharedActionQueue queue;
  final ProviderContainer container;

  OwnerSwitch get owners => container.read(ownerSwitchProvider);

  Future<String> shown() async =>
      (await container.read(localProfileProvider.future)).id;

  Future<void> idle() => container.read(afterWriteEffectsProvider).idle;

  /// [account] signs in (no guest work to choose about), then the switch.
  Future<void> signIn(String account) async {
    await signInAs(account);
  }

  /// [account]'s sign-in step through the switch; what it changed.
  Future<OwnerChange> signInAs(String account) async {
    final result = await owners.signIn(
      () => signInOwner(
        db,
        account,
        SharedHlc(db, FakeClock(ownerAppNow)),
        freshProfile: (id) => freshAccountProfile(id, 'UTC', 'en', ownerAppNow),
      ),
    );
    return result.change;
  }

  Future<void> write(List<Occurrence> rows) async {
    await container
        .read(writeUseCaseProvider)
        .apply(WriteBatch(userId: rows.first.userId, occurrences: rows));
    await idle();
  }

  /// Occurrence ids the OS holds, pending or shown.
  Set<String> notified() => {
    for (final n in [
      ...platform.pendingById.values,
      ...platform.delivered.values,
    ])
      ?decodeNotificationPayload(n.id, n.payload)?.occurrenceId,
  }..remove('');

  Set<String> snapshotDots() => {for (final d in sink.written.last.dots) d.id};
}
