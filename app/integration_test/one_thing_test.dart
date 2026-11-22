// Pick today's one thing on a device (docs/09 M20.3 part 3, R2-34,
// ED-339): the pick sheet (a dialog from medium width), a pick, Today
// with its ring and "· Your one thing", and the sheet again with the pick
// tinted. The Day menu is the system's own on the iPhone, iPad and Mac,
// so the sheet is opened directly. In-memory data on a fixed day:
//   tool/device_tests.sh ios <udid> one_thing       (DEVICE_SHOT)
//   tool/device_tests.sh android <serial> one_thing
//   SWEEP_TARGET=integration_test/one_thing_test.dart tool/mac_sweep.sh
//   flutter build web -t integration_test/one_thing_test.dart \
//     --dart-define=SWEEP_HOST_SHOTS=true, served, then
//   SHOTS=one_thing node tool/slice/web_journey.mjs <url> <width> <browser>
import 'dart:async';

import 'package:dottoday/core/router/app_routes.dart';
import 'package:dottoday/features/timeline/one_thing/one_thing_picker.dart';
import 'package:dottoday/features/timeline/one_thing/one_thing_sheet.dart';
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

  Future<void> open(WidgetTester tester) async {
    final screen = tester.element(find.byType(Scaffold).hitTestable().first);
    unawaited(showOneThingSheet(screen));
    await tester.pumpAndSettle();
  }

  for (final mode in [ThemeMode.dark, ThemeMode.light]) {
    testWidgets("today's one thing, ${mode.name}", (tester) async {
      Future<void> shot(String step) =>
          deviceShot(binding, tester, 'one_thing_${mode.name}_$step');
      final router = await pumpCalendar(
        tester,
        mode: mode,
        rows: [...calendarMonth(), ...pastYear(), ...sampleInbox()],
      );
      router.go(AppRoutes.today);
      await tester.pumpAndSettle();
      await open(tester);
      await shot('1_sheet');
      // The second of today's dots: any answer is right.
      await tester.tap(
        find
            .descendant(
              of: find.byType(OneThingPicker),
              matching: find.byType(InkWell),
            )
            .at(1),
      );
      await tester.pumpAndSettle();
      expect(find.byType(OneThingPicker), findsNothing);
      await shot('2_today');
      await open(tester);
      await shot('3_picked');
      Navigator.of(
        tester.element(find.byType(OneThingPicker)),
        rootNavigator: true,
      ).pop();
      await tester.pumpAndSettle();
    });
  }
}
