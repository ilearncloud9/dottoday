import 'package:dottoday/domain/entities/enums.dart';
import 'package:dottoday/domain/entities/settings.dart';
import 'package:dottoday/domain/time/clock_time.dart';
import 'package:timezone/timezone.dart' as tz;

/// A day's Wake Up → Bedtime span (docs/10 §6 "Wake Up / Bedtime drive the
/// day dot, the thread's caps, free-time maths…"), as UTC instants.
final class DayShape {
  const DayShape({required this.wakeUtc, required this.bedUtc});

  /// The span of [window] on [date]'s calendar day in [location]; DST-true
  /// because each end is resolved on its own wall clock (M1.2).
  ///
  /// ```dart
  /// DayShape.on(berlin, DateTime(2026, 10, 21), Settings.defaultDayBoundary);
  /// // 05:00Z → 20:00Z
  /// ```
  factory DayShape.on(tz.Location location, DateTime date, TimeWindow window) {
    final wake = ClockTime.parse(window.start) ?? const ClockTime(7, 0);
    final bed = ClockTime.parse(window.end) ?? const ClockTime(22, 0);
    return DayShape(
      wakeUtc: wake.onDate(location, date),
      bedUtc: bed.onDate(location, date),
    );
  }

  /// The span of the local day that contains [nowUtc] in [location], from
  /// that weekday's boundary in [settings].
  factory DayShape.containing(
    tz.Location location,
    DateTime nowUtc,
    Settings settings,
  ) {
    final local = tz.TZDateTime.from(nowUtc, location);
    final date = DateTime(local.year, local.month, local.day);
    final weekday = Weekday.values[date.weekday - 1];
    return DayShape.on(location, date, settings.boundaryFor(weekday));
  }

  final DateTime wakeUtc;
  final DateTime bedUtc;

  /// Waking minutes ("15 h awake").
  int get awakeMinutes => bedUtc.difference(wakeUtc).inMinutes;

  /// Share of the waking day elapsed at [nowUtc]: 0 before Wake Up, 1 from
  /// Bedtime on. Pass `clock.nowUtc()`; never read the system time here.
  double progressAt(DateTime nowUtc) {
    final total = bedUtc.difference(wakeUtc).inSeconds;
    if (total <= 0) return 0;
    final elapsed = nowUtc.difference(wakeUtc).inSeconds;
    return (elapsed / total).clamp(0.0, 1.0);
  }
}
