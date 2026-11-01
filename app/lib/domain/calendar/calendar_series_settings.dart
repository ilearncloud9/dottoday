import 'package:dottoday/domain/entities/alert.dart';
import 'package:dottoday/domain/entities/calendar_series.dart';
import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:dottoday/domain/entities/subtask.dart';
import 'package:dottoday/domain/time/wall_clock.dart';
import 'package:timezone/timezone.dart' as tz;

/// [o], a new instance of a repeating calendar event, with what the person
/// set for every instance of it ([series], docs/02 F5.7). A time of day is
/// placed on [o]'s own date in the series' zone, so DST never moves it.
///
/// ```dart
/// withSeriesSettings(o, s.copyWith(startMinute: 330)); // 05:30 that day
/// ```
Occurrence withSeriesSettings(Occurrence o, CalendarSeries series) =>
    atSeriesTime(
      o.copyWith(
        title: series.title ?? o.title,
        notes: series.notes ?? o.notes,
        colorKey: series.colorKey ?? o.colorKey,
        iconKey: series.iconKey ?? o.iconKey,
        durationMin: series.durationMin ?? o.durationMin,
        pinned: series.pinned ?? o.pinned,
        travelBufferMin: series.travelBufferMin ?? o.travelBufferMin,
        energy: series.energy ?? o.energy,
        alerts: series.alerts ?? o.alerts,
        soundId: series.soundId ?? o.soundId,
      ),
      series,
    );

/// [o] at [series]' time of day on [o]'s own date (in the series' zone),
/// or [o] as it is when no time is set.
Occurrence atSeriesTime(Occurrence o, CalendarSeries series) {
  final start = o.startUtc;
  final minute = series.startMinute;
  if (start == null || minute == null) return o;
  return o.copyWith(startUtc: _atMinute(start, minute, series.tzId ?? o.tzId));
}

/// The steps a new instance [o] starts with: [series]' list, unticked
/// (completion is per occurrence, R-09). Empty when none is set.
List<Subtask> seriesSubtasks(
  Occurrence o,
  CalendarSeries series, {
  required DateTime now,
  required String Function() newId,
}) => [
  for (final item in series.subtaskTemplate ?? const <SubtaskTemplateItem>[])
    Subtask(
      id: newId(),
      userId: o.userId,
      occurrenceId: o.id,
      title: item.title,
      sortOrder: item.sortOrder,
      durationMin: item.durationMin,
      createdAt: now,
      updatedAt: now,
    ),
];

/// [startUtc]'s local date in [tzId] at [minute] past midnight.
DateTime _atMinute(DateTime startUtc, int minute, String tzId) {
  final zone = tz.getLocation(tzId);
  final w = utcToWallClock(zone, startUtc);
  return wallClockToUtc(
    zone,
    DateTime(w.year, w.month, w.day, minute ~/ 60, minute % 60),
  );
}
