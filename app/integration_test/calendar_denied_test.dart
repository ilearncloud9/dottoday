// M7.1 on a device (docs/08 §6.2, M7.7): with calendar access denied
// (tool/device_tests.sh revokes it), Connect shows "Calendar access is
// off"; on iOS Open settings lands on Dottoday's page in Settings.
import 'package:dottoday/core/router/app_routes.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'support/cal_app.dart';
import 'support/calendar_qa.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('denied: the notice, and the way to Settings', (tester) async {
    final container = await startApp(tester);
    await go(tester, container, AppRoutes.settingsPage(SettingsPage.calendars));
    // Never asked on this install: Connect asks, and the OS says no at
    // once (no prompt for a denied permission).
    final connect = find.text('Connect a calendar');
    await tester.pump(const Duration(seconds: 1));
    if (tester.any(connect)) await tapOn(tester, connect);
    await waitFor(tester, find.text('Calendar access is off'));
    await deviceShot('calendar_denied');
    final open = find.text('Open settings');
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      await waitFor(tester, open);
      await tapAway(tester, open, 'calendar_open_settings');
      return;
    }
    // Android has no public link to an app's page: it says where to go.
    await tapOn(tester, open);
    await waitFor(tester, find.textContaining('find Dottoday'));
    await deviceShot('calendar_settings_path');
  });
}
