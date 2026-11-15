import 'package:dottoday/data/db/app_database.dart';
import 'package:dottoday/domain/devices/device.dart';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

/// This install on the device list (ED-084): its id per account, and its
/// platform and form. The id is a UUID v7 kept in `local_meta`, one per
/// account, so a second account signed in on the same phone gets a row of
/// its own (CR-160: no row is shared across accounts).
final class DeviceIdentity {
  DeviceIdentity(
    this._db, {
    DevicePlatform? platform,
    DeviceForm? form,
    String Function()? newId,
  }) : platform = platform ?? _platform(),
       _form = form,
       _newId = newId ?? const Uuid().v7;

  final AppDatabase _db;

  /// Where this install runs.
  final DevicePlatform platform;
  final DeviceForm? _form;
  final String Function() _newId;

  /// Phone or tablet by the screen's shortest side (600 dp, the Material
  /// compact limit); always desktop on a Mac and the web. Read when asked:
  /// the window may not be laid out at launch.
  DeviceForm get form => _form ?? _formOf(platform);

  /// Whether this install can ring Wake Up at all: phones and tablets
  /// (an iPad is iPhone-class for alarms, owner 2026-11-02).
  bool get canRing => form != DeviceForm.desktop;

  /// This install's id for [userId], created on first use.
  Future<String> idFor(String userId) async {
    final key = 'device_id:$userId';
    final row = await (_db.select(
      _db.localMeta,
    )..where((m) => m.key.equals(key))).getSingleOrNull();
    if (row != null) return row.value;
    final id = _newId();
    await _db
        .into(_db.localMeta)
        .insert(LocalMetaCompanion.insert(key: key, value: id));
    return id;
  }

  static DevicePlatform _platform() {
    if (kIsWeb) return DevicePlatform.web;
    return switch (defaultTargetPlatform) {
      TargetPlatform.android => DevicePlatform.android,
      TargetPlatform.macOS => DevicePlatform.macos,
      _ => DevicePlatform.ios,
    };
  }

  static DeviceForm _formOf(DevicePlatform platform) {
    if (platform == DevicePlatform.macos || platform == DevicePlatform.web) {
      return DeviceForm.desktop;
    }
    final views = PlatformDispatcher.instance.views;
    if (views.isEmpty) return DeviceForm.phone;
    final view = views.first;
    final size = view.physicalSize / view.devicePixelRatio;
    return size.shortestSide >= 600 ? DeviceForm.tablet : DeviceForm.phone;
  }
}
