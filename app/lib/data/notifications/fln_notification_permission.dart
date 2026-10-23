import 'package:dottoday/data/db/app_database.dart';
import 'package:dottoday/domain/notifications/notification_permission.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:url_launcher/url_launcher.dart';

/// The OS notification permission (docs/09 M5.1) on iOS, Android and macOS.
///
/// Neither Apple's check nor Android 13's tells "never asked" from "said
/// no", so whether Dottoday has asked on this device is kept in
/// `local_meta` (never synced, like onboarding progress).
final class FlnNotificationPermission implements NotificationPermission {
  FlnNotificationPermission(this._plugin, this._db);

  final FlutterLocalNotificationsPlugin _plugin;
  final AppDatabase _db;

  static const _askedKey = 'notification_permission_asked';

  @override
  Future<PermissionState> status() async {
    if (await _enabled()) return PermissionState.granted;
    return await _asked() ? PermissionState.denied : PermissionState.notAsked;
  }

  @override
  Future<PermissionState> request() async {
    await _db
        .into(_db.localMeta)
        .insertOnConflictUpdate(
          LocalMetaCompanion.insert(key: _askedKey, value: 'true'),
        );
    await _android?.requestNotificationsPermission();
    await _ios?.requestPermissions(alert: true, badge: true, sound: true);
    await _mac?.requestPermissions(alert: true, badge: true, sound: true);
    return status();
  }

  @override
  Future<bool> openSettings() async {
    // Android has no public URL for an app's notification settings; the
    // UI then says where to go (M3f.8).
    final url = switch (defaultTargetPlatform) {
      TargetPlatform.iOS => 'app-settings:',
      TargetPlatform.macOS =>
        'x-apple.systempreferences:com.apple.Notifications-Settings.extension',
      _ => null,
    };
    if (url == null) return false;
    return launchUrl(Uri.parse(url));
  }

  Future<bool> _enabled() async {
    final android = _android;
    if (android != null) {
      return await android.areNotificationsEnabled() ?? false;
    }
    final options =
        await _ios?.checkPermissions() ?? await _mac?.checkPermissions();
    return options?.isEnabled ?? false;
  }

  Future<bool> _asked() async {
    final row = await (_db.select(
      _db.localMeta,
    )..where((m) => m.key.equals(_askedKey))).getSingleOrNull();
    return row != null;
  }

  AndroidFlutterLocalNotificationsPlugin? get _android => _plugin
      .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin
      >();

  IOSFlutterLocalNotificationsPlugin? get _ios => _plugin
      .resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin
      >();

  MacOSFlutterLocalNotificationsPlugin? get _mac => _plugin
      .resolvePlatformSpecificImplementation<
        MacOSFlutterLocalNotificationsPlugin
      >();
}
