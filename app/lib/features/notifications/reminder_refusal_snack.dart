import 'package:dottoday/core/failures/failure_messages.dart';
import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/data/notifications/reminder_refusal.dart';
import 'package:dottoday/data/owners/owner_switch.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The app root's part of a refused reminder action (CR-160 §4): the
/// generic message as a SnackBar from [overlay] (the root navigator's), or
/// nothing while a D1 dialog shows it itself — under the dialog's barrier
/// it would be dimmed and never announced — or when [refusal] belongs to
/// an owner session that already ended.
void showReminderRefusal(
  WidgetRef ref,
  BuildContext? overlay,
  Refusal refusal,
) {
  if (overlay == null || ref.read(refusalDialogsProvider).open) return;
  if (!ref.read(reminderRefusalProvider.notifier).current(refusal)) return;
  ScaffoldMessenger.maybeOf(overlay)?.showSnackBar(
    SnackBar(
      content: _SessionBound(
        epoch: refusal.epoch,
        text: failureMessage(overlay.l10n, refusal.failure),
      ),
    ),
  );
}

/// The SnackBar's text while its owner session lasts. Queued behind another
/// SnackBar, or on screen, when the owner changes: it takes itself away
/// and shows nothing, so the next owner or guest never sees it.
class _SessionBound extends ConsumerWidget {
  const _SessionBound({required this.epoch, required this.text});

  final int epoch;
  final String text;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (ref.watch(ownerEpochProvider) == epoch) return Text(text);
    final messenger = ScaffoldMessenger.maybeOf(context);
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => messenger?.removeCurrentSnackBar(),
    );
    return const SizedBox.shrink();
  }
}
