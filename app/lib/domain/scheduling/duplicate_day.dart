import 'package:dottoday/core/ids/id_generator.dart';
import 'package:dottoday/domain/entities/enums.dart';
import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:dottoday/domain/time/clock_time.dart';
import 'package:timezone/timezone.dart' as tz;

/// Copies of [source]'s one-off tasks placed on [targetDate] at the same
/// wall-clock times in [location] ("Copy a day…", `A-ios-future-month`;
/// docs/03 §3.1 "Duplicate day").
///
/// Repeating tasks are left out (their series already reaches the target
/// day), as are skipped ones and inbox items. Copies are fresh: new ids,
/// planned, not completed, no snooze, calendar links dropped. DST-safe:
/// a 09:00 task stays at 09:00 even across a clock change.
///
/// ```dart
/// duplicateDay(source: mondayRows, targetDate: DateTime(2026, 12, 14),
///   location: berlin, nowUtc: clock.nowUtc(), ids: ids);
/// ```
List<Occurrence> duplicateDay({
  required List<Occurrence> source,
  required DateTime targetDate,
  required tz.Location location,
  required DateTime nowUtc,
  required IdGenerator ids,
}) => [
  for (final o in source)
    if (o.seriesId == null &&
        o.startUtc != null &&
        o.status != OccurrenceStatus.skipped &&
        o.source == OccurrenceSource.user)
      o.copyWith(
        id: ids.newId(),
        startUtc: ClockTime.ofUtc(
          location,
          o.startUtc!,
        ).onDate(location, targetDate),
        tzId: location.name,
        status: OccurrenceStatus.planned,
        completedAtUtc: null,
        snoozedUntilUtc: null,
        calendarLinkId: null,
        createdAt: nowUtc,
        updatedAt: nowUtc,
        deletedAt: null,
      ),
];
