import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/domain/thinking/breakdown_tree.dart';
import 'package:dottoday/domain/thinking/thinking_backend.dart';
import 'package:dottoday/shared/duration/step_length_chip.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';

/// One step of the mini thread and, when open, its sub-steps and actions
/// (`B-ios-break-it-down`). Top-level steps (depth 1) carry their number
/// and a drag handle; sub-steps a small ring.
class StepTile extends StatefulWidget {
  const StepTile({
    required this.step,
    required this.index,
    required this.depth,
    required this.tree,
    required this.color,
    required this.open,
    required this.splitting,
    required this.onToggle,
    required this.onEdit,
    required this.onSplit,
    this.onUp,
    this.onDown,
    super.key,
  });

  final StepNode step;

  /// Place among its siblings (the number and the drag handle).
  final int index;
  final int depth;

  /// The whole tree, so an edit returns the next tree.
  final BreakdownTree tree;
  final TaskColor color;
  final Set<String> open;
  final Set<String> splitting;
  final ValueChanged<String> onToggle;
  final ValueChanged<BreakdownTree> onEdit;
  final ValueChanged<StepNode> onSplit;
  final VoidCallback? onUp;
  final VoidCallback? onDown;

  @override
  State<StepTile> createState() => _StepTileState();
}

class _StepTileState extends State<StepTile> {
  late final _title = TextEditingController(text: widget.step.title);

  @override
  void dispose() {
    _title.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final s = widget.step;
    final open = widget.open.contains(s.id);
    return Semantics(
      customSemanticsActions: {
        CustomSemanticsAction(label: l10n.subtaskMoveUp): ?widget.onUp,
        CustomSemanticsAction(label: l10n.subtaskMoveDown): ?widget.onDown,
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [_row(context, open), if (open) _inside(context)],
      ),
    );
  }

  Widget _row(BuildContext context, bool open) {
    final t = DotTheme.of(context);
    final l10n = context.l10n;
    final s = widget.step;
    final top = widget.depth == 1;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: DotSpace.xs,
      children: [
        if (top)
          ReorderableDragStartListener(
            index: widget.index,
            child: Semantics(
              label: l10n.subtaskReorder(_label(l10n)),
              excludeSemantics: true,
              child: SizedBox.square(
                dimension: DotTouch.android,
                child: Center(
                  child: DotIcon(DotGlyphs.dragHandle, color: t.colors.muted),
                ),
              ),
            ),
          ),
        StepDot(
          color: widget.color,
          number: top ? widget.index + 1 : null,
          minutes: s.length,
        ),
        Expanded(
          child: TextField(
            controller: _title,
            style: top ? t.styles.rowTitle : t.styles.body,
            textCapitalization: TextCapitalization.sentences,
            maxLength: 200,
            decoration: InputDecoration(
              hintText: l10n.breakdownStepHint(widget.index + 1),
              border: InputBorder.none,
              counterText: '',
              isDense: true,
            ),
            onChanged: (v) => widget.onEdit(widget.tree.rename(s.id, v)),
          ),
        ),
        StepLengthChip(
          minutes: s.length,
          title: _label(l10n),
          onChanged: s.children.isEmpty
              ? (m) => widget.onEdit(widget.tree.setLength(s.id, m))
              : null,
        ),
        IconButton(
          tooltip: l10n.breakdownShow(_label(l10n)),
          onPressed: () => widget.onToggle(s.id),
          icon: DotIcon(
            open ? DotGlyphs.chevronUp : DotGlyphs.chevronDown,
            color: t.colors.muted,
            size: DotSize.rowIcon,
          ),
        ),
      ],
    );
  }

  /// Sub-steps, "depth 2 of 3", Break this down and Remove step.
  Widget _inside(BuildContext context) {
    final t = DotTheme.of(context);
    final l10n = context.l10n;
    final s = widget.step;
    final tree = widget.tree;
    final splitting = widget.splitting.contains(s.id);
    return Padding(
      padding: EdgeInsetsDirectional.only(
        start: widget.depth == 1 ? DotTouch.android + DotSpace.xl : DotSpace.xl,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final (i, c) in s.children.indexed)
            StepTile(
              key: ValueKey(c.id),
              step: c,
              index: i,
              depth: widget.depth + 1,
              tree: tree,
              color: widget.color,
              open: widget.open,
              splitting: widget.splitting,
              onToggle: widget.onToggle,
              onEdit: widget.onEdit,
              onSplit: widget.onSplit,
            ),
          if (s.children.isNotEmpty)
            Text(
              l10n.breakdownDepth(widget.depth + 1, BreakdownRequest.maxDepth),
              style: t.styles.rowMeta.copyWith(color: t.colors.muted),
            ),
          Wrap(
            spacing: DotSpace.s,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              if (splitting)
                const SizedBox.square(
                  dimension: DotSize.rowIcon,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              else if (tree.canSplit(s.id) &&
                  s.children.isEmpty &&
                  s.title.trim().isNotEmpty)
                TextButton(
                  onPressed: () => widget.onSplit(s),
                  child: Text(l10n.breakdownSplit),
                ),
              TextButton(
                onPressed: () => widget.onEdit(tree.remove(s.id)),
                child: Text(l10n.breakdownRemove),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _label(AppLocalizations l10n) {
    final title = widget.step.title.trim();
    return title.isEmpty ? l10n.breakdownStepHint(widget.index + 1) : title;
  }
}

/// A step's dot in the mini thread: a ring in the task's colour with its
/// [number] (top-level) or a small dot (sub-steps), and under it a
/// segment as long as the step, as on the thread.
class StepDot extends StatelessWidget {
  const StepDot({
    required this.color,
    required this.number,
    required this.minutes,
    super.key,
  });

  final TaskColor color;
  final int? number;
  final int? minutes;

  /// Segment length per minute and its bounds (a 40 min step ≈ the render).
  static const double _perMinute = 0.6;
  static const double _minSegment = DotSpace.s;
  static const double _maxSegment = DotSpace.xxl * 2;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final swatch = t.tasks[color];
    final size = number == null ? DotSize.pickerDot : DotSize.macRowDot;
    final m = minutes;
    final segment = m == null
        ? _minSegment
        : (m * _perMinute).clamp(_minSegment, _maxSegment);
    return ExcludeSemantics(
      child: Padding(
        padding: const EdgeInsets.only(top: DotSpace.s),
        child: Column(
          children: [
            Container(
              width: size,
              height: size,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: swatch.color,
                  width: DotSize.smallDotOutline,
                ),
              ),
              child: number == null
                  ? null
                  : Text(
                      MaterialLocalizations.of(context).formatDecimal(number!),
                      style: t.styles.rowMeta.copyWith(color: swatch.ink),
                    ),
            ),
            Container(
              width: DotSize.segment,
              height: segment,
              decoration: BoxDecoration(
                color: swatch.color.withValues(alpha: TaskAlpha.upcoming),
                borderRadius: const BorderRadius.all(
                  Radius.circular(DotRadii.pill),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
