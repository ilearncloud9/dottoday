import 'package:dottoday/domain/entities/enums.dart';
import 'package:dottoday/domain/entities/occurrence.dart';

import 'timeline_fakes.dart';

/// 10:22 in Berlin on the demo day: Deep work (9:00–11:00) has 38 min left.
final searchNow = DateTime.utc(2026, 10, 21, 8, 22);

/// The demo day plus the other `A-ios-search` "roadmap" results: done on
/// Monday, planned for Friday, and one in the Inbox.
List<Occurrence> sampleSearchRows() {
  Occurrence o(
    String id,
    String title, {
    DateTime? start,
    int minutes = 60,
    String color = 'indigo',
    String icon = 'code',
    OccurrenceStatus status = OccurrenceStatus.planned,
  }) => Occurrence(
    id: '0199f0b0-0000-7000-8000-$id',
    userId: testUserId,
    title: title,
    startUtc: start,
    tzId: 'Europe/Berlin',
    durationMin: minutes,
    colorKey: color,
    iconKey: icon,
    status: status,
    createdAt: DateTime.utc(2026, 10),
    updatedAt: DateTime.utc(2026, 10),
  );
  return [
    ...demoDayRows(DateTime(2026, 10, 21), now: searchNow),
    o(
      '000000000001',
      'Deep work: roadmap',
      start: DateTime.utc(2026, 10, 19, 7),
      minutes: 180,
      color: 'violet',
      status: OccurrenceStatus.done,
    ),
    o(
      '000000000002',
      'Write roadmap one-pager',
      start: DateTime.utc(2026, 10, 23, 12),
      color: 'amber',
      icon: 'document',
    ),
    o(
      '000000000003',
      'Roadmap review with Sam',
      minutes: 45,
      color: 'rose',
      icon: 'people',
    ),
  ];
}
