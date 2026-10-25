import 'package:dottoday/domain/thinking/breakdown_tree.dart';
import 'package:dottoday/domain/thinking/thinking_proposals.dart';
import 'package:flutter_test/flutter_test.dart';

// Break it down's editable tree (11 B1, docs/09 M10.4): depth capped at 3,
// lengths summed upwards, leaves flattened for B2's flat step list.

String Function() _ids() {
  var n = 0;
  return () => 'id${n++}';
}

String _join(String p, String s) => '$p · $s';

const _taxes = [
  ProposedStep(title: 'Gather documents', durationMin: 10),
  ProposedStep(title: 'Log in to the portal', durationMin: 15),
  ProposedStep(title: 'Enter income', durationMin: 30),
];

void main() {
  test('total sums the steps; a step with sub-steps sums them', () {
    final ids = _ids();
    var tree = BreakdownTree.of(_taxes, ids);
    expect(tree.total, 55);
    final income = tree.steps[2].id;
    tree = tree.split(income, const [
      ProposedStep(title: 'Salary', durationMin: 20),
      ProposedStep(title: 'Freelance', durationMin: 20),
    ], ids);
    expect(tree.steps[2].length, 40);
    expect(tree.total, 65);
  });

  test('depth is capped at 3', () {
    final ids = _ids();
    var tree = BreakdownTree.of(_taxes, ids);
    final top = tree.steps.first.id;
    expect((tree.depthOf(top), tree.canSplit(top)), (1, true));
    tree = tree.split(top, const [ProposedStep(title: 'Find P60')], ids);
    final second = tree.steps.first.children.single.id;
    expect((tree.depthOf(second), tree.canSplit(second)), (2, true));
    tree = tree.split(second, const [ProposedStep(title: 'Check email')], ids);
    final third = tree.steps.first.children.single.children.single.id;
    expect((tree.depthOf(third), tree.canSplit(third)), (3, false));
    final again = tree.split(third, const [ProposedStep(title: 'x')], ids);
    expect(again.steps.first.children.single.children.single.children, isEmpty);
    expect(tree.depthOf('nope'), 0);
  });

  test(
    'leaves: in order, sub-steps joined to their parents, empty dropped',
    () {
      final ids = _ids();
      var tree = BreakdownTree.of(_taxes, ids);
      tree = tree
          .split(tree.steps[2].id, const [
            ProposedStep(title: 'Salary', durationMin: 20),
            ProposedStep(title: 'Freelance'),
          ], ids)
          .add(StepNode(id: ids(), title: '  '));
      final leaves = tree.leaves(_join);
      expect(leaves.map((l) => l.title), [
        'Gather documents',
        'Log in to the portal',
        'Enter income · Salary',
        'Enter income · Freelance',
      ]);
      expect(leaves.map((l) => l.durationMin), [10, 15, 20, null]);
      expect(tree.complete, isFalse, reason: 'the empty step needs a title');
    },
  );

  test('a deep joined title is cut to the column limit', () {
    final ids = _ids();
    final long = 'x' * 150;
    var tree = BreakdownTree.of([ProposedStep(title: long)], ids);
    tree = tree.split(tree.steps.single.id, [ProposedStep(title: long)], ids);
    expect(tree.leaves(_join).single.title.length, 200);
  });

  test('edits: rename, length, remove, move, add up to 7', () {
    final ids = _ids();
    var tree = BreakdownTree.of(_taxes, ids);
    final first = tree.steps.first.id;
    tree = tree.rename(first, 'Find papers').setLength(first, 5);
    expect(
      (tree.steps.first.title, tree.steps.first.durationMin),
      ('Find papers', 5),
    );
    tree = tree.setLength(first, null);
    expect(tree.steps.first.durationMin, isNull);
    tree = tree.move(0, 2);
    expect(tree.steps.map((s) => s.title).last, 'Find papers');
    tree = tree.remove(first);
    expect(tree.steps, hasLength(2));
    for (var i = 0; i < 10; i++) {
      tree = tree.add(StepNode(id: ids(), title: 'More'));
    }
    expect(tree.steps, hasLength(7));
    expect(tree.canAdd, isFalse);
    expect(tree.complete, isTrue);
  });
}
