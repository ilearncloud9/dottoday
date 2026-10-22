import 'package:dottoday/domain/notifications/notification_permission.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'permission_providers.g.dart';

/// Until the platform scheduler lands (M5.1 / M5.3) nothing is posted, so
/// nothing is denied either.
final class UnwiredNotificationPermission implements NotificationPermission {
  const UnwiredNotificationPermission();

  @override
  Future<PermissionState> status() async => PermissionState.granted;

  @override
  Future<PermissionState> request() async => PermissionState.granted;

  @override
  Future<bool> openSettings() async => false;
}

@Riverpod(keepAlive: true)
NotificationPermission notificationPermission(Ref ref) =>
    const UnwiredNotificationPermission();

/// The permission now; re-read with `ref.invalidate` (on resume, after
/// Open settings).
@riverpod
Future<PermissionState> notificationPermissionState(Ref ref) =>
    ref.watch(notificationPermissionProvider).status();
