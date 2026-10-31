import 'package:dottoday/data/db/app_database.dart';
import 'package:dottoday/data/repositories/drift_wake_up_day_repository.dart';
import 'package:dottoday/domain/wake_up/wake_up_day.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

// This device's mornings in `wake_up_days` (docs/15 §3, M17.3).

void main() {
  late AppDatabase db;
  late DriftWakeUpDayRepository repo;
  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    repo = DriftWakeUpDayRepository(db);
  });
  tearDown(() => db.close());

  DateTime at(int d, int h, [int m = 0]) => DateTime.utc(2026, 11, d, h, m);

  test('events fold into their days; the test alarm into none', () async {
    await repo.applyEvents([
      AlarmEvent('wakeup:2026-11-02', AlarmEventKind.rang, at(2, 6, 30)),
      AlarmEvent('wakeup:2026-11-02', AlarmEventKind.snoozed, at(2, 6, 31)),
      AlarmEvent('wakeup:2026-11-02', AlarmEventKind.stopped, at(2, 6, 41)),
      AlarmEvent('wakeup:test', AlarmEventKind.stopped, at(2, 9)),
    ]);
    final day = await repo.watch('2026-11-02').first;
    expect(day?.rangAtUtc, at(2, 6, 30));
    expect(day?.snoozes, 1);
    expect(day?.stoppedAtUtc, at(2, 6, 41));
    expect(await db.select(db.wakeUpDaysTable).get(), hasLength(1));
  });

  test('the card is marked once; a later mark keeps the first', () async {
    await repo.markCardShown('2026-11-02', at(2, 7));
    await repo.markCardShown('2026-11-02', at(2, 8));
    expect((await repo.watch('2026-11-02').first)?.cardShownAtUtc, at(2, 7));
    await repo.markStarted('2026-11-02', at(2, 7, 5));
    final day = await repo.watch('2026-11-02').first;
    expect(day?.startedAtUtc, at(2, 7, 5));
    expect(day?.cardShownAtUtc, at(2, 7), reason: 'kept');
  });

  test('the last alarm is the newest day that rang or stopped', () async {
    expect(await repo.lastAlarm(), isNull);
    await repo.applyEvents([
      AlarmEvent('wakeup:2026-11-01', AlarmEventKind.stopped, at(1, 7)),
      AlarmEvent('wakeup:2026-11-02', AlarmEventKind.rang, at(2, 7)),
    ]);
    await repo.markCardShown('2026-11-03', at(3, 7));
    expect((await repo.lastAlarm())?.date, '2026-11-02');
  });
}
