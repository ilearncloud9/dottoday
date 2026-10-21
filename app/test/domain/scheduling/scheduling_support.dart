import 'package:dottoday/domain/entities/enums.dart';
import 'package:dottoday/domain/entities/occurrence.dart';

import '../fixtures.dart';

/// 2026-10-21 at `HH:mm` UTC.
DateTime at(String hhmm) {
  final [h, m] = hhmm.split(':').map(int.parse).toList();
  return DateTime.utc(2026, 10, 21, h, m);
}

String hhmm(DateTime t) =>
    '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

/// A scheduled block for scheduler tests.
Occurrence block(
  String id,
  String start,
  int minutes, {
  bool pinned = false,
  OccurrenceSource source = OccurrenceSource.user,
  OccurrenceStatus status = OccurrenceStatus.planned,
  int travelMin = 0,
}) => occurrenceFixture().copyWith(
  id: id,
  title: id,
  startUtc: at(start),
  durationMin: minutes,
  pinned: pinned,
  source: source,
  status: status,
  travelBufferMin: travelMin,
);

/// id → `HH:mm` start, in timeline order.
Map<String, String> starts(List<Occurrence> day) => {
  for (final o in day) o.id: hhmm(o.startUtc!),
};
