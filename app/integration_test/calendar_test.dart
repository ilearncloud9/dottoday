// The Calendar tab on a device (docs/09 M20.1): its month, a picked day,
// Month · Week where the width allows it, and Past days' Year strip, at
// the device's own size and platform, on a fixed day with in-memory data
// (a run touches nothing stored on the device). Shots as the slice's:
//   tool/device_tests.sh ios <udid> calendar          (DEVICE_SHOT)
//   tool/device_tests.sh android <serial> calendar
//   SWEEP_TARGET=integration_test/calendar_test.dart tool/mac_sweep.sh
//   flutter build web -t integration_test/calendar_test.dart \
//     --dart-define=SWEEP_HOST_SHOTS=true, served, then
//   SHOTS=calendar node tool/slice/web_journey.mjs <url> <width> <browser>
import 'package:dottoday/core/router/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:timezone/data/latest.dart' as tz_data;

import '../test/features/timeline/calendar/calendar_world.dart';
import 'support/device_shot.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(tz_data.initializeTimeZones);

  for (final mode in [ThemeMode.light, ThemeMode.dark]) {
    testWidgets('the Calendar, ${mode.name}', (tester) async {
      Future<void> shot(String step) =>
          deviceShot(binding, tester, 'calendar_${mode.name}_$step');
      final router = await pumpCalendar(tester, mode: mode);
      await shot('1_month');
      await tester.tap(find.bySemanticsLabel(RegExp('^Thursday, November 5')));
      await tester.pumpAndSettle();
      await shot('2_picked');
      if (tester.any(find.text('Week').hitTestable())) {
        await tester.tap(find.text('Week').hitTestable().first);
        await tester.pumpAndSettle();
        await shot('3_week');
      }
      router.go(AppRoutes.search);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Past days'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Year strip'));
      await tester.pumpAndSettle();
      await shot('4_year_strip');
    });
  }
}
