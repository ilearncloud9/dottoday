import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/shared/sheets/dot_alert.dart';
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
/// [setFiles]: the export was a set of that many files handed over but not
/// confirmed (CR-160 B7c), said as such.
Future<WithoutCopyChoice?> confirmDeleteWithoutCopy(
  BuildContext context, {
  required bool retry,
  int? setFiles,
}) {
  final l10n = context.l10n;
  return showChoiceAlert<WithoutCopyChoice?>(
    context,
    message: setFiles == null
        ? l10n.accountDeleteWithoutCopyQuestion
        : l10n.accountDeleteWithoutCopySetQuestion(setFiles),
    choices: [
      AlertChoice(label: l10n.editorCancel, value: null, cancel: true),
      if (retry)
        AlertChoice(
          label: l10n.accountDeleteExportRetry,
          value: WithoutCopyChoice.retry,
        ),
      AlertChoice(
        label: l10n.accountDeleteWithoutCopy,
        value: WithoutCopyChoice.delete,
        primary: true,
      ),
    ],
  );
}
