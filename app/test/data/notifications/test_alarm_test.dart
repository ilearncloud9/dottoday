import 'package:dottoday/data/notifications/notification_sync.dart';
import 'package:dottoday/data/notifications/test_alarm.dart';
import 'package:dottoday/data/repositories/drift_occurrence_repository.dart';
import 'package:dottoday/data/repositories/drift_series_repository.dart';
import 'package:dottoday/data/repositories/drift_settings_repository.dart';
import 'package:dottoday/domain/notifications/notification_planner.dart';
import 'package:dottoday/domain/notifications/planned_notification.dart';
import 'package:dottoday/domain/writes/write_batch.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest.dart' as tz_data;

import '../../domain/fixtures.dart';
import '../writes/write_harness.dart';

// The test alarm goes through the one reconcile path (docs/09 M6.5.9):
// stored, planned, pending once; cleared, it is cancelled.
void main() {
  setUpAll(tz_data.initializeTimeZones);
  late WriteHarness h;
  late TestAlarmStore store;
  late NotificationSync sync;

  setUp(() async {
    h = WriteHarness(DateTime.utc(2026, 10, 23, 9));
    await h.writes.apply(WriteBatch(userId: userId, profile: profileFixture()));
    await h.effects.idle;
    store = TestAlarmStore(h.db);
    sync = NotificationSync(
      clock: h.clock,
      planner: NotificationPlanner(clock: h.clock),
      gateway: h.gateway,
      occurrences: DriftOccurrenceRepository(h.db),
      series: DriftSeriesRepository(h.db),
      settings: DriftSettingsRepository(h.db),
      testAlarmAt: store.at,
    );
  });
  tearDown(() => h.dispose());

  Iterable<PlannedNotification> tests() => h.gateway.pendingSet.values.where(
    (n) => n.purpose == NotificationPurpose.testAlarm,
  );

  test(
    'stored → one pending loud alarm; resync again changes nothing',
    () async {
      final at = h.clock.nowUtc().add(TestAlarmStore.delay);
      await store.set(at);
      await sync.resync(userId);
      expect(tests().single.fireAtUtc, at);
      expect(tests().single.loud, isTrue);
      final applied = h.gateway.applied.length;
      await sync.resync(userId);
      expect(h.gateway.applied.length, applied, reason: 'idempotent');
    },
  );

  test('cleared → cancelled', () async {
    await store.set(h.clock.nowUtc().add(TestAlarmStore.delay));
    await sync.resync(userId);
    await store.clear();
    await sync.resync(userId);
    expect(tests(), isEmpty);
    expect(await store.at(), isNull);
  });
}
