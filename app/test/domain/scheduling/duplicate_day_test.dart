import 'package:dottoday/domain/entities/enums.dart';
import 'package:dottoday/domain/scheduling/duplicate_day.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import '../../support/fake_ids.dart';
import '../fixtures.dart';

void main() {
  tz_data.initializeTimeZones();
  final berlin = tz.getLocation('Europe/Berlin');
  final now = DateTime.utc(2026, 10, 21, 12);
  // Wed 21 Oct 09:00 Berlin (CEST) = 07:00Z.
  final nine = DateTime.utc(2026, 10, 21, 7);

  test('copies one-offs to the same wall-clock time, DST included', () {
    final copies = duplicateDay(
      source: [
        occurrenceFixture().copyWith(
          id: 'a',
          startUtc: nine,
          status: OccurrenceStatus.done,
          completedAtUtc: nine,
        ),
      ],
      // Mon 14 Dec is CET: 09:00 local = 08:00Z.
      targetDate: DateTime(2026, 12, 14),
      location: berlin,
      nowUtc: now,
      ids: FakeIds(),
    );
    final c = copies.single;
    expect(c.startUtc, DateTime.utc(2026, 12, 14, 8));
    expect(c.id, isNot('a'));
    expect(c.status, OccurrenceStatus.planned);
    expect(c.completedAtUtc, isNull);
    expect([c.createdAt, c.updatedAt], [now, now]);
  });

  test('leaves out repeats, skipped, inbox and calendar rows', () {
    final copies = duplicateDay(
      source: [
        occurrenceFixture().copyWith(startUtc: nine, seriesId: 's'),
        occurrenceFixture().copyWith(
          startUtc: nine,
          status: OccurrenceStatus.skipped,
        ),
        occurrenceFixture().copyWith(startUtc: null),
        occurrenceFixture().copyWith(
          startUtc: nine,
          source: OccurrenceSource.calendar,
        ),
        occurrenceFixture().copyWith(startUtc: nine, title: 'kept'),
      ],
      targetDate: DateTime(2026, 10, 22),
      location: berlin,
      nowUtc: now,
      ids: FakeIds(),
    );
    expect(copies.map((c) => c.title), ['kept']);
  });
}
