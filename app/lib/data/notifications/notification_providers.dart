import 'package:dottoday/core/clock/clock_provider.dart';
import 'package:dottoday/core/env/env_provider.dart';
import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/logging/logger_provider.dart';
import 'package:dottoday/core/router/router_provider.dart';
import 'package:dottoday/data/auth/account_providers.dart';
import 'package:dottoday/data/notifications/alarm_sound.dart';
import 'package:dottoday/data/notifications/fln_notification_platform.dart';
import 'package:dottoday/data/notifications/in_app_alerts.dart';
import 'package:dottoday/data/notifications/notification_platform.dart';
import 'package:dottoday/data/notifications/notification_responder.dart';
import 'package:dottoday/data/notifications/permission_providers.dart';
import 'package:dottoday/data/notifications/push/web_push_wiring.dart';
import 'package:dottoday/data/notifications/sound/sound_player.dart';
import 'package:dottoday/data/notifications/timer_notification_platform.dart';
import 'package:dottoday/data/notifications/web/browser_notifications_any.dart';
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

/// Plays a bundled reminder sound in the app (picker preview, web strip).
@Riverpod(keepAlive: true)
SoundPlayer soundPlayer(Ref ref) =>
    platformSoundPlayer(ref.watch(loggerProvider));

/// The scheduler under the gateway: the OS on iOS, Android and macOS; on
/// the web, timers while the tab is open, posting through the service
/// worker or the in-app banner (M5.3).
@Riverpod(keepAlive: true)
Future<NotificationPlatform> notificationPlatform(Ref ref) async {
  final profile = await ref.watch(localProfileProvider.future);
  final l10n = lookupAppLocalizations(Locale(profile.locale));
  if (kIsWeb) {
    final tab = TimerNotificationPlatform(
      clock: ref.watch(clockProvider),
      show: (n) => showBrowserNotification(
        n,
        doneLabel: l10n.notifActionDone,
        openLabel: l10n.notifActionOpen,
      ),
      onInApp: (n) => deliverInApp(
        n,
        add: ref.read(inAppAlertsProvider.notifier).add,
        player: ref.read(soundPlayerProvider),
      ),
      taps: browserNotificationTaps(),
    );
    return withServerPush(
      tab,
      client: ref.watch(supabaseClientProvider),
      vapidPublicKey: ref.watch(envProvider).webPushVapidPublicKey,
      permission: ref.watch(notificationPermissionProvider),
      l10n: l10n,
      logger: ref.watch(loggerProvider),
    );
  }
  final apple =
      defaultTargetPlatform == TargetPlatform.iOS ||
      defaultTargetPlatform == TargetPlatform.macOS;
  final logger = ref.watch(loggerProvider);
  return FlnNotificationPlatform(
    ref.watch(localNotificationsPluginProvider),
    l10n,
    ref.watch(clockProvider),
    prepare: apple ? () => installAlarmSound(logger: logger) : null,
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
/// handles the tap that launched the app. The gateway waits on this before
/// touching the OS.
@Riverpod(keepAlive: true)
Future<NotificationPlatform> notificationsStarted(Ref ref) async {
  final platform = await ref.watch(notificationPlatformProvider.future);
  final responder = ref.read(notificationResponderProvider);
  await platform.initialize((tap) => responder.handle(tap));
  final launch = await platform.launchTap();
  if (launch != null) await responder.handle(launch);
  return platform;
}
