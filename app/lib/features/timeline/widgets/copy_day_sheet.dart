import 'package:dottoday/core/failures/failure_messages.dart';
import 'package:dottoday/core/failures/result.dart';
import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/data/trash/trash_providers.dart';
import 'package:dottoday/features/timeline/state/day_actions.dart';
import 'package:dottoday/features/timeline/state/timeline_providers.dart';
import 'package:dottoday/features/timeline/widgets/day_picker_sheet.dart';
import 'package:dottoday/shared/feedback/undo_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Picks the day to copy onto [target] from a month sheet, then copies it
/// with Undo ("Copy a day…", `A-ios-future-month`; 03 §3.1 Duplicate day).
Future<void> showCopyDaySheet(
  BuildContext context, {
  required DateTime target,
}) async {
  final messenger = ScaffoldMessenger.of(context);
  final l10n = context.l10n;
  final container = ProviderScope.containerOf(context, listen: false);
  final undo = container.read(undoServiceProvider);
  final today = await container.read(todayDateProvider.future);
  if (!context.mounted) return;
  final source = await showDayPicker(
    context,
    title: l10n.copyDayTitle,
    today: today,
    initial: target,
  );
  if (source == null) return;
  final result = await copyDay(
    container,
    source: await occurrencesOn(container, source),
    target: target,
  );
  switch (result) {
    case Ok(value: null):
      messenger.showSnackBar(SnackBar(content: Text(l10n.copyDayNothing)));
    case Ok(value: (:final count, :final token)?):
      showUndoSnackbarOn(
        messenger,
        l10n,
        message: l10n.copyDayDone(count),
        onUndo: () => undo.undo(token),
      );
    case Err(:final failure):
      messenger.showSnackBar(
        SnackBar(content: Text(failureMessage(l10n, failure))),
      );
  }
}
