import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:dottoday/domain/scheduling/inbox_plan.dart';
import 'package:dottoday/domain/scheduling/schedule_result.dart';

/// Where an inbox item fits first: the index into the week's rooms (0 =
/// today) and the slot ("Fits today 11:30", "Fits Thu 12:00";
/// `A-mac-inbox`).
typedef WeekFit = ({int day, Slot slot});

/// The earliest slot for [item] across [days] (today from now, then the
/// following days), or null when the week has no room for it.
///
/// ```dart
/// firstFit(run, rooms)?.day; // 0: it fits today
/// ```
WeekFit? firstFit(Occurrence item, List<DayRoom> days) {
  for (final (i, room) in days.indexed) {
    final slot = room.slotsFor(item.durationMin).firstOrNull;
    if (slot != null) return (day: i, slot: slot);
  }
  return null;
}

/// "Auto-plan the week" (`A-mac-inbox`, ⇧⌘P): places the open [items] in
/// the order given, each in the earliest slot still free across [days];
/// later items see the earlier ones as booked. What finds no room stays
/// in the Inbox.
({List<({Occurrence item, Slot slot})> placed, List<Occurrence> unplaced})
autoPlan(Iterable<Occurrence> items, List<DayRoom> days) {
  final rooms = [...days];
  final placed = <({Occurrence item, Slot slot})>[];
  final unplaced = <Occurrence>[];
  for (final o in openItems(items)) {
    final fit = firstFit(o, rooms);
    if (fit == null) {
      unplaced.add(o);
      continue;
    }
    placed.add((item: o, slot: fit.slot));
    rooms[fit.day] = rooms[fit.day].withBlock(
      o.copyWith(startUtc: fit.slot.startUtc),
    );
  }
  return (placed: placed, unplaced: unplaced);
}

/// The Inbox's Sort menu (`A-mac-inbox` "Sort: duration").
enum InboxSort {
  /// As added (the repository's order).
  added,

  /// Shortest first, then by title.
  duration,

  /// Soonest fitting slot first; items that fit nowhere this week last.
  fit,
}

/// [items] in [sort] order; [fitOf] gives each item's [WeekFit] for
/// [InboxSort.fit]. Stable: ties keep the added order.
List<Occurrence> sortInbox(
  List<Occurrence> items,
  InboxSort sort,
  WeekFit? Function(Occurrence o) fitOf,
) {
  final indexed = [...items.indexed];
  int byAdded((int, Occurrence) a, (int, Occurrence) b) => a.$1 - b.$1;
  int byDuration((int, Occurrence) a, (int, Occurrence) b) {
    final d = a.$2.durationMin - b.$2.durationMin;
    return d != 0 ? d : byAdded(a, b);
  }

  int byFit((int, Occurrence) a, (int, Occurrence) b) {
    final fa = fitOf(a.$2)?.slot.startUtc;
    final fb = fitOf(b.$2)?.slot.startUtc;
    if (fa == null || fb == null) {
      if (fa == fb) return byAdded(a, b);
      return fa == null ? 1 : -1;
    }
    final d = fa.compareTo(fb);
    return d != 0 ? d : byAdded(a, b);
  }

  final compare = switch (sort) {
    InboxSort.added => byAdded,
    InboxSort.duration => byDuration,
    InboxSort.fit => byFit,
  };
  indexed.sort(compare);
  return [for (final (_, o) in indexed) o];
}
