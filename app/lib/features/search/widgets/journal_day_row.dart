import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/domain/review/journal.dart';
import 'package:dottoday/features/search/state/journal_state.dart';
import 'package:dottoday/shared/dot/task_dot.dart';
import 'package:dottoday/shared/time/time_labels.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Most dots a past day shows before "+N".
const journalRowDots = 12;

/// One past day (11 D3): its date, "4 of 5 done", and its thread as dots
/// in their colours (done solid); while searching, the matching tasks with
/// their times. A tap opens the day.
class JournalDayRow extends StatelessWidget {
  const JournalDayRow({
    required this.day,
    required this.data,
    required this.query,
    required this.onOpen,
    super.key,
  });

  final JournalDay day;
  final JournalData data;
  final String query;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final l10n = context.l10n;
    final locale = Localizations.localeOf(context).toLanguageTag();
    final dots = day.snapshot.dots;
    final q = query.toLowerCase();
    final matches = [
      if (q.isNotEmpty)
        for (final d in dots)
          if (d.title.toLowerCase().contains(q)) d,
    ];
    final summary = l10n.reviewSummary(
      day.snapshot.dayDone,
      day.snapshot.dayTotal,
    );
    final date = DateFormat.MMMEd(locale).format(day.date);
    return Material(
      color: t.colors.raised,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(DotRadii.card),
        side: BorderSide(color: t.colors.hairline),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onOpen,
        child: Semantics(
          button: true,
          label: l10n.journalDayLabel(date, summary),
          excludeSemantics: true,
          child: Padding(
            padding: const EdgeInsets.all(DotSpace.m),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: DotSpace.s,
              children: [
                Row(
                  children: [
                    Expanded(child: Text(date, style: t.styles.rowTitle)),
                    Text(summary, style: t.styles.rowMeta),
                  ],
                ),
                Wrap(
                  spacing: DotSpace.xs,
                  runSpacing: DotSpace.xs,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    for (final d in dots.take(journalRowDots))
                      TaskDot(
                        color: TaskColor.fromKey(d.colorKey),
                        icon: TaskIcon.fromKey(d.iconKey),
                        state: d.done ? DotState.done : DotState.upcoming,
                        label: d.title,
                        size: DotSize.pickerDot,
                      ),
                    if (dots.length > journalRowDots)
                      Text(
                        l10n.monthMore(dots.length - journalRowDots),
                        style: t.styles.rowMeta,
                      ),
                  ],
                ),
                for (final m in matches)
                  Text(
                    l10n.journalMatch(
                      m.title,
                      timeOfUtc(
                        context,
                        data.zone,
                        m.startUtc,
                        use24h: use24hFor(context, data.use24h),
                      ),
                    ),
                    style: t.styles.body,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
