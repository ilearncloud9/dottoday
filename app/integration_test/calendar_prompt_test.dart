// M7.1 on a device (docs/08 §6.2, M7.7): with calendar access never asked,
// Settings › Calendars explains and Connect shows the system prompt (iOS:
// with the usage text). tool/device_tests.sh resets the permission first
// and saves the screenshots; nobody answers the prompt (the run ends).
import 'package:dottoday/core/router/app_routes.dart';
import 'package:dottoday/data/calendar/calendar_providers.dart';
import 'package:dottoday/data/db/database_providers.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'support/cal_app.dart';
import 'support/calendar_qa.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('not asked: explain, then Connect shows the prompt', (
    tester,
  ) async {
    final container = await startApp(tester);
    final db = container.read(appDatabaseProvider);
    // A fresh install: forget an earlier run's "asked".
    await (db.delete(
      db.localMeta,
    )..where((m) => m.key.equals('calendar_permission_asked'))).go();
    container.invalidate(calendarPermissionStateProvider);
    await go(tester, container, AppRoutes.settingsPage(SettingsPage.calendars));
    await waitFor(tester, find.text('Connect a calendar'));
    expect(
      find.textContaining('asks your device once to see your calendars'),
      findsOneWidget,
    );
    await deviceShot('calendar_explain');
    await tapOn(tester, find.text('Connect a calendar'));
    // The prompt is the OS's: only a screenshot sees it.
    await Future<void>.delayed(const Duration(seconds: 3));
    await deviceShot('calendar_prompt');
  });
}
