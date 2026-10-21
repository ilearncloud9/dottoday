import 'package:dottoday/domain/entities/enums.dart';
import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:dottoday/domain/time/clock_time.dart';
import 'package:dottoday/domain/validation/field_rules.dart';
import 'package:timezone/timezone.dart' as tz;

/// The calendar day being shown, in the profile's zone (docs/04 §3: a day
/// is bucketed by local date). Its bounds are local midnights, so DST days are
/// 23 or 25 hours long.
final class TimelineDay {
  TimelineDay._(this.date, this.location, this.startUtc, this.endUtc);

  /// The local calendar day of [date] in [location].
  factory TimelineDay.of(DateTime date, tz.Location location) {
    final day = DateTime(date.year, date.month, date.day);
    final next = DateTime(date.year, date.month, date.day + 1);
    return TimelineDay._(
      day,
      location,
      const ClockTime(0, 0).onDate(location, day),
      const ClockTime(0, 0).onDate(location, next),
    );
  }

  /// Year/month/day only.
  final DateTime date;
  final tz.Location location;
  final DateTime startUtc;
  final DateTime endUtc;

  double get minutes => endUtc.difference(startUtc).inSeconds / 60;

  /// Elapsed minutes from the day start to [utc] (may be < 0 or > [minutes]).
  double minuteOf(DateTime utc) => utc.difference(startUtc).inSeconds / 60;

  /// The day's weekday as a settings key.
  Weekday get weekday => Weekday.values[date.weekday - 1];

  /// Whether [o] is an all-day item: it starts at this day's local midnight
  /// and lasts the maximum 24 h. Such items go in the all-day strip
  /// instead of the timeline (docs/03 §3.1, clarified in M3.2).
  bool isAllDay(Occurrence o) =>
      (o.startUtc?.isAtSameMomentAs(startUtc) ?? false) &&
      o.durationMin >= maxDurationMin;
}
