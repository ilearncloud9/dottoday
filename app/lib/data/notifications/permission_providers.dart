import 'package:dottoday/data/db/database_providers.dart';
import 'package:dottoday/data/notifications/fln_notification_permission.dart';
import 'package:dottoday/data/notifications/notification_providers.dart';
import 'package:dottoday/domain/notifications/notification_permission.dart';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'permission_providers.g.dart';

/// The web until web push (M5.3): nothing is posted, so nothing is
/// denied either.
final class UnwiredNotificationPermission implements NotificationPermission {
  const UnwiredNotificationPermission();

  @override
  Future<PermissionState> status() async => PermissionState.granted;

  @override
  Future<PermissionState> request() async => PermissionState.granted;

  @override
  Future<bool> openSettings() async => false;
}

/// The OS permission on iOS, Android and macOS (M5.1); the web's arrives
/// with web push (M5.3).
@Riverpod(keepAlive: true)
NotificationPermission notificationPermission(Ref ref) => kIsWeb
    ? const UnwiredNotificationPermission()
    : FlnNotificationPermission(
        ref.watch(localNotificationsPluginProvider),
        ref.watch(appDatabaseProvider),
      );

/// The permission now; re-read with `ref.invalidate` (on resume, after
/// Open settings).
@riverpod
Future<PermissionState> notificationPermissionState(Ref ref) =>
    ref.watch(notificationPermissionProvider).status();
