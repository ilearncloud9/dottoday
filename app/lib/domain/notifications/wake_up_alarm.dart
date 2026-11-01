import 'package:dottoday/domain/entities/settings.dart';
import 'package:dottoday/domain/notifications/sound_catalogue.dart';
import 'package:dottoday/domain/notifications/sound_resolution.dart';
import 'package:dottoday/domain/wake_up/mission.dart';

/// Snooze lengths Settings › Wake Up alarm offers, in minutes (15 §9).
const wakeUpSnoozeChoices = [5, 9, 10, 15];

/// Snooze limits on offer; 0 is "no limit" (15 §9).
const wakeUpSnoozeLimits = [1, 2, 3, 4, 5, 0];

/// Android's volume ramp on offer, in seconds; 0 starts at full (15 §9).
const wakeUpRampChoices = [0, 15, 30, 60];

/// The Wake Up Check's waits on offer, in minutes (15 §9: 5–30).
const wakeUpCheckChoices = [5, 10, 15, 20, 30];

/// The Start sounds a varied Wake Up alarm rotates through: the start tier
/// without the insistent one, which is opt-in only (docs/12 D7).
final List<CatalogueSound> wakeUpRotation = List.unmodifiable([
  for (final s in soundCatalogue)
    if (s.category == SoundCategory.start && s.id != insistentStartSoundId) s,
]);

/// What the Wake Up alarm plays on the civil [date] (15 W1 "Sound
/// rotation"): `wakeUpSoundId`, else the Start sound; with
/// `wakeUpVarySound` on, the next cue of [wakeUpRotation] each day from
/// there, so a given date always gets the same cue.
///
/// ```dart
/// wakeUpSound(const Settings(wakeUpSoundId: 'start.bells'), DateTime(2026, 11, 2));
/// // start.bells
/// ```
CatalogueSound wakeUpSound(Settings settings, DateTime date) {
  final base = resolveStartSound(
    settings.wakeUpSoundId ?? settings.startSoundId,
  );
  if (!settings.wakeUpVarySound) return base;
  final day = DateTime.utc(date.year, date.month, date.day);
  final days = day.millisecondsSinceEpoch ~/ Duration.millisecondsPerDay;
  final start = wakeUpRotation.indexOf(base).clamp(0, wakeUpRotation.length);
  return wakeUpRotation[(start + days) % wakeUpRotation.length];
}

/// One Wake Up alarm handed to the OS through `AlarmGateway.sync` (docs/15
/// W1b): its own text, because the ringing screen shows it with the app
/// closed.
final class WakeUpAlarm {
  const WakeUpAlarm({
    required this.id,
    required this.fireAtUtc,
    required this.sound,
    required this.title,
    required this.body,
    required this.stopLabel,
    required this.snoozeLabel,
    this.snoozeMinutes = 0,
    this.snoozeLimit = 0,
    this.rampSeconds = 0,
    this.minimal = false,
    this.check,
    this.mission,
  });

  /// `wakeup:<yyyy-mm-dd>` (the civil day), or [testId].
  final String id;
  final DateTime fireAtUtc;
  final CatalogueSound sound;

  /// "Wake Up", and what the day starts with.
  final String title;
  final String body;

  /// "I'm up" and "Snooze".
  final String stopLabel;
  final String snoozeLabel;

  /// 0 hides Snooze.
  final int snoozeMinutes;

  /// Snoozes before Snooze goes away; 0 = no limit.
  final int snoozeLimit;

  /// Android only: seconds from a low volume to the alarm stream's own.
  final int rampSeconds;

  /// Minimal mode's ringing screen (15 §10): one big "I'm up".
  final bool minimal;

  /// The Wake Up Check the OS arms when "I'm up" stops this alarm (15 W3),
  /// or null when it is off or the day has no dot to start.
  final WakeUpCheck? check;

  /// This morning's mission (15 §8), or null: "I'm up" then silences the
  /// ring and opens it, re-ringing each minute until an exit.
  final MissionPlan? mission;

  /// This alarm with [plan] as its mission.
  WakeUpAlarm withMission(MissionPlan? plan) => WakeUpAlarm(
    id: id,
    fireAtUtc: fireAtUtc,
    sound: sound,
    title: title,
    body: body,
    stopLabel: stopLabel,
    snoozeLabel: snoozeLabel,
    snoozeMinutes: snoozeMinutes,
    snoozeLimit: snoozeLimit,
    rampSeconds: rampSeconds,
    minimal: minimal,
    check: check,
    mission: plan,
  );

  /// The test alarm's id: `sync` never disarms it.
  static const testId = 'wakeup:test';

  @override
  bool operator ==(Object other) =>
      other is WakeUpAlarm &&
      other.id == id &&
      other.fireAtUtc == fireAtUtc &&
      other.sound == sound &&
      other.title == title &&
      other.body == body &&
      other.stopLabel == stopLabel &&
      other.snoozeLabel == snoozeLabel &&
      other.snoozeMinutes == snoozeMinutes &&
      other.snoozeLimit == snoozeLimit &&
      other.rampSeconds == rampSeconds &&
      other.minimal == minimal &&
      other.check == check &&
      other.mission == mission;

  @override
  int get hashCode => Object.hash(
    id,
    fireAtUtc,
    sound,
    title,
    body,
    stopLabel,
    snoozeLabel,
    snoozeMinutes,
    snoozeLimit,
    rampSeconds,
    minimal,
    check,
    mission,
  );

  @override
  String toString() => 'WakeUpAlarm($id, $fireAtUtc)';
}

/// The Wake Up Check (docs/15 W3): [minutes] after "I'm up", while
/// nothing has started, one nudge that starts [occurrenceId] in Focus.
/// The OS side arms it at the stop, so it reaches a phone put back down;
/// a start in the app calls it off (`AlarmGateway.sync`'s started days).
final class WakeUpCheck {
  const WakeUpCheck({
    required this.minutes,
    required this.occurrenceId,
    required this.title,
    required this.body,
    required this.startLabel,
    this.loud = false,
  });

  final int minutes;
  final String occurrenceId;

  /// "Just Lay out clothes · 2 min?" or "Start Run?".
  final String title;
  final String body;
  final String startLabel;

  /// Rings like the alarm (once, no snooze) instead of a gentle ping.
  final bool loud;

  @override
  bool operator ==(Object other) =>
      other is WakeUpCheck &&
      other.minutes == minutes &&
      other.occurrenceId == occurrenceId &&
      other.title == title &&
      other.body == body &&
      other.startLabel == startLabel &&
      other.loud == loud;

  @override
  int get hashCode =>
      Object.hash(minutes, occurrenceId, title, body, startLabel, loud);
}
