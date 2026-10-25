// Non-web builds: there is no browser (docs/09 M5.3). Never called there;
// the providers pick the OS scheduler instead.
import 'package:dottoday/data/notifications/notification_platform.dart';
import 'package:dottoday/domain/notifications/notification_permission.dart';

bool get browserNotificationsSupported => false;

PermissionState browserPermission() => PermissionState.denied;

Future<PermissionState> requestBrowserPermission() async =>
    PermissionState.denied;

Future<bool> showBrowserNotification(
  OsNotification n, {
  required String doneLabel,
  required String plusLabel,
}) async => false;

Stream<NotificationTap> browserNotificationTaps() => const Stream.empty();
