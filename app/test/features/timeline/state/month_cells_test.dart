import 'package:dottoday/domain/entities/enums.dart';
import 'package:dottoday/features/timeline/state/month_cells.dart';
import 'package:dottoday/shared/dot/month_grid.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../domain/fixtures.dart';

/// Month in the Workspace (E-R2-30, ED-333): the days of the months either
/// side fill the first and last weeks, "N of M done" on every day with
/// tasks, Light day on a day with none.
void main() {
  final today = DateTime(2026, 10, 21);
  List<MonthDay> cells(Map<DateTime, int> tasks) => expandedMonthCells(
    month: DateTime(2026, 10),
    firstDayOfWeek: 1,
    today: today,
    nowUtc: DateTime.utc(2026, 10, 21, 8),
    byDay: {
      for (final e in tasks.entries)
        e.key: [
          for (var i = 0; i < e.value; i++)
            occurrenceFixture().copyWith(
              id: '${e.key.day}-$i',
              startUtc: DateTime.utc(e.key.year, e.key.month, e.key.day, 9 + i),
              status: i == 0 && e.key.isBefore(today)
                  ? OccurrenceStatus.done
                  : OccurrenceStatus.planned,
            ),
        ],
    },
    dateText: (d) => '${d.day}',
    label: (d, c) => '${d.day}',
  ).nonNulls.toList();

  test('the first and last weeks are filled with faded days', () {
    final all = cells({});
    // 1 Oct 2026 is a Thursday: Mon 28 – Wed 30 Sep lead in.
    expect(all.take(3).map((c) => (c.date, c.outside)), [
      ('28', true),
      ('29', true),
      ('30', true),
    ]);
    expect(all[3].date, '1');
    expect(all[3].outside, isFalse);
    // 31 Oct is a Saturday: Sunday 1 Nov closes the week.
    expect(all.last.date, '1');
    expect(all.last.outside, isTrue);
    expect(all.length % 7, 0);
  });

  test('N of M done on every day with tasks, Light day on none', () {
    final all = cells({DateTime(2026, 10, 20): 2, DateTime(2026, 10, 23): 1});
    final past = all.firstWhere((c) => c.date == '20' && !c.outside);
    expect((past.done, past.total, past.isLight), (1, 2, false));
    final ahead = all.firstWhere((c) => c.date == '23' && !c.outside);
    expect((ahead.done, ahead.total, ahead.isLight), (0, 1, false));
    final empty = all.firstWhere((c) => c.date == '24' && !c.outside);
    expect((empty.total, empty.isLight), (0, true));
  });
}
