// Settings › Reminders, Notification health and the test alarm on a device
// (docs/09 M20.9 part 2; E-R2-20 §3–4, ED-317, ED-470): the real OS state,
// then the test alarm's steps as cards under its row, through the real
// scheduler, ringing a minute later and asking "Did it ring?".
// The runner saves the screen at each `DEVICE_SHOT` (tool/device_tests.sh).
//   tool/device_tests.sh android|ios [device] notification_health
import 'package:dottoday/core/router/app_routes.dart';
import 'package:dottoday/data/notifications/notification_providers.dart';
import 'package:dottoday/features/notifications/in_app_alert_banner.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'support/cal_app.dart';
import 'support/calendar_qa.dart';
import 'support/no_dialog_notifications.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Reminders, health and the test alarm', (tester) async {
    final c = await startApp(tester);
    final plugin = c.read(localNotificationsPluginProvider);
    await ensureNotificationsWithoutDialog(plugin, needExact: true);
    await plugin.cancelAll();

    await go(tester, c, AppRoutes.settingsPage(SettingsPage.reminders));
    await waitFor(tester, find.text('Notification health'));
    await deviceShot('reminders');

    await go(tester, c, AppRoutes.settingsPage(SettingsPage.notifications));
    await waitFor(tester, find.text('This device'));
    await deviceShot('health');

    // 1–2: the row, then what happens, in a card under it.
    await tapOn(tester, find.text('Send me a test alarm'));
    await waitFor(tester, find.text('Send'));
    await deviceShot('test_alarm_explain');

    // 3: on its way.
    await tapOn(tester, find.text('Send'));
    await waitFor(tester, find.textContaining('Ringing in'));
    await deviceShot('test_alarm_waiting');

    // 4–5: it arrives (the strip while open), then "Did it ring?".
    await waitFor(
      tester,
      find.text('Did it ring?'),
      timeout: const Duration(seconds: 90),
    );
    // Inside the app it is the strip with one OK (E-R2-20 §4, ED-470); the
    // OS still has it, with its sound, in Notification Center or the shade.
    final strip = find.descendant(
      of: find.byType(InAppAlertBanner),
      matching: find.textContaining('Test alarm', findRichText: true),
    );
    await waitFor(tester, strip);
    await deviceShot('test_alarm_ask');
    if (defaultTargetPlatform == TargetPlatform.android) {
      debugPrint('DEVICE_SHADE open');
      await deviceShot('test_alarm_shade');
      debugPrint('DEVICE_SHADE close');
    }
    await tapOn(
      tester,
      find.descendant(
        of: find.byType(InAppAlertBanner),
        matching: find.text('OK'),
      ),
    );
    expect(strip, findsNothing, reason: 'OK takes the strip away');
    await tapOn(tester, find.text('Yes'));
    await waitFor(tester, find.textContaining('It got through'));
    await deviceShot('test_alarm_yes');
  });
}
