import 'dart:async';

import 'package:dottoday/core/failures/app_failure.dart';
import 'package:dottoday/core/failures/failure_messages.dart';
import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/domain/undo/undo_service.dart';
import 'package:dottoday/shared/feedback/banner_strip.dart';
import 'package:dottoday/shared/feedback/undo_snackbar.dart';
import 'package:dottoday/shared/feedback/undo_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';

/// A write that didn't land, shown on the sheet that still holds what was
/// typed, with Try again (M8.5b, R-08 "never silent data loss"). A
/// snackbar would sit under a full-height sheet, out of sight.
class SaveFailureBanner extends StatelessWidget {
  const SaveFailureBanner({
    required this.failure,
    required this.onRetry,
    super.key,
  });

  final AppFailure failure;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return BannerStrip(
      glyph: DotGlyphs.warning,
      text: failureMessage(l10n, failure),
      actions: [(l10n.stateRetry, onRetry)],
    );
  }
}

/// [child] (a bounded-height scroller) under a [SaveFailureBanner] while
/// there is a [failure].
class SaveFailureFrame extends StatelessWidget {
  const SaveFailureFrame({
    required this.failure,
    required this.onRetry,
    required this.child,
    super.key,
  });

  final AppFailure? failure;
  final VoidCallback onRetry;
  final Widget child;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      if (failure case final f?)
        SaveFailureBanner(failure: f, onRetry: onRetry),
      Expanded(child: child),
    ],
  );
}

/// [failure] in the toast with Try again, for a write whose sheet has
/// already gone (the editor's last flush on dismiss; E-G4-7-States A7):
/// said assertively, as a failed save must be heard (D3).
void showSaveFailureSnack(
  ScaffoldMessengerState messenger,
  AppLocalizations l10n,
  AppFailure failure, {
  required VoidCallback onRetry,
}) {
  final text = failureMessage(l10n, failure);
  final context = messenger.context;
  messenger.showSnackBar(
    dotToast(
      messenger,
      UndoToast(
        message: text,
        action: l10n.stateRetry,
        onAction: onRetry,
        onClose: messenger.hideCurrentSnackBar,
        window: UndoService.window,
      ),
    ),
  );
  unawaited(
    SemanticsService.sendAnnouncement(
      View.of(context),
      text,
      Directionality.of(context),
      assertiveness: Assertiveness.assertive,
    ),
  );
}
