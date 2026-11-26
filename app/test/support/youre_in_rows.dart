import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:timezone/timezone.dart' as tz;

import 'timeline_fakes.dart';

/// The first Today after onboarding on Wed 21 Oct 2026 in Berlin (M20.11
/// part 5): Morning run at 7:15 and Read at 21:30, as What fills your days
/// leaves them (one day of each daily task).
List<Occurrence> youreInRows() {
  final berlin = tz.getLocation('Europe/Berlin');
  final at = DateTime.utc(2026, 10, 21, 5);
  Occurrence row(
    String id,
    String title,
    String color,
    String icon,
    int h,
    int m,
    int len,
  ) => Occurrence(
    id: id,
    userId: testUserId,
    title: title,
    colorKey: color,
    iconKey: icon,
    startUtc: tz.TZDateTime(berlin, 2026, 10, 21, h, m).toUtc(),
    tzId: 'Europe/Berlin',
    durationMin: len,
    createdAt: at,
    updatedAt: at,
  );
  return [
    row(
      '00000000-0000-7000-8000-00000000run1',
      'Morning run',
      'coral',
      'run',
      7,
      15,
      45,
    ),
    row(
      '00000000-0000-7000-8000-0000000read1',
      'Read',
      'brown',
      'book',
      21,
      30,
      30,
    ),
  ];
}
