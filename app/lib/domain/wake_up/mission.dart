import 'package:dottoday/domain/entities/enums.dart';
import 'package:dottoday/domain/entities/settings.dart';
import 'package:dottoday/domain/notifications/alarm_capabilities.dart';
import 'package:dottoday/domain/wake_up/one_thing.dart';

/// The backup missions on offer (15 §8 `missionBackup`): none, or one
/// that needs no dots.
const missionBackups = [null, MissionKind.walk, MissionKind.standUp];

/// Step targets on offer for Walk (15 §8: 10–60, default 20).
const missionStepChoices = [10, 20, 30, 40, 60];

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
  final kind = flagged
      ? flaggedMissionKind(settings, dots: dots, can: can)
      : missionKindFor(settings, dots: dots, can: can);
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

/// The mission of a "Make sure I'm up" morning (15 §8 rule 5): the chosen
/// one, else always the gentlest, Breathe, which every phone can run; never
/// a step count (owner, 2026-11-01). The user asked to be sure, so the
/// morning always has one.
///
/// ```dart
/// flaggedMissionKind(const Settings(missionKind: MissionKind.oneThing),
///     dots: 1, can: (_) => true); // MissionKind.breathe
/// ```
MissionKind? flaggedMissionKind(
  Settings settings, {
  required int dots,
  required bool Function(MissionKind kind) can,
}) {
  final chosen = settings.missionKind;
  final runs =
      can(chosen) &&
      (chosen != MissionKind.oneThing || dots >= oneThingMinDots);
  if (runs) return chosen;
  return can(MissionKind.breathe) ? MissionKind.breathe : null;
}

/// Whether the morning of [dateKey] is flagged "Make sure I'm up" (15 §8
/// rule 5): by the Wind Down review's toggle for that date, or by the task
/// sheet's switch on the day's [firstDotId]. Hidden and ignored while
/// missions are off.
///
/// ```dart
/// morningFlagged(const Settings(missionMode: MissionMode.whenAsked,
///     missionFlagDate: '2026-11-03'), '2026-11-03'); // true
/// ```
bool morningFlagged(Settings settings, String dateKey, {String? firstDotId}) {
  if (settings.missionMode == MissionMode.off) return false;
  if (settings.missionFlagDate == dateKey) return true;
  return firstDotId != null && settings.missionFlagIds.contains(firstDotId);
}

/// [settings] with [occurrenceId]'s "Make sure I'm up for this" switch set
/// to [on], keeping only flags in [live] (occurrences still ahead), so a
/// flag lasts one morning and the list never grows.
Settings withMissionFlag(
  Settings settings,
  String occurrenceId, {
  required bool on,
  required Set<String> live,
}) => settings.copyWith(
  missionFlagIds: [
    for (final id in settings.missionFlagIds)
      if (id != occurrenceId && live.contains(id)) id,
    if (on) occurrenceId,
  ],
);

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
