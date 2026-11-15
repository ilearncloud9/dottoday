import 'package:dottoday/domain/entities/enums.dart';
import 'package:dottoday/domain/entities/settings.dart';
import 'package:dottoday/domain/time/clock_time.dart';
import 'package:dottoday/domain/time/day_boundaries.dart';
import 'package:timezone/timezone.dart' as tz;

/// A day's Wake Up → Wind Down span (docs/10 §6 "Wake Up / Wind Down drive the
/// day dot, the thread's caps, free-time maths…"), as UTC instants.
final class DayShape {
  const DayShape({required this.wakeUtc, required this.bedUtc});

  /// The span of [window] on [date]'s calendar day in [location]; DST-true
  /// because each end is resolved on its own wall clock (M1.2). A Wind Down
  /// at or after `24:00` (or, from older data, at or before Wake Up) falls
  /// on the next calendar day and still belongs to [date] (docs/05, Q8).
  ///
  /// ```dart
  /// DayShape.on(berlin, DateTime(2026, 10, 21), Settings.defaultDayBoundary);
  /// // 05:00Z → 20:00Z
  /// DayShape.on(berlin, DateTime(2026, 10, 21),
  ///     const TimeWindow(start: '07:00', end: '24:30'));
  /// // 05:00Z → 2026-10-21 22:30Z (00:30 on the 22nd, Berlin)
  /// ```
  factory DayShape.on(tz.Location location, DateTime date, TimeWindow window) {
    final wake = _minutes(window.start, _defaultWake);
    var bed = tryWindowMinutes(window.end) ?? _minutes(window.end, _defaultBed);
    if (bed <= wake) bed += Duration.minutesPerDay;
    // Never a day of 24 h or more: an impossible end wraps back.
    if (bed - wake >= Duration.minutesPerDay) bed -= Duration.minutesPerDay;
    final bedDate = DateTime(
      date.year,
      date.month,
      date.day + bed ~/ Duration.minutesPerDay,
    );
    return DayShape(
      wakeUtc: ClockTime.fromMinutes(wake).onDate(location, date),
      bedUtc: ClockTime.fromMinutes(bed).onDate(location, bedDate),
    );
  }

  /// The span of the day that [nowUtc] belongs to in [location]: see
  /// [dayOf].
  factory DayShape.containing(
    tz.Location location,
    DateTime nowUtc,
    Settings settings,
  ) {
    final date = dayOf(location, nowUtc, settings);
    return DayShape.on(location, date, settings.boundaryFor(_weekday(date)));
  }

  /// The day [nowUtc] belongs to: the local calendar date, except after
  /// midnight up to and including the previous day's configured Wind Down,
  /// which still belongs to the day it closes (Q8).
  ///
  /// ```dart
  /// // Monday's Wind Down is 24:30 (00:30 Tuesday).
  /// dayOf(berlin, tuesdayAt0015Utc, s); // Monday
  /// dayOf(berlin, tuesdayAt0100Utc, s); // Tuesday
  /// ```
  static DateTime dayOf(
    tz.Location location,
    DateTime nowUtc,
    Settings settings,
  ) {
    final local = tz.TZDateTime.from(nowUtc, location);
    final date = DateTime(local.year, local.month, local.day);
    final before = DateTime(date.year, date.month, date.day - 1);
    final last = DayShape.on(
      location,
      before,
      settings.boundaryFor(_weekday(before)),
    );
    return nowUtc.isAfter(last.bedUtc) ? date : before;
  }

  final DateTime wakeUtc;
  final DateTime bedUtc;

  /// Waking minutes ("15 h awake").
  int get awakeMinutes => bedUtc.difference(wakeUtc).inMinutes;

  /// Share of the waking day elapsed at [nowUtc]: 0 before Wake Up, 1 from
  /// Wind Down on. Pass `clock.nowUtc()`; never read the system time here.
  double progressAt(DateTime nowUtc) {
    final total = bedUtc.difference(wakeUtc).inSeconds;
    if (total <= 0) return 0;
    final elapsed = nowUtc.difference(wakeUtc).inSeconds;
    return (elapsed / total).clamp(0.0, 1.0);
  }
}

/// 07:00, the default Wake Up, for an unreadable start.
const _defaultWake = 7 * 60;

/// 22:00, the default Wind Down, for an unreadable or impossible end.
const _defaultBed = 22 * 60;

/// A time of day (0–1439) from stored text, leniently as before Q8.
int _minutes(String text, int fallback) {
  final m = tryWindowMinutes(text);
  if (m != null && m < Duration.minutesPerDay) return m;
  return ClockTime.parse(text)?.minutesOfDay ?? fallback;
}

Weekday _weekday(DateTime date) => Weekday.values[date.weekday - 1];
