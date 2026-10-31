import 'dart:async';

import 'package:dottoday/core/clock/clock_provider.dart';
import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/data/calendar/calendar_shift_providers.dart';
import 'package:dottoday/data/inbox/inbox_providers.dart';
import 'package:dottoday/data/scheduling/learning_meta.dart';
import 'package:dottoday/data/scheduling/learning_providers.dart';
import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:dottoday/domain/time/day_shape.dart';
import 'package:dottoday/features/timeline/state/day_cues.dart';
import 'package:dottoday/features/timeline/state/day_summary.dart';
import 'package:dottoday/features/timeline/state/reality_thread.dart';
import 'package:dottoday/features/timeline/state/task_selection.dart';
import 'package:dottoday/features/timeline/state/timeline_providers.dart';
import 'package:dottoday/features/timeline/state/today_selection.dart';
import 'package:dottoday/features/timeline/widgets/cap_time_sheet.dart';
import 'package:dottoday/features/timeline/widgets/day_actions.dart';
import 'package:dottoday/features/timeline/widgets/day_drag.dart';
import 'package:dottoday/features/timeline/widgets/empty_day_actions.dart';
import 'package:dottoday/features/timeline/widgets/reality_insight.dart';
import 'package:dottoday/features/timeline/widgets/today_learning.dart';
import 'package:dottoday/shared/dot/day_card.dart';
import 'package:dottoday/shared/dot/thread.dart';
import 'package:dottoday/shared/dot/thread_day.dart';
import 'package:dottoday/shared/dot/week_strip.dart';
import 'package:dottoday/shared/duration/duration_chips.dart';
import 'package:dottoday/shared/states/screen_states.dart';
import 'package:dottoday/shared/time/time_labels.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:timezone/timezone.dart' as tz;

/// One page of the Today pager: [date]'s thread on a [DayCard.sheet]
/// (`Main`, ADR-0015);
/// with [side], a day beside the card on the Mac/web spread (M3e.1).
class DayPage extends ConsumerWidget {
  const DayPage({
    required this.date,
    required this.today,
    this.side,
    this.sheet = false,
    super.key,
  });

  final DateTime date;
  final DateTime today;
  final SideDay? side;

  /// The phones' pager page: a full-width [DayCard.sheet] whose numbers
  /// live in the screen header (ADR-0015). Off, the Mac/web spread's
  /// titled card.
  final bool sheet;

  /// How far a drop looks for a task dragged in from another day: a week
  /// either way, as hovering a week-strip day pages there mid-drag
  /// (ADR-0015).
  static const _dragReachDays = 7;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = ref.watch(timelineDataProvider(date)).value;
    if (data == null) return _waiting(ref);
    final subtasks = ref.watch(daySubtaskProgressProvider(date)).value;
    final firstSteps = ref.watch(dayFirstStepsProvider(date)).value ?? const {};
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
    final cues = dayCues(
      context.l10n,
      blocks: blocks,
      firstSteps: firstSteps,
      subtasks: subtasks,
      now: now,
    );
    // Today's card offers the Reality thread once the reality threshold
    // was crossed (docs/13 §4.3); there it is read-only for drags. Before
    // that, it promises it in a caption (§4.2).
    final learn = todayLearning(
      context,
      ref,
      isToday: date == today,
      isSide: side != null,
      hasActuals: hasActuals(blocks),
      realityOn: ref.watch(realityModeProvider),
      settings: data.settings,
      now: now,
      today: today,
    );
    final offerReality = learn.offer;
    final learning = offerReality
        ? ref.watch(learningIndexProvider).value
        : null;
    final reality = offerReality && ref.watch(realityModeProvider)
        ? realityThread(
            context.l10n,
            format,
            blocks: blocks,
            nowUtc: now,
            learning: learning,
            resetFor: (task) =>
                () => ref
                    .read(learningMetaProvider.notifier)
                    .resetUndoable(
                      task.title,
                      ref.read(clockProvider).nowUtc(),
                    ),
          )
        : null;
    final entries = threadEntries(
      blocks: reality?.blocks ?? blocks,
      shape: shape,
      nowUtc: now,
      format: format,
      subtasks: subtasks ?? const {},
      smallestSteps: reality == null ? cues.smallestSteps : const {},
      unstick: reality == null ? cues.unstick : const {},
      showFreeTime: data.settings.showFreeTime,
      reality: reality?.reality,
    );
    final actions = _actions(
      context,
      ref,
      data,
      format.time,
      drag: reality == null,
    );
    if (side case final s?) {
      return DayCard.side(
        title: DateFormat.EEEE(_locale(context)).format(date),
        side: s,
        summary: summary,
        entries: entries,
        actions: actions,
      );
    }
    final toggle = offerReality
        ? RealityToggle(
            on: reality != null,
            onChanged: (on) =>
                ref.read(realityModeProvider.notifier).set(on: on),
            highlight: learn.highlight,
          )
        : null;
    final footer = _footer(blocks, summary.total == 0);
    final card = sheet
        ? DayCard.sheet(
            entries: entries,
            actions: actions,
            footer: footer,
            handle: PullHandle(
              open: ref.watch(
                todaySelectionProvider.select((v) => v.monthOpen),
              ),
              onPull: ref.read(todaySelectionProvider.notifier).toggleMonth,
            ),
            reality: toggle,
            note: learn.note,
          )
        : DayCard(
            title: _title(context),
            isToday: date == today,
            summary: summary,
            entries: entries,
            actions: actions,
            footer: footer,
            reality: toggle,
            note: learn.note,
          );
    final insight = reality == null
        ? null
        : realityInsight(blocks, now, learning);
    if (insight == null ||
        ref.watch(dismissedInsightsProvider).contains(insight.task.id)) {
      return card;
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(child: card),
        RealityInsightStrip(
          task: insight.task,
          usualMinutes: insight.usualMinutes,
          samples: insight.samples,
        ),
      ],
    );
  }

  /// Skeleton or Try again while the day loads (docs/09 M3f.9b).
  Widget _waiting(WidgetRef ref) =>
      screenState([
        ref.watch(timelineDataProvider(date)),
      ], onRetry: () => ref.invalidate(timelineDataProvider(date))) ??
      const LoadingThread();

  /// Taps, drag, resize and selection for this day's thread; without
  /// [drag] (the Reality thread) nothing can be dragged or resized.
  ThreadActions _actions(
    BuildContext context,
    WidgetRef ref,
    TimelineData data,
    String Function(DateTime utc) time, {
    required bool drag,
  }) {
    final picked = ref.watch(taskSelectionProvider);
    final s = data.settings;
    return dayThreadActions(
      context,
      ref,
      blocks: data.blocks,
      timeText: time,
      drag: !drag
          ? null
          : dayThreadDrag(
              context,
              ref,
              blocks: data.blocks,
              zone: data.day.location,
              snapMinutes: s.snapMinutes,
              timeText: time,
              shiftFollowers: s.shiftFollowers,
              includeCalendar: s.includeCalendarInShift,
              readOnlyIds: ref.watch(readOnlyCalendarIdsProvider).value,
              elsewhere: (id) => _elsewhere(ref, id),
              defaultMinutes: s.defaultDurationMin,
              allDayStartUtc: data.day.startUtc,
            ),
      selectedIds: picked.day == date ? picked.ids : const {},
      onSelect: (id) =>
          ref.read(taskSelectionProvider.notifier).toggle(date, id),
      onCap: (windDown) => unawaited(
        showCapTimeSheet(context, date: date, windDown: windDown, settings: s),
      ),
    );
  }

  /// A task from a nearby day (the spread's columns) or the Inbox sidebar
  /// (M3e.2), dropped on this one.
  Occurrence? _elsewhere(WidgetRef ref, String id) {
    final inbox = ref.read(inboxItemsProvider).value;
    final fromInbox = inbox?.where((o) => o.id == id).firstOrNull;
    if (fromInbox != null) return fromInbox;
    for (var d = -_dragReachDays; d <= _dragReachDays; d++) {
      final day = DateTime(date.year, date.month, date.day + d);
      final data = ref.read(timelineDataProvider(day)).value;
      // This day's all-day chips too: dragged onto the thread (ADR-0015).
      final rows = d == 0 ? data?.allDay : [...?data?.blocks, ...?data?.allDay];
      final hit = rows?.where((o) => o.id == id).firstOrNull;
      if (hit != null) return hit;
    }
    return null;
  }

  static String _locale(BuildContext context) =>
      Localizations.localeOf(context).toLanguageTag();

  /// A free day from today on offers its actions (`A-ios-future-month`);
  /// an empty past day only says so.
  Widget? _footer(List<Occurrence> blocks, bool empty) {
    final oneOffs = blocks.any((o) => o.seriesId == null);
    if (date.isBefore(today)) return empty ? const EmptyDayLine() : null;
    if (oneOffs) return null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (empty) const EmptyDayLine(),
        EmptyDayActions(date: date),
      ],
    );
  }

  /// "Wednesday" in the week around today, "Monday, December 14" further
  /// out (`A-ios-future-month`).
  String _title(BuildContext context) {
    final locale = _locale(context);
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
