import 'dart:async';

import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/router/app_routes.dart';
import 'package:dottoday/core/shortcuts/app_shortcuts.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/data/inbox/inbox_providers.dart';
import 'package:dottoday/data/trash/trash_providers.dart';
import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:dottoday/domain/entities/settings.dart';
import 'package:dottoday/domain/scheduling/week_summary.dart';
import 'package:dottoday/domain/time/clock_time.dart';
import 'package:dottoday/domain/time/day_shape.dart';
import 'package:dottoday/features/timeline/state/drag_actions.dart';
import 'package:dottoday/features/timeline/state/timeline_providers.dart';
import 'package:dottoday/features/timeline/week/week_board.dart';
import 'package:dottoday/features/timeline/week/week_day_column.dart';
import 'package:dottoday/features/timeline/week/week_header.dart';
import 'package:dottoday/features/timeline/week/week_pieces.dart';
import 'package:dottoday/features/timeline/widgets/day_actions.dart';
import 'package:dottoday/shared/dot/thread.dart';
import 'package:dottoday/shared/dot/thread_day.dart';
import 'package:dottoday/shared/duration/duration_chips.dart';
import 'package:dottoday/shared/time/time_labels.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
    final (first, last) = _axisHours(shapes, data, zone);
    final axisMinutes = (last - first) * Duration.minutesPerHour;
    final board = WeekBoard(
      loads: loads,
      summary: summary,
      today: today,
      hourLabels: _labels(context, first, last),
      axisMinutes: axisMinutes,
      columns: [
        for (final (i, d) in data.indexed)
          _column(context, ref, d, shapes[i], loads[i], first, axisMinutes),
      ],
    );
    return _keys(
      Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(
          DotSpace.xxl,
          DotSpace.xl,
          DotSpace.xl,
          0,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: DotSpace.l,
          children: [
            WeekHeader(
              days: days,
              today: today,
              summary: summary,
              onPrevious: onPrevious,
              onNext: onNext,
              onToday: onToday,
              onMonth: onMonth,
            ),
            Expanded(child: board),
          ],
        ),
      ),
    );
  }

  /// ⌘← / ⌘→ step a week, ⌘T back to this week (Ctrl elsewhere).
  Widget _keys(Widget child) {
    final p = defaultTargetPlatform;
    return CallbackShortcuts(
      bindings: {
        AppShortcuts.activator(p, LogicalKeyboardKey.arrowLeft): onPrevious,
        AppShortcuts.activator(p, LogicalKeyboardKey.arrowRight): onNext,
        AppShortcuts.activator(p, LogicalKeyboardKey.keyT): onToday,
      },
      child: Focus(autofocus: true, child: child),
    );
  }

  /// The earliest Wake Up or task start and the latest Bedtime or task
  /// end of the week, in whole local hours, so every day fits one shared
  /// axis (a 6:45 run or a late train stays on the board).
  static (int, int) _axisHours(
    List<DayShape> shapes,
    List<TimelineData> data,
    tz.Location zone,
  ) {
    var first = 24;
    var last = 0;
    void cover(DateTime startUtc, DateTime endUtc) {
      final start = ClockTime.ofUtc(zone, startUtc);
      final end = ClockTime.ofUtc(zone, endUtc);
      final sameDay =
          endUtc.difference(startUtc) < const Duration(days: 1) &&
          (end.hour > start.hour ||
              (end.hour == start.hour && end.minute >= start.minute));
      if (start.hour < first) first = start.hour;
      final through = !sameDay
          ? 24
          : (end.minute > 0 ? end.hour + 1 : end.hour);
      if (through > last) last = through;
    }

    for (final s in shapes) {
      cover(s.wakeUtc, s.bedUtc);
    }
    for (final d in data) {
      for (final o in d.blocks) {
        if (o.startUtc case final at?) cover(at, o.endUtc!);
      }
    }
    return (first, last <= first ? first + 1 : last);
  }

  List<String> _labels(BuildContext context, int first, int last) {
    final locale = Localizations.localeOf(context).toLanguageTag();
    final format = DateFormat.j(locale);
    return [
      for (var h = first; h < last; h += 3)
        format.format(DateTime(2026, 1, 1, h)),
    ];
  }

  Widget _column(
    BuildContext context,
    WidgetRef ref,
    TimelineData d,
    DayShape shape,
    DayLoad load,
    int firstHour,
    int axisMinutes,
  ) {
    final l10n = context.l10n;
    final zone = d.day.location;
    final use24h = use24hFor(context, profile.settings.use24h);
    String time(DateTime utc) => timeOfUtc(context, zone, utc, use24h: use24h);
    final date = d.day.date;
    final tasks = _tasks(context, d, shape, time);
    final isToday = date == today;
    final locale = Localizations.localeOf(context).toLanguageTag();
    return WeekDayColumn(
      day: WeekDayView(
        date: date,
        tasks: tasks,
        starts: {
          for (final o in d.blocks)
            if (o.startUtc case final s?)
              o.id: (startUtc: s, minutes: o.durationMin),
        },
        axisStartUtc: ClockTime(firstHour, 0).onDate(zone, date),
        isToday: isToday,
        open: !date.isBefore(today),
        freeText: formatDurationShort(l10n, load.freeMinutes),
        nowUtc: isToday ? nowUtc : null,
      ),
      axisMinutes: axisMinutes,
      find: (id) => _find(ref, id),
      dropLabel: (start, minutes) => l10n.weekDropAt(
        DateFormat.E(locale).format(date),
        l10n.threadTimeRange(
          time(start),
          time(start.add(Duration(minutes: minutes))),
        ),
      ),
      onDrop: (id, start) => unawaited(_move(context, ref, id, start, time)),
      onOpen: (id) => unawaited(context.push(AppRoutes.task(id))),
      onAdd: () => Actions.maybeInvoke(context, AddTaskIntent(day: date)),
    );
  }

  /// [d]'s timed tasks with their states, as the thread reads them.
  List<ThreadTask> _tasks(
    BuildContext context,
    TimelineData d,
    DayShape shape,
    String Function(DateTime utc) time,
  ) {
    final l10n = context.l10n;
    return [
      for (final e in threadEntries(
        blocks: d.blocks,
        shape: shape,
        nowUtc: nowUtc,
        format: ThreadFormat(
          time: time,
          range: l10n.threadTimeRange,
          duration: (m) => formatDurationShort(l10n, m),
        ),
      ))
        if (e case ThreadTaskEntry(:final task)) task,
    ];
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
