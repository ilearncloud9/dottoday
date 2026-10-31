import 'package:dottoday/domain/notifications/notification_health.dart';
import 'package:dottoday/domain/notifications/notification_permission.dart';

/// How loud the Wake Up alarm can be on this device (docs/15 §2). The
/// existing notification path (W1a) reaches [alarm] on Android with the
/// full-screen intent, and [timeSensitive] on iPhone; AlarmKit (W1b)
/// raises iOS 26+ to [alarm].
enum AlarmTier {
  /// Takes over the screen and rings on the alarm stream.
  alarm,

  /// iPhone: breaks through Focus, not the Silent switch.
  timeSensitive,

  /// Android without the full-screen intent: a banner that rings.
  headsUp,

  /// Rings nowhere on this device (no permission, or not a phone).
  none,
}

/// Why the Wake Up alarm is below the tier this device could reach; each
/// has a fix the UI turns into one button (15 §2).
enum AlarmBlocker {
  /// Mac and the web: the alarm rings on the user's phone.
  notAPhone,

  /// Notifications are off for Dottoday.
  permissionDenied,

  /// Android 14+: the full-screen intent was revoked (by Play or the user).
  fullScreenIntentRevoked,

  /// Android 12+: "Alarms & reminders" is off, so the alarm may be late.
  exactAlarmDenied,
}

/// The single answer every Wake Up surface reads (15 §2): no screen checks
/// an OS version or permission itself.
final class AlarmCapabilities {
  const AlarmCapabilities(this.tier, [this.blockers = const []]);

  final AlarmTier tier;

  /// In the order the UI offers fixes: the first is the one to do now.
  final List<AlarmBlocker> blockers;

  @override
  bool operator ==(Object other) =>
      other is AlarmCapabilities &&
      other.tier == tier &&
      _sameList(other.blockers, blockers);

  @override
  int get hashCode => Object.hash(tier, Object.hashAll(blockers));

  @override
  String toString() => 'AlarmCapabilities(${tier.name}, $blockers)';
}

/// What the OS allows now → the Wake Up alarm's tier and blockers.
///
/// ```dart
/// alarmCapabilities(platform: HealthPlatform.android,
///     permission: PermissionState.granted, fullScreenIntent: false);
/// // AlarmCapabilities(headsUp, [fullScreenIntentRevoked])
/// ```
AlarmCapabilities alarmCapabilities({
  required HealthPlatform platform,
  required PermissionState permission,
  bool fullScreenIntent = true,
  bool exactAlarms = true,
}) {
  if (!platform.isPhone) {
    return const AlarmCapabilities(AlarmTier.none, [AlarmBlocker.notAPhone]);
  }
  if (permission != PermissionState.granted) {
    return const AlarmCapabilities(AlarmTier.none, [
      AlarmBlocker.permissionDenied,
    ]);
  }
  final timing = [if (!exactAlarms) AlarmBlocker.exactAlarmDenied];
  if (platform == HealthPlatform.iphone) {
    return AlarmCapabilities(AlarmTier.timeSensitive, timing);
  }
  return fullScreenIntent
      ? AlarmCapabilities(AlarmTier.alarm, timing)
      : AlarmCapabilities(AlarmTier.headsUp, [
          AlarmBlocker.fullScreenIntentRevoked,
          ...timing,
        ]);
}

/// The Wake Up alarm's port to the OS (docs/15 §3, ADR-0017). W1a only
/// reads and fixes capabilities: the alarm itself is still planned by
/// `NotificationPlanner` on the existing path. W1b adds arming through
/// AlarmKit and the Android ringing screen here.
abstract interface class AlarmGateway {
  /// What this device can do now; re-read on resume.
  Future<AlarmCapabilities> capabilities();

  /// Opens the system page (or prompt) that removes [blocker].
  Future<void> fix(AlarmBlocker blocker);
}

bool _sameList(List<AlarmBlocker> a, List<AlarmBlocker> b) {
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}
