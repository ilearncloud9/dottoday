import 'package:dottoday/domain/entities/enums.dart';
import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:dottoday/domain/entities/settings.dart';
import 'package:dottoday/domain/review/week_review.dart';
import 'package:dottoday/domain/snapshot/day_snapshot.dart';
import 'package:dottoday/domain/time/day_shape.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import '../../support/week_review_fixtures.dart';

// The weekly review (11 D1, docs/09 M12.1): which week, the counts,
// Busiest / Lightest and the sentence's rules. Only this week is read;
// nothing compares it with another.

late tz.Location berlin;

List<WeekReviewDay> _days(List<Occurrence> rows, DateTime first) => [
  for (var i = 0; i < 7; i++)
    () {
      final date = DateTime(first.year, first.month, first.day + i);
      final shape = DayShape.on(berlin, date, Settings.defaultDayBoundary);
      return WeekReviewDay(
        date: date,
        snapshot: DaySnapshot.ofDay(blocks: rows, shape: shape),
      );
    }(),
];

Occurrence _at(int day, int hour, {int late = 0, bool done = true}) {
  final start = tz.TZDateTime(berlin, 2026, 10, 18 + day, hour).toUtc();
  return Occurrence(
    id: 'o-$day-$hour',
    userId: 'u',
    title: 'T',
    startUtc: start,
    tzId: berlin.name,
    durationMin: 30,
    status: done ? OccurrenceStatus.done : OccurrenceStatus.planned,
    actualStartUtc: done ? start.add(Duration(minutes: late)) : null,
    createdAt: DateTime.utc(2026),
    updatedAt: DateTime.utc(2026),
  );
}

void main() {
  setUpAll(() {
    tz_data.initializeTimeZones();
    berlin = tz.getLocation('Europe/Berlin');
  });

  group('reviewWeek', () {
    test('Sunday-first weeks: Sunday shows the week that just ended', () {
      final w = reviewWeek(DateTime(2026, 10, 25), 7);
      expect(w.first, DateTime(2026, 10, 18));
      expect(w.last, DateTime(2026, 10, 24));
    });

    test('Monday-first weeks: Sunday shows the week ending tonight', () {
      final w = reviewWeek(DateTime(2026, 10, 25), 1);
      expect(w.first, DateTime(2026, 10, 19));
      expect(w.last, DateTime(2026, 10, 25));
    });

    test('mid-week on demand: the week so far', () {
      final w = reviewWeek(DateTime(2026, 10, 21), 1);
      expect(w.first, DateTime(2026, 10, 19));
      expect(w, hasLength(7));
    });

    test('across a month end', () {
      final w = reviewWeek(DateTime(2026, 11, 2), 1);
      expect(w.first, DateTime(2026, 10, 26));
      expect(w.last, DateTime(2026, 11, 1));
    });
  });

  test('counts, busiest and lightest of the render week', () {
    final r = WeekReview.of(_days(weekReviewRows(), reviewSunday), berlin);
    expect((r.done, r.total), (29, 34));
    expect(r.busiest!.date, DateTime(2026, 10, 22));
    expect(r.lightest!.date, DateTime(2026, 10, 24));
    expect(r.pace, WeekPace.morningsToPlan);
    expect(r.maxPlannedMinutes, 7 * 65);
  });

  group('the sentence', () {
    test('mornings: three real starts, at least 80 % on plan', () {
      final rows = [_at(0, 8), _at(1, 9, late: 10), _at(2, 10, late: 40)];
      expect(
        WeekReview.of(_days(rows, reviewSunday), berlin).pace,
        isNot(WeekPace.morningsToPlan),
        reason: 'two of three is under 80 %',
      );
      final more = [...rows, _at(3, 8), _at(4, 9)];
      expect(
        WeekReview.of(_days(more, reviewSunday), berlin).pace,
        WeekPace.morningsToPlan,
      );
    });

    test('fewer than three real starts say nothing about timing', () {
      final rows = [_at(0, 8), _at(1, 8), _at(2, 8, done: false)];
      expect(
        WeekReview.of(_days(rows, reviewSunday), berlin).pace,
        WeekPace.none,
      );
    });

    test('afternoons when the mornings do not qualify', () {
      final rows = [_at(0, 14), _at(1, 15), _at(2, 16), _at(3, 9, late: 50)];
      expect(
        WeekReview.of(_days(rows, reviewSunday), berlin).pace,
        WeekPace.afternoonsToPlan,
      );
    });

    test('everything done, with no real times', () {
      final rows = [
        for (final o in [_at(0, 8), _at(1, 9)])
          o.copyWith(actualStartUtc: null),
      ];
      expect(
        WeekReview.of(_days(rows, reviewSunday), berlin).pace,
        WeekPace.allDone,
      );
    });

    test('an empty week is quiet, with no busiest or lightest', () {
      final r = WeekReview.of(_days(const [], reviewSunday), berlin);
      expect(r.pace, WeekPace.quiet);
      expect(r.busiest, isNull);
      expect(r.lightest, isNull);
    });

    test('one planned day is the busiest and never also the lightest', () {
      final r = WeekReview.of(_days([_at(2, 9)], reviewSunday), berlin);
      expect(r.busiest!.date, DateTime(2026, 10, 20));
      expect(r.lightest, isNull);
    });
  });

  test('a day snapshot keeps every task of the day and no skipped one', () {
    final day = DateTime(2026, 10, 22);
    final shape = DayShape.on(berlin, day, Settings.defaultDayBoundary);
    final rows = weekReviewRows();
    final skipped = rows.first.copyWith(
      id: 'skipped',
      startUtc: shape.wakeUtc.add(const Duration(hours: 1)),
      status: OccurrenceStatus.skipped,
    );
    final s = DaySnapshot.ofDay(blocks: [...rows, skipped], shape: shape);
    expect(s.dots, hasLength(7));
    expect((s.dayDone, s.dayTotal), (5, 7));
    expect(s.generatedAtUtc, shape.bedUtc);
  });
}
