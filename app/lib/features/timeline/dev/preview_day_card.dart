import 'dart:async';

import 'package:dottoday/core/clock/clock_provider.dart';
import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/domain/entities/enums.dart';
import 'package:dottoday/domain/time/day_shape.dart';
import 'package:dottoday/features/timeline/state/block_actions.dart';
import 'package:dottoday/features/timeline/state/thread_day.dart';
import 'package:dottoday/features/timeline/state/timeline_providers.dart';
import 'package:dottoday/features/timeline/widgets/time_labels.dart';
import 'package:dottoday/shared/dot/day_card.dart';
import 'package:dottoday/shared/dot/thread.dart';
import 'package:dottoday/shared/duration/duration_chips.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

// DEBUG ONLY (M3a.10): one day of the preview pager on real data.

/// [date]'s thread on a [DayCard]; tapping a dot toggles done for real.
class PreviewDayCard extends ConsumerWidget {
  const PreviewDayCard({required this.date, required this.isToday, super.key});

  final DateTime date;
  final bool isToday;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = ref.watch(timelineDataProvider(date)).value;
    if (data == null) return const SizedBox.shrink();
    final subtasks = ref.watch(daySubtaskProgressProvider(date)).value;
    final now =
        ref.watch(minuteTickProvider).value ??
        ref.watch(clockProvider).nowUtc();
    final l10n = context.l10n;
    final location = data.day.location;
    final use24h =
        data.settings.use24h ?? MediaQuery.alwaysUse24HourFormatOf(context);
    final shape = DayShape.on(
      location,
      date,
      data.settings.boundaryFor(data.day.weekday),
    );
    final format = ThreadFormat(
      time: (utc) => timeOfUtc(context, location, utc, use24h: use24h),
      range: l10n.threadTimeRange,
      duration: (m) => formatDurationShort(l10n, m),
    );
    final blocks = data.blocks;
    final planned = blocks.fold(0, (sum, o) => sum + o.durationMin);
    return DayCard(
      title: DateFormat.EEEE(
        Localizations.localeOf(context).toLanguageTag(),
      ).format(date),
      isToday: isToday,
      summary: DaySummary(
        done: blocks.where((o) => o.status == OccurrenceStatus.done).length,
        total: blocks.length,
        plannedMinutes: planned,
        freeMinutes: (shape.awakeMinutes - planned).clamp(0, 24 * 60),
      ),
      entries: threadEntries(
        blocks: blocks,
        shape: shape,
        nowUtc: now,
        format: format,
        subtasks: subtasks ?? const {},
      ),
      actions: ThreadActions(
        onToggleDone: (id) =>
            unawaited(toggleDone(ref, blocks.firstWhere((o) => o.id == id))),
      ),
    );
  }
}
