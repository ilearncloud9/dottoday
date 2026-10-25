import 'package:dottoday/domain/entities/enums.dart';
import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:dottoday/domain/scheduling/energy_window.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import '../fixtures.dart';

// Energy suggestions (docs/09 M11.5, 11 C4): the two-hour window in which
// the user really starts most finished high-energy tasks, once there are
// twenty of them.

late tz.Location _berlin;
var _n = 0;

/// A finished task on Oct [day] that really started at [h]:[m] Berlin
/// (CEST, UTC+2 until the 25th).
Occurrence _run(
  int day,
  int h, {
  int m = 0,
  Energy? energy = Energy.high,
  OccurrenceStatus status = OccurrenceStatus.done,
  String title = 'Deep work',
}) {
  final start = tz.TZDateTime(_berlin, 2026, 10, day, h, m).toUtc();
  return occurrenceFixture().copyWith(
    id: 'e-${++_n}',
    title: title,
    energy: energy,
    status: status,
    startUtc: start,
    actualStartUtc: start,
    actualEndUtc: start.add(const Duration(minutes: 90)),
  );
}

void main() {
  setUpAll(() {
    tz_data.initializeTimeZones();
    _berlin = tz.getLocation('Europe/Berlin');
  });

  test('the busiest two hours of finished high-energy starts', () {
    final history = [
      for (var d = 1; d <= 12; d++) _run(d, 9, m: 15),
      for (var d = 1; d <= 6; d++) _run(d, 10, m: 30),
      for (var d = 1; d <= 5; d++) _run(d, 15),
    ];
    final w = bestEnergyWindow(history, _berlin)!;
    expect((w.startHour, w.endHour), (9, 11));
    expect(w.completions, 23);
    expect(w.knows('deep  WORK'), isTrue);
    expect(w.knows('Lunch'), isFalse);
  });

  test('under twenty completions: nothing', () {
    final history = [for (var d = 1; d <= 19; d++) _run(d, 9)];
    expect(bestEnergyWindow(history, _berlin), isNull);
  });

  test('only finished, high-energy tasks with real times count', () {
    final noise = [
      for (var d = 1; d <= 30; d++) _run(d, 20, energy: Energy.medium),
      for (var d = 1; d <= 30; d++)
        _run(d, 21, status: OccurrenceStatus.planned),
      for (var d = 1; d <= 30; d++)
        _run(d, 22).copyWith(actualStartUtc: null, actualEndUtc: null),
    ];
    expect(bestEnergyWindow(noise, _berlin), isNull);
    final real = [...noise, for (var d = 1; d <= 20; d++) _run(d, 7)];
    expect(
      bestEnergyWindow(real, _berlin)!.startHour,
      7,
      reason: '7–9 over 6–8: it starts at the busy hour',
    );
  });

  test('read in the user zone, across the clock change', () {
    // 9:00 local on both sides of 25 Oct (CEST then CET).
    final history = [
      for (var d = 15; d <= 24; d++) _run(d, 9),
      for (var d = 26; d <= 31; d++) _run(d, 9),
      for (var d = 1; d <= 4; d++) _run(d, 9),
    ];
    expect(bestEnergyWindow(history, _berlin)!.startHour, 9);
  });
}
