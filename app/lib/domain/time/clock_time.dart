import 'package:dottoday/domain/time/wall_clock.dart';
import 'package:timezone/timezone.dart' as tz;

/// A wall-clock time of day, `00:00`–`23:59`, with no date attached.
///
/// The shared `TimeInput` (docs/03 §3.3, R-20) only ever produces a
/// [ClockTime]; the date is combined later with [onDate], so editing a time
/// can never move a task to another day.
final class ClockTime implements Comparable<ClockTime> {
  const ClockTime(this.hour, this.minute)
    : assert(hour >= 0 && hour < 24, 'hour 0–23'),
      assert(minute >= 0 && minute < 60, 'minute 0–59');

  /// From minutes since midnight, wrapped into one day.
  factory ClockTime.fromMinutes(int minutes) {
    final m = minutes % Duration.minutesPerDay;
    return ClockTime(m ~/ 60, m % 60);
  }

  /// The wall-clock time of [utc] in [location].
  factory ClockTime.ofUtc(tz.Location location, DateTime utc) {
    final local = tz.TZDateTime.from(utc, location);
    return ClockTime(local.hour, local.minute);
  }

  final int hour;
  final int minute;

  /// Minutes since midnight.
  int get minutesOfDay => hour * 60 + minute;

  /// The UTC instant of this time on [date]'s calendar day in [location].
  /// Only the year/month/day of [date] are read; the result is on that day
  /// even across DST (a spring-forward gap resolves forward, M1.2).
  ///
  /// ```dart
  /// const ClockTime(9, 30).onDate(berlin, DateTime(2026, 3, 29)); // 07:30Z
  /// ```
  DateTime onDate(tz.Location location, DateTime date) => wallClockToUtc(
    location,
    DateTime(date.year, date.month, date.day, hour, minute),
  );

  /// Parses what a person types into a time field, or null if it is not a
  /// time. Independent of the 12/24-h display setting, so the same input
  /// always means the same time (no AM/PM flipping, R-20):
  ///
  /// - digits only: `9` → 09:00, `930` → 09:30, `1745` → 17:45;
  /// - separators `:`, `.`, `h` and space: `9:30`, `9.30`, `9h30`, `15h`;
  /// - optional `am`/`pm` (`a`, `p`, `a.m.` …): `12am` → 00:00,
  ///   `12:30 pm` → 12:30, `7pm` → 19:00; the hour must then be 1–12.
  static ClockTime? parse(String input) {
    final match = _pattern.firstMatch(input.trim().toLowerCase());
    if (match == null) return null;
    final (hourText, minuteText) = _split(match.namedGroup('time')!);
    if (hourText == null) return null;
    final hour = int.parse(hourText);
    final minute = minuteText == null ? 0 : int.parse(minuteText);
    if (minute > 59) return null;
    final marker = match.namedGroup('ap');
    if (marker == null) return hour < 24 ? ClockTime(hour, minute) : null;
    if (hour < 1 || hour > 12) return null;
    final pm = marker.startsWith('p');
    return ClockTime(hour % 12 + (pm ? 12 : 0), minute);
  }

  static final _pattern = RegExp(
    r'^(?<time>\d{1,2}(?:[:.h ]\d{0,2})?|\d{3,4})\s*(?<ap>[ap]\.?(?:m\.?)?)?$',
  );

  /// Hour and minute digits of a matched time body; minute null when absent.
  static (String?, String?) _split(String time) {
    final sep = RegExp('[:.h ]').firstMatch(time);
    if (sep != null) {
      final minute = time.substring(sep.end);
      if (minute.length == 1) return (null, null); // "9:3" is unfinished
      return (time.substring(0, sep.start), minute.isEmpty ? null : minute);
    }
    if (time.length <= 2) return (time, null);
    final split = time.length - 2;
    return (time.substring(0, split), time.substring(split));
  }

  @override
  int compareTo(ClockTime other) => minutesOfDay - other.minutesOfDay;

  @override
  bool operator ==(Object other) =>
      other is ClockTime && other.minutesOfDay == minutesOfDay;

  @override
  int get hashCode => minutesOfDay;

  @override
  String toString() =>
      '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
}
