import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:dottoday/domain/entities/subtask.dart';
import 'package:dottoday/domain/proposals/proposal.dart';
import 'package:dottoday/domain/scheduling/step_lengths.dart';
import 'package:dottoday/domain/snapshot/day_snapshot.dart';
import 'package:dottoday/domain/thinking/breakdown_tree.dart';

/// The one edit a Break it down proposal holds (11 B1, docs/09 M10.4).
const breakdownEditId = 'breakdown';

/// Break it down for a saved [task] as a [Proposal]: the [tree]'s leaves
/// become its steps after the ones it already has ([existing]), and the
/// task follows their sum — "the dot grows to fit". Nothing is written
/// until Accept; Undo sends the new steps to Trash and puts the length
/// back.
///
/// ```dart
/// breakdownProposal(task: taxes, existing: const [], tree: tree,
///     nowUtc: now, join: (p, s) => '$p · $s').toBatch().subtasks.length;
/// ```
Proposal breakdownProposal({
  required Occurrence task,
  required List<Subtask> existing,
  required BreakdownTree tree,
  required DateTime nowUtc,
  required String Function(String parent, String step) join,
}) {
  final live = [
    for (final s in existing)
      if (s.deletedAt == null) s,
  ];
  final last = live.fold<double>(
    0,
    (m, s) => s.sortOrder > m ? s.sortOrder : m,
  );
  final added = [
    for (final (i, leaf) in tree.leaves(join).indexed)
      Subtask(
        id: leaf.id,
        userId: task.userId,
        occurrenceId: task.id,
        title: leaf.title,
        durationMin: leaf.durationMin,
        sortOrder: last + i + 1,
        createdAt: nowUtc,
        updatedAt: nowUtc,
      ),
  ];
  final steps = [...live, ...added];
  final grown = stepsTotal(steps) == null
      ? task
      : setFollowSteps(task, steps, true).copyWith(updatedAt: nowUtc);
  return Proposal(
    userId: task.userId,
    before: _snapshot(task, nowUtc),
    edits: [
      ProposalEdit(
        id: breakdownEditId,
        change: ProposalChange.steps,
        before: _dot(task),
        after: _dot(grown),
        occurrences: [if (grown != task) grown],
        subtasks: added,
        removable: false,
      ),
    ],
  );
}

DaySnapshot _snapshot(Occurrence task, DateTime nowUtc) => DaySnapshot(
  generatedAtUtc: nowUtc,
  wakeUtc: nowUtc,
  bedUtc: nowUtc,
  dots: [?_dot(task)],
  inboxCount: 0,
);

/// The task as a snapshot dot; none for an Inbox task (no start).
SnapshotDot? _dot(Occurrence o) {
  final start = o.startUtc;
  if (start == null) return null;
  return SnapshotDot(
    id: o.id,
    title: o.title,
    startUtc: start,
    durationMin: o.durationMin,
    colorKey: o.colorKey,
    iconKey: o.iconKey,
    done: false,
  );
}
