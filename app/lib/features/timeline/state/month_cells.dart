import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/domain/entities/enums.dart';
import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:dottoday/features/timeline/state/day_summary.dart';
import 'package:dottoday/shared/dot/month_grid.dart';

/// The cells of [month] for a compact [MonthGrid], blanks included, with
/// the week starting on [firstDayOfWeek] (1 = Monday … 7 = Sunday).
///
/// Each day shows its first three tasks as dots in their colours, filled
/// once done, then "+n" (E-Phones Calendar, ED-075); skipped tasks are
/// left out. Nothing is red and nothing says late: a past day is only
/// lighter.
List<MonthDay?> compactMonthCells({
  required DateTime month,
  required int firstDayOfWeek,
  required DateTime today,
  required Map<DateTime, List<Occurrence>> byDay,
  required String Function(DateTime day) dateText,
  required String Function(DateTime day, ({int done, int total}) counts) label,
}) {
  final first = DateTime(month.year, month.month);
  final lead = (first.weekday - firstDayOfWeek) % 7;
  final length = DateTime(month.year, month.month + 1, 0).day;
  return [
    for (var i = 0; i < lead; i++) null,
    for (var d = 1; d <= length; d++)
      _cell(
        DateTime(month.year, month.month, d),
        today,
        byDay,
        dateText,
        label,
      ),
  ];
}

MonthDay _cell(
  DateTime day,
  DateTime today,
  Map<DateTime, List<Occurrence>> byDay,
  String Function(DateTime) dateText,
  String Function(DateTime, ({int done, int total})) label,
) {
  final rows = [
    for (final o in byDay[day] ?? const <Occurrence>[])
      if (o.status != OccurrenceStatus.skipped) o,
  ]..sort((a, b) => a.startUtc!.compareTo(b.startUtc!));
  return MonthDay(
    date: dateText(day),
    label: label(day, doneCounts(rows)),
    isPast: day.isBefore(today),
    isToday: day == today,
    dots: [
      for (final o in rows.take(_dotsShown))
        MonthDot(
          TaskColor.fromKey(o.colorKey),
          filled: o.status == OccurrenceStatus.done,
        ),
    ],
    more: rows.length > _dotsShown ? rows.length - _dotsShown : 0,
  );
}

const _dotsShown = 3;

/// The cells of [month] for the expanded Mac/web [MonthGrid] (E-R2-30,
/// ED-333): each day's tasks in start order (done struck, ended ones "not
/// done", the one running at [nowUtc] "now"), "N of M done" on every day
/// with tasks and "Light day" on a day with none. The first and last
/// weeks are filled with the faded days of the months either side.
List<MonthDay?> expandedMonthCells({
  required DateTime month,
  required int firstDayOfWeek,
  required DateTime today,
  required DateTime nowUtc,
  required Map<DateTime, List<Occurrence>> byDay,
  required String Function(DateTime day) dateText,
  required String Function(DateTime day, ({int done, int total}) counts) label,
}) {
  final first = DateTime(month.year, month.month);
  final lead = (first.weekday - firstDayOfWeek) % 7;
  final length = DateTime(month.year, month.month + 1, 0).day;
  final trail = (7 - (lead + length) % 7) % 7;
  MonthDay cell(DateTime day) {
    final rows = [
      for (final o in byDay[day] ?? const <Occurrence>[])
        if (o.status != OccurrenceStatus.skipped) o,
    ]..sort((a, b) => a.startUtc!.compareTo(b.startUtc!));
    final counts = doneCounts(rows);
    return MonthDay(
      date: dateText(day),
      label: label(day, counts),
      isPast: day.isBefore(today),
      isToday: day == today,
      items: [for (final o in rows) _item(o, nowUtc)],
      done: counts.done,
      total: counts.total,
      isLight: rows.isEmpty,
    );
  }

  MonthDay outside(DateTime day) =>
      MonthDay(date: dateText(day), label: '', outside: true);

  return [
    for (var i = lead; i > 0; i--)
      outside(DateTime(month.year, month.month, 1 - i)),
    for (var d = 1; d <= length; d++)
      cell(DateTime(month.year, month.month, d)),
    for (var i = 1; i <= trail; i++)
      outside(DateTime(month.year, month.month, length + i)),
  ];
}

MonthItem _item(Occurrence o, DateTime nowUtc) {
  final done = o.status == OccurrenceStatus.done;
  final ended = !o.endUtc!.isAfter(nowUtc);
  return MonthItem(
    title: o.title,
    color: TaskColor.fromKey(o.colorKey),
    done: done,
    missed: !done && ended,
    now: !done && !o.startUtc!.isAfter(nowUtc) && !ended,
  );
}

/// Days of [month] with at least one task, for "14 of 31 days planned".
int plannedDays(Map<DateTime, List<Occurrence>> byDay, DateTime month) => byDay
    .entries
    .where(
      (e) =>
          e.key.year == month.year &&
          e.key.month == month.month &&
          e.value.any((o) => o.status != OccurrenceStatus.skipped),
    )
    .length;
