import 'dart:async';

import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/domain/entities/subtask.dart';
import 'package:dottoday/shared/duration/duration_chips.dart';
import 'package:dottoday/shared/duration/step_length_chip.dart';
import 'package:dottoday/shared/menus/context_menu.dart';
import 'package:dottoday/shared/sheets/dot_alert.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';

/// One subtask (docs/09 M3f.3, R-09): the tick (this day only), the title
/// — tap to rename it — a "now" tag on the next one while the task
/// runs, its length chip (M10.3), × to remove, and a drag handle (reorder; screen readers and
/// keyboards get Move up / Move down).
class SubtaskRow extends StatefulWidget {
  const SubtaskRow({
    required this.subtask,
    required this.index,
    required this.now,
    required this.onTick,
    required this.onRename,
    required this.onRemove,
    this.onUp,
    this.onDown,
    this.onLength,
    this.editing = true,
    this.quiet = false,
    super.key,
  });

  /// Option D's editor (owner, M19.4): the step's time as text only; Set
  /// a time and Delete in its ⋯, and a long press drags it. Move up and
  /// Move down stay for keyboards and screen readers.
  final bool quiet;

  /// The editor's row (rename, remove, reorder); otherwise a tap anywhere
  /// ticks it (the task sheet, `TaskSheet` "tap to tick").
  final bool editing;

  final Subtask subtask;

  /// Its place, for the drag handle.
  final int index;

  /// The next one while the task runs.
  final bool now;
  final VoidCallback onTick;
  final ValueChanged<String> onRename;
  final VoidCallback onRemove;
  final VoidCallback? onUp;
  final VoidCallback? onDown;

  /// The editor's length chip (11 B2, M10.3); null hides it.
  final ValueChanged<int?>? onLength;

  @override
  State<SubtaskRow> createState() => _SubtaskRowState();
}

class _SubtaskRowState extends State<SubtaskRow> {
  /// Tap the title: a small dialog to rename it (Enter or Rename).
  Future<void> _rename() async {
    final l10n = context.l10n;
    final name = await showTextAlert(
      context,
      title: l10n.subtaskRenameTitle,
      initial: widget.subtask.title,
      action: l10n.subtaskRenameSave,
      cancel: l10n.editorCancel,
    );
    final title = name?.trim() ?? '';
    if (title.isNotEmpty && title != widget.subtask.title) {
      widget.onRename(title);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final l10n = context.l10n;
    final s = widget.subtask;
    final row = Semantics(
      customSemanticsActions: {
        CustomSemanticsAction(label: l10n.subtaskMoveUp): ?widget.onUp,
        CustomSemanticsAction(label: l10n.subtaskMoveDown): ?widget.onDown,
      },
      child: Row(
        children: [
          Checkbox(
            value: s.done,
            semanticLabel: s.title,
            onChanged: (_) => widget.onTick(),
          ),
          Expanded(
            child: widget.editing
                ? _title(t, l10n)
                : InkWell(onTap: widget.onTick, child: _label(t)),
          ),
          if (widget.now)
            Text(
              l10n.subtaskNow,
              style: t.styles.rowMeta.copyWith(color: t.colors.accentInk),
            ),
          if (widget.editing && widget.quiet) ..._quiet(t, l10n),
          if (widget.editing && !widget.quiet) ...[
            if (widget.onLength case final onLength?)
              StepLengthChip(
                minutes: s.durationMin,
                title: s.title,
                onChanged: onLength,
              ),
            IconButton(
              tooltip: l10n.subtaskRemove(s.title),
              onPressed: widget.onRemove,
              icon: DotIcon(DotGlyphs.close, color: t.colors.muted),
            ),
            ReorderableDragStartListener(
              index: widget.index,
              child: Semantics(
                label: l10n.subtaskReorder(s.title),
                excludeSemantics: true,
                child: SizedBox.square(
                  dimension: DotTouch.android,
                  child: Center(
                    child: DotIcon(DotGlyphs.dragHandle, color: t.colors.muted),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
    if (!widget.editing || !widget.quiet) return row;
    return ReorderableDelayedDragStartListener(index: widget.index, child: row);
  }

  /// The quiet row's end: the time, if any, and ⋯ with Set a time and
  /// Delete.
  List<Widget> _quiet(DotTheme t, AppLocalizations l10n) {
    final s = widget.subtask;
    final minutes = s.durationMin;
    return [
      if (minutes != null)
        Text(
          formatDurationShort(l10n, minutes),
          style: t.styles.rowMeta.copyWith(color: t.colors.muted),
        ),
      DotMenuButton<VoidCallback>(
        tooltip: l10n.subtaskMenu(s.title),
        icon: DotIcon(DotGlyphs.more, color: t.colors.muted),
        onSelected: (run) => run(),
        // The row's context: the menu's is gone once an item is picked.
        entries: () => [
          if (widget.onLength case final onLength?)
            ContextMenuEntry(
              value: () => unawaited(
                pickStepLength(context, minutes: minutes, onChanged: onLength),
              ),
              label: l10n.subtaskSetTime,
            ),
          ContextMenuEntry(value: widget.onRemove, label: l10n.sheetDelete),
        ],
      ),
    ];
  }

  Widget _title(DotTheme t, AppLocalizations l10n) => Semantics(
    onTapHint: l10n.subtaskRename(widget.subtask.title),
    child: InkWell(onTap: () => unawaited(_rename()), child: _label(t)),
  );

  Widget _label(DotTheme t) {
    final s = widget.subtask;
    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: DotTouch.android),
      child: Align(
        alignment: AlignmentDirectional.centerStart,
        child: Text(
          s.title,
          style: t.styles.body.copyWith(
            color: s.done ? t.colors.muted : null,
            decoration: s.done ? TextDecoration.lineThrough : null,
          ),
        ),
      ),
    );
  }
}
