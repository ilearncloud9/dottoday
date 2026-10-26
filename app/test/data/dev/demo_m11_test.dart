import 'package:dottoday/core/failures/result.dart';
import 'package:dottoday/data/dev/demo_day.dart';
import 'package:dottoday/data/dev/demo_m11.dart';
import 'package:dottoday/domain/entities/enums.dart';
import 'package:dottoday/domain/scheduling/learning.dart';
import 'package:dottoday/domain/scheduling/reality.dart';
import 'package:dottoday/domain/validation/routine_validator.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

// The debug M11 sample (docs/09 M11.6) gives the demo day a finished and
// an under-way task and three valid routines.

void main() {
  setUpAll(tz_data.initializeTimeZones);

  test('real times on two tasks and three valid routines', () {
    final now = DateTime.utc(2026, 10, 21, 13);
    final day = buildDemoDay(
      userId: 'u',
      location: tz.getLocation('Europe/Berlin'),
      date: DateTime(2026, 10, 21),
      nowUtc: now,
    ).occurrences;
    final sample = buildM11Sample(userId: 'u', day: day, nowUtc: now);
    final today = [
      for (final o in sample.occurrences)
        if (o.startUtc!.isAfter(now.subtract(const Duration(hours: 12)))) o,
    ];
    final kinds = realityOf(today, now).map((r) => r.kind);
    expect(kinds, [RealityKind.finished, RealityKind.underWay]);
    // docs/13: enough finished runs to reveal the reality thread, and the
    // task under way has a usual length.
    final index = LearningIndex.from(sample.occurrences);
    expect(realityRuns(sample.occurrences), greaterThanOrEqualTo(10));
    expect(index.forTask(title: today.last.title).usualMinutes, isNotNull);
    expect(sample.occurrences.map((o) => o.id).toSet(), hasLength(12));
    expect(sample.occurrences.first.status, OccurrenceStatus.done);
    expect(sample.routines.map((r) => r.title), [
      'Morning',
      'Shutdown',
      'Gym day',
    ]);
    expect(sample.routines.every((r) => validateRoutine(r) is Ok), isTrue);
  });
}
