import 'package:dottoday/core/clock/clock_provider.dart';
import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/logging/logger_provider.dart';
import 'package:dottoday/core/router/router_provider.dart';
import 'package:dottoday/data/notifications/fln_notification_platform.dart';
import 'package:dottoday/data/notifications/notification_platform.dart';
import 'package:dottoday/data/notifications/notification_responder.dart';
import 'package:dottoday/data/profile/profile_providers.dart';
import 'package:dottoday/data/repositories/repository_providers.dart';
import 'package:dottoday/data/writes/write_providers.dart';
import 'package:dottoday/domain/entities/settings.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'notification_providers.g.dart';

/// The plugin, one per app.
@Riverpod(keepAlive: true)
FlutterLocalNotificationsPlugin localNotificationsPlugin(Ref ref) =>
    FlutterLocalNotificationsPlugin();

/// The OS scheduler: iOS, Android and macOS; null on the web until web
/// push (M5.3).
@Riverpod(keepAlive: true)
Future<NotificationPlatform?> notificationPlatform(Ref ref) async {
  if (kIsWeb) return null;
  final profile = await ref.watch(localProfileProvider.future);
  return FlnNotificationPlatform(
    ref.watch(localNotificationsPluginProvider),
    lookupAppLocalizations(Locale(profile.locale)),
    ref.watch(clockProvider),
  );
}

/// The newest stored profile (settings and locale as changed since launch).
Future<Profile> latestProfile(Ref ref) async {
  final local = await ref.read(localProfileProvider.future);
  final stored = await ref
      .read(settingsRepositoryProvider)
      .watchProfile(local.id)
      .first;
  return stored ?? local;
}

@Riverpod(keepAlive: true)
NotificationResponder notificationResponder(Ref ref) => NotificationResponder(
  clock: ref.watch(clockProvider),
  writes: ref.watch(writeUseCaseProvider),
  occurrences: ref.watch(occurrenceRepositoryProvider),
  profile: () => latestProfile(ref),
  open: (location) => ref.read(routerProvider).go(location),
  logger: ref.watch(loggerProvider),
);

/// Initialises the platform once (channels, actions, the tap handler) and
/// handles the tap that launched the app; null on the web. The gateway
/// waits on this before touching the OS.
@Riverpod(keepAlive: true)
Future<NotificationPlatform?> notificationsStarted(Ref ref) async {
  final platform = await ref.watch(notificationPlatformProvider.future);
  if (platform == null) return null;
  final responder = ref.read(notificationResponderProvider);
  await platform.initialize((tap) => responder.handle(tap));
  final launch = await platform.launchTap();
  if (launch != null) await responder.handle(launch);
  return platform;
}
