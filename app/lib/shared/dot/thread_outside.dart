import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/shared/dot/task_row.dart';
import 'package:dottoday/shared/dot/thread_axis.dart';
import 'package:dottoday/shared/dot/thread_models.dart';
import 'package:flutter/material.dart';

/// The folded "outside hours" zone (docs/02 F1.15, R-17): one row, "2 tasks
/// before Wake Up" above the sun cap or "1 task after Bedtime" below the
/// moon cap, that unfolds into the tasks' own rows. Folded by default so
/// the day keeps its shape; unfolded when it holds the live task.
class OutsideRow extends StatefulWidget {
  const OutsideRow({
    required this.zone,
    required this.taskRow,
    this.reveal = false,
    super.key,
  });

  final ThreadOutside zone;

  /// One of its tasks is picked (multi-select or the keyboard's ↑↓):
  /// unfold so the pick shows.
  final bool reveal;

  /// Builds a task's row as the thread does (open, done, drag, select).
  final Widget Function(ThreadTask task) taskRow;

  @override
  State<OutsideRow> createState() => _OutsideRowState();
}

class _OutsideRowState extends State<OutsideRow> {
  late bool _open = widget.zone.open || widget.reveal;

  @override
  void didUpdateWidget(OutsideRow old) {
    super.didUpdateWidget(old);
    // The live task never hides: a zone it moves into unfolds.
    if (widget.zone.open && !old.zone.open) _open = true;
    if (widget.reveal && !old.reveal) _open = true;
  }

  @override
  Widget build(BuildContext context) {
    final zone = widget.zone;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _header(context),
        if (_open)
          for (final t in zone.tasks) widget.taskRow(t),
      ],
    );
  }

  Widget _header(BuildContext context) {
    final t = DotTheme.of(context);
    final l10n = context.l10n;
    final n = widget.zone.tasks.length;
    final label = widget.zone.bedtime
        ? l10n.threadOutsideAfter(n)
        : l10n.threadOutsideBefore(n);
    void toggle() => setState(() => _open = !_open);
    return Semantics(
      button: true,
      expanded: _open,
      label: label,
      onTap: toggle,
      excludeSemantics: true,
      child: InkWell(
        onTap: toggle,
        borderRadius: BorderRadius.circular(DotRadii.card),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: DotTouch.android),
          child: ThreadRowFrame(
            piece: const FreePiece(),
            dot: DotIcon(
              _open ? DotGlyphs.chevronUp : DotGlyphs.chevronDown,
              color: t.colors.muted,
              size: DotSize.rowIcon,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: DotSpace.s),
              child: Text(label, style: t.styles.stripWeekday),
            ),
          ),
        ),
      ),
    );
  }
}
