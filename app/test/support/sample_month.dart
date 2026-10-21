import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/shared/dot/month_grid.dart';
import 'package:dottoday/shared/dot/week_strip.dart';

const _names = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];

/// Weekday headers starting on Sunday (0) or Monday (1).
List<String> sampleWeekdays(int weekStart) => [
  for (var i = 0; i < 7; i++) _names[(i + weekStart) % 7],
];

/// A test month laid out like the renders: days before [today] are past
/// (completion dots, struck items), [today] is live, later days ahead.
/// Test-only sample data; literals are fine here.
List<MonthDay?> sampleMonth({
  required int year,
  required int month,
  required int weekStart,
  int today = 21,
  bool future = false,
}) {
  final first = DateTime.utc(year, month);
  final lead = (first.weekday % 7 - weekStart) % 7;
  final days = DateTime.utc(year, month + 1, 0).day;
  return [
    for (var i = 0; i < lead; i++) null,
    for (var d = 1; d <= days; d++) _day(d, today, future),
  ];
}

MonthDay _day(int d, int today, bool future) {
  final colors = TaskColor.values;
  if (future) {
    return MonthDay(
      date: '$d',
      label: 'Day $d',
      planned: [
        for (var i = 0; i < d % 4; i++) colors[(d + i) % colors.length],
      ],
      repeatsOnly: d % 4 == 0 && d.isOdd,
    );
  }
  final past = d < today;
  final total = 2 + d % 3;
  final done = past ? (d % 5 == 0 ? total - 1 : total) : (d == today ? 1 : 0);
  return MonthDay(
    date: '$d',
    label: 'Day $d',
    isPast: past,
    isToday: d == today,
    isLight: !past && total == 2,
    done: done,
    total: total,
    completion: past || d == today
        ? Completion.of(done / total)
        : const Completion.none(),
    items: [
      for (var i = 0; i < total; i++)
        MonthItem(
          title: [
            'Run',
            'Deep work',
            'Reply to email',
            'Spanish lesson',
          ][i % 4],
          color: colors[(d + i * 2) % colors.length],
          done: past && i < done,
          missed: past && i >= done,
          now: d == today && i == 1,
        ),
    ],
  );
}
