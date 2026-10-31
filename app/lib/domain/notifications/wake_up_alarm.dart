import 'package:dottoday/domain/entities/settings.dart';
import 'package:dottoday/domain/notifications/sound_catalogue.dart';
import 'package:dottoday/domain/notifications/sound_resolution.dart';

/// Snooze lengths Settings › Wake Up alarm offers, in minutes (15 §9).
const wakeUpSnoozeChoices = [5, 9, 10, 15];

/// Snooze limits on offer; 0 is "no limit" (15 §9).
const wakeUpSnoozeLimits = [1, 2, 3, 4, 5, 0];

/// Android's volume ramp on offer, in seconds; 0 starts at full (15 §9).
const wakeUpRampChoices = [0, 15, 30, 60];

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
      other.minimal == minimal;

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
  );

  @override
  String toString() => 'WakeUpAlarm($id, $fireAtUtc)';
}
