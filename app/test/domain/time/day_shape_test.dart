import 'package:dottoday/domain/entities/settings.dart';
import 'package:dottoday/domain/time/day_shape.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import '../../support/fake_clock.dart';

void main() {
  tzdata.initializeTimeZones();
  final berlin = tz.getLocation('Europe/Berlin');

  test('Wake Up → Bedtime on the local day, as UTC', () {
    final s = DayShape.on(
      berlin,
      DateTime(2026, 10, 21),
      Settings.defaultDayBoundary,
    );
    expect(s.wakeUtc, DateTime.utc(2026, 10, 21, 5));
    expect(s.bedUtc, DateTime.utc(2026, 10, 21, 20));
    expect(s.awakeMinutes, 15 * 60);
  });

  test('progress follows the injected clock and clamps at the caps', () {
    final s = DayShape.on(
      berlin,
      DateTime(2026, 10, 21),
      Settings.defaultDayBoundary,
    );
    final clock = FakeClock(DateTime.utc(2026, 10, 21, 4));
    expect(s.progressAt(clock.nowUtc()), 0);
    clock.now = DateTime.utc(2026, 10, 21, 12, 30); // 14:30 local
    expect(s.progressAt(clock.nowUtc()), closeTo(0.5, 1e-9));
    clock.advance(const Duration(hours: 12));
    expect(s.progressAt(clock.nowUtc()), 1);
  });

  test('a DST day keeps its wall-clock ends (25 h day, 23 h awake)', () {
    final s = DayShape.on(
      berlin,
      DateTime(2026, 10, 25),
      const TimeWindow(start: '01:00', end: '23:00'),
    );
    expect(s.wakeUtc, DateTime.utc(2026, 10, 24, 23));
    expect(s.bedUtc, DateTime.utc(2026, 10, 25, 22));
    expect(s.awakeMinutes, 23 * 60);
  });

  test('an empty or inverted window never divides by zero', () {
    final s = DayShape(wakeUtc: DateTime.utc(2026), bedUtc: DateTime.utc(2026));
    expect(s.progressAt(DateTime.utc(2026, 1, 2)), 0);
  });
}
