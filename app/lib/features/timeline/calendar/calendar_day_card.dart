import 'package:dottoday/core/clock/clock_provider.dart';
import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/router/app_routes.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/domain/entities/enums.dart';
import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:dottoday/domain/time/day_shape.dart';
import 'package:dottoday/features/timeline/state/day_summary.dart';
import 'package:dottoday/features/timeline/state/timeline_providers.dart';
import 'package:dottoday/shared/dot/task_dot.dart';
import 'package:dottoday/shared/duration/duration_chips.dart';
import 'package:dottoday/shared/time/time_labels.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:timezone/timezone.dart' as tz;

/// The picked day under the Calendar tab's month (E-Phones Calendar,
/// ED-075): "Tue 3 Nov · Today", Open day, the day's numbers and its
/// tasks in time order. iPhone draws it as a raised card, Android as an
/// M3 filled card.
class CalendarDayCard extends ConsumerWidget {
  const CalendarDayCard({required this.date, required this.today, super.key});

  final DateTime date;
  final DateTime today;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = DotTheme.of(context);
    final l10n = context.l10n;
    final locale = Localizations.localeOf(context).toLanguageTag();
    final android = DotIdiom.of(context) == DotIdiom.material;
    final data = ref.watch(timelineDataProvider(date)).value;
    final now =
        ref.watch(minuteTickProvider).value ??
        ref.watch(clockProvider).nowUtc();
    final name = DateFormat.MMMEd(locale).format(date);
    final blocks = [...?data?.blocks]
      ..sort((a, b) => a.startUtc!.compareTo(b.startUtc!));
    return DecoratedBox(
      decoration: BoxDecoration(
        color: android ? t.colors.tile : t.colors.raised,
        borderRadius: BorderRadius.circular(DotRadii.card),
      ),
      child: Padding(
        padding: const EdgeInsets.all(DotSpace.l),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: DotSpace.xs,
          children: [
            Row(
              children: [
                Expanded(
                  child: Semantics(
                    header: true,
                    child: Text(
                      date == today ? l10n.weekTodayDay(name) : name,
                      style: t.styles.rowTitle,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () => context.go(
                    date == today ? AppRoutes.today : AppRoutes.day(date),
                  ),
                  child: Text(l10n.calendarOpenDay),
                ),
              ],
            ),
            if (data != null) ...[
              Text(_numbers(context, data), style: t.styles.rowMeta),
              for (final o in blocks)
                _Row(task: o, nowUtc: now, use24h: data.settings.use24h),
            ],
          ],
        ),
      ),
    );
  }

  /// "3 of 9 done · 7 h 40 planned", or the free time of an empty day.
  String _numbers(BuildContext context, TimelineData data) {
    final l10n = context.l10n;
    final s = daySummaryOf(
      data.blocks,
      DayShape.on(
        data.day.location,
        date,
        data.settings.boundaryFor(data.day.weekday),
      ),
    );
    return s.total == 0
        ? l10n.dayCardNothing(formatDurationShort(l10n, s.freeMinutes))
        : l10n.dayCardSummary(
            s.done,
            s.total,
            formatDurationShort(l10n, s.plannedMinutes),
          );
  }
}

/// One task: its dot, "6:45–7:30 AM" (with "· Now, 18 min left" while it
/// runs) and the title.
class _Row extends StatelessWidget {
  const _Row({required this.task, required this.nowUtc, required this.use24h});

  final Occurrence task;
  final DateTime nowUtc;
  final bool? use24h;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final l10n = context.l10n;
    final start = task.startUtc!;
    final end = task.endUtc ?? start;
    final zone = tz.getLocation(task.tzId);
    final h24 = use24hFor(context, use24h);
    String at(DateTime utc) => timeOfUtc(context, zone, utc, use24h: h24);
    final range = l10n.blockTimeRange(at(start), at(end));
    final live =
        task.status == OccurrenceStatus.planned &&
        !nowUtc.isBefore(start) &&
        nowUtc.isBefore(end);
    final left = live ? (end.difference(nowUtc).inSeconds / 60).ceil() : null;
    final state = switch (task.status) {
      OccurrenceStatus.done => DotState.done,
      OccurrenceStatus.skipped => DotState.skipped,
      _ when live => DotState.live,
      _ => DotState.upcoming,
    };
    final span = end.difference(start).inSeconds;
    return Padding(
      padding: const EdgeInsets.only(top: DotSpace.xs),
      child: Row(
        spacing: DotSpace.s,
        children: [
          TaskDot(
            color: TaskColor.fromKey(task.colorKey),
            icon: TaskIcon.fromKey(task.iconKey),
            state: state,
            progress: live && span > 0
                ? nowUtc.difference(start).inSeconds / span
                : 0,
            label: taskDotLabel(
              l10n,
              title: task.title,
              state: state,
              minutesLeft: left,
            ),
            size: DotSize.calendarCardDot,
          ),
          Expanded(
            child: ExcludeSemantics(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    left == null
                        ? range
                        : l10n.liveMeta(range, l10n.liveNowLeft(left)),
                    style: t.styles.rowMeta.copyWith(color: t.colors.muted),
                  ),
                  Text(task.title, style: t.styles.rowTitle),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
