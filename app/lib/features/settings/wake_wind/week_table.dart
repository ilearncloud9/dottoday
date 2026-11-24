import 'dart:async';

import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/domain/entities/enums.dart';
import 'package:dottoday/domain/entities/settings.dart';
import 'package:dottoday/domain/time/clock_time.dart';
import 'package:dottoday/domain/time/day_boundaries.dart';
import 'package:dottoday/domain/time/schedules.dart';
import 'package:dottoday/features/settings/wake_wind/schedule_cards.dart';
import 'package:dottoday/features/settings/wake_wind/schedule_sheet/schedule_sheet.dart';
import 'package:dottoday/features/settings/wake_wind/schedule_sheet/schedule_text.dart';
import 'package:dottoday/features/settings/widgets/day_shape_group.dart';
import 'package:dottoday/features/settings/widgets/settings_change.dart';
import 'package:dottoday/shared/duration/duration_chips.dart';
import 'package:dottoday/shared/feedback/undo_snackbar.dart';
import 'package:dottoday/shared/settings/settings_form.dart';
import 'package:dottoday/shared/time_input/time_input_sheet.dart';
import 'package:flutter/material.dart';

/// The week as a table on a Mac/web form (E-FullA-v2 "Mac · Your day ›
/// Wake Up and Wind Down", ED-084; ED-452): each day with its schedule,
/// Wake Up, Wind Down, the night after it and whether it rings. The
/// selected schedule's rows are tinted; a schedule's name opens its sheet.
/// Typing a day's time splits it from its schedule, with Undo.
class WeekTable extends StatelessWidget {
  const WeekTable({
    required this.settings,
    required this.selected,
    required this.onSelect,
    required this.alarmHeader,
    super.key,
  });

  final Settings settings;

  /// The selected schedule's days.
  final List<Weekday> selected;
  final ValueChanged<List<Weekday>> onSelect;

  /// "Alarm (iPhone)".
  final String alarmHeader;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final l10n = context.l10n;
    final schedules = schedulesOf(settings, firstDay: settings.firstDayOfWeek);
    final days = [for (final s in schedules) ...s.days]
      ..sort((a, b) => _order(a).compareTo(_order(b)));
    final head = t.styles.inspectorLabel.copyWith(fontWeight: FontWeight.w700);
    Widget th(String s) => Padding(
      padding: const EdgeInsets.all(DotSpace.s - DotSpace.xxs),
      child: Text(s, style: head),
    );
    return Table(
      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
      columnWidths: const {
        0: FlexColumnWidth(1.3),
        1: FlexColumnWidth(1.4),
        2: FlexColumnWidth(1.3),
        3: FlexColumnWidth(1.3),
        4: FlexColumnWidth(0.9),
        5: FlexColumnWidth(1.1),
      },
      children: [
        TableRow(
          decoration: _line(t),
          children: [
            th(l10n.wwdColDay),
            th(l10n.wwdColSchedule),
            th(l10n.settingsWakeUp),
            th(l10n.settingsWindDown),
            th(l10n.wwdColNight),
            th(alarmHeader),
          ],
        ),
        for (final d in days)
          _row(
            context,
            t,
            d,
            schedules.indexWhere((s) => s.days.contains(d)),
            schedules,
          ),
      ],
    );
  }

  int _order(Weekday d) => (d.index + 8 - settings.firstDayOfWeek) % 7;

  BoxDecoration _line(DotTheme t, {bool tint = false}) => BoxDecoration(
    color: tint ? t.colors.chip : null,
    border: Border(bottom: BorderSide(color: t.colors.outline)),
  );

  TableRow _row(
    BuildContext context,
    DotTheme t,
    Weekday day,
    int index,
    List<DaySchedule> schedules,
  ) {
    final l10n = context.l10n;
    final schedule = schedules[index];
    final window = settings.boundaryFor(day);
    final name = scheduleName(l10n, schedule.days);
    final dayName = weekdayFull(context, day);
    final rings = settings.wakeUpAlarmDays.contains(day);
    final text = t.styles.inspectorValue;
    Widget cell(Widget child) => Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: DotSpace.s - DotSpace.xxs,
        vertical: DotSpace.xs,
      ),
      child: Align(alignment: AlignmentDirectional.centerStart, child: child),
    );
    Widget time(String field, int minute, bool wake) => FormButton(
      label: clockText(context, minute, settings.use24h),
      semanticLabel: l10n.wwdDayTime(field, dayName),
      onPressed: () => unawaited(
        _editDay(context, day, field, minute, wake: wake, from: schedule),
      ),
    );
    return TableRow(
      decoration: _line(t, tint: _same(schedule.days, selected)),
      children: [
        cell(
          InkWell(
            onTap: () => onSelect(schedule.days),
            child: Text(
              dayName,
              style: text.copyWith(fontWeight: FontWeight.w700),
            ),
          ),
        ),
        cell(
          Semantics(
            button: true,
            label: l10n.wwdChangeSchedule(name),
            excludeSemantics: true,
            child: InkWell(
              onTap: () =>
                  unawaited(showScheduleSheet(context, days: schedule.days)),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                spacing: DotSpace.xs + DotSpace.xxs,
                children: [
                  Container(
                    width: DotSpace.s,
                    height: DotSpace.s,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: t
                          .tasks[ScheduleCards.dots[index %
                              ScheduleCards.dots.length]]
                          .color,
                    ),
                  ),
                  Flexible(
                    child: Text(
                      name,
                      style: text.copyWith(
                        color: t.colors.accentInk,
                        decoration: TextDecoration.underline,
                        decorationColor: t.colors.accentInk,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        cell(time(l10n.settingsWakeUp, windowMinutes(window.start), true)),
        cell(
          time(
            l10n.settingsWindDown,
            windowMinutes(window.end) % Duration.minutesPerDay,
            false,
          ),
        ),
        cell(
          Text(
            formatDurationShort(l10n, nightAfter(settings, day)),
            style: text.copyWith(color: t.colors.muted),
          ),
        ),
        cell(
          FormCheck(
            value: rings,
            title: '',
            semanticLabel: l10n.wwdDayTime(alarmHeader, dayName),
            // Each day's "Ring on these days" (ED-448); with the alarm off
            // there is nothing to ring.
            onChanged: settings.wakeUpAlarm
                ? (on) => changeSettings(
                    context,
                    (s) => s.copyWith(
                      wakeUpAlarmDays: on
                          ? {...s.wakeUpAlarmDays, day}
                          : ({...s.wakeUpAlarmDays}..remove(day)),
                    ),
                  )
                : null,
          ),
        ),
      ],
    );
  }

  static bool _same(List<Weekday> a, List<Weekday> b) =>
      a.length == b.length && a.toSet().containsAll(b);

  /// Types [day]'s Wake Up ([wake]) or Wind Down; a day that shared its
  /// schedule leaves it, and the toast offers Undo (E-FullA-v2's rule).
  Future<void> _editDay(
    BuildContext context,
    Weekday day,
    String field,
    int minute, {
    required bool wake,
    required DaySchedule from,
  }) async {
    final messenger = ScaffoldMessenger.of(context);
    final l10n = context.l10n;
    final dayName = weekdayFull(context, day);
    final picked = await showTimeInputSheet(
      context,
      title: l10n.wwdDayTime(field, dayName),
      initial: ClockTime.fromMinutes(minute),
      use24h: settings.use24h,
    );
    if (picked == null || !context.mounted) return;
    final before = settings.dayBoundaries;
    final old = settings.boundaryFor(day);
    final oldWake = windowMinutes(old.start);
    // Stored as the editors store it: 24:30 for 12:30 AM (Q8).
    final window = wake
        ? dayWindow(picked.minutesOfDay, windowMinutes(old.end))
        : dayWindow(oldWake, picked.minutesOfDay);
    if (window == old) return;
    changeSettings(
      context,
      (s) => s.copyWith(dayBoundaries: {...s.dayBoundaries, day: window}),
    );
    if (from.days.length < 2) return;
    showUndoSnackbarOn(
      messenger,
      l10n,
      message: l10n.wwdDaySplit(dayName),
      onUndo: () =>
          changeSettings(context, (s) => s.copyWith(dayBoundaries: before)),
    );
  }
}
