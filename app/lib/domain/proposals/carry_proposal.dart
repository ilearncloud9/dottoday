import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:dottoday/domain/proposals/proposal.dart';
import 'package:dottoday/domain/proposals/rebalance_proposal.dart';
import 'package:dottoday/domain/scheduling/slot_finder.dart';
import 'package:dottoday/domain/scheduling/unstick.dart';
import 'package:dottoday/domain/snapshot/day_snapshot.dart';

/// A day tasks may be placed on: its blocks between Wake Up and Wind Down.
final class CarryDay {
  const CarryDay({
    required this.blocks,
    required this.wakeUtc,
    required this.bedUtc,
  });

  final List<Occurrence> blocks;
  final DateTime wakeUtc;
  final DateTime bedUtc;
}

/// Moving [tasks] onto [days] as a [Proposal] (11 D1 "move them to next
/// week?", D2 "move everything optional to tomorrow?"): each task, in its
/// planned order, goes to the first free slot of its length from the first
/// of [days] on — never before [nowUtc] — or to the Inbox when none of
/// them has room. One "moved to …" line per task; × keeps a task where it
/// is, and Accept writes exactly the lines left. Each move counts for
/// Unstick (M10.7).
///
/// ```dart
/// carryProposal(userId: me, tasks: unfinished, days: nextWeek,
///     nowUtc: now).edits.map((e) => e.movedToUtc);
/// ```
Proposal carryProposal({
  required String userId,
  required List<Occurrence> tasks,
  required List<CarryDay> days,
  required DateTime nowUtc,
}) {
  final ordered = [...tasks]
    ..sort((a, b) => a.startUtc!.compareTo(b.startUtc!));
  final taken = [
    for (final d in days) <Occurrence>[...d.blocks],
  ];
  final edits = <ProposalEdit>[];
  for (final o in ordered) {
    final placed = _place(o, days, taken, nowUtc);
    final moved = countMove(o, o.copyWith(startUtc: placed, updatedAt: nowUtc));
    edits.add(
      ProposalEdit(
        id: o.id,
        change: ProposalChange.movedToDay,
        before: snapshotDotOf(o),
        movedToUtc: placed,
        occurrences: [moved],
      ),
    );
  }
  final first = days.isEmpty ? null : days.first;
  return Proposal(
    userId: userId,
    before: DaySnapshot(
      generatedAtUtc: nowUtc,
      wakeUtc: first?.wakeUtc ?? nowUtc,
      bedUtc: first?.bedUtc ?? nowUtc,
      dots: [for (final o in ordered) ?snapshotDotOf(o)],
      inboxCount: 0,
    ),
    edits: edits,
  );
}

/// The first free start for [o] across [days] (marking it taken), or null.
DateTime? _place(
  Occurrence o,
  List<CarryDay> days,
  List<List<Occurrence>> taken,
  DateTime nowUtc,
) {
  for (final (i, d) in days.indexed) {
    if (!d.bedUtc.isAfter(nowUtc)) continue;
    final slot = findSlots(
      taken[i],
      o.durationMin,
      fromUtc: nowUtc,
      dayStartUtc: d.wakeUtc,
      dayEndUtc: d.bedUtc,
      limit: 1,
    ).firstOrNull;
    if (slot == null) continue;
    taken[i].add(o.copyWith(startUtc: slot.startUtc));
    return slot.startUtc;
  }
  return null;
}
