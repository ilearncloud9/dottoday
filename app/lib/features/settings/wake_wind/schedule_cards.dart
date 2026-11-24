import 'dart:async';

import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/domain/entities/settings.dart';
import 'package:dottoday/domain/time/day_boundaries.dart';
import 'package:dottoday/domain/time/schedules.dart';
import 'package:dottoday/features/settings/wake_wind/schedule_sheet/schedule_sheet.dart';
import 'package:dottoday/features/settings/wake_wind/schedule_sheet/schedule_text.dart';
import 'package:dottoday/features/settings/widgets/day_shape_group.dart';
import 'package:dottoday/shared/duration/duration_chips.dart';
import 'package:flutter/material.dart';

/// YOUR WEEK (E-Phones, ED-084): one card per schedule — its name and
/// days, whether it rings, Wake Up and Wind Down, the night after its first
/// day and Edit — then Add a schedule and how nights are counted.
class ScheduleCards extends StatelessWidget {
  const ScheduleCards({required this.settings, super.key});

  final Settings settings;

  /// The schedules' dots, in order.
  static const _dots = [
    TaskColor.violet,
    TaskColor.amber,
    TaskColor.teal,
    TaskColor.rose,
    TaskColor.sky,
    TaskColor.mint,
    TaskColor.coral,
  ];

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final l10n = context.l10n;
    final schedules = schedulesOf(settings, firstDay: settings.firstDayOfWeek);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: DotSpace.m,
      children: [
        Padding(
          padding: const EdgeInsetsDirectional.only(start: DotSpace.xs),
          child: Semantics(
            header: true,
            child: Text(l10n.wwdYourWeek, style: t.styles.caption),
          ),
        ),
        for (final (i, s) in schedules.indexed)
          _ScheduleCard(
            schedule: s,
            dot: _dots[i % _dots.length],
            settings: settings,
            onEdit: () => unawaited(showScheduleSheet(context, days: s.days)),
          ),
        // Each day its own schedule: nothing left to add (E-Phones checks
        // "Every day covered").
        if (schedules.length == 7)
          Padding(
            padding: const EdgeInsetsDirectional.symmetric(
              horizontal: DotSpace.xs,
            ),
            child: Text(l10n.schAllCovered, style: t.styles.body),
          ),
        if (schedules.length < 7)
          Material(
            color: t.colors.raised,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(DotRadii.cardLarge),
              side: BorderSide(color: t.colors.outline),
            ),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: () => unawaited(showScheduleSheet(context)),
              child: ConstrainedBox(
                constraints: const BoxConstraints(minHeight: DotTouch.android),
                child: Padding(
                  padding: const EdgeInsets.all(DotSpace.l),
                  child: Row(
                    spacing: DotSpace.s,
                    children: [
                      DotIcon(DotGlyphs.add, color: t.colors.accentInk),
                      Text(
                        l10n.wwdAddSchedule,
                        style: t.styles.cardTitle.copyWith(
                          color: t.colors.accentInk,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        Padding(
          padding: const EdgeInsetsDirectional.symmetric(
            horizontal: DotSpace.xs,
          ),
          child: Text(
            l10n.wwdWeekFooter,
            style: t.styles.rowMeta.copyWith(color: t.colors.muted),
          ),
        ),
      ],
    );
  }
}

class _ScheduleCard extends StatelessWidget {
  const _ScheduleCard({
    required this.schedule,
    required this.dot,
    required this.settings,
    required this.onEdit,
  });

  final DaySchedule schedule;
  final TaskColor dot;
  final Settings settings;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final l10n = context.l10n;
    final days = schedule.days;
    final kind = scheduleKind(days);
    final name = scheduleName(l10n, days);
    final wake = windowMinutes(schedule.window.start);
    final windDown = windowMinutes(schedule.window.end);
    // Rings when the alarm is on and this schedule's days ring (ED-448).
    final rings =
        settings.wakeUpAlarm && days.every(settings.wakeUpAlarmDays.contains);
    return Container(
      padding: const EdgeInsets.all(DotSpace.l),
      decoration: BoxDecoration(
        color: t.colors.raised,
        borderRadius: BorderRadius.circular(DotRadii.cardLarge),
        border: Border.all(color: t.colors.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: DotSpace.m,
        children: [
          Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: DotSpace.s,
            runSpacing: DotSpace.xs,
            children: [
              Container(
                width: DotSize.pickerDot / 2,
                height: DotSize.pickerDot / 2,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: t.tasks[dot].color,
                ),
              ),
              Text(name, style: t.styles.rowTitle),
              if (kind != ScheduleKind.everyDay)
                Text(
                  daysText(context, days),
                  style: t.styles.body.copyWith(color: t.colors.muted),
                ),
              Row(
                mainAxisSize: MainAxisSize.min,
                spacing: DotSpace.xs,
                children: [
                  DotIcon(
                    DotGlyphs.bell,
                    size: DotSize.rowIcon,
                    color: rings ? t.colors.accentInk : t.colors.muted,
                  ),
                  Text(
                    rings ? l10n.wwdAlarmOn : l10n.wwdNoAlarm,
                    style: t.styles.rowMeta.copyWith(
                      fontWeight: FontWeight.w700,
                      color: rings ? t.colors.accentInk : t.colors.muted,
                    ),
                  ),
                ],
              ),
            ],
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: DotSpace.m,
            children: [
              Expanded(
                child: _Time(
                  glyph: DotGlyphs.sun,
                  colour: TaskColor.amber,
                  label: l10n.settingsWakeUp,
                  time: clockText(context, wake, settings.use24h),
                ),
              ),
              // The clock time alone, as drawn ("12:30 AM"): the card's
              // night line already says where the night ends.
              Expanded(
                child: _Time(
                  glyph: DotGlyphs.moon,
                  colour: TaskColor.violet,
                  label: l10n.settingsWindDown,
                  time: clockText(
                    context,
                    windDown % Duration.minutesPerDay,
                    settings.use24h,
                  ),
                ),
              ),
            ],
          ),
          Divider(height: 1, color: t.colors.outline),
          Row(
            children: [
              Expanded(
                child: Text(
                  l10n.wwdNight(
                    formatDurationShort(l10n, nightAfter(settings, days.first)),
                  ),
                  style: t.styles.body.copyWith(color: t.colors.muted),
                ),
              ),
              TextButton(onPressed: onEdit, child: Text(l10n.sheetEdit)),
            ],
          ),
        ],
      ),
    );
  }
}

/// "Wake Up" over its time, by the sun (or Wind Down by the moon).
class _Time extends StatelessWidget {
  const _Time({
    required this.glyph,
    required this.colour,
    required this.label,
    required this.time,
  });

  final DotGlyph glyph;
  final TaskColor colour;
  final String label;
  final String time;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final c = t.tasks[colour];
    return Row(
      spacing: DotSpace.s,
      children: [
        Container(
          width: DotSize.rowDot,
          height: DotSize.rowDot,
          decoration: BoxDecoration(color: c.tint, shape: BoxShape.circle),
          child: Center(
            child: DotIcon(glyph, color: c.ink, size: DotSize.rowIcon),
          ),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: t.styles.rowMeta),
              Text(time, style: t.styles.promptTitle),
            ],
          ),
        ),
      ],
    );
  }
}
