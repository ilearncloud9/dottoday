import 'package:dottoday/domain/entities/enums.dart';
import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:dottoday/domain/scheduling/week_summary.dart';
import 'package:dottoday/domain/time/day_shape.dart';
import 'package:flutter_test/flutter_test.dart';

import '../fixtures.dart';

// The Week board's capacity maths (M3e.3, `A-mac-week-alt3-board`). Days
// run 07:00–22:00 UTC (15 h awake).

DateTime _at(int day, int h) => DateTime.utc(2026, 10, 18 + day, h);

DayShape _shape(int day) =>
    DayShape(wakeUtc: _at(day, 7), bedUtc: _at(day, 22));

Occurrence _o(
  int day,
  int h,
  int minutes, {
  OccurrenceStatus status = OccurrenceStatus.planned,
}) => occurrenceFixture().copyWith(
  id: '$day-$h',
  startUtc: _at(day, h),
  durationMin: minutes,
  status: status,
);

DayLoad _day(int day, List<Occurrence> blocks) =>
    DayLoad.of(DateTime(2026, 10, 18 + day), blocks, _shape(day));

void main() {
  test('a day: planned, free (overlaps once), done of total, share', () {
    final d = _day(0, [
      _o(0, 9, 120, status: OccurrenceStatus.done),
      _o(0, 10, 60),
      _o(0, 14, 30, status: OccurrenceStatus.skipped),
    ]);
    expect(d.plannedMinutes, 180);
    expect(d.freeMinutes, 900 - 120);
    expect((d.done, d.total), (1, 2));
    expect(d.share, closeTo(180 / 900, 1e-9));
  });

  test('week: busiest, lightest, sums; ties go to the earlier day', () {
    final s = WeekSummary.of([
      _day(0, [_o(0, 9, 270)]),
      _day(1, [_o(1, 9, 450)]),
      _day(2, const []),
      _day(3, [_o(3, 9, 450)]),
      _day(4, [_o(4, 9, 150, status: OccurrenceStatus.done)]),
    ]);
    expect(s.busiest!.date, DateTime(2026, 10, 19));
    expect(s.lightest!.date, DateTime(2026, 10, 22));
    expect(s.plannedMinutes, 270 + 450 + 450 + 150);
    expect(s.freeMinutes, 5 * 900 - (270 + 450 + 450 + 150));
    expect((s.done, s.total), (1, 4));
  });

  test('an empty week has neither; one busy day is not also lightest', () {
    expect(WeekSummary.of([_day(0, const [])]).busiest, isNull);
    final one = WeekSummary.of([
      _day(0, [_o(0, 9, 60)]),
      _day(1, const []),
    ]);
    expect(one.busiest!.plannedMinutes, 60);
    expect(one.lightest, isNull);
  });

  test('share caps at a full day', () {
    expect(_day(0, [_o(0, 0, 1440)]).share, 1);
  });
}
