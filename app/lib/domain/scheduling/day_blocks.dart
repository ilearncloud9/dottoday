import 'package:dottoday/domain/entities/enums.dart';
import 'package:dottoday/domain/entities/occurrence.dart';

// Helpers shared by the scheduling operations (docs/04 §5).

/// Scheduled, live blocks ordered by start (ties by id, so order is stable).
List<Occurrence> scheduledBlocks(Iterable<Occurrence> day) =>
    sortedByStart(day.where((o) => o.startUtc != null && o.deletedAt == null));

/// [blocks] ordered by start, ties by id. All must be scheduled.
List<Occurrence> sortedByStart(Iterable<Occurrence> blocks) => blocks.toList()
  ..sort((a, b) {
    final byStart = a.startUtc!.compareTo(b.startUtc!);
    return byStart != 0 ? byStart : a.id.compareTo(b.id);
  });

/// Whether [o] blocks its time slot: skipped blocks free their time; done
/// blocks still occupied it.
bool occupiesTime(Occurrence o) => o.status != OccurrenceStatus.skipped;

/// Start of the time [o] occupies, including its travel buffer (R-17).
DateTime footprintStart(Occurrence o) =>
    o.startUtc!.subtract(Duration(minutes: o.travelBufferMin));
