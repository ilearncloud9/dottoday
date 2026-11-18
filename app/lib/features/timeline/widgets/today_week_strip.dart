import 'dart:async';

import 'package:dottoday/core/failures/result.dart';
import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/l10n/weekday_names.dart';
import 'package:dottoday/data/trash/trash_providers.dart';
import 'package:dottoday/features/timeline/state/drag_actions.dart';
import 'package:dottoday/features/timeline/state/today_selection.dart';
import 'package:dottoday/features/timeline/widgets/day_actions.dart';
import 'package:dottoday/shared/dot/week_strip.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

/// The week around [shown], starting on the profile's first day of week
/// (Settings › Week starts), as E-Phones draws it: no completion dots,
/// in Full and Minimal alike (docs/14 §3, "Week strip + month pull-open").
class TodayWeekStrip extends ConsumerWidget {
  const TodayWeekStrip({
    required this.shown,
    required this.today,
    required this.firstDayOfWeek,
    required this.monthOpen,
    required this.onSelect,
    super.key,
  });

  final DateTime shown;
  final DateTime today;

  /// 1 = Monday … 7 = Sunday (docs/05 Settings).
  final int firstDayOfWeek;
  final bool monthOpen;
  final ValueChanged<DateTime> onSelect;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final start = weekStart(shown, firstDayOfWeek);
    final week = [
      for (var i = 0; i < 7; i++)
        DateTime(start.year, start.month, start.day + i),
    ];
    final strip = WeekStrip(
      days: [for (final d in week) _day(context, d)],
      selected: week.indexOf(DateTime(shown.year, shown.month, shown.day)),
      monthOpen: monthOpen,
      onSelect: (i) => onSelect(week[i]),
      // No handle (E-Phones): the strip itself pulls the month down.
      handle: false,
      onDropTask: (id, i) => unawaited(_drop(context, ref, id, week[i])),
    );
    // Pulling the strip down opens the month (E-Phones, "built, kept");
    // the title does the same with a tap, also for a screen reader.
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onVerticalDragEnd: (d) {
        if ((d.primaryVelocity ?? 0) > 0 && !monthOpen) {
          ref.read(todaySelectionProvider.notifier).toggleMonth();
        }
      },
      child: strip,
    );
  }

  /// Moves the dropped task to [date] at the same time, with Undo.
  Future<void> _drop(
    BuildContext context,
    WidgetRef ref,
    String id,
    DateTime date,
  ) async {
    final messenger = ScaffoldMessenger.of(context);
    final l10n = context.l10n;
    final undo = ref.read(undoServiceProvider);
    final day = DateFormat.MMMMEEEEd(
      Localizations.localeOf(context).toLanguageTag(),
    ).format(date);
    final result = await moveToDay(ref, id, date);
    if (result case Ok(value: null)) return;
    reportUndoable(
      messenger,
      l10n,
      undo,
      result,
      message: (v) => l10n.snackMovedDay(v!.$1.title, day),
      tokenOf: (v) => v!.$2,
    );
  }

  /// A day as E-Phones draws it: no completion dot (M19.1), so the label
  /// is the date alone; the shown day's numbers are in the summary line.
  StripDay _day(BuildContext context, DateTime d) {
    final locale = Localizations.localeOf(context).toLanguageTag();
    return StripDay(
      weekday: DateFormat.E(locale).format(d),
      weekdayNarrow: narrowWeekday(locale, d),
      date: DateFormat.d(locale).format(d),
      label: DateFormat.MMMMEEEEd(locale).format(d),
      isToday: d == today,
    );
  }
}

/// The first day of the week holding [d] (local calendar date).
DateTime weekStart(DateTime d, int firstDayOfWeek) {
  final back = (d.weekday - firstDayOfWeek) % 7;
  return DateTime(d.year, d.month, d.day - back);
}
