import 'package:dottoday/domain/entities/enums.dart';
import 'package:dottoday/domain/entities/occurrence.dart';

import 'timeline_fakes.dart';

/// The `A-ios-inbox` items: five open, two done.
List<Occurrence> sampleInbox() {
  final at = DateTime.utc(2026, 10, 21, 6);
  Occurrence item(
    int n,
    String title,
    int minutes,
    String color,
    String icon, {
    bool done = false,
  }) => Occurrence(
    id: '0199f0a0-0000-7000-8000-${n.toString().padLeft(12, '0')}',
    userId: testUserId,
    title: title,
    colorKey: color,
    iconKey: icon,
    tzId: 'Europe/Berlin',
    durationMin: minutes,
    sortOrder: n.toDouble(),
    status: done ? OccurrenceStatus.done : OccurrenceStatus.planned,
    completedAtUtc: done ? at : null,
    createdAt: at,
    updatedAt: at,
  );
  return [
    item(1, 'Go for a run', 60, 'mint', 'run'),
    item(2, 'Call Mum', 15, 'sky', 'call'),
    item(3, 'Do taxes', 90, 'amber', 'list'),
    item(4, 'Build new app', 120, 'violet', 'code'),
    item(5, 'Book flights', 45, 'indigo', 'travel'),
    item(6, 'Renew passport', 30, 'slate', 'document', done: true),
    item(7, 'Buy stamps', 15, 'coral', 'cart', done: true),
  ];
}
