import 'package:dottoday/core/l10n/l10n.dart';
import 'package:flutter/material.dart';

/// What the person chose when an export left no saved copy (CR-160 Stage C).
enum WithoutCopyChoice {
  /// Delete anyway, without a saved copy.
  delete,

  /// Run the export again.
  retry,
}

/// "Delete without a saved copy?": asked only after an export in this D1
/// session failed, was too large or was cancelled, so that never turns into
/// consent by itself. [retry] offers "Try export again" (not when the export
/// was too large: retrying can't help). Null: closed, nothing chosen.
Future<WithoutCopyChoice?> confirmDeleteWithoutCopy(
  BuildContext context, {
  required bool retry,
}) {
  final l10n = context.l10n;
  return showDialog<WithoutCopyChoice>(
    context: context,
    builder: (dialog) => AlertDialog(
      content: Text(l10n.accountDeleteWithoutCopyQuestion),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialog).pop(),
          child: Text(l10n.editorCancel),
        ),
        if (retry)
          TextButton(
            onPressed: () => Navigator.of(dialog).pop(WithoutCopyChoice.retry),
            child: Text(l10n.accountDeleteExportRetry),
          ),
        FilledButton(
          onPressed: () => Navigator.of(dialog).pop(WithoutCopyChoice.delete),
          child: Text(l10n.accountDeleteWithoutCopy),
        ),
      ],
    ),
  );
}
