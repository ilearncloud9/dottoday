import 'dart:async';

import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/data/recurrence/series_actions.dart';
import 'package:dottoday/data/trash/trash_providers.dart';
import 'package:dottoday/domain/recurrence/repeat_rule.dart';
import 'package:dottoday/domain/recurrence/series_edit.dart';
import 'package:dottoday/features/timeline/later/habit_offer.dart';
import 'package:dottoday/features/timeline/widgets/day_actions.dart';
import 'package:dottoday/shared/pickers/repeat/repeat_text.dart';
import 'package:dottoday/shared/proposals/proposal_sheet.dart';
import 'package:dottoday/shared/sheets/app_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// "Make it a habit" as a proposal (CLAUDE.md §11, ED-491): the task, now
/// "most days" and then the days it was done on; nothing changes until
/// Accept, which repeats it on just those days from its next day on (one
/// write, with Undo). Discard leaves it every day.
Future<void> showHabitSheet(
  BuildContext context,
  WidgetRef ref,
  HabitOffer offer,
) {
  final l10n = context.l10n;
  final locale = Localizations.localeOf(context).toLanguageTag();
  final days = weekdayList(l10n, locale, offer.days);
  final messenger = ScaffoldMessenger.of(context);
  final container = ProviderScope.containerOf(context, listen: false);
  final undo = container.read(undoServiceProvider);
  return showAppSheet<void>(
    context: context,
    fullHeight: true,
    builder: (sheet) {
      final t = DotTheme.of(sheet);
      return ProposalSheet(
        title: l10n.laterHabitTitle,
        subtitle: l10n.laterHabitDecide,
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(offer.series.title, style: t.styles.rowTitle),
            Text(l10n.laterHabitChange(days), style: t.styles.rowMeta),
          ],
        ),
        onDiscard: () => Navigator.of(sheet).pop(),
        onAccept: () {
          Navigator.of(sheet).pop();
          unawaited(() async {
            final result = await editSeries(
              container,
              series: offer.series,
              target: offer.next,
              change: SeriesChange(
                rule: RepeatRule(
                  frequency: RepeatFrequency.weekly,
                  days: offer.days,
                ),
              ),
              scope: EditScope.following,
            );
            reportUndoable(
              messenger,
              l10n,
              undo,
              result,
              message: (_) => l10n.laterHabitDone(offer.series.title, days),
              tokenOf: (token) => token,
            );
          }());
        },
      );
    },
  );
}
