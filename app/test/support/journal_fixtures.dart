import 'package:dottoday/domain/entities/enums.dart';
import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:timezone/timezone.dart' as tz;

import 'timeline_fakes.dart';
import 'week_review_fixtures.dart';

// The thread journal (docs/09 M12.3): the review week plus a run every
// few weeks back to March, all in Berlin, seen on Sun 25 Oct 2026.

/// The review week and the runs.
List<Occurrence> journalRows() {
  final berlin = tz.getLocation('Europe/Berlin');
  return [
    ...weekReviewRows(),
    for (var i = 1; i <= 10; i++)
      () {
        final start = tz.TZDateTime(berlin, 2026, 10, 18 - i * 21, 7, 30);
        return Occurrence(
          id: 'run-$i',
          userId: testUserId,
          title: 'Morning run',
          colorKey: 'coral',
          iconKey: 'run',
          startUtc: start.toUtc(),
          tzId: berlin.name,
          durationMin: 40,
          status: i.isEven ? OccurrenceStatus.done : OccurrenceStatus.planned,
          createdAt: DateTime.utc(2026),
          updatedAt: DateTime.utc(2026),
        );
      }(),
  ];
}
