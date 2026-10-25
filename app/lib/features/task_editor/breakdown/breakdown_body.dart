import 'dart:async';

import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/domain/thinking/breakdown_tree.dart';
import 'package:dottoday/domain/thinking/thinking_proposals.dart';
import 'package:dottoday/features/task_editor/breakdown/breakdown_rows.dart';
import 'package:flutter/material.dart';

/// Asks for sub-steps of [step] at [depth] (the model, else rules).
typedef StepSplitter =
    Future<List<ProposedStep>?> Function(StepNode step, int depth);

/// Break it down's mini thread inside the proposal card
/// (`B-ios-break-it-down`, docs/09 M10.4): numbered steps in the task's
/// colour, each with its title (editable), a length chip and a chevron;
/// open a step to see its sub-steps ("depth 2 of 3"), split it again or
/// remove it; drag (or Move up / down) to reorder; "Add a step" at the
/// end. Every edit goes to [onChanged]; nothing is written here.
class BreakdownBody extends StatefulWidget {
  const BreakdownBody({
    required this.initial,
    required this.color,
    required this.onChanged,
    required this.split,
    required this.newId,
    super.key,
  });

  final BreakdownTree initial;
  final TaskColor color;
  final ValueChanged<BreakdownTree> onChanged;
  final StepSplitter split;
  final String Function() newId;

  @override
  State<BreakdownBody> createState() => _BreakdownBodyState();
}

class _BreakdownBodyState extends State<BreakdownBody> {
  late BreakdownTree _tree = widget.initial;

  final _open = <String>{};
  final _splitting = <String>{};

  void _edit(BreakdownTree next) {
    setState(() => _tree = next);
    widget.onChanged(next);
  }

  Future<void> _split(StepNode step) async {
    final depth = _tree.depthOf(step.id);
    setState(() => _splitting.add(step.id));
    final into = await widget.split(step, depth);
    if (!mounted) return;
    setState(() => _splitting.remove(step.id));
    if (into == null || into.isEmpty) return;
    _edit(_tree.split(step.id, into, widget.newId));
  }

  @override
  Widget build(BuildContext context) {
    final steps = _tree.steps;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ReorderableListView(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          buildDefaultDragHandles: false,
          onReorderItem: (from, to) => _edit(_tree.move(from, to)),
          children: [
            for (final (i, s) in steps.indexed)
              StepTile(
                key: ValueKey(s.id),
                step: s,
                index: i,
                depth: 1,
                tree: _tree,
                color: widget.color,
                open: _open,
                splitting: _splitting,
                onToggle: (id) => setState(
                  () => _open.contains(id) ? _open.remove(id) : _open.add(id),
                ),
                onEdit: _edit,
                onSplit: (step) => unawaited(_split(step)),
                onUp: i == 0 ? null : () => _edit(_tree.move(i, i - 1)),
                onDown: i == steps.length - 1
                    ? null
                    : () => _edit(_tree.move(i, i + 1)),
              ),
          ],
        ),
        if (_tree.canAdd) _AddStep(onAdd: _add),
      ],
    );
  }

  void _add() => _edit(_tree.add(StepNode(id: widget.newId(), title: '')));
}

/// "+ Add a step": a dashed pill under the thread.
class _AddStep extends StatelessWidget {
  const _AddStep({required this.onAdd});

  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    return Padding(
      padding: const EdgeInsetsDirectional.only(
        start: DotTouch.android + DotSpace.s,
        top: DotSpace.s,
      ),
      child: Align(
        alignment: AlignmentDirectional.centerStart,
        child: OutlinedButton.icon(
          onPressed: onAdd,
          style: OutlinedButton.styleFrom(
            shape: dotChipShape(context),
            side: BorderSide(color: t.colors.outline),
            foregroundColor: t.colors.muted,
          ),
          icon: DotIcon(
            DotGlyphs.add,
            color: t.colors.muted,
            size: DotSize.rowIcon,
          ),
          label: Text(context.l10n.breakdownAddStep),
        ),
      ),
    );
  }
}
