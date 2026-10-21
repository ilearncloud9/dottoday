import 'package:dottoday/core/clock/clock_provider.dart';
import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:dottoday/domain/time/day_shape.dart';
import 'package:dottoday/features/timeline/state/day_summary.dart';
import 'package:dottoday/features/timeline/state/task_selection.dart';
import 'package:dottoday/features/timeline/state/thread_day.dart';
import 'package:dottoday/features/timeline/state/timeline_providers.dart';
import 'package:dottoday/features/timeline/widgets/day_actions.dart';
import 'package:dottoday/features/timeline/widgets/day_drag.dart';
import 'package:dottoday/features/timeline/widgets/empty_day_actions.dart';
import 'package:dottoday/features/timeline/widgets/time_labels.dart';
import 'package:dottoday/shared/dot/day_card.dart';
import 'package:dottoday/shared/duration/duration_chips.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:timezone/timezone.dart' as tz;

/// One page of the Today pager: [date]'s thread on a [DayCard] (`Main`).
class DayPage extends ConsumerWidget {
  const DayPage({required this.date, required this.today, super.key});

  final DateTime date;
  final DateTime today;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = ref.watch(timelineDataProvider(date)).value;
    if (data == null) return const SizedBox.shrink();
    final subtasks = ref.watch(daySubtaskProgressProvider(date)).value;
    final now =
        ref.watch(minuteTickProvider).value ??
        ref.watch(clockProvider).nowUtc();
    final shape = DayShape.on(
      data.day.location,
      date,
      data.settings.boundaryFor(data.day.weekday),
    );
    final blocks = data.blocks;
    final summary = daySummaryOf(blocks, shape);
    final format = _format(context, data.day.location, data.settings.use24h);
    final picked = ref.watch(taskSelectionProvider);
    return DayCard(
      title: _title(context),
      isToday: date == today,
      summary: summary,
      entries: threadEntries(
        blocks: blocks,
        shape: shape,
        nowUtc: now,
        format: format,
        subtasks: subtasks ?? const {},
      ),
      actions: dayThreadActions(
        context,
        ref,
        blocks: blocks,
        timeText: format.time,
        drag: dayThreadDrag(
          context,
          ref,
          blocks: blocks,
          zone: data.day.location,
          snapMinutes: data.settings.snapMinutes,
          timeText: format.time,
          shiftFollowers: data.settings.shiftFollowers,
          includeCalendar: data.settings.includeCalendarInShift,
        ),
        selectedIds: picked.day == date ? picked.ids : const {},
        onSelect: (id) =>
            ref.read(taskSelectionProvider.notifier).toggle(date, id),
      ),
      footer: _footer(blocks, summary.total == 0),
    );
  }

  /// A free day from today on offers its actions (`A-ios-future-month`);
  /// an empty past day only says so.
  Widget? _footer(List<Occurrence> blocks, bool empty) {
    final oneOffs = blocks.any((o) => o.seriesId == null);
    if (date.isBefore(today)) return empty ? const _Empty() : null;
    if (oneOffs) return null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (empty) const _Empty(),
        EmptyDayActions(date: date),
      ],
    );
  }

  /// "Wednesday" in the week around today, "Monday, December 14" further
  /// out (`A-ios-future-month`).
  String _title(BuildContext context) {
    final locale = Localizations.localeOf(context).toLanguageTag();
    final days = date.difference(today).inDays.abs();
    return days < 7
        ? DateFormat.EEEE(locale).format(date)
        : DateFormat.MMMMEEEEd(locale).format(date);
  }

  static ThreadFormat _format(
    BuildContext context,
    tz.Location location,
    bool? use24hSetting,
  ) {
    final l10n = context.l10n;
    final use24h = use24hFor(context, use24hSetting);
    return ThreadFormat(
      time: (utc) => timeOfUtc(context, location, utc, use24h: use24h),
      range: l10n.threadTimeRange,
      duration: (m) => formatDurationShort(l10n, m),
    );
  }
}

class _Empty extends StatelessWidget {
  const _Empty();

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(
        DotSpace.page,
        DotSpace.l,
        DotSpace.page,
        0,
      ),
      child: Text(
        context.l10n.todayEmpty,
        style: t.styles.body.copyWith(color: t.colors.muted),
      ),
    );
  }
}
