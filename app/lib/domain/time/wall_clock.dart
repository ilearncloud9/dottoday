import 'package:timezone/timezone.dart' as tz;

const _dayMs = Duration.millisecondsPerDay;

/// Converts a wall-clock time in [location] to its UTC instant, resolving DST
/// edges the RFC 5545 §3.3.5 way so recurring tasks never vanish or double:
///
/// - In a spring-forward gap the time is read with the offset *before* the
///   gap: 02:30 on a Berlin spring-forward day becomes 03:30 CEST.
/// - In a fall-back overlap the *first* (earlier) instant wins.
///
/// [wall] carries the wall-clock fields only; its own zone flag is ignored.
///
/// ```dart
/// wallClockToUtc(berlin, DateTime(2026, 3, 29, 2, 30)); // 2026-03-29 01:30Z
/// ```
DateTime wallClockToUtc(tz.Location location, DateTime wall) {
  final naive = DateTime.utc(
    wall.year,
    wall.month,
    wall.day,
    wall.hour,
    wall.minute,
    wall.second,
  ).millisecondsSinceEpoch;
  // A DST transition never sits closer than a day to another, so the offsets
  // a day either side are the only candidates.
  final before = location.timeZone(naive - _dayMs).offset;
  final after = location.timeZone(naive + _dayMs).offset;
  final valid = [
    for (final offset in {before, after})
      if (location.timeZone(naive - offset).offset == offset) naive - offset,
  ]..sort();
  final utc = valid.isEmpty ? naive - before : valid.first;
  return DateTime.fromMillisecondsSinceEpoch(utc, isUtc: true);
}

/// The wall-clock fields of [utc] in [location], as a floating UTC-flagged
/// [DateTime] (the form the `rrule` package iterates in).
DateTime utcToWallClock(tz.Location location, DateTime utc) {
  final local = tz.TZDateTime.from(utc, location);
  return DateTime.utc(
    local.year,
    local.month,
    local.day,
    local.hour,
    local.minute,
    local.second,
  );
}
