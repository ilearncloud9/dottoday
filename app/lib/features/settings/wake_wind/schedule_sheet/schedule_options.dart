import 'dart:async';

import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/domain/entities/enums.dart';
import 'package:dottoday/domain/entities/settings.dart';
import 'package:dottoday/domain/time/day_boundaries.dart';
import 'package:dottoday/features/settings/wake_wind/schedule_sheet/schedule_text.dart';
import 'package:dottoday/features/settings/widgets/day_shape_group.dart';
import 'package:dottoday/features/settings/widgets/wake_up_option_groups.dart';
import 'package:dottoday/shared/settings/settings_group.dart';
import 'package:flutter/material.dart';

/// The lower half of the schedule sheet (E-Phones "Edit Weekdays,
/// lower"): Wake Up alarm · Ring on these days and Sound and snooze
/// (shared by every schedule; a tap opens the Sound picker, owner
/// 2026-11-24), Reminders on these days · Wind Down reminder, and Remove
/// this schedule when editing. While Ring like an alarm is off, Ring on
/// these days is dimmed with why (owner 2026-11-24).
class ScheduleOptions extends StatelessWidget {
  const ScheduleOptions({
    required this.settings,
    required this.days,
    required this.wake,
    required this.ring,
    required this.remind,
    required this.onRing,
    required this.onRemind,
    required this.onRemove,
    super.key,
  });

  final Settings settings;

  /// The draft's days, in week order.
  final List<Weekday> days;
  final int wake;
  final bool ring;
  final bool remind;
  final ValueChanged<bool> onRing;
  final ValueChanged<bool> onRemind;

  /// Null for a new schedule.
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final l10n = context.l10n;
    final on = settings.wakeUpAlarm;
    final ringLine = days.isEmpty
        ? null
        : l10n.schRingAt(
            daysText(context, days),
            clockText(context, wake, settings.use24h),
          );
    final remove = onRemove;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: DotSpace.l,
      children: [
        SettingsGroup(
          caption: l10n.settingsWakeUpAlarm,
          footer: on ? l10n.schSharedFooter : null,
          children: [
            SettingsRow(
              glyph: TaskIcon.alarm.glyph!,
              tint: t.tasks[TaskColor.amber].ink,
              title: l10n.schRingDays,
              subtitle: on ? ringLine : l10n.schRingOff,
              toggle: on && ring,
              onToggle: on ? onRing : null,
            ),
            if (on)
              SettingsRow(
                glyph: DotGlyphs.sound,
                tint: t.tasks[TaskColor.amber].ink,
                title: l10n.schSoundSnooze,
                subtitle: _soundLine(l10n),
                onTap: () => unawaited(pickWakeUpSound(context)),
              ),
          ],
        ),
        SettingsGroup(
          caption: l10n.schRemindDays,
          children: [
            SettingsRow(
              glyph: DotGlyphs.bell,
              tint: t.tasks[TaskColor.violet].ink,
              title: l10n.settingsWindDownReminder,
              toggle: remind,
              onToggle: onRemind,
            ),
          ],
        ),
        if (remove != null) ...[
          OutlinedButton(
            onPressed: remove,
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(DotTouch.android),
              foregroundColor: t.colors.ink,
              side: BorderSide(color: t.colors.hairline),
            ),
            child: Text(l10n.schRemove),
          ),
          Text(
            l10n.schRemoveNote(
              l10n.wwdDayRange(
                clockText(
                  context,
                  windowMinutes(Settings.defaultDayBoundary.start),
                  settings.use24h,
                ),
                clockText(
                  context,
                  windowMinutes(Settings.defaultDayBoundary.end),
                  settings.use24h,
                ),
              ),
            ),
            style: t.styles.rowMeta.copyWith(color: t.colors.secondary),
          ),
        ],
      ],
    );
  }

  /// "Dawn chorus · 9 min · up to 3".
  String _soundLine(AppLocalizations l10n) {
    final sound = wakeUpSoundName(l10n, settings);
    if (!settings.wakeUpSnooze) return l10n.schSoundNoSnooze(sound);
    final length = l10n.durationMinutes(settings.wakeUpSnoozeMin);
    final max = settings.wakeUpSnoozeMax;
    final count = '$max'; // l10n-ignore: a count
    return max == 0
        ? l10n.schSoundNoLimit(sound, length)
        : l10n.schSoundSnoozeValue(sound, length, count);
  }
}
