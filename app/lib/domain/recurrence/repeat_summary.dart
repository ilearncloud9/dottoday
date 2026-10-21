import 'package:dottoday/domain/entities/enums.dart';

/// How a repeat rule reads in one line (task sheet "Repeat · Weekdays";
/// the full editor is M3f.1). Unknown shapes are [RepeatCustom], never an
/// error: the rule itself stays the source of truth.
sealed class RepeatSummary {
  const RepeatSummary();

  /// Summarises an RFC 5545 rule body (`FREQ=WEEKLY;BYDAY=MO,WE`).
  ///
  /// ```dart
  /// RepeatSummary.of('FREQ=WEEKLY;BYDAY=MO,TU,WE,TH,FR'); // RepeatWeekdays
  /// ```
  factory RepeatSummary.of(String rrule) {
    final parts = {
      for (final p in rrule.split(';'))
        if (p.contains('=')) p.split('=').first: p.split('=').last,
    };
    final interval = int.tryParse(parts['INTERVAL'] ?? '1') ?? 1;
    final byDay = (parts['BYDAY'] ?? '')
        .split(',')
        .where((d) => d.isNotEmpty)
        .toList();
    final extras = parts.keys.toSet()
      ..removeAll({'FREQ', 'INTERVAL', 'BYDAY', 'UNTIL', 'COUNT', 'WKST'});
    if (interval != 1 || extras.isNotEmpty) return const RepeatCustom();
    final days = [for (final d in byDay) _weekdays[d]];
    if (days.contains(null)) return const RepeatCustom();
    return switch (parts['FREQ']) {
      'DAILY' when byDay.isEmpty => const RepeatDaily(),
      'WEEKLY' when _isWeekdays(byDay) => const RepeatWeekdays(),
      'WEEKLY' when days.isNotEmpty => RepeatWeekly(days.cast<Weekday>()),
      'MONTHLY' when byDay.isEmpty => const RepeatMonthly(),
      'YEARLY' when byDay.isEmpty => const RepeatYearly(),
      _ => const RepeatCustom(),
    };
  }

  static bool _isWeekdays(List<String> days) =>
      days.toSet().containsAll(['MO', 'TU', 'WE', 'TH', 'FR']) &&
      days.length == 5;

  static const _weekdays = {
    'MO': Weekday.mon,
    'TU': Weekday.tue,
    'WE': Weekday.wed,
    'TH': Weekday.thu,
    'FR': Weekday.fri,
    'SA': Weekday.sat,
    'SU': Weekday.sun,
  };
}

final class RepeatDaily extends RepeatSummary {
  const RepeatDaily();
}

final class RepeatWeekdays extends RepeatSummary {
  const RepeatWeekdays();
}

/// Weekly on [days], in rule order.
final class RepeatWeekly extends RepeatSummary {
  const RepeatWeekly(this.days);

  final List<Weekday> days;
}

final class RepeatMonthly extends RepeatSummary {
  const RepeatMonthly();
}

final class RepeatYearly extends RepeatSummary {
  const RepeatYearly();
}

/// Any other rule (every 2 weeks, nth weekday, BYMONTHDAY …).
final class RepeatCustom extends RepeatSummary {
  const RepeatCustom();
}
