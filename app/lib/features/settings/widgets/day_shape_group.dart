import 'dart:async';

import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/router/app_routes.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/domain/entities/enums.dart';
import 'package:dottoday/domain/entities/settings.dart';
import 'package:dottoday/domain/time/clock_time.dart';
import 'package:dottoday/domain/time/day_boundaries.dart';
import 'package:dottoday/features/settings/panes/settings_pane_scope.dart';
import 'package:dottoday/features/settings/widgets/night_rows.dart';
import 'package:dottoday/features/settings/widgets/settings_change.dart';
import 'package:dottoday/features/settings/widgets/wake_up_alarm_row.dart';
import 'package:dottoday/shared/settings/settings_group.dart';
import 'package:dottoday/shared/time_input/time_input.dart';
import 'package:dottoday/shared/time_input/time_input_sheet.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Wake Up, its alarm (docs/15 W1a), Wake Up options and Wind Down, "same
/// every day": minimal Settings' rows 2–5 (docs/14 §4; the alarm is in both
/// layouts, docs/15 §10). Full Settings shows them as schedules on Wake Up
/// and Wind Down (ED-084).
List<Widget> dayTimeRows(BuildContext context, Settings settings) {
  final t = DotTheme.of(context);
  final l10n = context.l10n;
  final common = commonWindow(settings);
  final wake = windowMinutes(common.start);
  final bed = windowMinutes(common.end);
  String at(int m) => clockText(context, m, settings.use24h);
  void setWindow(int w, int b) =>
      changeSettings(context, (s) => withCommonWindow(s, dayWindow(w, b)));
  return [
    SettingsRow(
      glyph: DotGlyphs.horizon,
      tint: t.tasks[TaskColor.amber].ink,
      title: l10n.settingsWakeUp,
      value: at(wake),
      onTap: () => unawaited(
        _pickTime(
          context,
          settings,
          l10n.settingsWakeUp,
          wake,
          (m) => setWindow(m, bed),
        ),
      ),
    ),
    WakeUpAlarmRow(on: settings.wakeUpAlarm),
    // Sound, snooze and the Morning card (docs/15 §9); on the Mac and
    // the web too, where they sync to the phone (15 §11).
    SettingsRow(
      glyph: DotGlyphs.sound,
      tint: t.tasks[TaskColor.amber].ink,
      title: l10n.settingsWakeUpOptions,
      selected: SettingsPaneScope.selectedAt(context, SettingsPage.wakeUp),
      onTap: () => openSettingsPage(context, SettingsPage.wakeUp),
    ),
    SettingsRow(
      glyph: DotGlyphs.moon,
      tint: t.tasks[TaskColor.violet].ink,
      title: l10n.settingsWindDown,
      value: windDownValue(
        l10n,
        settings,
        wakeMinute: wake,
        windDownMinute: bed,
        at: (m) => windDownText(context, m, settings.use24h),
      ),
      onTap: () => unawaited(
        _pickTime(
          context,
          settings,
          l10n.settingsWindDown,
          bed,
          (m) => setWindow(wake, m),
        ),
      ),
    ),
  ];
}

Future<void> _pickTime(
  BuildContext context,
  Settings settings,
  String title,
  int minute,
  ValueChanged<int> set,
) async {
  final picked = await showTimeInputSheet(
    context,
    title: title,
    initial: ClockTime.fromMinutes(minute),
    use24h: settings.use24h,
  );
  if (picked != null) set(picked.minutesOfDay);
}

/// "7:00" / "7:00 AM" for a minute of the day in the user's format.
String clockText(BuildContext context, int minute, bool? use24h) =>
    formatClockTime(context, ClockTime.fromMinutes(minute), use24h: use24h);

/// [clockText] for a Wind Down, with ", next day" after midnight (Q8).
String windDownText(BuildContext context, int minute, bool? use24h) {
  final time = clockText(context, minute, use24h);
  return windDownNextDay(minute) ? context.l10n.timeNextDay(time) : time;
}

/// "Sat" for a weekday key.
String weekdayName(String locale, Weekday d) =>
    DateFormat.E(locale).format(DateTime(2024, 1, 1 + d.index));
