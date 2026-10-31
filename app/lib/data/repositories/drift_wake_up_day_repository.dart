import 'package:dottoday/data/db/app_database.dart';
import 'package:dottoday/domain/repositories/wake_up_day_repository.dart';
import 'package:dottoday/domain/wake_up/wake_up_day.dart';
import 'package:drift/drift.dart';

/// [WakeUpDayRepository] over `wake_up_days` (docs/15 §3, schema 10).
final class DriftWakeUpDayRepository implements WakeUpDayRepository {
  const DriftWakeUpDayRepository(this._db);

  final AppDatabase _db;

  @override
  Stream<WakeUpDay?> watch(String date) => (_db.select(
    _db.wakeUpDaysTable,
  )..where((d) => d.date.equals(date))).watchSingleOrNull().map(_toDay);

  @override
  Future<WakeUpDay?> lastAlarm() async {
    final t = _db.wakeUpDaysTable;
    final row =
        await (_db.select(t)
              ..where(
                (d) => d.rangAtUtc.isNotNull() | d.stoppedAtUtc.isNotNull(),
              )
              ..orderBy([(d) => OrderingTerm.desc(d.date)])
              ..limit(1))
            .getSingleOrNull();
    return _toDay(row);
  }

  @override
  Future<void> applyEvents(List<AlarmEvent> events) =>
      _db.transaction(() async {
        for (final event in events) {
          final date = event.date;
          if (date == null) continue;
          final day = await _read(date) ?? WakeUpDay(date: date);
          await _write(applyAlarmEvent(day, event));
        }
      });

  @override
  Future<void> markCardShown(String date, DateTime atUtc) => _update(
    date,
    (d) => d.copyWith(cardShownAtUtc: d.cardShownAtUtc ?? atUtc),
  );

  @override
  Future<void> markStarted(String date, DateTime atUtc) =>
      _update(date, (d) => d.copyWith(startedAtUtc: d.startedAtUtc ?? atUtc));

  Future<void> _update(String date, WakeUpDay Function(WakeUpDay) change) =>
      _db.transaction(
        () async => _write(change(await _read(date) ?? WakeUpDay(date: date))),
      );

  Future<WakeUpDay?> _read(String date) async => _toDay(
    await (_db.select(
      _db.wakeUpDaysTable,
    )..where((d) => d.date.equals(date))).getSingleOrNull(),
  );

  Future<void> _write(WakeUpDay day) => _db
      .into(_db.wakeUpDaysTable)
      .insertOnConflictUpdate(
        WakeUpDaysTableCompanion.insert(
          date: day.date,
          rangAtUtc: Value(_ms(day.rangAtUtc)),
          stoppedAtUtc: Value(_ms(day.stoppedAtUtc)),
          snoozes: Value(day.snoozes),
          cardShownAtUtc: Value(_ms(day.cardShownAtUtc)),
          startedAtUtc: Value(_ms(day.startedAtUtc)),
        ),
      );
}

WakeUpDay? _toDay(WakeUpDayRow? row) => row == null
    ? null
    : WakeUpDay(
        date: row.date,
        rangAtUtc: _utc(row.rangAtUtc),
        stoppedAtUtc: _utc(row.stoppedAtUtc),
        snoozes: row.snoozes,
        cardShownAtUtc: _utc(row.cardShownAtUtc),
        startedAtUtc: _utc(row.startedAtUtc),
      );

int? _ms(DateTime? at) => at?.millisecondsSinceEpoch;

DateTime? _utc(int? ms) =>
    ms == null ? null : DateTime.fromMillisecondsSinceEpoch(ms, isUtc: true);
