import 'package:dottoday/core/clock/clock_provider.dart';
import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/data/trash/trash_providers.dart';
import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:dottoday/domain/writes/write_batch.dart';
import 'package:dottoday/features/timeline/widgets/day_actions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// An editor's two ways out (`A-mac-editor` footer; option D's ⋯ and More
/// card, ED-086): Delete (confirmed) and Move to inbox, each with Undo.
final class EditorLeave {
  const EditorLeave({
    required this.task,
    required this.onLeft,
    required this.beforeLeave,
    this.scopedDelete,
  });

  /// The draft as it stands.
  final Occurrence task;

  /// After Delete or Move to inbox: the task is gone from here.
  final VoidCallback onLeft;

  /// Called before Delete or Move to inbox write, so the editor's own
  /// autosave doesn't put the old row back on close.
  final VoidCallback beforeLeave;

  /// A repeating task asks which instances to delete first (M3f.1);
  /// "This one" falls through to the confirmed delete.
  final Future<({bool cancelled, bool done})> Function()? scopedDelete;

  /// Typed confirmation (03 §3.4), then Trash with Undo (R-11). A
  /// repeating task asks "Delete which?" instead; its answer confirms.
  Future<void> delete(BuildContext context, WidgetRef ref) async {
    var sure = false;
    if (scopedDelete case final ask?) {
      final r = await ask();
      if (r.cancelled) return;
      if (r.done) {
        // Drop pending edits before the editor closes, or its last flush
        // would bring the deleted row back.
        beforeLeave();
        return onLeft();
      }
      sure = true;
    }
    if (!context.mounted) return;
    final l10n = context.l10n;
    final messenger = ScaffoldMessenger.of(context);
    final undo = ref.read(undoServiceProvider);
    final trash = ref.read(trashServiceProvider);
    sure = sure || await _confirm(context) == true;
    if (!sure) return;
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

  Future<bool?> _confirm(BuildContext context) {
    final l10n = context.l10n;
    return showDialog<bool>(
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
  }

  Future<void> toInbox(BuildContext context, WidgetRef ref) async {
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
