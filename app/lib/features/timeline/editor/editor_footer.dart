import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:dottoday/features/timeline/editor/editor_leave.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Delete (confirmed) · Move to inbox · Save (`A-mac-editor`).
class EditorFooter extends ConsumerWidget {
  const EditorFooter({
    required this.task,
    required this.onSave,
    required this.onLeft,
    required this.beforeLeave,
    this.scopedDelete,
    super.key,
  });

  /// A repeating task asks which instances to delete first (M3f.1);
  /// "This one" falls through to the confirmed delete below.
  final Future<({bool cancelled, bool done})> Function()? scopedDelete;

  /// After Delete or Move to inbox: the task is gone from here.
  final VoidCallback onLeft;

  /// The draft as it stands.
  final Occurrence task;
  final VoidCallback onSave;

  /// Called before Delete or Move to inbox write, so the editor's own
  /// autosave doesn't put the old row back on close.
  final VoidCallback beforeLeave;

  EditorLeave get _leave => EditorLeave(
    task: task,
    onLeft: onLeft,
    beforeLeave: beforeLeave,
    scopedDelete: scopedDelete,
  );

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
          onPressed: () => _leave.delete(context, ref),
          icon: DotIcon(DotGlyphs.trash, color: t.colors.ink),
        ),
        if (task.startUtc != null)
          OutlinedButton(
            onPressed: () => _leave.toInbox(context, ref),
            child: Text(l10n.editorMoveToInbox),
          ),
        FilledButton(onPressed: onSave, child: Text(l10n.editorSave)),
      ],
    );
  }
}
