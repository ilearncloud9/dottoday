// Phase 1 of "a dot-start fires with the app killed" (docs/09 M6.5.10,
// 11 A0). Schedules one task starting 75 s from now with an at-start alert
// through the real write path and OS scheduler, then ends. The host script
// `tool/killed_app_check.sh` kills the app the way the OS does (not
// force-stop, which cancels alarms), waits, and counts what the OS
// delivered: exactly one.
//
// Needs notification permission granted beforehand (the script grants it
// on Android; on iOS allow the prompt once).
import 'package:dottoday/bootstrap.dart';
import 'package:dottoday/core/ids/id_generator.dart';
import 'package:dottoday/data/notifications/notification_providers.dart';
import 'package:dottoday/data/profile/profile_providers.dart';
import 'package:dottoday/data/writes/write_providers.dart';
import 'package:dottoday/domain/entities/alert.dart';
import 'package:dottoday/domain/entities/enums.dart';
import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:dottoday/domain/notifications/notification_payload.dart';
import 'package:dottoday/domain/writes/write_batch.dart';
import 'package:dottoday/features/timeline/today_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'pass_onboarding.dart';
import 'support/no_dialog_notifications.dart';

/// The title the host script looks for (`KILLED_APP_TITLE` there).
const killedAppTitle = 'Killed-app check';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('schedules one dot-start 75 s out', (tester) async {
    final flutterOnError = FlutterError.onError;
    final platformOnError = PlatformDispatcher.instance.onError;
    await bootstrap();
    FlutterError.onError = flutterOnError;
    PlatformDispatcher.instance.onError = platformOnError;
    await passOnboarding(tester);
    final c = ProviderScope.containerOf(
      tester.element(find.byType(TodayScreen)),
    );
    // Granted by the harness (Android) or provisionally (iOS): never a
    // system dialog, which would stall the run (M6.5.12).
    await ensureNotificationsWithoutDialog(
      c.read(localNotificationsPluginProvider),
      needExact: true,
    );

    final profile = await c.read(localProfileProvider.future);
    final plugin = c.read(localNotificationsPluginProvider);
    await plugin.cancelAll();
    final now = DateTime.now().toUtc();
    final task = Occurrence(
      id: const UuidV7Generator().newId(),
      userId: profile.id,
      title: killedAppTitle,
      tzId: profile.tzId,
      startUtc: now.add(const Duration(seconds: 75)),
      durationMin: 5,
      alerts: const [Alert(kind: AlertKind.atStart)],
      createdAt: now,
      updatedAt: now,
    );
    await c
        .read(writeUseCaseProvider)
        .apply(WriteBatch(userId: profile.id, occurrences: [task]));
    await c.read(notificationSyncProvider).resync(profile.id);
    final pending = [
      for (final p in await plugin.pendingNotificationRequests())
        if (decodeNotificationPayload(p.id, p.payload)?.occurrenceId == task.id)
          p,
    ];
    expect(pending, hasLength(1), reason: 'one alert scheduled');
    // ignore: avoid_print
    print('KILLED_APP scheduled id=${pending.single.id} at=${task.startUtc}');
  });
}
