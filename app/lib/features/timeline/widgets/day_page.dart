import 'dart:async';

import 'package:dottoday/core/clock/clock_provider.dart';
import 'package:dottoday/core/editing/inspected_task.dart';
import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/data/calendar/calendar_shift_providers.dart';
import 'package:dottoday/data/inbox/inbox_providers.dart';
import 'package:dottoday/data/layout/layout_providers.dart';
import 'package:dottoday/data/layout/touch_content.dart';
import 'package:dottoday/data/scheduling/learning_meta.dart';
import 'package:dottoday/data/scheduling/learning_providers.dart';
import 'package:dottoday/data/wake_up/wake_up_providers.dart';
import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:dottoday/domain/layout/feature_id.dart';
import 'package:dottoday/domain/time/day_shape.dart';
import 'package:dottoday/features/timeline/state/day_cues.dart';
import 'package:dottoday/features/timeline/state/day_ends.dart';
import 'package:dottoday/features/timeline/state/day_hours.dart';
import 'package:dottoday/features/timeline/state/day_summary.dart';
import 'package:dottoday/features/timeline/state/earlier_fold.dart';
import 'package:dottoday/features/timeline/state/reality_thread.dart';
import 'package:dottoday/features/timeline/state/task_selection.dart';
import 'package:dottoday/features/timeline/state/timeline_providers.dart';
import 'package:dottoday/features/timeline/widgets/cap_time_sheet.dart';
import 'package:dottoday/features/timeline/widgets/day_actions.dart';
import 'package:dottoday/features/timeline/widgets/day_drag.dart';
import 'package:dottoday/features/timeline/widgets/day_hours_header.dart';
import 'package:dottoday/features/timeline/widgets/empty_day_actions.dart';
import 'package:dottoday/features/timeline/widgets/later_row.dart';
import 'package:dottoday/features/timeline/widgets/reality_insight.dart';
import 'package:dottoday/features/timeline/widgets/running_late_sheet.dart';
import 'package:dottoday/features/timeline/widgets/today_learning.dart';
import 'package:dottoday/features/timeline/workspace/workspace_scope.dart';
import 'package:dottoday/shared/dot/day_card.dart';
import 'package:dottoday/shared/dot/thread.dart';
import 'package:dottoday/shared/dot/thread_day.dart';
import 'package:dottoday/shared/duration/duration_chips.dart';
import 'package:dottoday/shared/states/screen_states.dart';
import 'package:dottoday/shared/time/time_labels.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:timezone/timezone.dart' as tz;

/// One page of the Today pager: [date]'s thread on a [DayCard.page]
/// (`Main`, ADR-0015); with [hours], the Workspace's Day view.
class DayPage extends ConsumerWidget {
  const DayPage({
    required this.date,
    required this.today,
    this.page = false,
    this.hours = false,
    super.key,
  });

  final DateTime date;
  final DateTime today;

  /// The phones' pager page: the thread straight on the page
  /// ([DayCard.page], E-Phones) whose numbers live in the screen header.
  /// Off, the Mac/web spread's titled card.
  final bool page;

  /// The Workspace's Day view (E-FullA-v2 web Day, M19.2 part 2): the page
  /// thread on the hour scale under the day's header line.
  final bool hours;

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
    // The effective Wind Down caps the thread (docs/15 W4).
    final shape =
        ref.watch(dayEndsProvider(date)).value?.shape ??
        DayShape.on(
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
      isSide: false,
      hasActuals: hasActuals(blocks),
      realityOn: ref.watch(realityModeProvider),
      settings: data.settings,
      now: now,
      today: today,
    );
    // Minimal layout (docs/14 §3): no Plan / Reality switch and no
    // "coming" caption; learning itself keeps running.
    final realityShown = watchOnScreen(ref, FeatureId.realityThread);
    final offerReality = realityShown && learn.offer;
    final note = realityShown ? learn.note : null;
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
    final minimal = watchSimplified(ref, FeatureId.threadOutside);
    final threaded = threadEntries(
      blocks: reality?.blocks ?? blocks,
      shape: shape,
      nowUtc: now,
      format: format,
      subtasks: subtasks ?? const {},
      smallestSteps: reality == null ? cues.smallestSteps : const {},
      unstick: reality == null ? cues.unstick : const {},
      showFreeTime: data.settings.showFreeTime,
      reality: reality?.reality,
      // Today's one thing rings on today only (docs/15 §8).
      oneThingId: date == today ? ref.watch(todayOneThingIdProvider) : null,
      outsideCounted: !minimal,
    );
    // Today folds its done tasks into Earlier on Minimal phones and on the
    // Mac/web card; Full phones keep their rows (ED-164, docs/14 §3).
    final fold = date == today && (!page || minimal);
    final entries = fold
        ? foldEarlier(
            threaded,
            open: ref.watch(earlierOpenProvider).contains(date),
          )
        : threaded;
    // Full phones draw an empty day's free time as E-Phones does: the
    // free hours, a line and the actions inside the thread (M19.1).
    // Minimal keeps its quiet line (docs/14 §3, M19.6); past days too.
    final emptyActions = !watchSimplified(ref, FeatureId.emptyDayActions);
    final emptyBody =
        page && summary.total == 0 && !date.isBefore(today) && emptyActions;
    final actions = _actions(
      context,
      ref,
      data,
      format.time,
      drag: reality == null,
      // Today's free time left after now; another day's whole day.
      emptyDay: emptyBody
          ? (minutes) => EmptyDayBody(date: date, freeMinutes: minutes)
          : null,
    );
    final toggle = offerReality
        ? RealityToggle(
            on: reality != null,
            onChanged: (on) =>
                ref.read(realityModeProvider.notifier).set(on: on),
            highlight: learn.highlight,
          )
        : null;
    final footer = _footer(
      blocks,
      summary.total == 0,
      inThread: emptyBody,
      emptyActions: emptyActions,
      later: page && watchSimplified(ref, FeatureId.inbox),
    );
    final card = page
        ? DayCard.page(
            entries: entries,
            actions: actions,
            footer: footer,
            reality: toggle,
            note: note,
            openAtNow: date == today,
            hours: hours
                ? dayHours(
                    entries,
                    zone: data.day.location,
                    // Touch sizes: the grid's 96 an hour (ED-269, owner).
                    pxPerMinute:
                        (watchTouchContent(context, ref)
                            ? DotSize.gridTouchHour
                            : DotSize.gridDayHour) /
                        Duration.minutesPerHour,
                    label: (local) => DateFormat.j(
                      _locale(context),
                    ).format(DateTime(2026, 1, 1, local.hour)),
                    nowUtc: date == today ? now : null,
                  )
                : null,
          )
        : DayCard(
            title: _title(context),
            isToday: date == today,
            summary: summary,
            entries: entries,
            actions: actions,
            footer: footer,
            reality: toggle,
            note: note,
            openAtNow: date == today,
          );
    if (hours) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          DayHoursHeader(
            date: date,
            isToday: date == today,
            summary: summary,
            wake: format.time(shape.wakeUtc),
            windDown: format.time(shape.bedUtc),
          ),
          // The thread keeps a readable width from the gutter.
          Expanded(
            child: Align(
              alignment: AlignmentDirectional.topStart,
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: hourGutter(context) + DotSize.readableColumn,
                ),
                child: card,
              ),
            ),
          ),
        ],
      );
    }
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
    Widget Function(int freeMinutes)? emptyDay,
  }) {
    final picked = ref.watch(taskSelectionProvider);
    final s = data.settings;
    return dayThreadActions(
      context,
      ref,
      blocks: data.blocks,
      timeText: time,
      emptyDay: emptyDay,
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
      pickedId: WorkspaceScope.of(context)
          ? ref.watch(inspectedTaskProvider)
          : null,
      onEarlier: (open) =>
          ref.read(earlierOpenProvider.notifier).set(date, open: open),
      onSelect: (id) =>
          ref.read(taskSelectionProvider.notifier).toggle(date, id),
      // Minimal keeps the caps as labels (docs/14 §3).
      onCap: watchOnScreen(ref, FeatureId.capTimeEdit)
          ? (windDown) => unawaited(
              showCapTimeSheet(
                context,
                date: date,
                windDown: windDown,
                settings: s,
              ),
            )
          : null,
      // Minimal: Running late on the live row (docs/14 §4).
      onRunningLate: watchSimplified(ref, FeatureId.shiftRunningLate)
          ? (_) => unawaited(showRunningLateSheet(context, today))
          : null,
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
  ///
  /// Minimal (docs/14 §3): no empty-day actions ([emptyActions] false), and
  /// from today on the thread ends in the [LaterRow] ([later]).
  /// Below the thread. [inThread]: the empty day's line and actions are
  /// already in the thread's free time, so only Later is left here.
  Widget? _footer(
    List<Occurrence> blocks,
    bool empty, {
    required bool inThread,
    required bool emptyActions,
    required bool later,
  }) {
    final oneOffs = blocks.any((o) => o.seriesId == null);
    if (date.isBefore(today)) return empty ? const EmptyDayLine() : null;
    if (inThread) return later ? const LaterRow() : null;
    final actions = emptyActions && !oneOffs;
    if (!actions && !later) return empty ? const EmptyDayLine() : null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (empty) const EmptyDayLine(),
        if (actions) EmptyDayActions(date: date, inset: true),
        if (later) const LaterRow(),
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
