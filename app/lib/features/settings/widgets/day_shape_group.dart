import 'dart:async';

import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/router/app_routes.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/domain/entities/enums.dart';
import 'package:dottoday/domain/entities/settings.dart';
import 'package:dottoday/domain/time/clock_time.dart';
import 'package:dottoday/domain/time/day_boundaries.dart';
import 'package:dottoday/features/settings/widgets/night_rows.dart';
import 'package:dottoday/features/settings/widgets/settings_change.dart';
import 'package:dottoday/features/settings/widgets/wake_up_alarm_row.dart';
import 'package:dottoday/features/settings/widgets/weekday_sheet.dart';
import 'package:dottoday/shared/dot/day_shape_slider.dart';
import 'package:dottoday/shared/duration/duration_chips.dart';
import 'package:dottoday/shared/settings/settings_group.dart';
import 'package:dottoday/shared/time_input/time_input.dart';
import 'package:dottoday/shared/time_input/time_input_sheet.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

/// DAY SHAPE (`A-ios-settings`): the sun → moon slider, Wake Up, its alarm
/// (docs/15 W1a), Wind Down and different days (R-17). Week starts and
/// Time format are on Appearance ([FormatGroup], M20.7).
class DayShapeGroup extends StatelessWidget {
  const DayShapeGroup({required this.settings, super.key});

  final Settings settings;

  /// Wake Up, its alarm and Wind Down, "same every day" (minimal Settings
  /// rows 2–5, docs/14 §4; the alarm is in both layouts, docs/15 §10).
  List<Widget> times(BuildContext context) => _times(context);

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final l10n = context.l10n;
    final common = commonWindow(settings);
    final wake = windowMinutes(common.start);
    final bed = windowMinutes(common.end);
    String at(int m) => clockText(context, m, settings.use24h);
    void setWindow(int w, int b) =>
        changeSettings(context, (s) => withCommonWindow(s, dayWindow(w, b)));
    return SettingsGroup(
      caption: l10n.settingsDayShape,
      children: [
        DayShapeSlider(
          wakeMinute: wake,
          bedMinute: bed,
          timeText: at,
          awakeText: (m) => l10n.settingsAwake(formatDurationShort(l10n, m)),
          wakeLabel: l10n.settingsWakeUp,
          bedLabel: l10n.settingsWindDown,
          onChanged: setWindow,
        ),
        ..._times(context),
        // The full list only: minimal Settings stays short (docs/14 §4),
        // and these live under Everything else… there.
        ...nightRows(context, settings),
        _days(context, t),
      ],
    );
  }

  List<Widget> _times(BuildContext context) {
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
        glyph: DotGlyphs.sunrise,
        tint: t.tasks[TaskColor.amber].ink,
        title: l10n.settingsWakeUp,
        value: at(wake),
        onTap: () => unawaited(
          _time(context, l10n.settingsWakeUp, wake, (m) => setWindow(m, bed)),
        ),
      ),
      WakeUpAlarmRow(on: settings.wakeUpAlarm),
      // Sound, snooze and the Morning card (docs/15 §9); on the Mac and
      // the web too, where they sync to the phone (15 §11).
      SettingsRow(
        glyph: DotGlyphs.sound,
        tint: t.tasks[TaskColor.amber].ink,
        title: l10n.settingsWakeUpOptions,
        onTap: () => unawaited(
          context.push(AppRoutes.settingsPage(SettingsPage.wakeUp)),
        ),
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
          _time(context, l10n.settingsWindDown, bed, (m) => setWindow(wake, m)),
        ),
      ),
    ];
  }

  Future<void> _time(
    BuildContext context,
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

  Widget _days(BuildContext context, DotTheme t) {
    final l10n = context.l10n;
    final locale = Localizations.localeOf(context).toLanguageTag();
    final custom = customDays(settings);
    return SettingsRow(
      glyph: DotGlyphs.week,
      tint: t.colors.accentInk,
      title: l10n.settingsPerWeekday,
      value: custom.isEmpty
          ? l10n.settingsSameEveryDay
          : l10n.settingsCustomDays(
              custom.map((d) => weekdayName(locale, d)).reduce(l10n.listJoin),
            ),
      onTap: () => unawaited(showWeekdaySheet(context)),
    );
  }
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
