import 'package:dottoday/data/notifications/web/browser_notifications_any.dart';
import 'package:dottoday/domain/notifications/notification_permission.dart';

/// The browser's notification permission (docs/09 M5.3). "Default" is
/// not asked yet; a browser has no settings page a site can open, so the
/// M3f.8 notice says where to go.
final class WebNotificationPermission implements NotificationPermission {
  const WebNotificationPermission();

  @override
  Future<PermissionState> status() async => browserPermission();

  @override
  Future<PermissionState> request() => requestBrowserPermission();

  @override
  Future<bool> openSettings() async => false;
}
