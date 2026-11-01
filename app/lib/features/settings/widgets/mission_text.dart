import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/domain/entities/enums.dart';

/// "Only after a snooze" (docs/15 §8 rule 2).
String missionModeText(AppLocalizations l10n, MissionMode mode) =>
    switch (mode) {
      MissionMode.off => l10n.missionModeOff,
      MissionMode.whenAsked => l10n.missionModeWhenAsked,
      MissionMode.afterSnooze => l10n.missionModeAfterSnooze,
      MissionMode.chosenDays => l10n.missionModeChosenDays,
      MissionMode.always => l10n.missionModeAlways,
    };

/// "Stand up" (15 §8).
String missionKindText(AppLocalizations l10n, MissionKind kind) =>
    switch (kind) {
      MissionKind.standUp => l10n.missionStandUp,
      MissionKind.walk => l10n.missionWalk,
      MissionKind.light => l10n.missionLight,
      MissionKind.breathe => l10n.missionBreathe,
      MissionKind.catchDot => l10n.missionCatchDot,
      MissionKind.oneThing => l10n.missionOneThing,
    };

/// The backup mission, or "None".
String missionBackupText(AppLocalizations l10n, MissionKind? kind) =>
    kind == null ? l10n.missionBackupNone : missionKindText(l10n, kind);
