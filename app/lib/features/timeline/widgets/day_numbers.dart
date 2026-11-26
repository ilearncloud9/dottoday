import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/data/sync/sync_providers.dart';
import 'package:dottoday/domain/time/day_shape.dart';
import 'package:dottoday/features/timeline/state/day_ends.dart';
import 'package:dottoday/features/timeline/state/day_summary.dart';
import 'package:dottoday/features/timeline/state/timeline_providers.dart';
import 'package:dottoday/shared/duration/duration_chips.dart';
import 'package:dottoday/shared/time/time_labels.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// "2 of 13 done · 10 h planned" under Today's title (ADR-0015: moved up
/// from the day card's header row, so the sheet below is all thread).
class DayNumbers extends ConsumerWidget {
  const DayNumbers({required this.date, super.key});

  final DateTime date;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = DotTheme.of(context);
    final l10n = context.l10n;
    // The first sync on a new device says so in place of the numbers,
    // which would only count what has arrived so far (E-G4-7 A2, ED-482).
    if (ref.watch(firstSyncProvider) != null) {
      return Text(
        l10n.accountRestoring,
        style: t.styles.dayCaption.copyWith(letterSpacing: 0),
      );
    }
    final data = ref.watch(timelineDataProvider(date)).value;
    if (data == null) return const SizedBox.shrink();
    final s = daySummaryOf(
      data.blocks,
      DayShape.on(
        data.day.location,
        date,
        data.settings.boundaryFor(data.day.weekday),
      ),
    );
    final style = t.styles.dayCaption.copyWith(letterSpacing: 0);
    final numbers = Text(
      s.total == 0
          ? l10n.dayCardNothing(formatDurationShort(l10n, s.freeMinutes))
          : l10n.dayCardSummary(
              s.done,
              s.total,
              formatDurationShort(l10n, s.plannedMinutes),
            ),
      style: style,
    );
    // An early tomorrow moved Wind Down (docs/15 W4): say so, once, here.
    final ends = ref.watch(dayEndsProvider(date)).value;
    if (ends == null || !ends.derived) return numbers;
    String at(DateTime utc) => timeOfUtc(
      context,
      data.day.location,
      utc,
      use24h: use24hFor(context, data.settings.use24h),
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        numbers,
        Text(
          l10n.todayWindDownFooter(at(ends.nextWakeUtc), at(ends.shape.bedUtc)),
          style: style,
        ),
      ],
    );
  }
}
