import 'package:dottoday/domain/notifications/alarm_capabilities.dart';
import 'package:dottoday/domain/notifications/notification_permission.dart';
import 'package:dottoday/domain/notifications/notification_planner.dart';
import 'package:dottoday/domain/notifications/sound_resolution.dart';
import 'package:dottoday/domain/sync/clock_skew.dart';

/// Where Dottoday runs, for which checks apply (docs/09 M6.5.8). Not a
/// layout switch: the panel's rows differ because the OSes do.
enum HealthPlatform {
  iphone,
  android,
  mac,
  web;

  /// Rings the Wake Up alarm (docs/15 W1–W3: mobile only).
  bool get isPhone => this == iphone || this == android;
}

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

  /// The Wake Up alarm's tier on this phone, when it is on (docs/15 §2).
  wakeUp,
}

/// What can still stop an alarm-grade Wake Up on Android (docs/15 §2):
/// neither lowers the tier, so they show only in the health panel's Wake
/// Up row, each with its fix (owner, 2026-11-01: never a modal).
enum WakeUpWarning {
  /// Do Not Disturb doesn't let alarms through: the alarm is silenced.
  dndBlocksAlarms,

  /// Battery optimisation may delay arming after a reboot or a long sleep.
  batteryRestricted,
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
    this.wakeUp,
    this.wakeUpWarning,
  });

  final HealthCheckKind kind;
  final HealthLevel level;

  /// For [HealthCheckKind.clock] when it is off.
  final ClockSkew? skew;

  /// For [HealthCheckKind.sounds]: the muted sound ids, sorted.
  final List<String> mutedSounds;

  /// For [HealthCheckKind.wakeUp]: what the alarm can do here.
  final AlarmCapabilities? wakeUp;

  /// For [HealthCheckKind.wakeUp] at the alarm tier: what may still stop
  /// it, the most serious first; null when nothing does.
  final WakeUpWarning? wakeUpWarning;

  @override
  bool operator ==(Object other) =>
      other is HealthCheck &&
      other.kind == kind &&
      other.level == level &&
      other.skew == skew &&
      other.wakeUp == wakeUp &&
      other.wakeUpWarning == wakeUpWarning &&
      _sameList(other.mutedSounds, mutedSounds);

  @override
  int get hashCode => Object.hash(
    kind,
    level,
    skew,
    wakeUp,
    wakeUpWarning,
    Object.hashAll(mutedSounds),
  );

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
    this.dndAlarmsBlocked = false,
    this.webPushReady = false,
    this.clockSkew,
    this.mutedSounds = const {},
    this.wakeUp,
  });

  final HealthPlatform platform;
  final PermissionState permission;
  final bool exactAlarms;
  final bool batteryRestricted;
  final bool doNotDisturb;

  /// Do Not Disturb's settings don't let alarms through (Android).
  final bool dndAlarmsBlocked;
  final bool webPushReady;
  final ClockSkew? clockSkew;

  /// Sound ids in use (the defaults and pending reminders') whose Android
  /// channel is muted (docs/12 §4).
  final Set<String> mutedSounds;

  /// The Wake Up alarm's capabilities when it is on (docs/15 W1a); null
  /// when it is off, so the row only shows for someone who uses it.
  final AlarmCapabilities? wakeUp;
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
    if (i.wakeUp case final wakeUp? when i.platform.isPhone)
      _wakeUpCheck(i, wakeUp),
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

/// The Wake Up row: its tier, and at the alarm tier with nothing else to
/// fix, the first [WakeUpWarning] that applies (docs/15 §2).
HealthCheck _wakeUpCheck(HealthInputs i, AlarmCapabilities wakeUp) {
  final warning = wakeUp.tier != AlarmTier.alarm || wakeUp.blockers.isNotEmpty
      ? null
      : i.dndAlarmsBlocked
      ? WakeUpWarning.dndBlocksAlarms
      : i.batteryRestricted
      ? WakeUpWarning.batteryRestricted
      : null;
  final level = switch (wakeUp.tier) {
    AlarmTier.alarm when warning != null => HealthLevel.problem,
    AlarmTier.alarm => HealthLevel.ok,
    AlarmTier.timeSensitive => HealthLevel.info,
    AlarmTier.headsUp || AlarmTier.none => HealthLevel.problem,
  };
  return HealthCheck(
    HealthCheckKind.wakeUp,
    level,
    wakeUp: wakeUp,
    wakeUpWarning: warning,
  );
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
