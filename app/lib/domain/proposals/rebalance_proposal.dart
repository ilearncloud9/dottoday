import 'package:dottoday/domain/entities/enums.dart';
import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:dottoday/domain/proposals/proposal.dart';
import 'package:dottoday/domain/scheduling/day_blocks.dart';
import 'package:dottoday/domain/scheduling/rebalance.dart';
import 'package:dottoday/domain/scheduling/unstick.dart';
import 'package:dottoday/domain/snapshot/day_snapshot.dart';

/// [plan] for [day] as a [Proposal] (11 C1, docs/09 M11.1): one line per
/// changed task — shifted, shrunk, moved to tomorrow or the Inbox — and a
/// "pinned · untouched" line per pin it worked around, in day order. Each
/// written task counts a move when its start changes (Unstick, M10.7).
///
/// ```dart
/// rebalanceProposal(day: blocks, plan: plan, wakeUtc: w, bedUtc: b,
///     nowUtc: now).edits.map((e) => e.change);
/// ```
Proposal rebalanceProposal({
  required List<Occurrence> day,
  required RebalancePlan plan,
  required DateTime wakeUtc,
  required DateTime bedUtc,
  required DateTime nowUtc,
}) {
  final timed = scheduledBlocks(day);
  final edits = <ProposalEdit>[
    for (final o in timed)
      if (plan.changed[o.id] case final next?)
        _edit(
          o,
          countMove(o, next).copyWith(updatedAt: nowUtc),
          leaves: plan.sentOffIds.contains(o.id),
        )
      else if (plan.pinnedIds.contains(o.id))
        ProposalEdit(
          id: o.id,
          change: ProposalChange.untouched,
          before: snapshotDotOf(o),
          after: snapshotDotOf(o),
          removable: false,
        ),
  ];
  return Proposal(
    userId: day.first.userId,
    before: DaySnapshot(
      generatedAtUtc: nowUtc,
      wakeUtc: wakeUtc,
      bedUtc: bedUtc,
      dots: [
        for (final o in timed)
          if (o.status != OccurrenceStatus.skipped) snapshotDotOf(o)!,
      ],
      inboxCount: 0,
    ),
    edits: edits,
  );
}

ProposalEdit _edit(
  Occurrence before,
  Occurrence after, {
  required bool leaves,
}) {
  final start = after.startUtc;
  return ProposalEdit(
    id: before.id,
    change: switch (()) {
      _ when leaves => ProposalChange.movedToDay,
      _ when after.durationMin != before.durationMin => ProposalChange.resized,
      _ => ProposalChange.shifted,
    },
    before: snapshotDotOf(before),
    after: leaves ? null : snapshotDotOf(after),
    movedToUtc: leaves ? start : null,
    occurrences: [after],
  );
}

/// [o] as a snapshot dot; none for an Inbox task (no start).
SnapshotDot? snapshotDotOf(Occurrence o) =>
    o.startUtc == null ? null : SnapshotDot.fromOccurrence(o);
