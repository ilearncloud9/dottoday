import 'dart:async';

import 'package:dottoday/core/editing/editing_task.dart';
import 'package:dottoday/core/editing/inspected_task.dart';
import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/shortcuts/single_keys.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/data/inbox/inbox_providers.dart';
import 'package:dottoday/data/layout/touch_content.dart';
import 'package:dottoday/data/trash/trash_providers.dart';
import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:dottoday/domain/entities/settings.dart';
import 'package:dottoday/domain/scheduling/week_summary.dart';
import 'package:dottoday/domain/time/clock_time.dart';
import 'package:dottoday/domain/time/day_shape.dart';
import 'package:dottoday/features/timeline/state/drag_actions.dart';
import 'package:dottoday/features/timeline/state/timeline_providers.dart';
import 'package:dottoday/features/timeline/week/grid_axis.dart';
import 'package:dottoday/features/timeline/week/grid_focus.dart';
import 'package:dottoday/features/timeline/week/grid_proposed.dart';
import 'package:dottoday/features/timeline/week/grid_scale.dart';
import 'package:dottoday/features/timeline/week/week_board.dart';
import 'package:dottoday/features/timeline/week/week_day_column.dart';
import 'package:dottoday/features/timeline/week/week_header.dart';
import 'package:dottoday/features/timeline/week/week_pieces.dart';
import 'package:dottoday/features/timeline/week/week_tasks.dart';
import 'package:dottoday/features/timeline/widgets/day_actions.dart';
import 'package:dottoday/features/timeline/workspace/inspector_pick.dart';
import 'package:dottoday/features/timeline/workspace/workspace_scope.dart';
import 'package:dottoday/shared/time/time_labels.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:timezone/timezone.dart' as tz;

/// The Week board for [days] with their [data] (M3e.3): header, summary
/// chips and columns; drops move a task (a week's or the Inbox's) with
/// Undo; ⌘← ⌘T ⌘→ step the week.
class WeekView extends ConsumerWidget {
  const WeekView({
    required this.days,
    required this.data,
    required this.today,
    required this.nowUtc,
    required this.profile,
    required this.onPrevious,
    required this.onNext,
    required this.onToday,
    required this.onMonth,
    this.cues = true,
    super.key,
  });

  final List<DateTime> days;
  final List<TimelineData> data;
  final DateTime today;
  final DateTime nowUtc;
  final Profile profile;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final VoidCallback onToday;
  final VoidCallback onMonth;

  /// The week's header and cue chips (Busiest, Lightest, Free, Done);
  /// 3 days shows the grid alone (E-R2-30).
  final bool cues;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Touch sizes on tablets and touch-first web (ED-269).
    final scale = watchTouchContent(context, ref)
        ? GridScale.touchSizes
        : GridScale.pointer;
    final zone = data.first.day.location;
    final shapes = [
      for (final d in data)
        DayShape.on(
          d.day.location,
          d.day.date,
          d.settings.boundaryFor(d.day.weekday),
        ),
    ];
    final loads = [
      for (final (i, d) in data.indexed)
        DayLoad.of(days[i], d.blocks, shapes[i]),
    ];
    final summary = WeekSummary.of(loads);
    final (first, last) = gridAxisHours(shapes, data, zone);
    final axisMinutes =
        (last - first) * Duration.minutesPerHour + GridScale.leadMinutes * 2;
    final todayAt = days.indexOf(today);
    final axisStart = todayAt < 0 ? null : _axisStart(zone, today, first);
    final use24h = use24hFor(context, profile.settings.use24h);
    // Arrow keys between the blocks (handoff "Week", M19.2 part 3b).
    final board = GridFocus(
      child: WeekBoard(
        loads: loads,
        today: today,
        hourLabels: _labels(context, first, last),
        axisMinutes: axisMinutes,
        nowY: axisStart == null
            ? null
            : nowUtc.difference(axisStart).inSeconds /
                  Duration.secondsPerMinute *
                  scale.pxPerMinute,
        nowText: timeOfUtc(context, zone, nowUtc, use24h: use24h),
        long: !cues,
        columns: [
          for (final (i, d) in data.indexed)
            _column(context, ref, d, shapes[i], first, axisMinutes),
        ],
      ),
    );
    if (!cues) return _keys(GridScaleScope(scale: scale, child: board));
    // The header (or, in the Workspace, the cue chips) over the grid; the
    // grid runs to the content's edges (E-FullA-v2 Week).
    return _keys(
      LayoutBuilder(
        builder: (context, box) => Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // At large text the header may be taller than the window: it
            // gets half and scrolls itself, the grid keeps the rest
            // (M3f.9b).
            ConstrainedBox(
              constraints: BoxConstraints(maxHeight: box.maxHeight / 2),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(DotSpace.m),
                child: WeekHeader(
                  days: days,
                  today: today,
                  summary: summary,
                  onPrevious: onPrevious,
                  onNext: onNext,
                  onToday: onToday,
                  onMonth: onMonth,
                ),
              ),
            ),
            Expanded(
              child: GridScaleScope(scale: scale, child: board),
            ),
          ],
        ),
      ),
    );
  }

  /// ⌘← / ⌘→ step a week, ⌘T back to this week (web `[` `]` `t`).
  Widget _keys(Widget child) {
    return PeriodKeys(
      onPrevious: onPrevious,
      onNext: onNext,
      onCurrent: onToday,
      child: Focus(
        autofocus: true,
        // Catches keys only; adds nothing for screen readers.
        includeSemantics: false,
        // No Tab stop: Tab from here starts at Skip to content (SkipLink).
        skipTraversal: true,
        child: child,
      ),
    );
  }

  /// Every whole hour of the axis, "7 AM" … (the last one too).
  List<String> _labels(BuildContext context, int first, int last) {
    final locale = Localizations.localeOf(context).toLanguageTag();
    final format = DateFormat.j(locale);
    return [
      for (var h = first; h <= last && h < 24; h++)
        format.format(DateTime(2026, 1, 1, h)),
    ];
  }

  /// The axis' top on [date]: half an hour before [firstHour] (DST-aware).
  static DateTime _axisStart(tz.Location zone, DateTime date, int firstHour) =>
      ClockTime(firstHour, 0)
          .onDate(zone, date)
          .subtract(const Duration(minutes: GridScale.leadMinutes));

  Widget _column(
    BuildContext context,
    WidgetRef ref,
    TimelineData d,
    DayShape shape,
    int firstHour,
    int axisMinutes,
  ) {
    final l10n = context.l10n;
    final zone = d.day.location;
    final use24h = use24hFor(context, profile.settings.use24h);
    String time(DateTime utc) => timeOfUtc(context, zone, utc, use24h: use24h);
    final date = d.day.date;
    final tasks = weekTasks(context, ref, d, shape, time, nowUtc: nowUtc);
    final isToday = date == today;
    final locale = Localizations.localeOf(context).toLanguageTag();
    final workspace = WorkspaceScope.of(context);
    return WeekDayColumn(
      day: WeekDayView(
        date: date,
        tasks: tasks,
        starts: {
          for (final o in d.blocks)
            if (o.startUtc case final s?)
              o.id: (startUtc: s, minutes: o.durationMin),
        },
        axisStartUtc: _axisStart(zone, date, firstHour),
        isToday: isToday,
        open: !date.isBefore(today),
        snapMinutes: profile.settings.snapMinutes,
        pickedId: workspace ? ref.watch(inspectedTaskProvider) : null,
        nowUtc: isToday ? nowUtc : null,
      ),
      axisMinutes: axisMinutes,
      proposed: gridProposedOn(ref, date, zone),
      find: (id) => _find(ref, id),
      dropLabel: (start, minutes) => l10n.weekDropAt(
        DateFormat.E(locale).format(date),
        l10n.threadTimeRange(
          time(start),
          time(start.add(Duration(minutes: minutes))),
        ),
      ),
      onDrop: (id, start) => unawaited(_move(context, ref, id, start, time)),
      onMove: (id, minutes, days) {
        final start = _find(ref, id)?.startUtc;
        if (start == null) return;
        final to = _shifted(zone, start, minutes: minutes, days: days);
        unawaited(_move(context, ref, id, to, time));
      },
      // In the Workspace a click picks into the inspector and a second
      // opens the editor (ED-170 C1).
      onEmpty: workspace
          ? () => ref.read(inspectedTaskProvider.notifier).close()
          : null,
      onOpen: (id) => workspace
          ? InspectorPick.click(context, ref, id)
          : ref.read(editingTaskProvider.notifier).open(id),
      onCue: (id) => openWeekCue(
        context,
        ref,
        tasks.where((t) => t.id == id).firstOrNull,
        find: (id) => _find(ref, id),
      ),
    );
  }

  /// [startUtc] moved by [minutes], and by [days] at the same local time
  /// (DST-safe).
  static DateTime _shifted(
    tz.Location zone,
    DateTime startUtc, {
    required int minutes,
    required int days,
  }) {
    final l = tz.TZDateTime.from(startUtc, zone);
    return tz.TZDateTime(
      zone,
      l.year,
      l.month,
      l.day + days,
      l.hour,
      l.minute,
    ).add(Duration(minutes: minutes)).toUtc();
  }

  /// A task of this week or the Inbox.
  Occurrence? _find(WidgetRef ref, String id) {
    for (final d in data) {
      final hit = d.blocks.where((o) => o.id == id).firstOrNull;
      if (hit != null) return hit;
    }
    final inbox = ref.read(inboxItemsProvider).value;
    return inbox?.where((o) => o.id == id).firstOrNull;
  }

  Future<void> _move(
    BuildContext context,
    WidgetRef ref,
    String id,
    DateTime start,
    String Function(DateTime utc) time,
  ) async {
    final o = _find(ref, id);
    if (o == null || start == o.startUtc) return;
    final l10n = context.l10n;
    final messenger = ScaffoldMessenger.of(context);
    final undo = ref.read(undoServiceProvider);
    final result = await moveTask(ref, o, start);
    reportUndoable(
      messenger,
      l10n,
      undo,
      result,
      message: (_) => l10n.snackMoved(o.title, time(start)),
      tokenOf: (t) => t,
    );
  }
}
