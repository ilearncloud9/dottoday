import 'dart:math' as math;

import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/domain/thinking/breakdown_tree.dart';
import 'package:dottoday/domain/thinking/thinking_backend.dart';
import 'package:dottoday/shared/duration/step_length_chip.dart';
import 'package:dottoday/shared/text/system_text_menu.dart';
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
    final total = widget.tree.total;
    final share = total == null || total == 0 || s.length == null
        ? null
        : s.length! / total;
    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: DotSize.stepRow),
      child: Row(
        spacing: DotSpace.s,
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
            share: share,
          ),
          Expanded(
            child: TextField(
              contextMenuBuilder: systemTextMenu,
              controller: _title,
              style: top ? t.styles.chip : t.styles.body,
              textCapitalization: TextCapitalization.sentences,
              // A long title wraps rather than being cut (E-R2-23 rows).
              minLines: 1,
              maxLines: 3,
              textInputAction: TextInputAction.done,
              maxLength: 200,
              // A title to edit, underlined as on the board (E-R2-23).
              decoration: InputDecoration(
                hintText: l10n.breakdownStepHint(widget.index + 1),
                border: UnderlineInputBorder(
                  borderSide: BorderSide(color: t.colors.hairline),
                ),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: t.colors.hairline),
                ),
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
      ),
    );
  }

  /// Sub-steps, "depth 2 of 3", Break this down and Remove step.
  Widget _inside(BuildContext context) {
    final t = DotTheme.of(context);
    final l10n = context.l10n;
    final s = widget.step;
    final tree = widget.tree;
    final splitting = widget.splitting.contains(s.id);
    // The opened step's area, tinted (E-R2-23 "a step opened").
    return DecoratedBox(
      decoration: BoxDecoration(
        color: t.colors.sunk,
        borderRadius: BorderRadius.circular(DotRadii.tile),
      ),
      child: Padding(
        padding: EdgeInsetsDirectional.only(
          start: widget.depth == 1 ? DotTouch.android : DotSpace.xl,
          end: DotSpace.xs,
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
            Wrap(
              spacing: DotSpace.s,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                if (s.children.isNotEmpty)
                  Text(
                    l10n.breakdownDepth(
                      widget.depth + 1,
                      BreakdownRequest.maxDepth,
                    ),
                    style: t.styles.rowMeta.copyWith(color: t.colors.muted),
                  ),
                if (splitting)
                  const SizedBox.square(
                    dimension: DotSize.rowIcon,
                    // iOS's activity indicator on Apple platforms (native pass).
                    child: CircularProgressIndicator.adaptive(strokeWidth: 2),
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
      ),
    );
  }

  String _label(AppLocalizations l10n) {
    final title = widget.step.title.trim();
    return title.isEmpty ? l10n.breakdownStepHint(widget.index + 1) : title;
  }
}

/// A step's dot (E-R2-23): a ring in the task's colour whose arc is
/// the step's [share] of the task's length, with its [number] inside
/// (top-level) or a small ring (sub-steps).
class StepDot extends StatelessWidget {
  const StepDot({
    required this.color,
    required this.number,
    required this.share,
    super.key,
  });

  final TaskColor color;
  final int? number;

  /// The step's part of the whole (0 to 1); null draws a full ring.
  final double? share;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final swatch = t.tasks[color];
    final top = number != null;
    final size = top ? DotSize.stepRing : DotSize.pickerDot;
    return ExcludeSemantics(
      child: SizedBox.square(
        dimension: size,
        child: CustomPaint(
          painter: _ShareRing(
            track: swatch.color.withValues(alpha: TaskAlpha.upcoming),
            arc: swatch.color,
            share: top ? share : 1,
          ),
          child: top
              ? Center(
                  child: Text(
                    MaterialLocalizations.of(context).formatDecimal(number!),
                    style: t.styles.rowMeta.copyWith(color: swatch.ink),
                  ),
                )
              : null,
        ),
      ),
    );
  }
}

/// The step ring: a faint full track and the arc of the step's share,
/// from twelve o'clock.
final class _ShareRing extends CustomPainter {
  const _ShareRing({
    required this.track,
    required this.arc,
    required this.share,
  });

  final Color track;
  final Color arc;
  final double? share;

  @override
  void paint(Canvas canvas, Size size) {
    const w = DotSize.smallDotOutline;
    final rect = (Offset.zero & size).deflate(w / 2);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = w
      ..strokeCap = StrokeCap.round;
    canvas.drawOval(rect, paint..color = track);
    final s = (share ?? 1).clamp(0.0, 1.0);
    if (s <= 0) return;
    canvas.drawArc(
      rect,
      -math.pi / 2,
      s * 2 * math.pi,
      false,
      paint..color = arc,
    );
  }

  @override
  bool shouldRepaint(_ShareRing old) =>
      old.track != track || old.arc != arc || old.share != share;
}
