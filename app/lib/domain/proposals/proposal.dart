import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:dottoday/domain/entities/subtask.dart';
import 'package:dottoday/domain/snapshot/day_snapshot.dart';
import 'package:dottoday/domain/writes/write_batch.dart';

/// What one proposed edit does to a dot, for its chip (`B-ios-rebalance`:
/// "shifted +25 min", "shrunk to 45 min", "moved to tomorrow 9:00",
/// "pinned · untouched").
enum ProposalChange {
  /// Same length, new start.
  shifted,

  /// Same start, new length (or both, when the length changed).
  resized,

  /// Leaves this day for [ProposalEdit.movedToUtc] (or the Inbox).
  movedToDay,

  /// A new dot.
  added,

  /// Shown so the user sees why others moved; writes nothing.
  untouched,

  /// The dot keeps its place and gains steps (Break it down, 11 B1).
  steps,
}

/// One line of the proposal's change list: the dot now ([before]) and as
/// proposed ([after]), and the rows Accept writes for it.
final class ProposalEdit {
  const ProposalEdit({
    required this.id,
    required this.change,
    this.before,
    this.after,
    this.movedToUtc,
    this.occurrences = const [],
    this.subtasks = const [],
    this.removable = true,
  });

  /// Stable within a proposal (a key, and what [Proposal.without] names).
  final String id;
  final ProposalChange change;
  final SnapshotDot? before;

  /// Null when the dot leaves this day.
  final SnapshotDot? after;

  /// Where a [ProposalChange.movedToDay] dot goes; null = the Inbox.
  final DateTime? movedToUtc;

  /// Rows written on Accept: new versions of existing rows or new rows.
  final List<Occurrence> occurrences;
  final List<Subtask> subtasks;

  /// Whether the user may drop this edit with × ([untouched] lines can't).
  final bool removable;

  /// Minutes the start moved ([shifted]) or the length changed
  /// ([resized]); 0 otherwise.
  int get deltaMin {
    final b = before;
    final a = after;
    if (b == null || a == null) return 0;
    return switch (change) {
      ProposalChange.shifted => a.startUtc.difference(b.startUtc).inMinutes,
      ProposalChange.resized => a.durationMin - b.durationMin,
      _ => 0,
    };
  }
}

/// B3 (11 §0): a model- or rule-made change to a day, shown by
/// `ProposalSheet` and written only on Accept (CLAUDE.md §11 "Proposal
/// rule"). [before] is the day as it is, in the one snapshot format (B5);
/// [after] is derived from it and the edits still in the list, so dropping
/// an edit with × redraws the proposed thread without it.
///
/// ```dart
/// final p = Proposal(userId: me, before: today, edits: [shiftEmail]);
/// p.after.dots;          // the proposed thread
/// p.without(shiftEmail.id).toBatch().isEmpty; // true
/// ```
final class Proposal {
  const Proposal({
    required this.userId,
    required this.before,
    required this.edits,
  });

  final String userId;
  final DaySnapshot before;
  final List<ProposalEdit> edits;

  /// [before] with every edit applied, earliest first.
  DaySnapshot get after {
    final byBefore = {
      for (final e in edits)
        if (e.before != null) e.before!.id: e,
    };
    final dots = [
      for (final d in before.dots)
        if (byBefore[d.id] case final e?) ?e.after else d,
      for (final e in edits)
        if (e.before == null) ?e.after,
    ]..sort((a, b) => a.startUtc.compareTo(b.startUtc));
    return DaySnapshot(
      generatedAtUtc: before.generatedAtUtc,
      wakeUtc: before.wakeUtc,
      bedUtc: before.bedUtc,
      dots: List.unmodifiable(dots),
      inboxCount: before.inboxCount,
      dayDone: before.dayDone,
      dayTotal: before.dayTotal,
    );
  }

  /// This proposal without edit [id], if the user may drop it.
  Proposal without(String id) => Proposal(
    userId: userId,
    before: before,
    edits: [
      for (final e in edits)
        if (e.id != id || !e.removable) e,
    ],
  );

  /// The same day with [edits] replaced (an editable body, e.g. the
  /// breakdown's steps).
  Proposal withEdits(List<ProposalEdit> edits) =>
      Proposal(userId: userId, before: before, edits: edits);

  /// Whether Accept would write anything.
  bool get isEmpty => toBatch().isEmpty;

  /// Every row the remaining edits write, as one batch (one transaction,
  /// one Undo). A row named by two edits is written once, as the later
  /// edit has it.
  WriteBatch toBatch() {
    final occurrences = <String, Occurrence>{};
    final subtasks = <String, Subtask>{};
    for (final e in edits) {
      for (final o in e.occurrences) {
        occurrences[o.id] = o;
      }
      for (final s in e.subtasks) {
        subtasks[s.id] = s;
      }
    }
    return WriteBatch(
      userId: userId,
      occurrences: occurrences.values.toList(),
      subtasks: subtasks.values.toList(),
    );
  }
}
