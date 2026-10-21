import 'package:dottoday/features/timeline/layout/time_scale.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TimeScale day({bool before = false, bool after = false}) => TimeScale.forDay(
    dayMinutes: 1440,
    coreFrom: 420,
    coreTo: 1320,
    pxPerMin: 1.6,
    collapsedPxPerMin: 0.4,
    expandBefore: before,
    expandAfter: after,
  );

  test('core is full density, outside hours collapsed, whole day laid out', () {
    final s = day();
    expect(s.segments, hasLength(3));
    expect(s.yOf(0), 0);
    expect(s.yOf(420), 168); // 7 h × 24 px
    expect(s.yOf(480), 168 + 96);
    expect(s.yOf(1320), 168 + 1440);
    expect(s.height, 168 + 1440 + 48);
    expect(s.yOf(1440), s.height); // the bottom of the day exists (R-14)
  });

  test('expanding a zone gives it full density', () {
    expect(day(before: true).yOf(420), 672);
    expect(day(after: true).height, 672 / 4 + 1440 + 192);
  });

  test('minuteAt inverts yOf and clamps', () {
    final s = day();
    for (final m in [0.0, 100.0, 420.0, 777.5, 1320.0, 1439.0, 1440.0]) {
      expect(s.minuteAt(s.yOf(m)), closeTo(m, 1e-9));
    }
    expect(s.minuteAt(-50), 0);
    expect(s.minuteAt(s.height + 50), 1440);
    expect(s.yOf(-10), 0);
    expect(s.yOf(2000), s.height);
  });

  test('a whole-day core window has a single segment', () {
    final s = TimeScale.forDay(
      dayMinutes: 1500,
      coreFrom: 0,
      coreTo: 1500,
      pxPerMin: 2,
      collapsedPxPerMin: 1,
    );
    expect(s.segments, hasLength(1));
    expect(s.height, 3000);
  });
}
