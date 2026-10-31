import 'package:dottoday/domain/notifications/notification_health.dart';
import 'package:dottoday/domain/notifications/notification_permission.dart';
import 'package:dottoday/domain/notifications/wake_up_alarm.dart';

/// How loud the Wake Up alarm can be on this device (docs/15 §2): [alarm]
/// on Android with the full-screen intent and on iOS 26+ with AlarmKit
/// allowed (W1b), [timeSensitive] on other iPhones.
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

  /// iOS 26+: Dottoday's alarms are not allowed yet (asked or turned off).
  alarmsDenied,

  /// iOS below 26 on an iPhone that can update to it.
  osTooOld,
}

/// AlarmKit on this iPhone (docs/15 §2, W1b); every other device reads
/// [unsupported].
enum AlarmKitStatus {
  /// iOS 26+, alarms allowed.
  authorized,

  /// iOS 26+, never asked.
  notAsked,

  /// iOS 26+, turned off in Settings.
  denied,

  /// Below iOS 26 on hardware that can run it.
  needsUpdate,

  /// No AlarmKit here, and no update brings it.
  unsupported,
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
  AlarmKitStatus alarmKit = AlarmKitStatus.unsupported,
}) {
  if (!platform.isPhone) {
    return const AlarmCapabilities(AlarmTier.none, [AlarmBlocker.notAPhone]);
  }
  if (platform == HealthPlatform.iphone) return _iphone(permission, alarmKit);
  if (permission != PermissionState.granted) {
    return const AlarmCapabilities(AlarmTier.none, [
      AlarmBlocker.permissionDenied,
    ]);
  }
  final timing = [if (!exactAlarms) AlarmBlocker.exactAlarmDenied];
  return fullScreenIntent
      ? AlarmCapabilities(AlarmTier.alarm, timing)
      : AlarmCapabilities(AlarmTier.headsUp, [
          AlarmBlocker.fullScreenIntentRevoked,
          ...timing,
        ]);
}

/// The Wake Up alarm's port to the OS (docs/15 §3, ADR-0017): AlarmKit on
/// iOS 26+, the ringing screen on Android. Where it arms nothing (older
/// iPhones, exact alarms off, the Mac and the web) `NotificationPlanner`
/// rings the Wake Up on the notification path instead (W1a).
abstract interface class AlarmGateway {
  /// What this device can do now; re-read on resume.
  Future<AlarmCapabilities> capabilities();

  /// Opens the system page (or prompt) that removes [blocker].
  Future<void> fix(AlarmBlocker blocker);

  /// Shows the OS's own alarm prompt where it was never shown (iOS 26+,
  /// when the Wake Up switch goes on); anywhere else, nothing.
  Future<void> requestAuthorization();

  /// Makes [alarms] the armed set: arms new and changed ones and disarms
  /// the rest, except one ringing or snoozed now (only dismissing ends
  /// those) and the test alarm. Returns the instants armed, or null when
  /// the OS side can't be reached (a background engine), so the caller
  /// keeps what it knew. Idempotent.
  Future<Set<DateTime>?> sync(List<WakeUpAlarm> alarms);

  /// Stops and disarms every Wake Up alarm, ringing or snoozed included:
  /// the switch went off.
  Future<void> disarmAll();

  /// Arms [alarm] (a [WakeUpAlarm.testId] one) apart from [sync]'s set;
  /// false when this device has no alarm path, so the caller falls back to
  /// the notification test alarm.
  Future<bool> test(WakeUpAlarm alarm);
}

/// AlarmKit rings without the notification permission, so an allowed
/// AlarmKit is the alarm tier on its own; otherwise allowing it is the
/// first fix offered.
AlarmCapabilities _iphone(PermissionState permission, AlarmKitStatus kit) {
  if (kit == AlarmKitStatus.authorized) {
    return const AlarmCapabilities(AlarmTier.alarm);
  }
  final blockers = [
    if (kit == AlarmKitStatus.notAsked || kit == AlarmKitStatus.denied)
      AlarmBlocker.alarmsDenied,
    if (permission != PermissionState.granted) AlarmBlocker.permissionDenied,
    if (kit == AlarmKitStatus.needsUpdate) AlarmBlocker.osTooOld,
  ];
  final tier = permission == PermissionState.granted
      ? AlarmTier.timeSensitive
      : AlarmTier.none;
  return AlarmCapabilities(tier, blockers);
}

bool _sameList(List<AlarmBlocker> a, List<AlarmBlocker> b) {
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}
