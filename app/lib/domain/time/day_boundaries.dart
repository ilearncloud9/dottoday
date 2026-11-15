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
      ? dayWindow(windowMinutes(w.start), minute)
      : dayWindow(minute, windowMinutes(w.end));
  if (!everyDay) return withDayWindow(s, day, moved(s.boundaryFor(day)));
  final common = moved(commonWindow(s));
  return withDayWindow(withCommonWindow(s, common), day, common);
}

/// `HH:mm` for minutes after the day's own midnight. A Wind Down after
/// midnight keeps counting (docs/05 "Day boundaries", Q8): 1440 is `24:00`
/// and 00:30 the next morning is `24:30`.
String windowTime(int minutes) {
  String two(int n) => n.toString().padLeft(2, '0');
  return '${two(minutes ~/ 60)}:${two(minutes % 60)}';
}

/// Minutes after midnight of an `HH:mm` window end (`24:30` is 1470).
int windowMinutes(String hhmm) {
  final parts = hhmm.split(':');
  return int.parse(parts[0]) * 60 + int.parse(parts[1]);
}

/// [windowMinutes] for stored text that may be malformed: null unless it
/// is `HH:mm` with hours 0–47.
int? tryWindowMinutes(String hhmm) {
  final m = _windowPattern.firstMatch(hhmm);
  if (m == null) return null;
  final hours = int.parse(m.group(1)!);
  return hours < 48 ? hours * 60 + int.parse(m.group(2)!) : null;
}

final _windowPattern = RegExp(r'^(\d{2}):([0-5]\d)$');

/// The stored Wind Down for a picked wall-clock [pickedMinute] (0–1439, or
/// 1440 for midnight) on a day that wakes at [wakeMinute]: at or before
/// Wake Up it falls after midnight and belongs to the day it closes (Q8),
/// so it is stored a day on.
///
/// ```dart
/// windDownMinute(420, 30); // 1470: 00:30 the next morning
/// windDownMinute(420, 1320); // 1320: 22:00 the same evening
/// ```
int windDownMinute(int wakeMinute, int pickedMinute) =>
    pickedMinute <= wakeMinute
    ? pickedMinute + Duration.minutesPerDay
    : pickedMinute;

/// The stored window for Wake Up [wake] (0–1439) and Wind Down [bed]
/// (either a wall-clock pick or an already stored end): a Wind Down at or
/// before Wake Up moves a day on ([windDownMinute]), and one a full day or
/// more after it moves back, so the window always validates (Q8).
///
/// ```dart
/// dayWindow(420, 30); // 07:00–24:30
/// dayWindow(420, 1320); // 07:00–22:00
/// ```
TimeWindow dayWindow(int wake, int bed) {
  var end = windDownMinute(wake, bed);
  if (end - wake >= Duration.minutesPerDay) end -= Duration.minutesPerDay;
  return TimeWindow(start: windowTime(wake), end: windowTime(end));
}

/// Whether a stored Wind Down ([windowMinutes]) is after midnight, so the
/// editors label it "next day". `24:00` reads as the day's own midnight,
/// as it did before Q8, so it carries no label.
bool windDownNextDay(int minutes) => minutes > Duration.minutesPerDay;
