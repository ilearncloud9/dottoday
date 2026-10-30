import 'package:dottoday/domain/notifications/notification_permission.dart';
import 'package:dottoday/domain/notifications/notification_planner.dart';
import 'package:dottoday/domain/notifications/sound_resolution.dart';
import 'package:dottoday/domain/sync/clock_skew.dart';

/// Where Dottoday runs, for which checks apply (docs/09 M6.5.8). Not a
/// layout switch: the panel's rows differ because the OSes do.
enum HealthPlatform { iphone, android, mac, web }

/// One thing that decides whether a reminder gets through.
enum HealthCheckKind {
  /// Notifications allowed at all (every platform).
  permission,

  /// Android 12+ "Alarms & reminders": exact timing.
  exactAlarms,

  /// Android battery optimisation may delay background work.
  battery,

  /// Android Do Not Disturb is on: alarms ring, other reminders are quiet.
  doNotDisturb,

  /// Android: a reminder sound in use whose channel the user muted in the
  /// system settings — named, rather than falling silent (docs/12 §4).
  sounds,

  /// iPhone/Mac Focus: can't be read; dot-starts break through anyway.
  focus,

  /// Web: reminders with the tab closed need push (sign in + allow).
  webPush,

  /// This device's clock against the server's (M6.5.7).
  clock,
}

/// Whether a check needs fixing ([problem]) or is only worth knowing.
enum HealthLevel { ok, problem, info }

/// A row of the panel.
final class HealthCheck {
  const HealthCheck(
    this.kind,
    this.level, {
    this.skew,
    this.mutedSounds = const [],
  });

  final HealthCheckKind kind;
  final HealthLevel level;

  /// For [HealthCheckKind.clock] when it is off.
  final ClockSkew? skew;

  /// For [HealthCheckKind.sounds]: the muted sound ids, sorted.
  final List<String> mutedSounds;

  @override
  bool operator ==(Object other) =>
      other is HealthCheck &&
      other.kind == kind &&
      other.level == level &&
      other.skew == skew &&
      _sameList(other.mutedSounds, mutedSounds);

  @override
  int get hashCode =>
      Object.hash(kind, level, skew, Object.hashAll(mutedSounds));

  @override
  String toString() => 'HealthCheck(${kind.name}, ${level.name})';
}

/// What the OS reports right now; read fresh on every launch and resume.
final class HealthInputs {
  const HealthInputs({
    required this.platform,
    required this.permission,
    this.exactAlarms = true,
    this.batteryRestricted = false,
    this.doNotDisturb = false,
    this.webPushReady = false,
    this.clockSkew,
    this.mutedSounds = const {},
  });

  final HealthPlatform platform;
  final PermissionState permission;
  final bool exactAlarms;
  final bool batteryRestricted;
  final bool doNotDisturb;
  final bool webPushReady;
  final ClockSkew? clockSkew;

  /// Sound ids in use (the defaults and pending reminders') whose Android
  /// channel is muted (docs/12 §4).
  final Set<String> mutedSounds;
}

/// The panel's rows for [i], in display order (11 A0 "Notification
/// health"): permission first, then what this platform adds, then the
/// clock.
///
/// ```dart
/// notificationHealth(HealthInputs(platform: HealthPlatform.android,
///     permission: PermissionState.granted, batteryRestricted: true))
///   .where((c) => c.level == HealthLevel.problem); // battery
/// ```
List<HealthCheck> notificationHealth(HealthInputs i) {
  HealthLevel problemIf(bool bad) => bad ? HealthLevel.problem : HealthLevel.ok;
  return [
    HealthCheck(
      HealthCheckKind.permission,
      problemIf(i.permission != PermissionState.granted),
    ),
    if (i.platform == HealthPlatform.android) ...[
      HealthCheck(HealthCheckKind.exactAlarms, problemIf(!i.exactAlarms)),
      HealthCheck(HealthCheckKind.battery, problemIf(i.batteryRestricted)),
      HealthCheck(
        HealthCheckKind.doNotDisturb,
        i.doNotDisturb ? HealthLevel.info : HealthLevel.ok,
      ),
      HealthCheck(
        HealthCheckKind.sounds,
        problemIf(i.mutedSounds.isNotEmpty),
        mutedSounds: [...i.mutedSounds]..sort(),
      ),
    ],
    if (i.platform == HealthPlatform.iphone || i.platform == HealthPlatform.mac)
      const HealthCheck(HealthCheckKind.focus, HealthLevel.info),
    if (i.platform == HealthPlatform.web)
      HealthCheck(
        HealthCheckKind.webPush,
        i.webPushReady ? HealthLevel.ok : HealthLevel.info,
      ),
    HealthCheck(
      HealthCheckKind.clock,
      problemIf(i.clockSkew != null),
      skew: i.clockSkew,
    ),
  ];
}

/// How many rows need fixing, for "1 thing to fix" in Settings.
int healthProblems(List<HealthCheck> checks) =>
    checks.where((c) => c.level == HealthLevel.problem).length;

bool _sameList(List<String> a, List<String> b) {
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}

/// The sound ids this user can hear right now (docs/12 §4): the default
/// task sound, the Start sound, and each of [plannedSounds] (pending
/// reminders' keys). Silent and OS-sound keys name no sound of ours.
///
/// ```dart
/// soundsInUse(reminderSound: 'system', plannedSounds: ['clear.lift']);
/// // {'dot_alarm', 'clear.lift'}
/// ```
Set<String> soundsInUse({
  String? reminderSound,
  String? startSoundId,
  Iterable<String?> plannedSounds = const [],
}) => {
  ?soundKeyFor(settings: reminderSound),
  resolveStartSound(startSoundId).id,
  for (final key in plannedSounds)
    if (key != null) resolveSound(key).id,
}..remove(soundNoneKey);
