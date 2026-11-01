import 'package:dottoday/data/daos/calendar_series_dao.dart';
import 'package:dottoday/data/db/app_database.dart';
import 'package:dottoday/data/mappers/entity_mappers.dart';
import 'package:dottoday/domain/entities/calendar_series.dart';
import 'package:dottoday/domain/repositories/calendar_series_repository.dart';

/// [CalendarSeriesRepository] over the local Drift database.
final class DriftCalendarSeriesRepository implements CalendarSeriesRepository {
  DriftCalendarSeriesRepository(AppDatabase db) : _dao = CalendarSeriesDao(db);

  final CalendarSeriesDao _dao;

  @override
  Future<List<CalendarSeries>> findAll(String userId) async =>
      (await _dao.findAll(userId)).map(calendarSeriesFromRow).toList();

  @override
  Future<CalendarSeries?> findByKey(
    String userId,
    String accountId,
    String seriesKey,
  ) async {
    final row = await _dao.findByKey(userId, accountId, seriesKey);
    return row == null ? null : calendarSeriesFromRow(row);
  }

  @override
  Future<CalendarSeries?> findById(String userId, String id) async {
    final row = await _dao.findById(userId, id);
    return row == null ? null : calendarSeriesFromRow(row);
  }

  @override
  Future<void> upsertAll(Iterable<CalendarSeries> rows) => _dao.upsertAll(
    rows.map((s) => calendarSeriesCodec.encode<CalendarSeriesRow>(s.toJson())),
  );
}
