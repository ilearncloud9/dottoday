import 'package:dottoday/domain/entities/enums.dart';

/// How often a rule repeats (the Repeat editor's choices, M3f.1).
enum RepeatFrequency { daily, weekly, monthly, yearly }

/// How a monthly rule picks its day: the date ("on the 21st") or the
/// weekday's place in the month ("on the 3rd Wednesday", "the last
/// Friday").
enum MonthlyBy { date, weekday }

/// When a rule stops: never, after [count] times, or on [until] (a local
/// date, inclusive).
sealed class RepeatEnd {
  const RepeatEnd();
}

final class EndsNever extends RepeatEnd {
  const EndsNever();

  @override
  bool operator ==(Object other) => other is EndsNever;

  @override
  int get hashCode => 0;
}

final class EndsAfter extends RepeatEnd {
  const EndsAfter(this.count) : assert(count > 0);

  final int count;

  @override
  bool operator ==(Object other) => other is EndsAfter && other.count == count;

  @override
  int get hashCode => count;
}

final class EndsOn extends RepeatEnd {
  const EndsOn(this.until);

  /// Local calendar date (y/m/d), the last day it may happen.
  final DateTime until;

  @override
  bool operator ==(Object other) => other is EndsOn && other.until == until;

  @override
  int get hashCode => until.hashCode;
}

/// A repeat rule as the Repeat editor builds it (docs/09 M3f.1, R-01):
/// every [interval] days / weeks / months / years, on [days] for weekly,
/// by date or by weekday for monthly, ending per [end]. Round-trips the
/// RFC 5545 body stored in `series.rrule` for every shape it can express;
/// anything else is left to [RepeatRule.parse] returning null (shown as
/// "Custom", never rewritten).
///
/// ```dart
/// RepeatRule.parse('FREQ=WEEKLY;BYDAY=MO,WE')!.days; // {mon, wed}
/// const RepeatRule.weekdays().rruleFrom(monday); // FREQ=WEEKLY;BYDAY=MO,TU,WE,TH,FR
/// ```
final class RepeatRule {
  const RepeatRule({
    required this.frequency,
    this.interval = 1,
    this.days = const {},
    this.monthlyBy = MonthlyBy.date,
    this.end = const EndsNever(),
  }) : assert(interval > 0);

  /// Monday to Friday.
  const RepeatRule.weekdays({this.end = const EndsNever()})
    : frequency = RepeatFrequency.weekly,
      interval = 1,
      days = const {
        Weekday.mon,
        Weekday.tue,
        Weekday.wed,
        Weekday.thu,
        Weekday.fri,
      },
      monthlyBy = MonthlyBy.date;

  final RepeatFrequency frequency;
  final int interval;

  /// Weekly only; empty means the start's own weekday.
  final Set<Weekday> days;

  /// Monthly only.
  final MonthlyBy monthlyBy;
  final RepeatEnd end;

  RepeatRule copyWith({
    RepeatFrequency? frequency,
    int? interval,
    Set<Weekday>? days,
    MonthlyBy? monthlyBy,
    RepeatEnd? end,
  }) => RepeatRule(
    frequency: frequency ?? this.frequency,
    interval: interval ?? this.interval,
    days: days ?? this.days,
    monthlyBy: monthlyBy ?? this.monthlyBy,
    end: end ?? this.end,
  );

  /// Whether this is Monday–Friday weekly.
  bool get isWeekdays =>
      frequency == RepeatFrequency.weekly &&
      interval == 1 &&
      days.length == 5 &&
      !days.contains(Weekday.sat) &&
      !days.contains(Weekday.sun);

  /// The rule body for a series starting on [start] (a local date): the
  /// weekday or the nth-weekday of a monthly rule comes from it. [end]
  /// is stored on the series (`count`, `untilUtc`), not in the body.
  String rruleFrom(DateTime start) {
    final parts = ['FREQ=${frequency.name.toUpperCase()}'];
    if (interval != 1) parts.add('INTERVAL=$interval');
    switch (frequency) {
      case RepeatFrequency.weekly when days.isNotEmpty:
        final ordered = [
          for (final d in Weekday.values)
            if (days.contains(d)) _codes[d]!,
        ];
        parts.add('BYDAY=${ordered.join(',')}');
      case RepeatFrequency.monthly when monthlyBy == MonthlyBy.weekday:
        parts.add('BYDAY=${nthOfMonth(start)}${_codes[_weekday(start)]}');
      case _:
        break;
    }
    return parts.join(';');
  }

  /// Reads a stored body back, or null for shapes the editor can't show
  /// (BYSETPOS, BYMONTH, several monthly days …): those stay as they are.
  static RepeatRule? parse(String rrule, {RepeatEnd end = const EndsNever()}) {
    final parts = <String, String>{
      for (final p in rrule.split(';'))
        if (p.contains('=')) p.split('=').first: p.split('=').last,
    };
    final known = {'FREQ', 'INTERVAL', 'BYDAY', 'WKST', 'UNTIL', 'COUNT'};
    if (!known.containsAll(parts.keys)) return null;
    final frequency = RepeatFrequency.values
        .where((f) => f.name.toUpperCase() == parts['FREQ'])
        .firstOrNull;
    final interval = int.tryParse(parts['INTERVAL'] ?? '1');
    if (frequency == null || interval == null || interval < 1) return null;
    final byDay = (parts['BYDAY'] ?? '')
        .split(',')
        .where((d) => d.isNotEmpty)
        .toList();
    return switch (frequency) {
      RepeatFrequency.weekly => _weekly(byDay, interval, end),
      RepeatFrequency.monthly => _monthly(byDay, interval, end),
      _ when byDay.isNotEmpty => null,
      _ => RepeatRule(frequency: frequency, interval: interval, end: end),
    };
  }

  static RepeatRule? _weekly(List<String> byDay, int interval, RepeatEnd end) {
    final days = {for (final d in byDay) _byCode[d]};
    if (days.contains(null)) return null;
    return RepeatRule(
      frequency: RepeatFrequency.weekly,
      interval: interval,
      days: days.cast<Weekday>(),
      end: end,
    );
  }

  static RepeatRule? _monthly(List<String> byDay, int interval, RepeatEnd end) {
    if (byDay.length > 1) return null;
    if (byDay.isNotEmpty && !_nthDay.hasMatch(byDay.single)) return null;
    return RepeatRule(
      frequency: RepeatFrequency.monthly,
      interval: interval,
      monthlyBy: byDay.isEmpty ? MonthlyBy.date : MonthlyBy.weekday,
      end: end,
    );
  }

  /// "3" for the 3rd weekday of its kind in the month, "-1" for the last.
  static String nthOfMonth(DateTime date) {
    final last = DateTime(date.year, date.month + 1, 0).day;
    if (date.day + 7 > last) return '-1';
    return '${(date.day - 1) ~/ 7 + 1}';
  }

  static Weekday _weekday(DateTime d) => Weekday.values[d.weekday - 1];

  static final _nthDay = RegExp(r'^(-1|[1-4])(MO|TU|WE|TH|FR|SA|SU)$');

  static const _codes = {
    Weekday.mon: 'MO',
    Weekday.tue: 'TU',
    Weekday.wed: 'WE',
    Weekday.thu: 'TH',
    Weekday.fri: 'FR',
    Weekday.sat: 'SA',
    Weekday.sun: 'SU',
  };

  static final _byCode = {for (final e in _codes.entries) e.value: e.key};

  @override
  bool operator ==(Object other) =>
      other is RepeatRule &&
      other.frequency == frequency &&
      other.interval == interval &&
      other.days.length == days.length &&
      other.days.containsAll(days) &&
      other.monthlyBy == monthlyBy &&
      other.end == end;

  @override
  int get hashCode => Object.hash(
    frequency,
    interval,
    Object.hashAllUnordered(days),
    monthlyBy,
    end,
  );
}
