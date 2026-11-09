import 'package:dottoday/core/failures/app_failure.dart';
import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/data/notifications/reminder_refusal.dart';
import 'package:dottoday/shared/feedback/save_failure.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The app root's part of a refused reminder action (CR-160 §4): the
/// generic message as a SnackBar from [overlay] (the root navigator's), or
/// nothing while a D1 dialog shows it itself — under the dialog's barrier
/// it would be dimmed and never announced.
void showReminderRefusal(
  WidgetRef ref,
  BuildContext? overlay,
  AppFailure failure,
) {
  if (overlay == null || ref.read(refusalDialogsProvider).open) return;
  final messenger = ScaffoldMessenger.maybeOf(overlay);
  if (messenger != null) showFailureSnack(messenger, overlay.l10n, failure);
}
