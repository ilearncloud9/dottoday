import 'package:dottoday/domain/entities/enums.dart';
import 'package:dottoday/domain/entities/settings.dart';
import 'package:dottoday/domain/time/schedules.dart';
import 'package:flutter_test/flutter_test.dart';

// Schedules (ED-084): weekdays that share a window, grouped.

const _weekdays = TimeWindow(start: '06:30', end: '23:00');
const _weekend = TimeWindow(start: '08:30', end: '24:30');

Settings _split() => Settings(
  dayBoundaries: {
    for (final d in Weekday.values) d: d.index < 5 ? _weekdays : _weekend,
  },
);

void main() {
  test('one window is one Every day schedule', () {
    final s = schedulesOf(const Settings());
    expect(s, hasLength(1));
    expect(scheduleKind(s.single.days), ScheduleKind.everyDay);
  });

  test('weekdays and weekend, in week order from the week start', () {
    final monday = schedulesOf(_split());
    expect(monday.map((s) => scheduleKind(s.days)), [
      ScheduleKind.weekdays,
      ScheduleKind.weekend,
    ]);
    final sunday = schedulesOf(_split(), firstDay: 7);
    expect(sunday.first.days.first, Weekday.sun);
    expect(sunday.first.window, _weekend);
  });

  test('other days are named by their days', () {
    expect(scheduleKind([Weekday.mon, Weekday.wed]), ScheduleKind.days);
    expect(scheduleKind([Weekday.sat]), ScheduleKind.days);
  });

  test('a night runs to the next morning, after midnight too', () {
    expect(nightAfter(const Settings(), Weekday.mon), 9 * 60);
    final s = _split();
    expect(nightAfter(s, Weekday.mon), 7 * 60 + 30); // 23:00 → 06:30
    expect(nightAfter(s, Weekday.fri), 9 * 60 + 30); // 23:00 → 08:30
    expect(nightAfter(s, Weekday.sat), 8 * 60); // 00:30 → 08:30
    expect(nightAfter(s, Weekday.sun), 6 * 60); // 00:30 → 06:30
  });
}
