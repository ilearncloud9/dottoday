import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/domain/undo/undo_service.dart';
import 'package:dottoday/shared/feedback/undo_toast.dart';
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
    dotToast(
      messenger,
      UndoToast(
        message: message,
        action: l10n.undoAction,
        onAction: onUndo,
        onClose: messenger.hideCurrentSnackBar,
        window: UndoService.window,
        expired: l10n.failureUndoExpired,
      ),
    ),
  );
}

/// [body] on the toast surface (E-R2-7): floating above the bottom row on
/// phones; from the medium width on, centred and 400 wide (440, the M3
/// snackbar, off Apple platforms). The body closes it, so the messenger
/// never times it out on its own (ED-281: it waits while held).
SnackBar dotToast(ScaffoldMessengerState messenger, Widget body) {
  final context = messenger.context;
  final wide = MediaQuery.sizeOf(context).width >= WidthClass.mediumFrom;
  final apple = appleChrome(context);
  return SnackBar(
    content: body,
    persist: true,
    width: wide
        ? (apple ? DotSize.toastWide : DotSize.toastWideMaterial)
        : null,
    padding: const EdgeInsetsDirectional.fromSTEB(
      DotSpace.l,
      DotSpace.xs,
      DotSpace.xs,
      DotSpace.xs,
    ),
  );
}
