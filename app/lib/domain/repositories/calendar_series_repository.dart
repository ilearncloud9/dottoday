import 'package:dottoday/domain/calendar/calendar_series_edit.dart';
import 'package:dottoday/domain/entities/calendar_series.dart';
import 'package:dottoday/domain/entities/occurrence.dart';

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

  /// The repeating event the link [linkId] is an instance of, with its
  /// settings; null for a one-off event or an unknown link.
  Future<ImportedSeries?> seriesOfLink(String userId, String linkId);

  /// The imported occurrences of [seriesKey] in [accountId], deleted ones
  /// included (callers filter).
  Future<List<Occurrence>> instances(
    String userId,
    String accountId,
    String seriesKey,
  );

  /// Inserts or replaces each row by id.
  Future<void> upsertAll(Iterable<CalendarSeries> rows);
}
