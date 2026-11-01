import 'dart:async';

import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/data/notifications/permission_providers.dart';
import 'package:dottoday/data/wake_up/wake_up_providers.dart';
import 'package:dottoday/domain/entities/enums.dart';
import 'package:dottoday/domain/entities/settings.dart';
import 'package:dottoday/domain/notifications/alarm_capabilities.dart';
import 'package:dottoday/domain/wake_up/mission.dart';
import 'package:dottoday/domain/wake_up/mission_sensors.dart';
import 'package:dottoday/features/settings/widgets/mission_text.dart';
import 'package:dottoday/features/settings/widgets/settings_change.dart';
import 'package:dottoday/shared/pickers/weekday_chips.dart';
import 'package:dottoday/shared/settings/settings_group.dart';
import 'package:dottoday/shared/sheets/choice_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Wake Up options › MISSIONS (docs/15 §8–§9, M17.7a): when (off by
/// default), the days, which mission, Walk's steps, a backup and the
/// skip offer. Greyed, never hidden, with its reason where this phone
/// can't: no alarm tier, or a mission's sensor missing or denied. Picking
/// Walk or Light asks for its permission there, never while ringing.
/// [full] false is minimal mode: the When row only (docs/14 §3).
class MissionGroup extends ConsumerWidget {
  const MissionGroup({required this.settings, required this.full, super.key});

  final Settings settings;
  final bool full;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = DotTheme.of(context);
    final l10n = context.l10n;
    final tier = ref.watch(alarmCapabilitiesNowProvider).value?.tier;
    final able = tier == AlarmTier.alarm;
    final mode = settings.missionMode;
    final on = able && mode != MissionMode.off;
    return SettingsGroup(
      caption: l10n.settingsMissions,
      children: [
        SettingsRow(
          glyph: DotGlyphs.bolt,
          tint: t.tasks[TaskColor.amber].ink,
          title: l10n.settingsMissions,
          subtitle: able ? null : l10n.missionNeedsAlarm,
          value: missionModeText(l10n, mode),
          onTap: able ? () => unawaited(_pickMode(context)) : null,
        ),
        if (on && full) ...[
          if (mode == MissionMode.chosenDays)
            SettingsRow(
              glyph: DotGlyphs.week,
              tint: t.colors.accentInk,
              title: l10n.settingsMissionDays,
              below: WeekdayChips(
                days: settings.missionDays.toSet(),
                onChanged: (days) => changeSettings(
                  context,
                  (s) => s.copyWith(
                    missionDays: [
                      for (final d in Weekday.values)
                        if (days.contains(d)) d,
                    ],
                  ),
                ),
              ),
            ),
          _KindRow(settings: settings),
          if (settings.missionKind == MissionKind.walk)
            SettingsRow(
              glyph: DotGlyphs.clock,
              tint: t.colors.accentInk,
              title: l10n.settingsMissionSteps,
              value: '${settings.missionSteps}', // l10n-ignore: a count
              onTap: () => unawaited(_pickSteps(context)),
            ),
          SettingsRow(
            glyph: DotGlyphs.check,
            tint: t.colors.accentInk,
            title: l10n.settingsMissionBackup,
            value: missionBackupText(l10n, settings.missionBackup),
            onTap: () => unawaited(_pickBackup(context)),
          ),
          SettingsRow(
            glyph: DotGlyphs.bell,
            tint: t.colors.accentInk,
            title: l10n.settingsMissionSkipOffer,
            toggle: settings.missionSkipOffer,
            onToggle: (v) =>
                changeSettings(context, (s) => s.copyWith(missionSkipOffer: v)),
          ),
        ],
      ],
    );
  }

  Future<void> _pickMode(BuildContext context) async {
    final l10n = context.l10n;
    final picked = await showChoiceSheet<MissionMode>(
      context,
      title: l10n.settingsMissions,
      selected: settings.missionMode,
      options: [
        for (final m in MissionMode.values)
          (value: m, label: missionModeText(l10n, m), detail: null),
      ],
    );
    if (picked != null && context.mounted) {
      changeSettings(context, (s) => s.copyWith(missionMode: picked));
    }
  }

  Future<void> _pickSteps(BuildContext context) async {
    final picked = await showChoiceSheet<int>(
      context,
      title: context.l10n.settingsMissionSteps,
      selected: settings.missionSteps,
      options: [
        for (final n in missionStepChoices)
          (value: n, label: '$n', detail: null), // l10n-ignore: a count
      ],
    );
    if (picked != null && context.mounted) {
      changeSettings(context, (s) => s.copyWith(missionSteps: picked));
    }
  }

  Future<void> _pickBackup(BuildContext context) async {
    final l10n = context.l10n;
    // A record, so None is a pick and only a dismissed sheet is null.
    final picked = await showChoiceSheet<(MissionKind?,)>(
      context,
      title: l10n.settingsMissionBackup,
      selected: (settings.missionBackup,),
      options: [
        for (final k in missionBackups)
          (value: (k,), label: missionBackupText(l10n, k), detail: null),
      ],
    );
    if (picked != null && context.mounted) {
      changeSettings(context, (s) => s.copyWith(missionBackup: picked.$1));
    }
  }
}

/// The Mission row: which mission, each greyed with its reason when this
/// phone can't run it (15 §8). Pick today's one thing arrives in M17.7b.
class _KindRow extends ConsumerWidget {
  const _KindRow({required this.settings});

  final Settings settings;

  static const _offered = [
    MissionKind.standUp,
    MissionKind.walk,
    MissionKind.light,
    MissionKind.breathe,
    MissionKind.catchDot,
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = DotTheme.of(context);
    final l10n = context.l10n;
    final kind = settings.missionKind;
    return SettingsRow(
      glyph: DotGlyphs.check,
      tint: t.tasks[TaskColor.amber].ink,
      title: l10n.settingsMission,
      subtitle: kind.onScreen ? l10n.missionOnScreenNote : null,
      value: missionKindText(l10n, kind),
      onTap: () => unawaited(_pick(context, ref)),
    );
  }

  Future<void> _pick(BuildContext context, WidgetRef ref) async {
    final l10n = context.l10n;
    final support = {
      for (final k in _offered)
        k: await ref.read(missionSupportProvider(k).future),
    };
    if (!context.mounted) return;
    final picked = await showChoiceSheet<MissionKind>(
      context,
      title: l10n.settingsMission,
      selected: settings.missionKind,
      options: [
        for (final k in _offered)
          (
            value: k,
            label: missionKindText(l10n, k),
            detail: switch (support[k]) {
              MissionSupport.missing => l10n.missionSensorMissing,
              MissionSupport.denied => l10n.missionSensorDenied,
              _ when k.onScreen => l10n.missionOnScreenNote,
              _ => null,
            },
          ),
      ],
    );
    if (picked == null || !context.mounted) return;
    switch (support[picked]) {
      case MissionSupport.missing || MissionSupport.denied:
        return;
      case MissionSupport.needsPermission:
        final ok = await ref.read(missionSensorsProvider).request(picked);
        ref.invalidate(missionSupportProvider(picked));
        if (!ok || !context.mounted) return;
      case MissionSupport.ready || null:
        break;
    }
    if (context.mounted) {
      changeSettings(context, (s) => s.copyWith(missionKind: picked));
    }
  }
}
