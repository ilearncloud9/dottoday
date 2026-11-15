import 'package:freezed_annotation/freezed_annotation.dart';

part 'device.freezed.dart';

/// Where an install runs (`devices.platform`, migration 0016).
enum DevicePlatform { ios, android, macos, web }

/// What kind of device it is (`devices.form`): phones and tablets can ring
/// Wake Up; a desktop (Mac, web) never does (ED-084).
enum DeviceForm { phone, tablet, desktop }

/// One install on the account's device list (ED-084, docs/05 `devices`):
/// written only by that install, read by every device for "Alarm sounds
/// on". No name or model is stored (06 §1); the UI labels it from
/// [platform] and [form].
@freezed
abstract class Device with _$Device {
  const factory Device({
    required String id,
    required String userId,
    required DevicePlatform platform,
    required DeviceForm form,
    required DateTime lastSeenUtc,

    /// Whether this device can ring Wake Up at all.
    @Default(false) bool canRing,

    /// Whether Wake Up alarms are on and allowed here right now.
    @Default(false) bool alarmOn,

    /// Whether this device has taken over as the one that rings: it has
    /// read `alarmDeviceId` naming it. False while a switch is pending.
    @Default(false) bool rings,

    /// The next Wake Up this device has armed, for "Ready · 06:30".
    DateTime? armedWakeUtc,
    DateTime? deletedAt,
  }) = _Device;
}
