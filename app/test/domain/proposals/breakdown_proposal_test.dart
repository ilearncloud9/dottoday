import 'package:dottoday/domain/proposals/breakdown_proposal.dart';
import 'package:dottoday/domain/proposals/proposal.dart';
import 'package:dottoday/domain/thinking/breakdown_tree.dart';
import 'package:dottoday/domain/thinking/thinking_proposals.dart';
import 'package:flutter_test/flutter_test.dart';

import '../fixtures.dart';

// Break it down as a proposal (docs/09 M10.4): the leaves become the
// task's steps after the ones it has, and the task grows to their sum.

void main() {
  var n = 0;
  String id() => '01928c3e-0000-7000-8000-0000000ff0${n++}';
  final task = occurrenceFixture().copyWith(durationMin: 30);

  test('steps after the existing ones; the dot grows to fit', () {
    final existing = subtaskFixture().copyWith(
      occurrenceId: task.id,
      durationMin: 5,
      sortOrder: 3,
    );
    final tree = BreakdownTree.of(const [
      ProposedStep(title: 'Clear', durationMin: 10),
      ProposedStep(title: 'Wipe', durationMin: 20),
    ], id);
    final p = breakdownProposal(
      task: task,
      existing: [existing],
      tree: tree,
      nowUtc: t1,
      join: (a, b) => '$a · $b',
    );
    final edit = p.edits.single;
    expect(
      (edit.id, edit.change, edit.removable),
      (breakdownEditId, ProposalChange.steps, false),
    );
    final batch = p.toBatch();
    expect(batch.subtasks.map((s) => (s.title, s.sortOrder, s.occurrenceId)), [
      ('Clear', 4.0, task.id),
      ('Wipe', 5.0, task.id),
    ]);
    final grown = batch.occurrences.single;
    expect((grown.durationFromSteps, grown.durationMin), (true, 35));
    expect(edit.after!.durationMin, 35);
    expect(edit.before!.durationMin, 30);
  });

  test('no lengths: steps only, the task keeps its length', () {
    final tree = BreakdownTree.of(const [ProposedStep(title: 'Start')], id);
    final p = breakdownProposal(
      task: task,
      existing: const [],
      tree: tree,
      nowUtc: t1,
      join: (a, b) => '$a · $b',
    );
    expect(p.toBatch().occurrences, isEmpty);
    expect(p.toBatch().subtasks, hasLength(1));
  });

  test('an Inbox task has no dot but still gets its steps', () {
    final inbox = task.copyWith(startUtc: null);
    final tree = BreakdownTree.of(const [ProposedStep(title: 'Start')], id);
    final p = breakdownProposal(
      task: inbox,
      existing: const [],
      tree: tree,
      nowUtc: t1,
      join: (a, b) => '$a · $b',
    );
    expect(p.before.dots, isEmpty);
    expect(p.toBatch().subtasks, hasLength(1));
  });
}
