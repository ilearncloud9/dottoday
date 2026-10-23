import 'package:dottoday/domain/entities/enums.dart';
import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:dottoday/domain/entities/series.dart';
import 'package:dottoday/domain/entities/settings.dart';
import 'package:dottoday/domain/recurrence/series_edit.dart';
import 'package:dottoday/domain/time/wall_clock.dart';
import 'package:dottoday/domain/writes/write_batch.dart';
import 'package:timezone/timezone.dart' as tz;

/// What to do with planned tasks after the device moved to another zone
/// (docs/07 "Time zone changes while travelling", docs/09 M5.9).
enum ZoneMoveChoice {
  /// The default: 9:00 stays 9:00 in the new zone.
  keepTimes,

  /// The tasks keep their moment: 9:00 in New York reads 15:00 in Berlin.
  shift,
}

/// The one batch a move to [newZone] writes (one Undo reverts it): the
/// profile in [newZone] and, for [ZoneMoveChoice.keepTimes], every task
/// not yet started at the same clock time there. Started, done or
/// skipped tasks and calendar events (their own zone, 07) stay as they
/// are. A repeat is split at its first upcoming instance, as for a new
/// time ([SeriesEditor]).
///
/// ```dart
/// planZoneMove(profile: p, newZone: 'Europe/Berlin',
///     choice: ZoneMoveChoice.keepTimes, upcoming: rows, series: [],
///     editor: editor, nowUtc: now);
/// ```
WriteBatch planZoneMove({
  required Profile profile,
  required String newZone,
  required ZoneMoveChoice choice,
  required List<Occurrence> upcoming,
  required List<({Series series, List<Occurrence> rows})> series,
  required SeriesEditor editor,
  required DateTime nowUtc,
}) {
  final moved = profile.copyWith(tzId: newZone, updatedAt: nowUtc);
  if (choice == ZoneMoveChoice.shift) {
    return WriteBatch(userId: profile.id, profile: moved);
  }
  final zone = tz.getLocation(newZone);
  final outSeries = <Series>[];
  final outRows = <Occurrence>[
    for (final o in upcoming)
      if (o.seriesId == null && _movable(o, nowUtc, newZone))
        _keepClock(o, zone, nowUtc),
  ];
  for (final (:series, :rows) in series) {
    if (series.tzId == newZone) continue;
    final first = _firstUpcoming(rows, nowUtc, newZone);
    if (first == null) continue;
    final w = editor.edit(
      series: series,
      rows: rows,
      target: first,
      change: SeriesChange(tzId: newZone),
      scope: EditScope.following,
    );
    outSeries.addAll(w.series);
    outRows.addAll(w.occurrences);
  }
  return WriteBatch(
    userId: profile.id,
    profile: moved,
    series: outSeries,
    occurrences: outRows,
  );
}

/// A planned task of the person's own that hasn't started, in another zone.
bool _movable(Occurrence o, DateTime nowUtc, String newZone) {
  final start = o.startUtc;
  return start != null &&
      !start.isBefore(nowUtc) &&
      o.deletedAt == null &&
      o.status == OccurrenceStatus.planned &&
      o.source == OccurrenceSource.user &&
      o.calendarLinkId == null &&
      o.tzId != newZone;
}

Occurrence? _firstUpcoming(
  List<Occurrence> rows,
  DateTime nowUtc,
  String newZone,
) {
  Occurrence? first;
  for (final o in rows) {
    if (!_movable(o, nowUtc, newZone)) continue;
    if (first == null || o.startUtc!.isBefore(first.startUtc!)) first = o;
  }
  return first;
}

/// [o] at the same wall-clock time in [zone].
Occurrence _keepClock(Occurrence o, tz.Location zone, DateTime nowUtc) {
  final wall = utcToWallClock(tz.getLocation(o.tzId), o.startUtc!);
  return o.copyWith(
    startUtc: wallClockToUtc(zone, wall),
    tzId: zone.name,
    updatedAt: nowUtc,
  );
}
