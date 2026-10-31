import 'dart:async';

import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/data/trash/trash_providers.dart';
import 'package:dottoday/domain/scheduling/day_review.dart';
import 'package:dottoday/features/timeline/state/late_actions.dart';
import 'package:dottoday/features/timeline/state/timeline_providers.dart';
import 'package:dottoday/features/timeline/widgets/day_actions.dart';
import 'package:dottoday/shared/sheets/app_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The Day review (docs/09 M3f.5) in a sheet, from Today's ⋯ menu at any
/// time; at Wind Down it shows on Today itself (`TodayPrompt`).
Future<void> showDayReviewSheet(BuildContext context, DateTime day) =>
    showAppSheet<void>(
      context: context,
      title: context.l10n.reviewTitle,
      builder: (sheet) =>
          DayReviewBody(day: day, onDone: () => Navigator.of(sheet).pop()),
    );

/// "3 of 7 done · Move the rest to tomorrow?" with the one action:
/// tomorrow, or the Inbox when "Roll unfinished to tomorrow" is off
/// (Settings › Planning). Repeating tasks and calendar events stay; the
/// count says so.
class DayReviewBody extends ConsumerWidget {
  const DayReviewBody({
    required this.day,
    this.onDone,
    this.onNotNow,
    super.key,
  });

  final DateTime day;

  /// After the move (the sheet closes).
  final VoidCallback? onDone;

  /// Shows "Not now" (the prompt on Today).
  final VoidCallback? onNotNow;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = DotTheme.of(context);
    final l10n = context.l10n;
    final data = ref.watch(timelineDataProvider(day)).value;
    if (data == null) return const SizedBox.shrink();
    final review = reviewOf(data.blocks);
    final roll = data.settings.rollUnfinished;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: DotSpace.s,
      children: [
        Text(
          l10n.reviewSummary(review.done, review.total),
          style: t.styles.cardTitle,
        ),
        Text(
          !review.hasRest
              ? l10n.reviewAllDone
              : roll
              ? l10n.reviewAskTomorrow
              : l10n.reviewAskInbox,
          style: t.styles.body,
        ),
        if (review.staying > 0)
          Text(l10n.reviewStaying(review.staying), style: t.styles.rowMeta),
        _buttons(context, ref, review, roll),
      ],
    );
  }

  Widget _buttons(
    BuildContext context,
    WidgetRef ref,
    DayReview review,
    bool roll,
  ) {
    final l10n = context.l10n;
    final count = review.movable.length;
    return Wrap(
      spacing: DotSpace.s,
      runSpacing: DotSpace.s,
      children: [
        if (review.hasRest)
          FilledButton(
            onPressed: () => unawaited(_move(context, ref, review, roll)),
            child: Text(
              roll
                  ? l10n.reviewMoveTomorrow(count)
                  : l10n.reviewSendInbox(count),
            ),
          ),
        if (onNotNow case final notNow?)
          TextButton(onPressed: notNow, child: Text(l10n.promptNotNow)),
      ],
    );
  }

  Future<void> _move(
    BuildContext context,
    WidgetRef ref,
    DayReview review,
    bool roll,
  ) async {
    final container = ProviderScope.containerOf(context, listen: false);
    final messenger = ScaffoldMessenger.of(context);
    final l10n = context.l10n;
    final undo = ref.read(undoServiceProvider);
    final rows = review.movable;
    onDone?.call();
    final tomorrow = DateTime(day.year, day.month, day.day + 1);
    reportUndoable(
      messenger,
      l10n,
      undo,
      await (roll
          ? rollToDay(container, rows, tomorrow)
          : sendToInbox(container, rows)),
      message: (_) => roll
          ? l10n.snackRolled(rows.length)
          : l10n.snackSentToInbox(rows.length),
      tokenOf: (t) => t,
    );
  }
}
