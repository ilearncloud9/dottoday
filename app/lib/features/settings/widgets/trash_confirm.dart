import 'package:dottoday/core/l10n/l10n.dart';
import 'package:flutter/material.dart';

/// "Delete “{title}” now?" (ED-337): true only on Delete. Permanent
/// delete always asks first (docs/02 F7.6).
Future<bool> confirmDeleteNow(BuildContext context, String title) {
  final l10n = context.l10n;
  return _confirm(
    context,
    title: l10n.trashDeleteNowTitle(title),
    body: l10n.trashDeleteNowBody,
    action: l10n.trashDeleteNowAction,
  );
}

/// "Empty Trash?" for [count] tasks (ED-337): true only on Empty Trash.
Future<bool> confirmEmptyTrash(BuildContext context, int count) {
  final l10n = context.l10n;
  return _confirm(
    context,
    title: l10n.trashEmptyTitle,
    body: l10n.trashEmptyBody(count),
    action: l10n.trashEmptyAction,
  );
}

/// Cancel and one ink action: [FilledButton] takes the accent, never red
/// (no-shame rule, CLAUDE.md §11).
Future<bool> _confirm(
  BuildContext context, {
  required String title,
  required String body,
  required String action,
}) async {
  final l10n = context.l10n;
  final ok = await showDialog<bool>(
    context: context,
    builder: (dialog) => AlertDialog(
      title: Text(title),
      content: Text(body),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialog).pop(false),
          child: Text(l10n.editorCancel),
        ),
        FilledButton(
          onPressed: () => Navigator.of(dialog).pop(true),
          child: Text(action),
        ),
      ],
    ),
  );
  return ok ?? false;
}
