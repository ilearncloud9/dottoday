import 'package:dottoday/core/failures/failure_messages.dart';
import 'package:dottoday/core/failures/result.dart';
import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/data/profile/profile_providers.dart';
import 'package:dottoday/data/schedule/planned_colors.dart';
import 'package:dottoday/data/trash/trash_providers.dart';
import 'package:dottoday/features/timeline/state/day_actions.dart';
import 'package:dottoday/features/timeline/state/timeline_providers.dart';
import 'package:dottoday/shared/feedback/undo_snackbar.dart';
import 'package:dottoday/shared/pickers/day_pickers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Picks the day to copy onto [target] from a month sheet, then copies it
/// with Undo ("Copy a day…", `A-ios-future-month`; 03 §3.1 Duplicate day).
Future<void> showCopyDaySheet(
  BuildContext context, {
  required DateTime target,
}) =>
    _copy(context, fixed: target, title: context.l10n.copyDayTitle, into: true);

/// Picks the day to copy [source] onto, then copies it with Undo (Today's
/// ⋯ › Duplicate day…, 03 §3.1, docs/09 M3f.6).
Future<void> showDuplicateDaySheet(
  BuildContext context, {
  required DateTime source,
}) => _copy(
  context,
  fixed: source,
  title: context.l10n.duplicateDayTitle,
  into: false,
);

/// [fixed] is the target when [into], else the source; the other day is
/// picked.
Future<void> _copy(
  BuildContext context, {
  required DateTime fixed,
  required String title,
  required bool into,
}) async {
  final messenger = ScaffoldMessenger.of(context);
  final l10n = context.l10n;
  final container = ProviderScope.containerOf(context, listen: false);
  final undo = container.read(undoServiceProvider);
  final today = await container.read(todayDateProvider.future);
  if (!context.mounted) return;
  final picked = await showMonthDayPicker(
    context,
    plannedFor: (m) => plannedColors(container, m),
    firstDayOfWeek: _weekStart(container),
    title: title,
    today: today,
    initial: fixed,
  );
  if (picked == null || picked == fixed) return;
  final source = into ? picked : fixed;
  final result = await copyDay(
    container,
    source: await occurrencesOn(container, source),
    target: into ? fixed : picked,
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

int _weekStart(ProviderContainer c) =>
    c.read(currentProfileProvider).value?.settings.firstDayOfWeek ?? 1;
