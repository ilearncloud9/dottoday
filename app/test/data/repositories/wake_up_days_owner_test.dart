import 'package:dottoday/data/db/app_database.dart';
import 'package:dottoday/data/db/owner_meta.dart';
import 'package:dottoday/data/repositories/drift_wake_up_day_repository.dart';
import 'package:dottoday/domain/wake_up/wake_up_day.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

// CR-160 Wake Up audit: each owner sees, and is steered by, its own
// mornings only: today's row, "Last wake-up", the learning, mission skips.

void main() {
  late AppDatabase db;
  late DriftWakeUpDayRepository repo;

  Future<void> show(String id) => db.customStatement(
    'INSERT OR REPLACE INTO local_meta (key, value) VALUES (?, ?)',
    [activeOwnerKey, id],
  );

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    repo = DriftWakeUpDayRepository(db);
    for (final id in ['a', 'b']) {
      await db.customStatement(
        'INSERT INTO profiles (id, tz_id, locale, settings, created_at, '
        "updated_at) VALUES ('$id', 'UTC', 'en', '{}', 0, 0)",
      );
    }
  });
  tearDown(() => db.close());

  final rang = DateTime.utc(2026, 11, 12, 6, 30);
  final stopped = DateTime.utc(2026, 11, 12, 6, 41);

  test("A's morning never shows for B, and B's day is its own", () async {
    await show('a');
    await repo.applyEvents([
      AlarmEvent('wakeup:2026-11-12', AlarmEventKind.rang, rang),
      AlarmEvent('wakeup:2026-11-12', AlarmEventKind.stopped, stopped),
    ]);
    await repo.markStarted('2026-11-12', stopped);
    await repo.markMissionSkipped('2026-11-12', stopped);

    await show('b');
    expect(await repo.watch('2026-11-12').first, isNull);
    expect(await repo.lastAlarm(), isNull);
    expect(await repo.recentStops(14), isEmpty);
    expect(await repo.missionSkipsSince(DateTime.utc(2026)), isEmpty);
    await repo.markCardShown('2026-11-12', stopped);
    expect((await repo.watch('2026-11-12').first)?.startedAtUtc, isNull);

    await show('a');
    final a = await repo.watch('2026-11-12').first;
    expect(
      (a?.rangAtUtc, a?.startedAtUtc, a?.cardShownAtUtc),
      (rang, stopped, null),
    );
    expect((await repo.lastAlarm())?.date, '2026-11-12');
  });
}
