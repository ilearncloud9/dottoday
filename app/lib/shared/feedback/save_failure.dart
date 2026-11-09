import 'package:dottoday/core/failures/app_failure.dart';
import 'package:dottoday/core/failures/failure_messages.dart';
import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/shared/feedback/banner_strip.dart';
import 'package:flutter/material.dart';

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

/// [failure] as a snackbar with Try again, for a write whose sheet has
/// already gone (the editor's last flush on dismiss).
void showSaveFailureSnack(
  ScaffoldMessengerState messenger,
  AppLocalizations l10n,
  AppFailure failure, {
  required VoidCallback onRetry,
}) => messenger.showSnackBar(
  SnackBar(
    content: Text(failureMessage(l10n, failure)),
    action: SnackBarAction(label: l10n.stateRetry, onPressed: onRetry),
  ),
);
