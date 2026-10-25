import 'package:dottoday/domain/thinking/model_output.dart';
import 'package:dottoday/domain/thinking/thinking_backend.dart';
import 'package:dottoday/domain/thinking/thinking_proposals.dart';

/// One step in a Break it down proposal (11 B1): its own length, or the
/// sum of its sub-steps once it has some.
final class StepNode {
  const StepNode({
    required this.id,
    required this.title,
    this.durationMin,
    this.children = const [],
  });

  /// A UUID v7: the subtask id Accept writes for a leaf.
  final String id;
  final String title;
  final int? durationMin;
  final List<StepNode> children;

  /// The sub-steps' sum when there are any, else [durationMin].
  int? get length {
    if (children.isEmpty) return durationMin;
    final lengths = [for (final c in children) ?c.length];
    return lengths.isEmpty ? null : lengths.fold<int>(0, (a, b) => a + b);
  }

  StepNode copyWith({
    String? title,
    int? Function()? durationMin,
    List<StepNode>? children,
  }) => StepNode(
    id: id,
    title: title ?? this.title,
    durationMin: durationMin == null ? this.durationMin : durationMin(),
    children: children ?? this.children,
  );
}

/// A leaf step as Accept writes it: flat, in order (B2's model has no
/// parent), a sub-step's title joined to its parent's.
typedef LeafStep = ({String id, String title, int? durationMin});

/// The editable breakdown behind the proposal sheet's mini thread: steps
/// with sub-steps to [BreakdownRequest.maxDepth] levels (the task is level
/// 0, its steps level 1). Immutable; every edit returns a new tree.
///
/// ```dart
/// final tree = BreakdownTree.of(proposal.steps, ids.newId);
/// tree.leaves((p, c) => '$p · $c'); // what Accept writes
/// ```
final class BreakdownTree {
  const BreakdownTree(this.steps);

  /// Top-level steps from a proposal, each with a fresh [newId].
  factory BreakdownTree.of(List<ProposedStep> steps, String Function() newId) =>
      BreakdownTree([for (final s in steps) _node(s, newId)]);

  final List<StepNode> steps;

  /// Sum of the steps that have a length; null when none has one.
  int? get total {
    final lengths = [for (final s in steps) ?s.length];
    return lengths.isEmpty ? null : lengths.fold<int>(0, (a, b) => a + b);
  }

  /// Level of step [id] (1 = top), or 0 when it isn't in the tree.
  int depthOf(String id) => _depth(steps, id, 1);

  /// Whether step [id] may be split again: its sub-steps would land at
  /// most at [BreakdownRequest.maxDepth].
  bool canSplit(String id) {
    final depth = depthOf(id);
    return depth > 0 && depth < BreakdownRequest.maxDepth;
  }

  /// Whether another top-level step fits the sheet.
  bool get canAdd => steps.length < BreakdownRequest.maxSteps;

  BreakdownTree add(StepNode step) =>
      canAdd ? BreakdownTree([...steps, step]) : this;

  BreakdownTree remove(String id) => BreakdownTree(_without(steps, id));

  BreakdownTree rename(String id, String title) =>
      _edit(id, (n) => n.copyWith(title: title));

  /// Sets a leaf's length; a step with sub-steps keeps their sum.
  BreakdownTree setLength(String id, int? minutes) =>
      _edit(id, (n) => n.copyWith(durationMin: () => minutes));

  /// Gives step [id] the sub-steps [into], when [canSplit] allows it.
  BreakdownTree split(
    String id,
    List<ProposedStep> into,
    String Function() newId,
  ) {
    if (!canSplit(id) || into.isEmpty) return this;
    return _edit(
      id,
      (n) => n.copyWith(children: [for (final s in into) _node(s, newId)]),
    );
  }

  /// Moves top-level step [from] to position [to] of the list without it
  /// (as `ReorderableListView.onReorderItem` reports).
  BreakdownTree move(int from, int to) {
    if (from < 0 || from >= steps.length) return this;
    final list = [...steps];
    final step = list.removeAt(from);
    list.insert(to.clamp(0, list.length), step);
    return BreakdownTree(list);
  }

  /// The steps Accept writes: leaves in order, empty titles dropped, a
  /// sub-step's title [join]ed to its parents' ("Enter income · Salary").
  List<LeafStep> leaves(String Function(String parent, String step) join) => [
    for (final s in steps) ..._leaves(s, null, join),
  ];

  /// Whether every step has a title (the template's empty ones must be
  /// filled before Accept).
  bool get complete => steps.isNotEmpty && _complete(steps);

  BreakdownTree _edit(String id, StepNode Function(StepNode) edit) =>
      BreakdownTree(_map(steps, id, edit));
}

StepNode _node(ProposedStep s, String Function() newId) =>
    StepNode(id: newId(), title: s.title, durationMin: s.durationMin);

int _depth(List<StepNode> nodes, String id, int level) {
  for (final n in nodes) {
    if (n.id == id) return level;
    final inner = _depth(n.children, id, level + 1);
    if (inner > 0) return inner;
  }
  return 0;
}

List<StepNode> _map(
  List<StepNode> nodes,
  String id,
  StepNode Function(StepNode) edit,
) => [
  for (final n in nodes)
    n.id == id ? edit(n) : n.copyWith(children: _map(n.children, id, edit)),
];

List<StepNode> _without(List<StepNode> nodes, String id) => [
  for (final n in nodes)
    if (n.id != id) n.copyWith(children: _without(n.children, id)),
];

bool _complete(List<StepNode> nodes) =>
    nodes.every((n) => n.title.trim().isNotEmpty && _complete(n.children));

Iterable<LeafStep> _leaves(
  StepNode n,
  String? parent,
  String Function(String, String) join,
) sync* {
  final title = n.title.trim();
  if (title.isEmpty) return;
  final joined = parent == null ? title : join(parent, title);
  // The title column's limit (docs/05): a deep join is cut, never refused.
  final full = joined.length <= ModelOutput.maxTitle
      ? joined
      : joined.substring(0, ModelOutput.maxTitle);
  if (n.children.isEmpty) {
    yield (id: n.id, title: full, durationMin: n.durationMin);
    return;
  }
  for (final c in n.children) {
    yield* _leaves(c, full, join);
  }
}
