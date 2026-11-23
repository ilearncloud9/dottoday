import 'dart:async';

import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/domain/entities/enums.dart';
import 'package:dottoday/domain/entities/settings.dart';
import 'package:dottoday/domain/time/day_boundaries.dart';
import 'package:dottoday/domain/time/schedules.dart';
import 'package:dottoday/features/settings/widgets/day_shape_group.dart';
import 'package:dottoday/features/settings/widgets/weekday_sheet.dart';
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
    // Until the schedule sheet (M20.7 part 4b), Edit and Add open the
    // per-weekday sheet.
    void edit() => unawaited(showWeekdaySheet(context));
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
            onEdit: edit,
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
              onTap: edit,
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
    final name = switch (kind) {
      ScheduleKind.everyDay => l10n.wwdEveryDay,
      ScheduleKind.weekdays => l10n.wwdWeekdays,
      ScheduleKind.weekend => l10n.wwdWeekend,
      ScheduleKind.days => l10n.wwdDays,
    };
    final wake = windowMinutes(schedule.window.start);
    final windDown = windowMinutes(schedule.window.end);
    final rings = settings.wakeUpAlarm;
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
                  _daysText(context, days),
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

  /// "Mon–Fri" for consecutive days, else "Mon, Wed".
  String _daysText(BuildContext context, List<Weekday> days) {
    final l10n = context.l10n;
    final locale = Localizations.localeOf(context).toLanguageTag();
    final names = [for (final d in days) weekdayName(locale, d)];
    final run = [
      for (var i = 1; i < days.length; i++)
        (days[i].index - days[i - 1].index) % 7 == 1,
    ].every((b) => b);
    if (days.length > 2 && run) {
      return l10n.wwdDayRange(names.first, names.last);
    }
    return names.reduce(l10n.listJoin);
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
