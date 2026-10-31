import 'dart:async';

import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/domain/entities/enums.dart';
import 'package:dottoday/domain/entities/settings.dart';
import 'package:dottoday/domain/time/clock_time.dart';
import 'package:dottoday/domain/time/day_boundaries.dart';
import 'package:dottoday/features/settings/widgets/settings_change.dart';
import 'package:dottoday/features/settings/widgets/wake_up_alarm_row.dart';
import 'package:dottoday/features/settings/widgets/weekday_sheet.dart';
import 'package:dottoday/shared/dot/day_shape_slider.dart';
import 'package:dottoday/shared/duration/duration_chips.dart';
import 'package:dottoday/shared/settings/settings_group.dart';
import 'package:dottoday/shared/sheets/choice_sheet.dart';
import 'package:dottoday/shared/time_input/time_input.dart';
import 'package:dottoday/shared/time_input/time_input_sheet.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// DAY SHAPE (`A-ios-settings`): the sun → moon slider, Wake Up, its alarm
/// (docs/15 W1a), Wind Down, different days, Week starts, Time format
/// (R-17, R-20).
class DayShapeGroup extends StatelessWidget {
  const DayShapeGroup({required this.settings, super.key});

  final Settings settings;

  /// Wake Up, its alarm and Wind Down, "same every day" (minimal Settings
  /// rows 2–3, docs/14 §4; the alarm is in both layouts, docs/15 §10).
  List<Widget> times(BuildContext context) => _times(context);

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final l10n = context.l10n;
    final common = commonWindow(settings);
    final wake = windowMinutes(common.start);
    final bed = windowMinutes(common.end);
    String at(int m) => clockText(context, m, settings.use24h);
    void setWindow(int w, int b) => changeSettings(
      context,
      (s) => withCommonWindow(
        s,
        TimeWindow(start: windowTime(w), end: windowTime(b)),
      ),
    );
    return SettingsGroup(
      caption: l10n.settingsDayShape,
      children: [
        DayShapeSlider(
          wakeMinute: wake,
          bedMinute: bed,
          timeText: at,
          awakeText: (m) => l10n.settingsAwake(formatDurationShort(l10n, m)),
          wakeLabel: l10n.settingsWakeUp,
          bedLabel: l10n.settingsBedtime,
          onChanged: setWindow,
        ),
        ..._times(context),
        _days(context, t),
        _weekStart(context, t),
        _timeFormat(context, t),
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
    void setWindow(int w, int b) => changeSettings(
      context,
      (s) => withCommonWindow(
        s,
        TimeWindow(start: windowTime(w), end: windowTime(b)),
      ),
    );
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
      SettingsRow(
        glyph: DotGlyphs.moon,
        tint: t.tasks[TaskColor.violet].ink,
        title: l10n.settingsBedtime,
        value: at(bed),
        onTap: () => unawaited(
          _time(context, l10n.settingsBedtime, bed, (m) => setWindow(wake, m)),
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

  Widget _weekStart(BuildContext context, DotTheme t) {
    final l10n = context.l10n;
    final locale = Localizations.localeOf(context).toLanguageTag();
    String name(int iso) =>
        DateFormat.EEEE(locale).format(DateTime(2024, 1, iso));
    return SettingsRow(
      glyph: DotGlyphs.calendar,
      tint: t.tasks[TaskColor.sky].ink,
      title: l10n.settingsWeekStarts,
      value: name(settings.firstDayOfWeek),
      onTap: () async {
        final picked = await showChoiceSheet<int>(
          context,
          title: l10n.settingsWeekStarts,
          selected: settings.firstDayOfWeek,
          options: [
            for (final d in const [1, 7, 6])
              (value: d, label: name(d), detail: null),
          ],
        );
        if (picked != null && context.mounted) {
          changeSettings(context, (s) => s.copyWith(firstDayOfWeek: picked));
        }
      },
    );
  }

  Widget _timeFormat(BuildContext context, DotTheme t) {
    final l10n = context.l10n;
    final osIs24 = MediaQuery.alwaysUse24HourFormatOf(context);
    String label(_Format f) => switch (f) {
      _Format.h24 => l10n.settingsTime24,
      _Format.h12 => l10n.settingsTime12,
      _Format.device => l10n.settingsTimeSystem(
        osIs24 ? l10n.settingsTime24 : l10n.settingsTime12,
      ),
    };
    final current = _Format.of(settings.use24h);
    return SettingsRow(
      glyph: DotGlyphs.clock,
      tint: t.colors.muted,
      title: l10n.settingsTimeFormat,
      value: label(current),
      onTap: () async {
        // An enum, not bool?: a dismissed sheet's null must not read as
        // "like this device".
        final picked = await showChoiceSheet<_Format>(
          context,
          title: l10n.settingsTimeFormat,
          selected: current,
          options: [
            for (final f in _Format.values)
              (value: f, label: label(f), detail: null),
          ],
        );
        if (picked == null || picked == current || !context.mounted) return;
        changeSettings(context, (s) => s.copyWith(use24h: picked.use24h));
      },
    );
  }
}

enum _Format {
  device(null),
  h12(false),
  h24(true);

  const _Format(this.use24h);

  final bool? use24h;

  static _Format of(bool? v) => values.firstWhere((f) => f.use24h == v);
}

/// "7:00" / "7:00 AM" for a minute of the day in the user's format.
String clockText(BuildContext context, int minute, bool? use24h) =>
    formatClockTime(context, ClockTime.fromMinutes(minute), use24h: use24h);

/// "Sat" for a weekday key.
String weekdayName(String locale, Weekday d) =>
    DateFormat.E(locale).format(DateTime(2024, 1, 1 + d.index));
