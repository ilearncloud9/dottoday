// A reminder that comes due while Dottoday is open (docs/09 M20.9 part 1;
// E-R2-20 §1, ED-317, ED-467, ED-468): the app's strip shows it on every
// platform; iPhone and the Mac hold their banner back, Android's pop-down is
// quieted once posted, and the reminder stays in Notification Center or the
// shade. A real task through the real write path.
// The runner saves the screen at each `DEVICE_SHOT` (tool/device_tests.sh).
//   tool/device_tests.sh android|ios [device] reminder_strip
import 'package:dottoday/bootstrap.dart';
import 'package:dottoday/core/ids/id_generator.dart';
import 'package:dottoday/data/notifications/notification_providers.dart';
import 'package:dottoday/data/profile/profile_providers.dart';
import 'package:dottoday/data/writes/write_providers.dart';
import 'package:dottoday/domain/entities/alert.dart';
import 'package:dottoday/domain/entities/enums.dart';
import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:dottoday/domain/writes/write_batch.dart';
import 'package:dottoday/features/notifications/in_app_alert_banner.dart';
import 'package:dottoday/features/timeline/today_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'pass_onboarding.dart';
import 'support/device_shot.dart';
import 'support/no_dialog_notifications.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('a reminder due while open', (tester) async {
    final flutterOnError = FlutterError.onError;
    final platformOnError = PlatformDispatcher.instance.onError;
    await bootstrap();
    FlutterError.onError = flutterOnError;
    PlatformDispatcher.instance.onError = platformOnError;
    await passOnboarding(tester);
    final c = ProviderScope.containerOf(
      tester.element(find.byType(TodayScreen)),
    );
    final plugin = c.read(localNotificationsPluginProvider);
    await ensureNotificationsWithoutDialog(plugin, needExact: true);
    await plugin.cancelAll();

    final profile = await c.read(localProfileProvider.future);
    final now = DateTime.now().toUtc();
    final due = now.add(const Duration(seconds: 35));
    await c
        .read(writeUseCaseProvider)
        .apply(
          WriteBatch(
            userId: profile.id,
            occurrences: [
              // The day's first dot rings loud (R2-19), the system's on
              // purpose; the strip takes the ordinary reminder after it.
              Occurrence(
                id: const UuidV7Generator().newId(),
                userId: profile.id,
                title: 'Morning run',
                tzId: profile.tzId,
                startUtc: due.subtract(const Duration(minutes: 30)),
                durationMin: 15,
                createdAt: now,
                updatedAt: now,
              ),
              Occurrence(
                id: const UuidV7Generator().newId(),
                userId: profile.id,
                title: 'Team standup',
                tzId: profile.tzId,
                startUtc: due,
                durationMin: 15,
                alerts: const [Alert(kind: AlertKind.atStart)],
                createdAt: now,
                updatedAt: now,
              ),
            ],
          ),
        );

    final strip = find.descendant(
      of: find.byType(InAppAlertBanner),
      matching: find.textContaining('Team standup', findRichText: true),
    );
    final end = due.add(const Duration(seconds: 20));
    while (DateTime.now().toUtc().isBefore(end) && strip.evaluate().isEmpty) {
      await tester.pump(const Duration(milliseconds: 500));
    }
    // The strip shows it while open, every platform (E-R2-20, ED-468).
    expect(strip, findsOneWidget, reason: 'the strip shows it while open');
    if (defaultTargetPlatform == TargetPlatform.android) {
      // Android's pop-down gives way to the strip; the reminder stays in the
      // shade, quiet (the ring-and-dot mark in the App colour, ED-467).
      await deviceShot(binding, tester, 'reminder_strip_open');
      debugPrint('DEVICE_SHADE open');
      await deviceShot(binding, tester, 'reminder_strip_shade');
      debugPrint('DEVICE_SHADE close');
    } else {
      await deviceShot(binding, tester, 'reminder_strip_open');
    }
  });
}
