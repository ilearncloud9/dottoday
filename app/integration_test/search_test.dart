// Search on a device (docs/09 M20.2 part 2; E-R2-13 on touch, E-R2-30 on
// the Mac and web): results for "Call" with an Inbox task's Schedule, no
// matches with Show all, and nothing typed, at the device's own size
// and platform, on a fixed day with in-memory data. Shots as the
// Calendar's:
//   tool/device_tests.sh ios <udid> search              (DEVICE_SHOT)
//   tool/device_tests.sh android <serial> search
//   SWEEP_TARGET=integration_test/search_test.dart tool/mac_sweep.sh
//   flutter build web -t integration_test/search_test.dart \
//     --dart-define=SWEEP_HOST_SHOTS=true, served, then
//   SHOTS=search node tool/slice/web_journey.mjs <url> <width> <browser>
import 'package:dottoday/core/router/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:timezone/data/latest.dart' as tz_data;

import '../test/features/timeline/calendar/calendar_world.dart';
import '../test/support/sample_inbox.dart';
import 'support/device_shot.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(tz_data.initializeTimeZones);

  for (final mode in [ThemeMode.light, ThemeMode.dark]) {
    testWidgets('Search, ${mode.name}', (tester) async {
      Future<void> shot(String step) =>
          deviceShot(binding, tester, 'search_${mode.name}_$step');
      final rows = [...calendarMonth(), ...pastYear(), ...sampleInbox()];
      final router = await pumpCalendar(tester, mode: mode, rows: rows);
      router.go(AppRoutes.search);
      await tester.pumpAndSettle();
      // All typing first: after a chip tap (the web) or a submit (iOS)
      // the device's text input takes no more typing.
      final field = find.byType(TextField);
      await tester.enterText(field, 'Call');
      await tester.pumpAndSettle();
      await shot('1_results');
      await tester.enterText(field, 'zebra');
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(FilterChip, 'Done'));
      await tester.pumpAndSettle();
      await shot('2_no_results');
      await tester.tap(find.text('Show all'));
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Clear search'));
      await tester.pumpAndSettle();
      FocusManager.instance.primaryFocus?.unfocus();
      await tester.pumpAndSettle();
      await shot('3_empty');
    });
  }
}
