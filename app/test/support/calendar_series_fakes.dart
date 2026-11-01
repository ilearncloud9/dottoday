import 'package:dottoday/domain/calendar/calendar_series_edit.dart';
import 'package:dottoday/domain/entities/calendar_series.dart';
import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:dottoday/domain/repositories/calendar_series_repository.dart';

import 'timeline_fakes.dart';

/// In-memory [CalendarSeriesRepository] (docs/02 F5.7). [links] maps a
/// link id to its account and series key, standing in for
/// `calendar_links`; instances are read from [occurrences].
final class FakeCalendarSeriesRepository implements CalendarSeriesRepository {
  FakeCalendarSeriesRepository({
    this.links = const {},
    Iterable<CalendarSeries> rows = const [],
  }) : rows = [...rows];

  final Map<String, (String account, String key)> links;
  final List<CalendarSeries> rows;

  /// Set by `timelineOverrides`.
  FakeOccurrenceRepository? occurrences;

  @override
  Future<List<CalendarSeries>> findAll(String userId) async => [
    for (final r in rows)
      if (r.userId == userId) r,
  ];

  @override
  Future<CalendarSeries?> findByKey(
    String userId,
    String accountId,
    String seriesKey,
  ) async => rows
      .where(
        (r) =>
            r.userId == userId &&
            r.accountId == accountId &&
            r.seriesKey == seriesKey,
      )
      .firstOrNull;

  @override
  Future<CalendarSeries?> findById(String userId, String id) async =>
      rows.where((r) => r.userId == userId && r.id == id).firstOrNull;

  @override
  Future<ImportedSeries?> seriesOfLink(String userId, String linkId) async {
    final link = links[linkId];
    if (link == null) return null;
    final (account, key) = link;
    return ImportedSeries(
      accountId: account,
      seriesKey: key,
      settings: await findByKey(userId, account, key),
    );
  }

  @override
  Future<List<Occurrence>> instances(
    String userId,
    String accountId,
    String seriesKey,
  ) async => [
    for (final o in occurrences?.rows ?? const <Occurrence>[])
      if (o.userId == userId &&
          links[o.calendarLinkId] == (accountId, seriesKey))
        o,
  ];

  @override
  Future<void> upsertAll(Iterable<CalendarSeries> series) async {
    for (final s in series) {
      rows
        ..removeWhere((r) => r.id == s.id)
        ..add(s);
    }
  }
}
