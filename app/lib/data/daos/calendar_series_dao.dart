import 'package:dottoday/data/db/app_database.dart';
import 'package:dottoday/data/db/tables/calendar_series_table.dart';
import 'package:drift/drift.dart';

part 'calendar_series_dao.g.dart';

/// Single-table queries over `calendar_series`; rows only, no mapping.
@DriftAccessor(tables: [CalendarSeriesTable])
class CalendarSeriesDao extends DatabaseAccessor<AppDatabase>
    with _$CalendarSeriesDaoMixin {
  CalendarSeriesDao(super.attachedDatabase);

  Future<List<CalendarSeriesRow>> findAll(String userId) => (select(
    calendarSeriesTable,
  )..where((s) => s.userId.equals(userId))).get();

  Future<CalendarSeriesRow?> findByKey(
    String userId,
    String accountId,
    String seriesKey,
  ) =>
      (select(calendarSeriesTable)..where(
            (s) =>
                s.userId.equals(userId) &
                s.accountId.equals(accountId) &
                s.seriesKey.equals(seriesKey),
          ))
          .getSingleOrNull();

  Future<CalendarSeriesRow?> findById(String userId, String id) => (select(
    calendarSeriesTable,
  )..where((s) => s.userId.equals(userId) & s.id.equals(id))).getSingleOrNull();

  Future<void> upsertAll(Iterable<Insertable<CalendarSeriesRow>> rows) =>
      batch((b) => b.insertAllOnConflictUpdate(calendarSeriesTable, rows));
}
