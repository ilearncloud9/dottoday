import 'package:dottoday/domain/entities/series.dart';
import 'package:dottoday/domain/time/wall_clock.dart';
import 'package:rrule/rrule.dart';
import 'package:timezone/timezone.dart' as tz;

/// Expands a [Series] into the UTC start instants of its instances
/// (ADR-0004, docs/04 §3, R-01, R-09).
///
/// Expansion runs on the series' wall clock in its own zone, then converts
/// each instance to UTC, so "07:00 every Monday" stays 07:00 across DST. DST
/// edges resolve per [wallClockToUtc].
///
/// RFC 5545 semantics kept on purpose:
/// - `COUNT` counts instances *before* exceptions are removed (EXDATE).
/// - A day that does not exist in a month (the 31st, Feb 29) is skipped,
///   not moved; "last day" is `BYMONTHDAY=-1`.
/// - `UNTIL` ending in `Z` is a UTC instant; otherwise it is wall-clock in the
///   series zone, and a date-only `UNTIL` includes that whole local day.
/// - [Series.untilUtc] and [Series.count] narrow the rule further.
final class RecurrenceExpander {
  const RecurrenceExpander();

  // Iteration runs on wall clock; a zone offset is at most ±14 h, so a 1-day
  // margin around the UTC window catches every instance inside it.
  static const _margin = Duration(days: 1);

  /// UTC starts of [series] instances in `[fromUtc, toUtc)`, ascending,
  /// minus any in [exceptionsUtc] (matched on the original start).
  ///
  /// [series] must already pass `validateSeries`; an invalid rule or zone is
  /// a bug and throws.
  ///
  /// ```dart
  /// expander.expand(series, fromUtc: day, toUtc: day.add(Duration(days: 90)));
  /// ```
  List<DateTime> expand(
    Series series, {
    required DateTime fromUtc,
    required DateTime toUtc,
    Set<DateTime> exceptionsUtc = const {},
  }) {
    final location = tz.getLocation(series.tzId);
    final start = _floating(DateTime.parse(series.dtstartLocal));
    final parsed = RecurrenceRule.fromString('RRULE:${series.rrule}');
    final untilUtc = _earliest(
      series.untilUtc,
      _ruleUntilUtc(series.rrule, parsed.until, location),
    );
    final rule = parsed.copyWith(
      clearUntil: true,
      count: series.count ?? parsed.count,
    );

    final after = utcToWallClock(location, fromUtc.subtract(_margin));
    final before = utcToWallClock(location, toUtc.add(_margin));
    if (before.isBefore(start)) return const [];

    final instances = rule.getInstances(
      start: start,
      after: after.isAfter(start) ? after : null,
      before: before,
    );
    return [
      for (final wall in instances)
        if (wallClockToUtc(location, wall) case final utc
            when !utc.isBefore(fromUtc) &&
                utc.isBefore(toUtc) &&
                (untilUtc == null || !utc.isAfter(untilUtc)) &&
                !exceptionsUtc.contains(utc))
          utc,
    ];
  }

  static DateTime _floating(DateTime d) =>
      DateTime.utc(d.year, d.month, d.day, d.hour, d.minute, d.second);

  static DateTime? _earliest(DateTime? a, DateTime? b) {
    if (a == null) return b;
    if (b == null) return a;
    return a.isBefore(b) ? a : b;
  }

  static final _untilPart = RegExp(r'UNTIL=(\d{8})(T\d{6}(Z)?)?');

  static DateTime? _ruleUntilUtc(
    String rrule,
    DateTime? until,
    tz.Location location,
  ) {
    final match = _untilPart.firstMatch(rrule);
    if (until == null || match == null) return null;
    if (match.group(3) != null) return _floating(until);
    final dateOnly = match.group(2) == null;
    final wall = dateOnly
        ? DateTime.utc(until.year, until.month, until.day, 23, 59, 59)
        : until;
    return wallClockToUtc(location, wall);
  }
}
