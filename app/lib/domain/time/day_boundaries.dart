import 'package:dottoday/domain/entities/enums.dart';
import 'package:dottoday/domain/entities/settings.dart';

/// The everyday Wake Up → Wind Down window (Settings › DAY SHAPE): the one
/// most weekdays use (ties go to the earliest weekday). Days with their
/// own window are "custom".
///
/// ```dart
/// commonWindow(const Settings()); // 07:00–22:00
/// ```
TimeWindow commonWindow(Settings s) {
  final counts = <TimeWindow, int>{};
  for (final d in Weekday.values) {
    final w = s.boundaryFor(d);
    counts[w] = (counts[w] ?? 0) + 1;
  }
  var best = s.boundaryFor(Weekday.mon);
  for (final MapEntry(key: w, value: n) in counts.entries) {
    if (n > counts[best]!) best = w;
  }
  return best;
}

/// Weekdays whose window differs from the everyday one.
List<Weekday> customDays(Settings s) {
  final common = commonWindow(s);
  return [
    for (final d in Weekday.values)
      if (s.boundaryFor(d) != common) d,
  ];
}

/// [s] with the everyday window set to [window]: every weekday that used
/// the old everyday window moves with it; custom days keep theirs.
Settings withCommonWindow(Settings s, TimeWindow window) {
  final old = commonWindow(s);
  return s.copyWith(
    dayBoundaries: {
      for (final d in Weekday.values)
        d: s.boundaryFor(d) == old ? window : s.boundaryFor(d),
    },
  );
}

/// [s] with [day]'s own window, or (null) back to the everyday one.
Settings withDayWindow(Settings s, Weekday day, TimeWindow? window) {
  final common = commonWindow(s);
  return s.copyWith(
    dayBoundaries: {
      for (final d in Weekday.values)
        d: d == day ? (window ?? common) : s.boundaryFor(d),
    },
  );
}

/// [s] with one end of [day]'s window moved to [minute]: Wake Up, or
/// Wind Down when [windDown]. With [everyDay] the everyday window takes
/// the new time and [day] follows it; otherwise only [day] does (the
/// thread's caps, R-17).
///
/// ```dart
/// withCapAt(s, Weekday.sat, windDown: false, minute: 540, everyDay: false);
/// // Saturdays wake at 09:00; other days keep theirs.
/// ```
Settings withCapAt(
  Settings s,
  Weekday day, {
  required bool windDown,
  required int minute,
  required bool everyDay,
}) {
  TimeWindow moved(TimeWindow w) => windDown
      ? w.copyWith(end: windowTime(minute))
      : w.copyWith(start: windowTime(minute));
  if (!everyDay) return withDayWindow(s, day, moved(s.boundaryFor(day)));
  final common = moved(commonWindow(s));
  return withDayWindow(withCommonWindow(s, common), day, common);
}

/// `HH:mm` for minutes after midnight; 1440 is `24:00` (Wind Down at
/// midnight).
String windowTime(int minutes) {
  String two(int n) => n.toString().padLeft(2, '0');
  return '${two(minutes ~/ 60)}:${two(minutes % 60)}';
}

/// Minutes after midnight of an `HH:mm` window end (`24:00` is 1440).
int windowMinutes(String hhmm) {
  final parts = hhmm.split(':');
  return int.parse(parts[0]) * 60 + int.parse(parts[1]);
}
