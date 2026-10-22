import 'package:dottoday/domain/entities/enums.dart';
import 'package:dottoday/domain/entities/settings.dart';
import 'package:dottoday/domain/time/day_boundaries.dart';
import 'package:flutter_test/flutter_test.dart';

const _late = TimeWindow(start: '09:00', end: '23:30');
const _early = TimeWindow(start: '06:00', end: '21:00');

void main() {
  test('defaults: 07:00–22:00 everyday, no custom days', () {
    expect(commonWindow(const Settings()), Settings.defaultDayBoundary);
    expect(customDays(const Settings()), isEmpty);
  });

  test('a custom weekend keeps its window when the everyday one moves', () {
    var s = withDayWindow(const Settings(), Weekday.sat, _late);
    s = withDayWindow(s, Weekday.sun, _late);
    expect(customDays(s), [Weekday.sat, Weekday.sun]);
    s = withCommonWindow(s, _early);
    expect(s.boundaryFor(Weekday.mon), _early);
    expect(s.boundaryFor(Weekday.fri), _early);
    expect(s.boundaryFor(Weekday.sat), _late);
  });

  test('back to everyday with null; the majority wins', () {
    var s = withDayWindow(const Settings(), Weekday.sat, _late);
    s = withDayWindow(s, Weekday.sat, null);
    expect(customDays(s), isEmpty);
    // Four days late, three default: late is now everyday.
    for (final d in [Weekday.mon, Weekday.tue, Weekday.wed, Weekday.thu]) {
      s = withDayWindow(s, d, _late);
    }
    expect(commonWindow(s), _late);
    expect(customDays(s), [Weekday.fri, Weekday.sat, Weekday.sun]);
  });

  test('windowTime / windowMinutes, including 24:00', () {
    expect(windowTime(7 * 60), '07:00');
    expect(windowTime(1440), '24:00');
    expect(windowMinutes('22:30'), 1350);
    expect(windowMinutes('24:00'), 1440);
  });
}
