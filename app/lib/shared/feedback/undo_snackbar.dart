import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/layout/app_layout.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/domain/undo/undo_service.dart';
import 'package:dottoday/shared/feedback/undo_toast.dart';
import 'package:dottoday/shared/navigation/dot_rail.dart';
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
/// phones; from the medium width on, 400 wide (440, the M3 snackbar, off
/// Apple platforms) and centred on the content beside the rail or the
/// sidebar, never under it (ED-334). The body closes it, so the messenger
/// never times it out on its own (ED-281: it waits while held).
SnackBar dotToast(ScaffoldMessengerState messenger, Widget body) {
  final context = messenger.context;
  final window = MediaQuery.sizeOf(context).width;
  final wide = window >= WidthClass.mediumFrom && !AppLayout.isShort(context);
  const padding = EdgeInsetsDirectional.fromSTEB(
    DotSpace.l,
    DotSpace.xs,
    DotSpace.xs,
    DotSpace.xs,
  );
  if (!wide) {
    // Android's toolbar floats in the page: the toast sits above it
    // (E-R2-7, ED-125).
    final android =
        !webChrome(context) && DotIdiom.of(context) == DotIdiom.material;
    return SnackBar(
      content: body,
      persist: true,
      padding: padding,
      margin: android
          ? const EdgeInsets.fromLTRB(
              DotSpace.l,
              0,
              DotSpace.l,
              DotSize.androidBar + DotSize.androidBarBottom + DotSpace.s,
            )
          : null,
    );
  }
  final apple = appleChrome(context);
  final width = apple ? DotSize.toastWide : DotSize.toastWideMaterial;
  final start = _navigationWidth(context, window);
  final side = ((window - start - width) / 2).clamp(DotSpace.l, window);
  return SnackBar(
    content: body,
    persist: true,
    padding: padding,
    margin: EdgeInsetsDirectional.only(
      start: start + side,
      end: side,
      bottom: DotSpace.l,
    ),
  );
}

/// How much of the window's start edge the navigation takes: the rail at
/// medium width (the iPad's top tabs take none), the sidebar when
/// expanded (E-R2-1).
double _navigationWidth(BuildContext context, double window) {
  final klass = AppLayout.classOf(context, width: window);
  return switch ((klass, DotIdiom.of(context))) {
    (WidthClass.compact, _) => 0,
    (WidthClass.medium, DotIdiom.cupertino) => 0,
    (WidthClass.medium, DotIdiom.material) => DotRailShell.width,
    (WidthClass.expanded, _) => DotSize.sidebar,
  };
}
