import 'package:dottoday/domain/notifications/notification_permission.dart';
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
  const HealthCheck(this.kind, this.level, {this.skew});

  final HealthCheckKind kind;
  final HealthLevel level;

  /// For [HealthCheckKind.clock] when it is off.
  final ClockSkew? skew;

  @override
  bool operator ==(Object other) =>
      other is HealthCheck &&
      other.kind == kind &&
      other.level == level &&
      other.skew == skew;

  @override
  int get hashCode => Object.hash(kind, level, skew);

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
  });

  final HealthPlatform platform;
  final PermissionState permission;
  final bool exactAlarms;
  final bool batteryRestricted;
  final bool doNotDisturb;
  final bool webPushReady;
  final ClockSkew? clockSkew;
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
