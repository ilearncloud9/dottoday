import 'package:dottoday/domain/entities/enums.dart';
import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:dottoday/domain/proposals/proposal.dart';
import 'package:dottoday/domain/proposals/rebalance_proposal.dart';
import 'package:dottoday/domain/scheduling/day_blocks.dart';
import 'package:dottoday/domain/snapshot/day_snapshot.dart';

/// Dropping a routine's [tasks] onto [day] as a [Proposal] (11 C2, docs/09
/// M11.4): one "added" line per step over the day as it is. Nothing is
/// moved to make room: a task already there that a step overlaps gets an
/// "already here · overlaps" line (never written), × drops a step, and
/// Accept writes exactly the steps that are left.
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
  edits: _byStart([
    for (final t in tasks)
      ProposalEdit(
        id: t.id,
        change: ProposalChange.added,
        after: snapshotDotOf(t),
        occurrences: [t],
      ),
    for (final o in scheduledBlocks(day))
      if (o.status == OccurrenceStatus.planned &&
          tasks.any((t) => _overlap(o, t)))
        ProposalEdit(
          id: o.id,
          change: ProposalChange.overlaps,
          before: snapshotDotOf(o),
          after: snapshotDotOf(o),
          removable: false,
        ),
  ]),
);

/// [edits] in day order, so an overlap sits beside the step it meets.
List<ProposalEdit> _byStart(List<ProposalEdit> edits) => edits
  ..sort(
    (a, b) => (a.after ?? a.before)!.startUtc.compareTo(
      (b.after ?? b.before)!.startUtc,
    ),
  );

bool _overlap(Occurrence a, Occurrence b) =>
    a.startUtc!.isBefore(b.endUtc!) && b.startUtc!.isBefore(a.endUtc!);
