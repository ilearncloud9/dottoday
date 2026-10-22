import 'package:dottoday/domain/entities/enums.dart';
import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:dottoday/domain/scheduling/month_stats.dart';
import 'package:flutter_test/flutter_test.dart';

import '../fixtures.dart';

// The Month header's numbers (M3e.4, `A-mac-month`). Now: 21 Oct 09:30Z.
final _now = DateTime.utc(2026, 10, 21, 9, 30);

Occurrence _o(
  int day,
  int h,
  int minutes, [
  OccurrenceStatus status = OccurrenceStatus.planned,
]) => occurrenceFixture().copyWith(
  id: '$day-$h',
  startUtc: DateTime.utc(2026, 10, day, h),
  durationMin: minutes,
  status: status,
);

void main() {
  test('done, missed (ended, not done), ahead (live included)', () {
    final s = MonthStats.of({
      DateTime(2026, 10, 13): [
        _o(13, 9, 120, OccurrenceStatus.done),
        _o(13, 14, 60),
        _o(13, 16, 300, OccurrenceStatus.skipped),
      ],
      DateTime(2026, 10, 21): [_o(21, 9, 120), _o(21, 7, 30)],
      DateTime(2026, 10, 22): [_o(22, 9, 60)],
    }, _now);
    expect((s.done, s.missed, s.ahead), (1, 2, 2));
    expect(s.busiest, DateTime(2026, 10, 13));
  });

  test('ties go to the earlier day; an empty month has no busiest', () {
    final s = MonthStats.of({
      DateTime(2026, 10, 23): [_o(23, 9, 60)],
      DateTime(2026, 10, 22): [_o(22, 9, 60)],
    }, _now);
    expect(s.busiest, DateTime(2026, 10, 22));
    expect(MonthStats.of(const {}, _now).busiest, isNull);
  });
}
