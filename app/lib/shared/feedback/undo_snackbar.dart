import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/domain/undo/undo_service.dart';
import 'package:flutter/material.dart';

/// Shows [message] with an "Undo" action for [UndoService.window] (R-11,
/// docs/02 F1 "Undo snackbar (30 s) for every move/delete/complete").
///
/// Replaces any snackbar already showing, so only the latest action is
/// offered for undo. The caller redeems its token in [onUndo].
///
/// ```dart
/// showUndoSnackbar(context, message: l10n.movedBlock, onUndo: () =>
///     ref.read(undoServiceProvider).undo(token));
/// ```
ScaffoldFeatureController<SnackBar, SnackBarClosedReason> showUndoSnackbar(
  BuildContext context, {
  required String message,
  required VoidCallback onUndo,
}) => showUndoSnackbarOn(
  ScaffoldMessenger.of(context),
  context.l10n,
  message: message,
  onUndo: onUndo,
);

/// [showUndoSnackbar] for callers that captured the messenger before an
/// `await` (the BuildContext may be gone by then).
ScaffoldFeatureController<SnackBar, SnackBarClosedReason> showUndoSnackbarOn(
  ScaffoldMessengerState messenger,
  AppLocalizations l10n, {
  required String message,
  required VoidCallback onUndo,
}) {
  messenger.hideCurrentSnackBar();
  return messenger.showSnackBar(
    SnackBar(
      content: Text(message),
      duration: UndoService.window,
      behavior: SnackBarBehavior.floating,
      // Stay up for the whole window even with accessible navigation on,
      // which would otherwise keep an action snackbar open indefinitely.
      persist: false,
      action: SnackBarAction(label: l10n.undoAction, onPressed: onUndo),
    ),
  );
}
