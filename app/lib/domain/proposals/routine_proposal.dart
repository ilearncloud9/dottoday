import 'package:dottoday/domain/entities/enums.dart';
import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:dottoday/domain/proposals/proposal.dart';
import 'package:dottoday/domain/proposals/rebalance_proposal.dart';
import 'package:dottoday/domain/scheduling/day_blocks.dart';
import 'package:dottoday/domain/snapshot/day_snapshot.dart';

/// Dropping a routine's [tasks] onto [day] as a [Proposal] (11 C2, docs/09
/// M11.4): one "added" line per step over the day as it is. Nothing is
/// moved to make room — an overlap shows on the thread, and × drops that
/// step — so Accept writes exactly the steps that are left.
///
/// ```dart
/// routineProposal(userId: me, day: blocks, tasks: steps, …).toBatch();
/// ```
Proposal routineProposal({
  required String userId,
  required List<Occurrence> day,
  required List<Occurrence> tasks,
  required DateTime wakeUtc,
  required DateTime bedUtc,
  required DateTime nowUtc,
}) => Proposal(
  userId: userId,
  before: DaySnapshot(
    generatedAtUtc: nowUtc,
    wakeUtc: wakeUtc,
    bedUtc: bedUtc,
    dots: [
      for (final o in scheduledBlocks(day))
        if (o.status != OccurrenceStatus.skipped) snapshotDotOf(o)!,
    ],
    inboxCount: 0,
  ),
  edits: [
    for (final t in tasks)
      ProposalEdit(
        id: t.id,
        change: ProposalChange.added,
        after: snapshotDotOf(t),
        occurrences: [t],
      ),
  ],
);
