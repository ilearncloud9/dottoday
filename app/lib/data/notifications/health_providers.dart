import 'package:dottoday/data/notifications/notification_providers.dart';
import 'package:dottoday/data/notifications/permission_providers.dart';
import 'package:dottoday/data/profile/profile_providers.dart';
import 'package:dottoday/data/sync/sync_providers.dart';
import 'package:dottoday/domain/notifications/notification_health.dart';
import 'package:dottoday/domain/notifications/notification_payload.dart';
import 'package:dottoday/domain/notifications/notification_permission.dart';
import 'package:dottoday/domain/sync/sync_status.dart';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'health_providers.g.dart';

/// This device for the health checks (not for layout, CLAUDE.md §11).
HealthPlatform currentHealthPlatform() {
  if (kIsWeb) return HealthPlatform.web;
  return switch (defaultTargetPlatform) {
    TargetPlatform.android => HealthPlatform.android,
    TargetPlatform.macOS => HealthPlatform.mac,
    _ => HealthPlatform.iphone,
  };
}

/// Battery optimisation and Do Not Disturb now (Android); re-read with
/// `ref.invalidate` on resume.
@riverpod
Future<({bool battery, bool dnd})> powerState(Ref ref) async {
  final power = ref.watch(batteryOptimizationProvider);
  return (battery: await power.restricted(), dnd: await power.doNotDisturb());
}

/// Sounds in use whose Android channel the user muted (docs/12 §4): the
/// default and Start sounds and every pending reminder's. Re-read with
/// `ref.invalidate` on resume.
@riverpod
Future<Set<String>> mutedSounds(Ref ref) async {
  final platform = await ref.watch(notificationPlatformProvider.future);
  final muted = await platform.mutedSoundIds();
  if (muted.isEmpty) return const {};
  final settings = (await ref.watch(currentProfileProvider.future)).settings;
  final inUse = soundsInUse(
    reminderSound: settings.reminderSound,
    startSoundId: settings.startSoundId,
    plannedSounds: [
      for (final (id, payload) in await platform.pending())
        decodeNotificationPayload(id, payload)?.sound,
    ],
  );
  return muted.intersection(inUse);
}

/// The notification health panel's rows from the real OS state (docs/09
/// M6.5.8, 11 A0), recomputed whenever one of its inputs is re-read.
@riverpod
Future<List<HealthCheck>> notificationHealthChecks(Ref ref) async {
  final permission = await ref.watch(
    notificationPermissionStateProvider.future,
  );
  final exact = await ref.watch(exactAlarmsAllowedProvider.future);
  final power = await ref.watch(powerStateProvider.future);
  final muted = await ref.watch(mutedSoundsProvider.future);
  final sync = ref.watch(syncStatusProvider).value;
  final settings = (await ref.watch(currentProfileProvider.future)).settings;
  final wakeUp = settings.wakeUpAlarm
      ? await ref.watch(alarmCapabilitiesNowProvider.future)
      : null;
  final signedIn = sync != null && sync.state != SyncState.localOnly;
  return notificationHealth(
    HealthInputs(
      platform: currentHealthPlatform(),
      permission: permission,
      exactAlarms: exact,
      batteryRestricted: power.battery,
      doNotDisturb: power.dnd,
      // The tab mirrors reminders to push once signed in with notifications
      // allowed (M5.3b, M6.1).
      webPushReady: signedIn && permission == PermissionState.granted,
      clockSkew: sync?.clockSkew,
      mutedSounds: muted,
      wakeUp: wakeUp,
    ),
  );
}
