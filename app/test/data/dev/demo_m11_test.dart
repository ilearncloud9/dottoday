import 'package:dottoday/core/failures/result.dart';
import 'package:dottoday/data/dev/demo_day.dart';
import 'package:dottoday/data/dev/demo_m11.dart';
import 'package:dottoday/domain/entities/enums.dart';
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
    final kinds = realityOf(sample.occurrences, now).map((r) => r.kind);
    expect(kinds, [RealityKind.finished, RealityKind.underWay]);
    expect(sample.occurrences.first.status, OccurrenceStatus.done);
    expect(sample.routines.map((r) => r.title), [
      'Morning',
      'Shutdown',
      'Gym day',
    ]);
    expect(sample.routines.every((r) => validateRoutine(r) is Ok), isTrue);
  });
}
