import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/domain/entities/enums.dart';
import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:dottoday/features/timeline/state/day_summary.dart';
import 'package:dottoday/shared/dot/month_grid.dart';

/// The cells of [month] for a compact [MonthGrid], blanks included, with
/// the week starting on [firstDayOfWeek] (1 = Monday … 7 = Sunday).
///
/// Days up to [today] show their completion dot; later days show up to
/// three colours of what is planned on them, or the repeats-only outline
/// when only repeating tasks fall there (`A-ios-future-month` legend).
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
  final rows = byDay[day] ?? const <Occurrence>[];
  final ahead = day.isAfter(today);
  final oneOffs = [
    for (final o in rows)
      if (o.seriesId == null && o.status != OccurrenceStatus.skipped) o,
  ];
  return MonthDay(
    date: dateText(day),
    label: label(day, doneCounts(rows)),
    isPast: day.isBefore(today),
    isToday: day == today,
    completion: ahead ? null : completionOf(rows, begun: true),
    planned: ahead
        ? [for (final o in oneOffs.take(3)) TaskColor.fromKey(o.colorKey)]
        : const [],
    repeatsOnly: ahead && oneOffs.isEmpty && rows.isNotEmpty,
  );
}

/// The cells of [month] for the expanded Mac/web [MonthGrid]
/// (`A-mac-month`): each day's tasks in start order (done struck, ended
/// ones "missed", the one running at [nowUtc] "now"), "N of M done" up
/// to [today], a completion badge on days begun, and "Light day" for a
/// day ahead with at most one task.
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
  MonthDay cell(DateTime day) {
    final rows = [
      for (final o in byDay[day] ?? const <Occurrence>[])
        if (o.status != OccurrenceStatus.skipped) o,
    ]..sort((a, b) => a.startUtc!.compareTo(b.startUtc!));
    final counts = doneCounts(rows);
    final ahead = day.isAfter(today);
    return MonthDay(
      date: dateText(day),
      label: label(day, counts),
      isPast: day.isBefore(today),
      isToday: day == today,
      completion: ahead || rows.isEmpty
          ? null
          : completionOf(rows, begun: true),
      items: [for (final o in rows) _item(o, nowUtc)],
      done: ahead ? 0 : counts.done,
      total: ahead ? 0 : counts.total,
      isLight: ahead && rows.length == 1,
    );
  }

  return [
    for (var i = 0; i < lead; i++) null,
    for (var d = 1; d <= length; d++)
      cell(DateTime(month.year, month.month, d)),
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
