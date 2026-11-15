import 'package:dottoday/core/clock/clock.dart';
import 'package:dottoday/core/logging/logger.dart';
import 'package:dottoday/data/devices/device_identity.dart';
import 'package:dottoday/data/devices/device_remote.dart';
import 'package:dottoday/domain/devices/alarm_device.dart';
import 'package:dottoday/domain/devices/device.dart';
import 'package:dottoday/domain/entities/settings.dart';
import 'package:dottoday/domain/repositories/device_repository.dart';

/// Keeps this install's row on the device list (ED-084) and decides
/// whether it rings Wake Up. `NotificationSync` asks [ringsHere] before
/// arming and calls [report] after, so the row says what was armed.
final class DeviceReporter {
  DeviceReporter({
    required DeviceIdentity identity,
    required DeviceRepository devices,
    required Clock clock,
    required Future<void> Function(Profile profile, String deviceId) claim,
    DeviceRemote? remote,
    Future<bool> Function()? alarmsAllowed,
    Logger? logger,
  }) : _identity = identity,
       _devices = devices,
       _clock = clock,
       _claim = claim,
       _remote = remote,
       _alarmsAllowed = alarmsAllowed,
       _logger = logger;

  final DeviceIdentity _identity;
  final DeviceRepository _devices;
  final Clock _clock;
  final Future<void> Function(Profile profile, String deviceId) _claim;
  final DeviceRemote? _remote;
  final Future<bool> Function()? _alarmsAllowed;
  final Logger? _logger;

  /// The row last sent, per account; null after a launch, so the first
  /// report of a run always goes out.
  final _sent = <String, Device>{};

  /// This install's id for [userId].
  Future<String> selfId(String userId) => _identity.idFor(userId);

  /// Whether this install rings Wake Up for [profile].
  Future<bool> ringsHere(Profile profile) async => ringsOnThisDevice(
    profile.settings,
    canRing: _identity.canRing,
    deviceId: await selfId(profile.id),
  );

  /// Records this install's row ([ringsHere], its next Wake Up
  /// [nextWakeUtc]), claims the alarm when none is chosen, sends the row
  /// when it changed or every few hours, and refreshes the cached list.
  /// A network failure is logged and retried on the next report.
  Future<void> report(
    Profile profile, {
    required bool ringsHere,
    DateTime? nextWakeUtc,
  }) async {
    final id = await selfId(profile.id);
    if (claimsAlarmDevice(profile.settings, canRing: _identity.canRing)) {
      await _claim(profile, id);
    }
    final self = await _self(profile, id, ringsHere, nextWakeUtc);
    await _devices.upsertAll([self]);
    final remote = _remote;
    if (remote == null || !deviceNeedsReport(_sent[profile.id], self)) return;
    try {
      await remote.put(self);
      _sent[profile.id] = self;
      await _devices.upsertAll(await remote.list());
    } on Object catch (e, st) {
      _logger?.warn('devices.report_failed', error: e, stackTrace: st);
    }
  }

  /// Pulls the account's list into the cache (Settings › Alarm sounds on).
  Future<void> refresh() async {
    final remote = _remote;
    if (remote == null) return;
    try {
      await _devices.upsertAll(await remote.list());
    } on Object catch (e, st) {
      _logger?.warn('devices.refresh_failed', error: e, stackTrace: st);
    }
  }

  Future<Device> _self(
    Profile profile,
    String id,
    bool ringsHere,
    DateTime? nextWakeUtc,
  ) async {
    final canRing = _identity.canRing;
    final alarmOn =
        canRing &&
        profile.settings.wakeUpAlarm &&
        (await _alarmsAllowed?.call() ?? true);
    final rings = alarmOn && ringsHere;
    return Device(
      id: id,
      userId: profile.id,
      platform: _identity.platform,
      form: _identity.form,
      canRing: canRing,
      alarmOn: alarmOn,
      rings: rings,
      armedWakeUtc: rings ? nextWakeUtc : null,
      lastSeenUtc: _clock.nowUtc(),
    );
  }
}
