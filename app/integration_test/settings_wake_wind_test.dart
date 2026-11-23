// Settings › Your day › Wake Up and Wind Down (docs/09 M20.7 part 4a;
// E-Phones, ED-084): Tonight, the week as schedules, Add a schedule, the
// night, the Wake Up alarm and reminders. In-memory data:
//   tool/device_tests.sh ios <udid> settings_wake_wind   (DEVICE_SHOT)
//   tool/device_tests.sh android <serial> settings_wake_wind
//   SWEEP_TARGET=integration_test/settings_wake_wind_test.dart tool/mac_sweep.sh
//   flutter build web -t integration_test/settings_wake_wind_test.dart \
//     --dart-define=SWEEP_HOST_SHOTS=true, served, then
//   SHOTS=settings_wake_wind node tool/slice/web_journey.mjs <url> compact|expanded <b>
import 'package:dottoday/core/router/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:timezone/data/latest.dart' as tz_data;

import '../test/features/timeline/calendar/calendar_world.dart';
import 'support/device_shot.dart';

/// The page's list: the widest on screen (a wide window's sidebar has its
/// own).
Finder _onScreenList(WidgetTester tester) {
  final lists = find
      .byWidgetPredicate(
        (w) => w is Scrollable && w.axisDirection == AxisDirection.down,
      )
      .hitTestable();
  var best = 0;
  for (var i = 1; i < lists.evaluate().length; i++) {
    if (tester.getSize(lists.at(i)).width >
        tester.getSize(lists.at(best)).width) {
      best = i;
    }
  }
  return lists.at(best);
}

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(tz_data.initializeTimeZones);

  for (final mode in [ThemeMode.dark, ThemeMode.light]) {
    testWidgets('wake up and wind down, ${mode.name}', (tester) async {
      Future<void> shot(String step) => deviceShot(
        binding,
        tester,
        'settings_wake_wind_${mode.name}_$step',
      );
      final router = await pumpCalendar(tester, mode: mode);
      router.go(AppRoutes.settingsPage(SettingsPage.wakeWindDown));
      await tester.pumpAndSettle();
      await shot('1_tonight_week');

      // 2 · The night and the Wake Up alarm, further down.
      await tester.scrollUntilVisible(
        find.text('Show the night on the day dot'), // l10n-ignore: finder
        300,
        scrollable: _onScreenList(tester),
      );
      await tester.pumpAndSettle();
      await shot('2_night_alarm');

      // 3 · Reminders, at the end.
      await tester.scrollUntilVisible(
        find.text('Wind Down reminder'), // l10n-ignore: finder
        300,
        scrollable: _onScreenList(tester),
      );
      await tester.pumpAndSettle();
      await shot('3_reminders');
      router.go(AppRoutes.today);
      await tester.pumpAndSettle();
    });
  }
}
