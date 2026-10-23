import 'package:dottoday/data/notifications/notification_sync.dart';
import 'package:dottoday/data/refresh/daily_refresh.dart';
import 'package:dottoday/data/repositories/drift_occurrence_repository.dart';
import 'package:dottoday/data/repositories/drift_series_repository.dart';
import 'package:dottoday/data/repositories/drift_settings_repository.dart';
import 'package:dottoday/domain/notifications/notification_planner.dart';
import 'package:dottoday/domain/writes/write_batch.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest.dart' as tz_data;

import '../../domain/fixtures.dart';
import '../writes/write_harness.dart';

final _now = DateTime.utc(2026, 10, 21, 6);

void main() {
  late WriteHarness h;
  late DailyRefresh refresh;

  setUpAll(tz_data.initializeTimeZones);

  setUp(() async {
    h = WriteHarness(_now);
    await h.writes.apply(WriteBatch(userId: userId, profile: profileFixture()));
    await h.writes.apply(WriteBatch(userId: userId, series: [seriesFixture()]));
    await h.effects.idle;
    refresh = DailyRefresh(
      clock: h.clock,
      series: DriftSeriesRepository(h.db),
      writes: h.writes,
      notifications: NotificationSync(
        clock: h.clock,
        planner: NotificationPlanner(clock: h.clock),
        gateway: h.gateway,
        occurrences: DriftOccurrenceRepository(h.db),
        series: DriftSeriesRepository(h.db),
        settings: DriftSettingsRepository(h.db),
      ),
      logger: h.logger,
    );
  });
  tearDown(() => h.dispose());

  Future<DateTime> lastStart() async {
    final rows = await h.db.select(h.db.occurrences).get();
    return rows
        .map(
          (o) => DateTime.fromMillisecondsSinceEpoch(o.startUtc!, isUtc: true),
        )
        .reduce((a, b) => a.isAfter(b) ? a : b);
  }

  test('rolls a repeat forward as the days pass (M5.2)', () async {
    final before = await lastStart();
    h.clock.advance(const Duration(days: 30));
    expect(await refresh.run(userId), isTrue);
    await h.effects.idle;
    final after = await lastStart();
    expect(after.difference(before).inDays, inInclusiveRange(28, 31));
    expect(
      after.isAfter(h.clock.nowUtc().add(const Duration(days: 85))),
      isTrue,
    );
  });

  test('a second run the same day writes nothing', () async {
    h.clock.advance(const Duration(days: 3));
    await refresh.run(userId);
    await h.effects.idle;
    final rows = (await h.db.select(h.db.occurrences).get()).length;
    final log = (await h.changeLog()).length;
    await refresh.run(userId);
    await h.effects.idle;
    expect((await h.db.select(h.db.occurrences).get()).length, rows);
    expect((await h.changeLog()).length, log);
  });

  test('nothing due still re-plans notifications', () async {
    final applied = h.gateway.applied.length;
    h.gateway.pendingSet.clear();
    await refresh.run(userId);
    expect(h.gateway.applied.length, greaterThan(applied));
  });
}
