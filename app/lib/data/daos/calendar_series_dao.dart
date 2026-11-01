import 'package:dottoday/data/db/app_database.dart';
import 'package:dottoday/data/db/tables/calendar_series_table.dart';
import 'package:dottoday/data/db/tables/calendar_tables.dart';
import 'package:dottoday/data/db/tables/occurrences.dart';
import 'package:drift/drift.dart';

part 'calendar_series_dao.g.dart';

/// Queries over `calendar_series` and the links that name a series; rows
/// only, no mapping.
@DriftAccessor(tables: [CalendarSeriesTable, CalendarLinks, Occurrences])
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

  /// The link [linkId] of [userId], or null.
  Future<CalendarLinkRow?> link(String userId, String linkId) =>
      (select(calendarLinks)
            ..where((l) => l.userId.equals(userId) & l.id.equals(linkId)))
          .getSingleOrNull();

  /// Occurrences linked to [seriesKey] in [accountId].
  Future<List<OccurrenceRow>> instances(
    String userId,
    String accountId,
    String seriesKey,
  ) async {
    final query =
        select(occurrences).join([
          innerJoin(
            calendarLinks,
            calendarLinks.id.equalsExp(occurrences.calendarLinkId),
          ),
        ])..where(
          occurrences.userId.equals(userId) &
              calendarLinks.accountId.equals(accountId) &
              calendarLinks.seriesKey.equals(seriesKey),
        );
    return [for (final r in await query.get()) r.readTable(occurrences)];
  }

  Future<void> upsertAll(Iterable<Insertable<CalendarSeriesRow>> rows) =>
      batch((b) => b.insertAllOnConflictUpdate(calendarSeriesTable, rows));
}
