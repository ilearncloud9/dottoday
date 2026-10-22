import 'package:dottoday/core/clock/clock_provider.dart';
import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/data/trash/trash_providers.dart';
import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:dottoday/domain/writes/write_batch.dart';
import 'package:dottoday/features/timeline/widgets/day_actions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Delete (confirmed) · Move to inbox · Save (`A-mac-editor`).
class EditorFooter extends ConsumerWidget {
  const EditorFooter({
    required this.task,
    required this.onSave,
    required this.onLeft,
    required this.beforeLeave,
    super.key,
  });

  /// After Delete or Move to inbox: the task is gone from here.
  final VoidCallback onLeft;

  /// The draft as it stands.
  final Occurrence task;
  final VoidCallback onSave;

  /// Called before Delete or Move to inbox write, so the editor's own
  /// autosave doesn't put the old row back on close.
  final VoidCallback beforeLeave;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = DotTheme.of(context);
    final l10n = context.l10n;
    // Wrap, not Row: at 390 pt and large text the three don't fit a line.
    return Wrap(
      spacing: DotSpace.s,
      runSpacing: DotSpace.s,
      alignment: WrapAlignment.spaceBetween,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        IconButton.outlined(
          tooltip: l10n.editorDelete,
          onPressed: () => _delete(context, ref),
          icon: DotIcon(DotGlyphs.trash, color: t.colors.text),
        ),
        if (task.startUtc != null)
          OutlinedButton(
            onPressed: () => _toInbox(context, ref),
            child: Text(l10n.editorMoveToInbox),
          ),
        FilledButton(onPressed: onSave, child: Text(l10n.editorSave)),
      ],
    );
  }

  /// Typed confirmation (03 §3.4), then Trash with Undo (R-11).
  Future<void> _delete(BuildContext context, WidgetRef ref) async {
    final l10n = context.l10n;
    final messenger = ScaffoldMessenger.of(context);
    final undo = ref.read(undoServiceProvider);
    final trash = ref.read(trashServiceProvider);
    final sure = await showDialog<bool>(
      context: context,
      builder: (dialog) => AlertDialog(
        title: Text(l10n.editorDeleteConfirm(task.title)),
        content: Text(l10n.editorDeleteBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialog).pop(false),
            child: Text(l10n.editorCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialog).pop(true),
            child: Text(l10n.editorDelete),
          ),
        ],
      ),
    );
    if (sure != true) return;
    beforeLeave();
    final result = await trash.trashOccurrences(task.userId, {task.id});
    onLeft();
    reportUndoable(
      messenger,
      l10n,
      undo,
      result,
      message: (_) => l10n.snackDeleted(task.title),
      tokenOf: (token) => token,
    );
  }

  Future<void> _toInbox(BuildContext context, WidgetRef ref) async {
    final l10n = context.l10n;
    final messenger = ScaffoldMessenger.of(context);
    final undo = ref.read(undoServiceProvider);
    final now = ref.read(clockProvider).nowUtc();
    beforeLeave();
    final row = task.copyWith(startUtc: null, updatedAt: now);
    final result = await undo.applyUndoable(
      WriteBatch(userId: task.userId, occurrences: [row]),
    );
    onLeft();
    reportUndoable(
      messenger,
      l10n,
      undo,
      result,
      message: (_) => l10n.snackMovedToInbox(task.title),
      tokenOf: (token) => token,
    );
  }
}
