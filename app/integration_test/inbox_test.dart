// The Inbox on a device (docs/09 M20.2 part 1, E-R2-13): its rows with
// where each fits and Place, a row's menu from a hold, Completed open,
// and Minimal's Inbox, at the device's own size and platform, on a fixed
// day with in-memory data (a run touches nothing stored on the device).
// Shots as the Calendar's:
//   tool/device_tests.sh ios <udid> inbox               (DEVICE_SHOT)
//   tool/device_tests.sh android <serial> inbox
//   SWEEP_TARGET=integration_test/inbox_test.dart tool/mac_sweep.sh
//   flutter build web -t integration_test/inbox_test.dart \
//     --dart-define=SWEEP_HOST_SHOTS=true, served, then
//   SHOTS=inbox node tool/slice/web_journey.mjs <url> <width> <browser>
import 'package:dottoday/core/router/app_routes.dart';
import 'package:dottoday/domain/entities/enums.dart';
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
    testWidgets('the Inbox, ${mode.name}', (tester) async {
      Future<void> shot(String step) =>
          deviceShot(binding, tester, 'inbox_${mode.name}_$step');
      final rows = [...calendarMonth(), ...sampleInbox()];
      final router = await pumpCalendar(tester, mode: mode, rows: rows);
      router.go(AppRoutes.inbox);
      await tester.pumpAndSettle();
      await shot('1_inbox');
      await tester.ensureVisible(find.text('Do taxes'));
      await tester.pumpAndSettle();
      await tester.longPress(find.text('Do taxes'));
      await tester.pumpAndSettle();
      await shot('2_menu');
      await tester.tapAt(Offset.zero);
      await tester.pumpAndSettle();
      final completed = find.text('Completed · 2');
      await tester.ensureVisible(completed);
      await tester.pumpAndSettle();
      await tester.tap(completed);
      await tester.pumpAndSettle();
      await shot('3_completed');
      final minimal = await pumpCalendar(
        tester,
        mode: mode,
        rows: rows,
        layout: UiLayout.minimal,
      );
      minimal.go(AppRoutes.inbox);
      await tester.pumpAndSettle();
      await shot('4_minimal');
    });
  }
}
