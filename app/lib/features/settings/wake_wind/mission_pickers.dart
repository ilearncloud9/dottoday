import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/domain/entities/enums.dart';
import 'package:dottoday/domain/entities/settings.dart';
import 'package:dottoday/domain/wake_up/mission.dart';
import 'package:dottoday/features/settings/widgets/mission_text.dart';
import 'package:dottoday/features/settings/widgets/settings_change.dart';
import 'package:dottoday/shared/sheets/choice_sheet.dart';
import 'package:flutter/widgets.dart';

/// The missions Settings offers, in the board's order (E-R2-28).
const offeredMissions = [
  MissionKind.standUp,
  MissionKind.walk,
  MissionKind.light,
  MissionKind.breathe,
  MissionKind.catchDot,
  MissionKind.oneThing,
];

/// The app's own task icon for [kind] (E-R2-28, ED-331).
TaskIcon missionIcon(MissionKind kind) => switch (kind) {
  MissionKind.standUp => TaskIcon.standUp,
  MissionKind.walk => TaskIcon.walking,
  MissionKind.light => TaskIcon.lightBulb,
  MissionKind.breathe => TaskIcon.lungs,
  MissionKind.catchDot => TaskIcon.target,
  MissionKind.oneThing => TaskIcon.star,
};

/// When missions run (docs/15 §8 rule 2).
Future<void> pickMissionMode(BuildContext context, Settings settings) async {
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

/// Walk's steps (15 §9: 10–60).
Future<void> pickMissionSteps(BuildContext context, Settings settings) async {
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

/// The backup when the chosen mission can't run that morning.
Future<void> pickMissionBackup(BuildContext context, Settings settings) async {
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
