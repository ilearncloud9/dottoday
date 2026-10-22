import 'package:dottoday/domain/entities/occurrence.dart';

/// The Inbox in its own order (PRD F3, docs/09 M3f.9c): [shown] with the
/// item at [from] moved to [to] (its index afterwards), renumbered 1…n.
/// Returns only the items whose `sortOrder` changed, so one write (and one
/// Undo) puts the list back.
///
/// ```dart
/// reorderInbox([a, b, c], 2, 0); // c=1, a=2, b=3 (those that changed)
/// ```
List<Occurrence> reorderInbox(List<Occurrence> shown, int from, int to) {
  if (from == to || from < 0 || from >= shown.length) return const [];
  final order = [...shown];
  final moved = order.removeAt(from);
  order.insert(to.clamp(0, order.length), moved);
  return [
    for (final (i, o) in order.indexed)
      if (o.sortOrder != i + 1) o.copyWith(sortOrder: (i + 1).toDouble()),
  ];
}
