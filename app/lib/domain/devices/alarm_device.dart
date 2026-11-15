import 'package:dottoday/domain/devices/device.dart';
import 'package:dottoday/domain/entities/settings.dart';

// "Alarm sounds on" (ED-084, docs/15 §9a): one device per account arms
// Wake Up; every other device disarms when it syncs. Mac and web never
// ring. There is no backup ringing and no exactly-once claim across
// devices: a device that is offline during a switch may ring once more.

/// Whether this install rings Wake Up: it must be able to ([canRing]: a
/// phone or tablet), and be the chosen device. Before any device is chosen
/// every phone rings, as before the device list, so an upgrade silences
/// nobody.
///
/// ```dart
/// ringsOnThisDevice(s.copyWith(alarmDeviceId: 'a'), canRing: true,
///     deviceId: 'b'); // false: another device rings
/// ```
bool ringsOnThisDevice(
  Settings settings, {
  required bool canRing,
  required String? deviceId,
}) {
  if (!canRing) return false;
  final chosen = settings.alarmDeviceId;
  return chosen == null || chosen == deviceId;
}

/// Whether this install should make itself the alarm device: the alarm is
/// on, none is chosen yet, and it can ring (first phone to sync wins).
bool claimsAlarmDevice(Settings settings, {required bool canRing}) =>
    canRing && settings.wakeUpAlarm && settings.alarmDeviceId == null;

/// How long without a report before the chosen device reads "Offline".
const alarmDeviceOfflineAfter = Duration(hours: 24);

/// How often an unchanged device re-reports that it is still here.
const deviceSeenEvery = Duration(hours: 6);

/// The "Alarm sounds on" row's state (ED-084 states).
enum AlarmDeviceState {
  /// The chosen device rings; its next Wake Up, when one is planned.
  ready,

  /// Chosen, but it hasn't synced and taken over yet (a switch).
  waitingToSync,

  /// The chosen device has Wake Up alarms turned off or not allowed.
  alarmsOff,

  /// No device is chosen, or the chosen one is gone or can't ring.
  noDevice,

  /// The chosen device hasn't been seen for [alarmDeviceOfflineAfter].
  offline,
}

/// The state of [chosen] (the device `alarmDeviceId` names, or null) at
/// [nowUtc].
///
/// ```dart
/// alarmDeviceState(phone.copyWith(alarmOn: true, rings: true),
///     nowUtc: now);
/// // AlarmDeviceState.ready
/// ```
AlarmDeviceState alarmDeviceState(Device? chosen, {required DateTime nowUtc}) {
  if (chosen == null || chosen.deletedAt != null || !chosen.canRing) {
    return AlarmDeviceState.noDevice;
  }
  if (nowUtc.difference(chosen.lastSeenUtc) > alarmDeviceOfflineAfter) {
    return AlarmDeviceState.offline;
  }
  if (!chosen.alarmOn) return AlarmDeviceState.alarmsOff;
  if (!chosen.rings) return AlarmDeviceState.waitingToSync;
  return AlarmDeviceState.ready;
}

/// Whether [next] (this install's fresh row) needs sending: something
/// changed since [last], or it was last seen [deviceSeenEvery] ago.
bool deviceNeedsReport(Device? last, Device next) {
  if (last == null) return true;
  if (last.copyWith(lastSeenUtc: next.lastSeenUtc) != next) return true;
  return next.lastSeenUtc.difference(last.lastSeenUtc) >= deviceSeenEvery;
}
