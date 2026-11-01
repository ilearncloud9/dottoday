import 'package:dottoday/domain/entities/enums.dart';
import 'package:dottoday/domain/entities/settings.dart';
import 'package:dottoday/domain/notifications/alarm_capabilities.dart';

/// The backup missions on offer (15 §8 `missionBackup`): none, or one
/// that needs no dots.
const missionBackups = [null, MissionKind.walk, MissionKind.standUp];

/// Step targets on offer for Walk (15 §8: 10–60, default 20).
const missionStepChoices = [10, 20, 30, 40, 60];

/// Pick today's one thing needs a real choice (15 §8).
const oneThingMinDots = 2;

/// How many dots Pick today's one thing offers at most (15 §8: 3–5).
const oneThingMaxDots = 5;

/// Skips that bring the offer to turn missions off, and over how long
/// (15 §8 rule 4).
const missionSkipOfferCount = 3;
const missionSkipOfferWindow = Duration(days: 7);

/// The mission on one morning, as armed with its Wake Up alarm.
final class MissionPlan {
  const MissionPlan(this.kind, {required this.afterSnooze});

  final MissionKind kind;

  /// Only rings after a snooze ask for it (15 §8: "Only after a snooze");
  /// the first ring then dismisses with "I'm up" as usual.
  final bool afterSnooze;

  @override
  bool operator ==(Object other) =>
      other is MissionPlan &&
      other.kind == kind &&
      other.afterSnooze == afterSnooze;

  @override
  int get hashCode => Object.hash(kind, afterSnooze);

  @override
  String toString() => 'MissionPlan($kind, afterSnooze: $afterSnooze)';
}

/// The mission for the morning of [weekday], or null when it has none
/// (15 §8). [flagged] is a "Make sure I'm up" morning; [dots] is how many
/// dots the day has; [can] says whether this device can run a mission.
/// Missions need the alarm tier (rule 3), and Pick today's one thing
/// needs [oneThingMinDots], else the backup mission runs, if any.
///
/// ```dart
/// missionFor(const Settings(missionMode: MissionMode.afterSnooze),
///     weekday: Weekday.mon, tier: AlarmTier.alarm, dots: 3,
///     can: (_) => true);
/// // MissionPlan(MissionKind.standUp, afterSnooze: true)
/// ```
MissionPlan? missionFor(
  Settings settings, {
  required Weekday weekday,
  required AlarmTier tier,
  required int dots,
  required bool Function(MissionKind kind) can,
  bool flagged = false,
}) {
  final mode = settings.missionMode;
  if (mode == MissionMode.off || tier != AlarmTier.alarm) return null;
  final asked = switch (mode) {
    MissionMode.off || MissionMode.whenAsked => false,
    MissionMode.afterSnooze || MissionMode.always => true,
    MissionMode.chosenDays => settings.missionDays.contains(weekday),
  };
  if (!asked && !flagged) return null;
  final kind = missionKindFor(settings, dots: dots, can: can);
  if (kind == null) return null;
  // A flagged morning asks from the first ring (15 §8 rule 5).
  return MissionPlan(
    kind,
    afterSnooze: mode == MissionMode.afterSnooze && !flagged,
  );
}

/// The mission that can run on a day with [dots] dots: the chosen one,
/// else the backup, else none (15 §8 rule 3).
MissionKind? missionKindFor(
  Settings settings, {
  required int dots,
  required bool Function(MissionKind kind) can,
}) {
  bool runs(MissionKind k) =>
      can(k) && (k != MissionKind.oneThing || dots >= oneThingMinDots);
  if (runs(settings.missionKind)) return settings.missionKind;
  final backup = settings.missionBackup;
  return backup != null && runs(backup) ? backup : null;
}

/// Whether to offer turning missions off now (15 §8 rule 4): on, not yet
/// answered, and [missionSkipOfferCount] skips within the last
/// [missionSkipOfferWindow]. It is an offer; missions are never turned off
/// by the app.
bool missionOffOfferDue(
  Settings settings, {
  required Iterable<DateTime> skipsUtc,
  required DateTime nowUtc,
}) {
  if (settings.missionMode == MissionMode.off) return false;
  if (!settings.missionSkipOffer || settings.missionOffOfferAnswered) {
    return false;
  }
  final since = nowUtc.subtract(missionSkipOfferWindow);
  return skipsUtc.where((s) => s.isAfter(since)).length >=
      missionSkipOfferCount;
}

/// "Can't right now" skips after a hold this long (15 §8 rule 3).
const missionSkipHold = Duration(seconds: 5);

/// The ring the alarm re-rings after on a mission morning while the
/// screen is left alone, and how often a screen in use pushes it out.
const missionReRing = Duration(minutes: 1);
const missionKeepEvery = Duration(seconds: 30);

/// Breathe (15 §8): hold while the ring grows, let go while it shrinks,
/// [breaths] times (about 20 s).
const breatheIn = Duration(seconds: 4);
const breatheOut = Duration(seconds: 3);
const breaths = 3;

/// Catch the dot (15 §8): [catchTaps] taps on a dot that drifts once
/// round its path every [catchLoop], slow and forgiving.
const catchTaps = 5;
const catchLoop = Duration(seconds: 10);
