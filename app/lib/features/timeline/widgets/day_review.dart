import 'dart:async';

import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/data/trash/trash_providers.dart';
import 'package:dottoday/domain/entities/enums.dart';
import 'package:dottoday/domain/scheduling/day_review.dart';
import 'package:dottoday/features/timeline/state/late_actions.dart';
import 'package:dottoday/features/timeline/state/timeline_providers.dart';
import 'package:dottoday/features/timeline/widgets/day_actions.dart';
import 'package:dottoday/features/timeline/widgets/day_review_parts.dart';
import 'package:dottoday/features/timeline/widgets/make_sure_up.dart';
import 'package:dottoday/features/timeline/widgets/review_night.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// "3 of 7 done · Move the rest to tomorrow?" with the one action:
/// tomorrow, or the Inbox when "Roll unfinished to tomorrow" is off
/// (Settings › Planning). Repeating tasks and calendar events stay; the
/// count says so. Shown by `openReview` (ED-099) as E-Phones-2 draws it:
/// the count, question and Move on a card, the night on a pill, then the
/// Week in review row ([onWeek]). Today's Wind Down prompt ([onNotNow])
/// keeps its plain lines inside the prompt card.
class DayReviewBody extends ConsumerWidget {
  const DayReviewBody({
    required this.day,
    this.onDone,
    this.onNotNow,
    this.onWeek,
    super.key,
  });

  final DateTime day;

  /// After the move (the sheet closes).
  final VoidCallback? onDone;

  /// Shows "Not now" (the prompt on Today).
  final VoidCallback? onNotNow;

  /// Shows the Week in review row, which pushes Week in review.
  final VoidCallback? onWeek;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = DotTheme.of(context);
    final l10n = context.l10n;
    final data = ref.watch(timelineDataProvider(day)).value;
    if (data == null) return const SizedBox.shrink();
    final review = reviewOf(data.blocks);
    final roll = data.settings.rollUnfinished;
    final settings = data.settings;
    final ask = !review.hasRest
        ? l10n.reviewAllDone
        : roll
        ? l10n.reviewAskTomorrow
        : l10n.reviewAskInbox;
    final staying = review.staying > 0
        ? Text(l10n.reviewStaying(review.staying), style: t.styles.rowMeta)
        : null;
    final tail = [
      // "Make sure I'm up" for tomorrow (15 §8 rule 5), missions on only:
      // a hidden child would still take a gap.
      if (settings.missionMode != MissionMode.off)
        TomorrowMattersToggle(day: day),
      // Once, for an account from before the sleep target (15 §11).
      if (settings.sleepTargetMin == null && !settings.sleepOfferAnswered)
        const SleepOffer(),
    ];
    if (onNotNow != null) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: DotSpace.s,
        children: [
          // The night first (docs/15 W6); then the day as before.
          ReviewNightLine(day: day),
          Text(
            l10n.reviewSummary(review.done, review.total),
            style: t.styles.cardTitle,
          ),
          // E-R2-27: "Nothing left to move" in the accent.
          Text(
            ask,
            style: review.hasRest
                ? t.styles.body
                : t.styles.body.copyWith(color: t.colors.accentInk),
          ),
          ?staying,
          _buttons(context, ref, review, roll),
          ...tail,
        ],
      );
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: DotSpace.m,
      children: [
        ReviewCountCard(
          count: l10n.reviewSummary(review.done, review.total),
          ask: ask,
          move: review.hasRest ? _moveButton(context, ref, review, roll) : null,
          staying: staying,
        ),
        ReviewNightLine(day: day, pill: true),
        ...tail,
        if (onWeek case final week?) ReviewWeekRow(day: day, onTap: week),
      ],
    );
  }

  Widget _moveButton(
    BuildContext context,
    WidgetRef ref,
    DayReview review,
    bool roll,
  ) {
    final l10n = context.l10n;
    final count = review.movable.length;
    return FilledButton(
      onPressed: () => unawaited(_move(context, ref, review, roll)),
      child: Text(
        roll ? l10n.reviewMoveTomorrow(count) : l10n.reviewSendInbox(count),
      ),
    );
  }

  Widget _buttons(
    BuildContext context,
    WidgetRef ref,
    DayReview review,
    bool roll,
  ) {
    return Wrap(
      spacing: DotSpace.s,
      runSpacing: DotSpace.s,
      children: [
        if (review.hasRest) _moveButton(context, ref, review, roll),
        if (onNotNow case final notNow?)
          TextButton(onPressed: notNow, child: Text(context.l10n.promptNotNow)),
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
