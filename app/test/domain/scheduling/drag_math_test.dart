import 'package:dottoday/domain/scheduling/drag_math.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

void main() {
  late tz.Location berlin;
  setUpAll(() {
    tzdata.initializeTimeZones();
    berlin = tz.getLocation('Europe/Berlin');
  });

  // 09:05 Berlin on 21 Oct 2026 (CEST, UTC+2).
  final gap = DateTime.utc(2026, 10, 21, 7, 5);

  DateTime drop(
    double f, {
    int gapMin = 60,
    int dur = 30,
    int snap = 15,
    bool fit = true,
  }) => dropStart(
    zone: berlin,
    gapStartUtc: gap,
    gapMinutes: gapMin,
    fraction: f,
    durationMin: dur,
    snapMinutes: snap,
    fit: fit,
  );

  group('dropStart', () {
    test('snaps to the wall clock, not to the gap start', () {
      expect(drop(0.4), DateTime.utc(2026, 10, 21, 7, 30)); // 09:29 → 09:30
    });

    test('clamps so the task fits before the gap ends', () {
      expect(drop(1), DateTime.utc(2026, 10, 21, 7, 35)); // ends 10:05
    });

    test('never starts before the gap opens', () {
      expect(drop(0), gap); // 09:05 would snap to 09:00
    });

    test('a task longer than the gap starts at its opening', () {
      expect(drop(0.5, gapMin: 20), gap);
    });
  });

  group('dropStart on a task row (ADR-0015)', () {
    test('lands where it was let go, overlapping the task', () {
      // 3/4 down a 60-min task from 09:05: 09:50, snapped to 09:45.
      expect(drop(0.75, fit: false), DateTime.utc(2026, 10, 21, 7, 45));
    });

    test('is not pulled back to fit inside the row', () {
      expect(drop(1, fit: false), DateTime.utc(2026, 10, 21, 8, 0)); // 10:00
    });
  });

  test('sameTimeOn keeps the wall time across a DST change', () {
    // 09:30 CEST on 21 Oct → 09:30 CET on 26 Oct (UTC+1).
    final start = DateTime.utc(2026, 10, 21, 7, 30);
    expect(
      sameTimeOn(berlin, start, DateTime(2026, 10, 26)),
      DateTime.utc(2026, 10, 26, 8, 30),
    );
  });
}
