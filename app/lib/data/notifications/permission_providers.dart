import 'package:dottoday/data/db/database_providers.dart';
import 'package:dottoday/data/notifications/fln_exact_alarms.dart';
import 'package:dottoday/data/notifications/fln_notification_permission.dart';
import 'package:dottoday/data/notifications/notification_providers.dart';
import 'package:dottoday/data/notifications/web_notification_permission.dart';
import 'package:dottoday/domain/notifications/exact_alarms.dart';
import 'package:dottoday/domain/notifications/notification_permission.dart';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'permission_providers.g.dart';

/// Nothing is posted, so nothing is denied either: tests and any build
/// without an OS scheduler.
final class UnwiredNotificationPermission implements NotificationPermission {
  const UnwiredNotificationPermission();

  @override
  Future<PermissionState> status() async => PermissionState.granted;

  @override
  Future<PermissionState> request() async => PermissionState.granted;

  @override
  Future<bool> openSettings() async => false;
}

/// The OS permission on iOS, Android and macOS (M5.1), the browser's on
/// the web (M5.3).
@Riverpod(keepAlive: true)
NotificationPermission notificationPermission(Ref ref) => kIsWeb
    ? const WebNotificationPermission()
    : FlnNotificationPermission(
        ref.watch(localNotificationsPluginProvider),
        ref.watch(appDatabaseProvider),
      );

/// The permission now; re-read with `ref.invalidate` (on resume, after
/// Open settings).
@riverpod
Future<PermissionState> notificationPermissionState(Ref ref) =>
    ref.watch(notificationPermissionProvider).status();

/// Exact reminder timing (M5.6): gated on Android 12+ only.
@Riverpod(keepAlive: true)
ExactAlarms exactAlarms(Ref ref) =>
    !kIsWeb && defaultTargetPlatform == TargetPlatform.android
    ? FlnExactAlarms(ref.watch(localNotificationsPluginProvider))
    : const AlwaysExactAlarms();

/// Whether exact timing is allowed now; re-read with `ref.invalidate` (on
/// resume, after the system screen).
@riverpod
Future<bool> exactAlarmsAllowed(Ref ref) =>
    ref.watch(exactAlarmsProvider).allowed();
