import 'package:dottoday/domain/entities/enums.dart';
import 'package:dottoday/domain/time/day_shape.dart';
import 'package:dottoday/features/timeline/state/day_summary.dart';
import 'package:dottoday/features/timeline/widgets/today_header.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../domain/fixtures.dart';

void main() {
  final shape = DayShape(
    wakeUtc: DateTime.utc(2026, 10, 21, 5),
    bedUtc: DateTime.utc(2026, 10, 21, 20),
  );
  final blocks = [
    occurrenceFixture().copyWith(
      id: 'a',
      durationMin: 60,
      status: OccurrenceStatus.done,
    ),
    occurrenceFixture().copyWith(id: 'b', durationMin: 120),
    occurrenceFixture().copyWith(
      id: 'c',
      durationMin: 45,
      status: OccurrenceStatus.skipped,
    ),
  ];

  test('summary: skipped tasks are neither planned nor to do', () {
    final s = daySummaryOf(blocks, shape);
    expect(
      [s.done, s.total, s.plannedMinutes, s.freeMinutes],
      [1, 2, 180, 720],
    );
  });

  test('free time never goes below zero', () {
    final busy = [occurrenceFixture().copyWith(durationMin: 1000)];
    expect(daySummaryOf(busy, shape).freeMinutes, 0);
  });

  test('completion: share once begun, outline ahead or when empty', () {
    expect(completionOf(blocks, begun: true).share, 0.5);
    expect(completionOf(blocks, begun: false).share, isNull);
    expect(completionOf(const [], begun: true).share, isNull);
  });

  test('greeting part by local hour', () {
    expect(
      [
        dayPart(5),
        dayPart(11),
        dayPart(12),
        dayPart(16),
        dayPart(17),
        dayPart(23),
      ],
      ['morning', 'morning', 'afternoon', 'afternoon', 'evening', 'evening'],
    );
  });
}
