import 'package:dottoday/domain/entities/calendar_series.dart';

/// Read/write access to what the person set for repeating calendar events
/// (docs/02 F5.7), owner-scoped. Writes are for the write path only.
abstract interface class CalendarSeriesRepository {
  /// Every series row of [userId]: one per repeating event ever edited
  /// with scope All, so a short list.
  Future<List<CalendarSeries>> findAll(String userId);

  /// The row for [seriesKey] in [accountId], or null.
  Future<CalendarSeries?> findByKey(
    String userId,
    String accountId,
    String seriesKey,
  );

  /// The row [id] owned by [userId], or null.
  Future<CalendarSeries?> findById(String userId, String id);

  /// Inserts or replaces each row by id.
  Future<void> upsertAll(Iterable<CalendarSeries> rows);
}
