import 'dart:async';

import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/router/app_routes.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/data/notifications/permission_providers.dart';
import 'package:dottoday/data/profile/profile_providers.dart';
import 'package:dottoday/data/wake_up/wake_up_providers.dart';
import 'package:dottoday/domain/entities/enums.dart';
import 'package:dottoday/domain/entities/settings.dart';
import 'package:dottoday/domain/notifications/alarm_capabilities.dart';
import 'package:dottoday/domain/wake_up/mission_sensors.dart';
import 'package:dottoday/features/settings/pages/page_frame.dart';
import 'package:dottoday/features/settings/wake_wind/mission_pickers.dart';
import 'package:dottoday/features/settings/widgets/mission_text.dart';
import 'package:dottoday/features/settings/widgets/settings_change.dart';
import 'package:dottoday/shared/pickers/weekday_chips.dart';
import 'package:dottoday/shared/settings/settings_form.dart';
import 'package:dottoday/shared/settings/settings_group.dart';
import 'package:dottoday/shared/sheets/choice_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Wake Up alarm › Missions (E-Phones, ED-084): when missions run, opening
/// the Missions page. Greyed, never hidden, with its reason where this
/// phone has no alarm tier (docs/15 §8).
class MissionsRow extends ConsumerWidget {
  const MissionsRow({required this.settings, super.key});

  final Settings settings;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = DotTheme.of(context);
    final l10n = context.l10n;
    final able = _able(ref);
    return SettingsRow(
      glyph: DotGlyphs.bolt,
      tint: t.tasks[TaskColor.amber].ink,
      title: l10n.settingsMissions,
      subtitle: able ? null : l10n.missionNeedsAlarm,
      value: missionModeText(l10n, settings.missionMode),
      formButton: l10n.settingsFormOpen(l10n.settingsMissions),
      onTap: able
          ? () => unawaited(
              context.push(AppRoutes.settingsPage(SettingsPage.missions)),
            )
          : null,
    );
  }
}

/// Missions can be set here: on a phone that rings like an alarm, or on
/// a Mac or the web, which never ring and set them for the phone that
/// does (ED-450, E-FullA-v2).
bool _able(WidgetRef ref) {
  final caps = ref.watch(alarmCapabilitiesNowProvider).value;
  return caps?.tier == AlarmTier.alarm || _remote(ref);
}

/// A Mac or the web: missions run on another device.
bool _remote(WidgetRef ref) =>
    ref
        .watch(alarmCapabilitiesNowProvider)
        .value
        ?.blockers
        .contains(AlarmBlocker.notAPhone) ??
    false;

/// Wake Up and Wind Down › Missions (E-R2-28, ED-331; docs/15 §8–§9):
/// when missions run (off by default) and on which days, then while on
/// the missions themselves, each with its task icon and, where this phone
/// can't run it, dimmed with the reason; Walk's steps; the backup and the
/// skip offer. The drawn page is the list and Backup mission; the rest is
/// as built (owner 2026-11-24). Picking Walk or Light asks for its
/// permission here, never while ringing.
class MissionsPage extends ConsumerWidget {
  const MissionsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(currentProfileProvider).value?.settings;
    if (settings == null) return const SizedBox.shrink();
    final t = DotTheme.of(context);
    final l10n = context.l10n;
    final mode = settings.missionMode;
    final on = _able(ref) && mode != MissionMode.off;
    return SettingsPageFrame(
      title: l10n.settingsMissions,
      page: SettingsPage.missions,
      form: true,
      children: [
        if (_remote(ref)) PageText(l10n.missionsRunOnPhone),
        SettingsGroup(
          caption: '',
          children: [
            SettingsRow(
              glyph: DotGlyphs.bolt,
              tint: t.tasks[TaskColor.amber].ink,
              title: l10n.settingsMissions,
              subtitle: _able(ref) ? null : l10n.missionNeedsAlarm,
              value: missionModeText(l10n, mode),
              onTap: _able(ref)
                  ? () => unawaited(pickMissionMode(context, settings))
                  : null,
            ),
            if (on && mode == MissionMode.chosenDays)
              _DaysRow(settings: settings),
          ],
        ),
        if (on) ...[
          SettingsGroup(
            caption: l10n.settingsMission,
            children: [
              if (settingsFormFits(context))
                FormLine(
                  label: l10n.settingsMission,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: DotSpace.xs,
                    children: [
                      for (final k in offeredMissions)
                        _MissionChoice(
                          kind: k,
                          chosen: settings.missionKind == k,
                        ),
                    ],
                  ),
                )
              else
                for (final k in offeredMissions)
                  _MissionChoice(kind: k, chosen: settings.missionKind == k),
              if (settings.missionKind == MissionKind.walk)
                SettingsRow(
                  glyph: DotGlyphs.clock,
                  tint: t.colors.accentInk,
                  title: l10n.settingsMissionSteps,
                  value: '${settings.missionSteps}', // l10n-ignore: a count
                  onTap: () => unawaited(pickMissionSteps(context, settings)),
                ),
            ],
          ),
          SettingsGroup(
            caption: l10n.settingsMissionBackup,
            children: [
              SettingsRow(
                glyph: DotGlyphs.check,
                tint: t.colors.accentInk,
                title: l10n.settingsMissionBackup,
                value: missionBackupText(l10n, settings.missionBackup),
                onTap: () => unawaited(pickMissionBackup(context, settings)),
              ),
              SettingsRow(
                glyph: DotGlyphs.bell,
                tint: t.colors.accentInk,
                title: l10n.settingsMissionSkipOffer,
                toggle: settings.missionSkipOffer,
                onToggle: (v) => changeSettings(
                  context,
                  (s) => s.copyWith(missionSkipOffer: v),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

class _DaysRow extends StatelessWidget {
  const _DaysRow({required this.settings});

  final Settings settings;

  @override
  Widget build(BuildContext context) => SettingsRow(
    glyph: DotGlyphs.week,
    tint: DotTheme.of(context).colors.accentInk,
    title: context.l10n.settingsMissionDays,
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
  );
}

/// One mission on the list (E-R2-28): its task icon, its name and why it
/// can't run here, checked when chosen. A tap picks it, asking for its
/// sensor first where needed (docs/15 §8).
class _MissionChoice extends ConsumerWidget {
  const _MissionChoice({required this.kind, required this.chosen});

  final MissionKind kind;
  final bool chosen;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = DotTheme.of(context);
    final l10n = context.l10n;
    // On a Mac or the web the sensor is the ringing phone's, not this
    // device's (ED-450).
    final remote = _remote(ref);
    final support = remote
        ? null
        : ref.watch(missionSupportProvider(kind)).value;
    final blocked =
        support == MissionSupport.missing || support == MissionSupport.denied;
    if (settingsFormAt(context)) {
      return FormRadio(
        selected: chosen,
        title: missionKindText(l10n, kind),
        detail: _detail(l10n, support, remote: remote),
        onTap: blocked ? null : () => unawaited(_pick(context, ref, support)),
      );
    }
    return ChoiceRow<MissionKind>(
      choice: (
        value: kind,
        label: missionKindText(l10n, kind),
        detail: switch (support) {
          MissionSupport.missing => l10n.missionSensorMissing,
          MissionSupport.denied => l10n.missionSensorDenied,
          _ when kind == MissionKind.oneThing => l10n.missionOneThingNeeds,
          _ when kind.onScreen => l10n.missionOnScreenNote,
          _ => null,
        },
      ),
      selected: chosen,
      disabled: blocked,
      leading: SettingsIcon(
        glyph: missionIcon(kind).glyph!,
        // In the accent, as E-R2-28 draws them.
        tint: t.colors.accentInk,
      ),
      onTap: blocked ? null : () => unawaited(_pick(context, ref, support)),
    );
  }

  /// Why it can't run, or what it needs; on a Mac or the web, that Walk
  /// and Light use the phone's sensor.
  String? _detail(
    AppLocalizations l10n,
    MissionSupport? support, {
    required bool remote,
  }) => switch (support) {
    _ when remote && kind.usesSensor => l10n.missionSensorOnPhone,
    MissionSupport.missing => l10n.missionSensorMissing,
    MissionSupport.denied => l10n.missionSensorDenied,
    _ when kind == MissionKind.oneThing => l10n.missionOneThingNeeds,
    _ when kind.onScreen => l10n.missionOnScreenNote,
    _ => null,
  };

  Future<void> _pick(
    BuildContext context,
    WidgetRef ref,
    MissionSupport? support,
  ) async {
    if (support == MissionSupport.needsPermission) {
      final ok = await ref.read(missionSensorsProvider).request(kind);
      ref.invalidate(missionSupportProvider(kind));
      if (!ok || !context.mounted) return;
    }
    if (context.mounted) {
      changeSettings(context, (s) => s.copyWith(missionKind: kind));
    }
  }
}
