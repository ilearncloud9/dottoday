import 'dart:async';

import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/domain/entities/settings.dart';
import 'package:dottoday/domain/time/clock_time.dart';
import 'package:dottoday/domain/time/day_boundaries.dart';
import 'package:dottoday/features/settings/widgets/day_shape_group.dart';
import 'package:dottoday/features/settings/widgets/settings_change.dart';
import 'package:dottoday/shared/settings/settings_group.dart';
import 'package:dottoday/shared/time_input/time_input_sheet.dart';
import 'package:flutter/material.dart';

/// Settings › Reminders › Quiet hours (docs/02 F6.2, M8.4d): a switch
/// (off by default, docs/05) and, when on, From and Until. Reminders in
/// the window arrive silently; the day's first task and routine starts
/// still ring (11 A0, recorded under PRD F6.2).
class QuietHoursRow extends StatelessWidget {
  const QuietHoursRow({required this.settings, super.key});

  final Settings settings;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final l10n = context.l10n;
    final quiet = settings.quietHours;
    String at(String hhmm) =>
        clockText(context, windowMinutes(hhmm), settings.use24h);
    final toggle = SettingsRow(
      glyph: DotGlyphs.bellOff,
      tint: t.tasks[TaskColor.violet].ink,
      title: l10n.settingsQuietHours,
      subtitle: quiet == null
          ? l10n.settingsQuietHoursOff
          : l10n.settingsQuietHoursOn(at(quiet.start), at(quiet.end)),
      toggle: quiet != null,
      onToggle: (on) => changeSettings(
        context,
        (s) => s.copyWith(quietHours: on ? Settings.suggestedQuietHours : null),
      ),
    );
    if (quiet == null) return toggle;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        toggle,
        _end(context, l10n.settingsQuietFrom, quiet.start, (v) {
          return TimeWindow(start: v, end: quiet.end);
        }),
        _end(context, l10n.settingsQuietUntil, quiet.end, (v) {
          return TimeWindow(start: quiet.start, end: v);
        }),
      ],
    );
  }

  Widget _end(
    BuildContext context,
    String title,
    String hhmm,
    TimeWindow Function(String) window,
  ) {
    final t = DotTheme.of(context);
    final minute = windowMinutes(hhmm);
    return SettingsRow(
      glyph: DotGlyphs.clock,
      tint: t.colors.muted,
      title: title,
      value: clockText(context, minute, settings.use24h),
      onTap: () => unawaited(_pick(context, title, minute, window)),
    );
  }

  Future<void> _pick(
    BuildContext context,
    String title,
    int minute,
    TimeWindow Function(String) window,
  ) async {
    final picked = await showTimeInputSheet(
      context,
      title: title,
      initial: ClockTime.fromMinutes(minute),
      use24h: settings.use24h,
    );
    if (picked == null || !context.mounted) return;
    // An empty window (From = Until) is refused by the validator, which
    // says why in a snackbar.
    final value = windowTime(picked.minutesOfDay);
    changeSettings(context, (s) => s.copyWith(quietHours: window(value)));
  }
}
