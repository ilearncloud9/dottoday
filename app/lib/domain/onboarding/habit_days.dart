import 'package:dottoday/domain/entities/enums.dart';
import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:timezone/timezone.dart' as tz;

/// "Make it a habit" (M20.11 part 6, ED-491): once three of a daily
/// task's days are done, the weekdays they were done on, to suggest it
/// repeat on just those; null while fewer than three are done, or when
/// they fall on every day of the week (nothing to narrow).
///
/// ```dart
/// habitDays(gymRows, berlin); // {mon, wed, fri}
/// ```
Set<Weekday>? habitDays(Iterable<Occurrence> rows, tz.Location zone) {
  final done = [
    for (final o in rows)
      if (o.status == OccurrenceStatus.done && o.startUtc != null) o,
  ];
  if (done.length < 3) return null;
  final days = {
    for (final o in done)
      Weekday.values[tz.TZDateTime.from(o.startUtc!, zone).weekday - 1],
  };
  return days.length == Weekday.values.length ? null : days;
}
