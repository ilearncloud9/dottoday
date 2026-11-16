// The Wake Up alarm follows a plan the background resync changed (R-10,
// ADR-0019), Android: a sync pull moves the Wake Up, then turns it off,
// and the WorkManager worker — its own engine — re-arms and disarms the
// native alarm. Each time exactly one ring source is left: the native
// alarm at the new time and no Wake Up notification, then neither.
// The change is written on a second database connection, as the worker's
// sync applies it, so the app on screen never sees it and only the worker
// can move the alarm.
// Run: tool/device_tests.sh android wake_up_background
import 'dart:convert';

import 'package:dottoday/background_refresh.dart';
import 'package:dottoday/core/ids/id_generator.dart';
import 'package:dottoday/data/db/app_database.dart';
import 'package:dottoday/data/db/database_providers.dart';
import 'package:dottoday/data/notifications/notification_providers.dart';
import 'package:dottoday/data/profile/profile_providers.dart';
import 'package:dottoday/data/profile/settings_actions.dart';
import 'package:dottoday/data/writes/write_providers.dart';
import 'package:dottoday/domain/entities/enums.dart';
import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:dottoday/domain/entities/settings.dart';
import 'package:dottoday/domain/notifications/notification_payload.dart';
import 'package:dottoday/domain/notifications/planned_notification.dart';
import 'package:dottoday/domain/writes/write_batch.dart';
import 'package:drift/drift.dart' show Value;
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:workmanager/workmanager.dart';

import 'live_activity_test.dart' show waitUntil;
import 'support/cal_app.dart';
import 'support/no_dialog_notifications.dart';

const _channel = MethodChannel('dottoday/alarm');

/// The stored Wake Up alarms (not the test alarm), as id → fireAtMs.
Future<Map<String, int>> _wakeUps() async {
  final all = await _channel.invokeListMethod<Map<Object?, Object?>>('stored');
  return {
    for (final a in all ?? const <Map<Object?, Object?>>[])
      if ((a['id']! as String).startsWith('wakeup:2'))
        a['id']! as String: a['fireAtMs']! as int,
  };
}

/// What a sync pull from another device writes: [change] to the profile's
/// settings, on a connection of its own (drift's "created multiple times"
/// warning is expected: each connection has its own executor).
Future<void> _pull(String userId, Settings Function(Settings) change) async {
  final other = ProviderContainer();
  try {
    final db = other.read(appDatabaseProvider);
    final row = await (db.select(
      db.profiles,
    )..where((p) => p.id.equals(userId))).getSingle();
    final settings = Settings.fromJson(
      jsonDecode(row.settings) as Map<String, Object?>,
    );
    await (db.update(db.profiles)..where((p) => p.id.equals(userId))).write(
      ProfilesCompanion(settings: Value(jsonEncode(change(settings).toJson()))),
    );
  } finally {
    other.dispose();
  }
}

Future<void> _runWorker(String name) => Workmanager().registerOneOffTask(
  name,
  rearmTask,
  existingWorkPolicy: ExistingWorkPolicy.replace,
);

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('the worker moves, then disarms, the native Wake Up', (
    tester,
  ) async {
    if (defaultTargetPlatform != TargetPlatform.android) return;
    final c = await startApp(tester);
    final plugin = c.read(localNotificationsPluginProvider);
    await ensureNotificationsWithoutDialog(plugin, needExact: true);
    final profile = await c.read(localProfileProvider.future);
    final zone = tz.getLocation(profile.tzId);
    final now = tz.TZDateTime.now(zone);
    final tomorrow = tz.TZDateTime(zone, now.year, now.month, now.day + 1);
    final weekday = Weekday.values[tomorrow.weekday - 1];
    final id = 'wakeup:${tomorrow.toIso8601String().substring(0, 10)}';
    int at(int hour, int minute) => tz.TZDateTime(
      zone,
      tomorrow.year,
      tomorrow.month,
      tomorrow.day,
      hour,
      minute,
    ).millisecondsSinceEpoch;
    Settings wakeAt(Settings s, String start) => s.copyWith(
      dayBoundaries: {
        ...s.dayBoundaries,
        weekday: TimeWindow(start: start, end: '22:00'),
      },
    );

    // A Wake Up rings only on a day with a dot.
    final created = DateTime.now().toUtc();
    await c
        .read(writeUseCaseProvider)
        .apply(
          WriteBatch(
            userId: profile.id,
            occurrences: [
              Occurrence(
                id: const UuidV7Generator().newId(),
                userId: profile.id,
                title: 'Wake Up background check',
                tzId: profile.tzId,
                startUtc: DateTime.fromMillisecondsSinceEpoch(
                  at(9, 0),
                  isUtc: true,
                ),
                durationMin: 30,
                createdAt: created,
                updatedAt: created,
              ),
            ],
          ),
        );
    await updateSettings(
      c,
      (s) => wakeAt(s.copyWith(wakeUpAlarm: true), '06:00'),
    );
    await c.read(notificationSyncProvider).resync(profile.id);
    expect((await _wakeUps())[id], at(6, 0), reason: 'armed in the app');

    Future<List<PlannedNotification>> wakeUpNotes() async => [
      for (final r in await plugin.pendingNotificationRequests())
        if (decodeNotificationPayload(r.id, r.payload) case final p?
            when p.purpose == NotificationPurpose.wakeUp)
          p,
    ];

    // Moved on another device: the worker re-arms the native alarm.
    await _pull(profile.id, (s) => wakeAt(s, '06:30'));
    await _runWorker('dottoday.wakeup.moved');
    await waitUntil(
      tester,
      () async => (await _wakeUps())[id] == at(6, 30),
      timeout: const Duration(seconds: 90),
    );
    expect((await _wakeUps()).values, isNot(contains(at(6, 0))));
    expect(
      await wakeUpNotes(),
      isEmpty,
      reason: 'the alarm rings it, not a notification',
    );

    // Turned off on another device: the worker disarms it.
    await _pull(profile.id, (s) => s.copyWith(wakeUpAlarm: false));
    await _runWorker('dottoday.wakeup.off');
    await waitUntil(
      tester,
      () async => (await _wakeUps()).isEmpty,
      timeout: const Duration(seconds: 90),
    );
    expect(await wakeUpNotes(), isEmpty);
    final db = c.read(appDatabaseProvider);
    final meta = await (db.select(
      db.localMeta,
    )..where((m) => m.key.equals('armed_wake_ups'))).getSingleOrNull();
    expect(meta, isNull, reason: 'forgotten only after the disarm landed');
    debugPrint('WAKE_UP_BACKGROUND moved and disarmed by the worker');
  });
}
