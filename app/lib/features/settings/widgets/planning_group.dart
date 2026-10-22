import 'dart:async';

import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/domain/entities/enums.dart';
import 'package:dottoday/domain/entities/settings.dart';
import 'package:dottoday/features/settings/widgets/settings_change.dart';
import 'package:dottoday/shared/duration/duration_chips.dart';
import 'package:dottoday/shared/duration/duration_sheet.dart';
import 'package:dottoday/shared/settings/settings_group.dart';
import 'package:dottoday/shared/sheets/choice_sheet.dart';
import 'package:flutter/material.dart';

/// PLANNING (`A-ios-settings`) plus PRD F8's snapping and shift default:
/// Default duration, Snap to, Shift later tasks, Show free time,
/// Running-late nudge, Roll unfinished to tomorrow (R-16, R-17).
class PlanningGroup extends StatelessWidget {
  const PlanningGroup({required this.settings, super.key});

  final Settings settings;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final l10n = context.l10n;
    return SettingsGroup(
      caption: l10n.settingsPlanning,
      children: [
        SettingsRow(
          glyph: DotGlyphs.clock,
          tint: t.colors.accentInk,
          title: l10n.settingsDefaultDuration,
          value: formatDurationShort(l10n, settings.defaultDurationMin),
          onTap: () => unawaited(_duration(context)),
        ),
        _snap(context, t),
        _shift(context, t),
        SettingsRow(
          glyph: DotGlyphs.dottedLine,
          tint: t.colors.muted,
          title: l10n.settingsShowFree,
          subtitle: l10n.settingsShowFreeDetail,
          toggle: settings.showFreeTime,
          onToggle: (v) =>
              changeSettings(context, (s) => s.copyWith(showFreeTime: v)),
        ),
        SettingsRow(
          glyph: DotGlyphs.bolt,
          tint: t.tasks[TaskColor.coral].ink,
          title: l10n.settingsLateNudge,
          subtitle: l10n.settingsLateNudgeDetail,
          toggle: settings.runningLateNudge,
          onToggle: (v) =>
              changeSettings(context, (s) => s.copyWith(runningLateNudge: v)),
        ),
        SettingsRow(
          glyph: DotGlyphs.rollForward,
          tint: t.tasks[TaskColor.teal].ink,
          title: l10n.settingsRoll,
          subtitle: l10n.settingsRollDetail,
          toggle: settings.rollUnfinished,
          onToggle: (v) =>
              changeSettings(context, (s) => s.copyWith(rollUnfinished: v)),
        ),
      ],
    );
  }

  Future<void> _duration(BuildContext context) async {
    final minutes = await showDurationSheet(
      context,
      initial: settings.defaultDurationMin,
      color: TaskColor.indigo,
      icon: TaskIcon.fallback,
      presets: settings.durationPresets,
      onPresets: (p) =>
          changeSettings(context, (s) => s.copyWith(durationPresets: p)),
    );
    if (minutes != null && context.mounted) {
      changeSettings(context, (s) => s.copyWith(defaultDurationMin: minutes));
    }
  }

  Widget _snap(BuildContext context, DotTheme t) {
    final l10n = context.l10n;
    return SettingsRow(
      glyph: DotGlyphs.move,
      tint: t.tasks[TaskColor.sky].ink,
      title: l10n.settingsSnap,
      value: l10n.settingsSnapValue(settings.snapMinutes),
      onTap: () async {
        final picked = await showChoiceSheet<int>(
          context,
          title: l10n.settingsSnap,
          selected: settings.snapMinutes,
          options: [
            for (final m in Settings.snapChoices.toList()..sort())
              (value: m, label: l10n.settingsSnapValue(m), detail: null),
          ],
        );
        if (picked != null && context.mounted) {
          changeSettings(context, (s) => s.copyWith(snapMinutes: picked));
        }
      },
    );
  }

  Widget _shift(BuildContext context, DotTheme t) {
    final l10n = context.l10n;
    String label(ShiftFollowersPolicy p) => switch (p) {
      ShiftFollowersPolicy.ask => l10n.settingsShiftAsk,
      ShiftFollowersPolicy.always => l10n.settingsShiftAlways,
      ShiftFollowersPolicy.never => l10n.settingsShiftNever,
    };
    return SettingsRow(
      glyph: DotGlyphs.rollForward,
      tint: t.tasks[TaskColor.violet].ink,
      title: l10n.settingsShiftLater,
      value: label(settings.shiftFollowers),
      onTap: () async {
        final picked = await showChoiceSheet<ShiftFollowersPolicy>(
          context,
          title: l10n.settingsShiftLater,
          selected: settings.shiftFollowers,
          options: [
            for (final p in ShiftFollowersPolicy.values)
              (value: p, label: label(p), detail: null),
          ],
        );
        if (picked != null && context.mounted) {
          changeSettings(context, (s) => s.copyWith(shiftFollowers: picked));
        }
      },
    );
  }
}
