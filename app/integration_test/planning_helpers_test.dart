// The planning helpers on a device (docs/09 M20.3 part 2, R2-22, ED-322):
// Routines with another day picked, Edit routine, a drop's proposal,
// Duplicate day's month sheet, and low-energy Today with what's later and
// its proposal. Nothing is written: each sheet is closed or discarded. The
// Day menu is the system's own on the iPhone, iPad and Mac, so the sheets
// it opens are opened directly. In-memory data on a fixed day:
//   tool/device_tests.sh ios <udid> planning_helpers       (DEVICE_SHOT)
//   tool/device_tests.sh android <serial> planning_helpers
//   SWEEP_TARGET=integration_test/planning_helpers_test.dart tool/mac_sweep.sh
//   flutter build web -t integration_test/planning_helpers_test.dart \
//     --dart-define=SWEEP_HOST_SHOTS=true, served, then
//   SHOTS=planning_helpers node tool/slice/web_journey.mjs <url> <width> <browser>
import 'dart:async';

import 'package:dottoday/core/router/app_routes.dart';
import 'package:dottoday/features/timeline/low_energy/low_energy_actions.dart';
import 'package:dottoday/features/timeline/widgets/copy_day_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:timezone/data/latest.dart' as tz_data;

import '../test/features/timeline/calendar/calendar_world.dart';
import '../test/support/routine_samples.dart';
import 'support/device_shot.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(tz_data.initializeTimeZones);

  BuildContext screen(WidgetTester tester) =>
      tester.element(find.byType(Scaffold).hitTestable().first);

  // The sheet's barrier covers the screen, so any Scaffold's context.
  Future<void> closeSheet(WidgetTester tester) async {
    final any = tester.element(find.byType(Scaffold).first);
    Navigator.of(any, rootNavigator: true).pop();
    await tester.pumpAndSettle();
  }

  for (final mode in [ThemeMode.dark, ThemeMode.light]) {
    testWidgets('the planning helpers, ${mode.name}', (tester) async {
      Future<void> shot(String step) =>
          deviceShot(binding, tester, 'planning_${mode.name}_$step');
      final router = await pumpCalendar(
        tester,
        mode: mode,
        routines: sampleRoutines(),
      );
      router.go(AppRoutes.settingsPage(SettingsPage.routines));
      await tester.pumpAndSettle();
      await shot('1_routines');
      // Tomorrow on the strip: every button drops there.
      await tester.tap(find.text('4').hitTestable().first);
      await tester.pumpAndSettle();
      await shot('2_day_picked');
      await tester.tap(find.text('Edit').hitTestable().first);
      await tester.pumpAndSettle();
      await shot('3_editor');
      await closeSheet(tester);
      await tester.tap(find.textContaining('Drop on').hitTestable().first);
      await tester.pumpAndSettle();
      await shot('4_drop');
      await tester.tap(find.text('Discard').hitTestable().first);
      await tester.pumpAndSettle();
      router.go(AppRoutes.today);
      await tester.pumpAndSettle();
      unawaited(
        showDuplicateDaySheet(screen(tester), source: DateTime(2026, 11, 3)),
      );
      await tester.pumpAndSettle();
      await shot('5_duplicate');
      await closeSheet(tester);
      toggleLowEnergy(screen(tester), on: true);
      await tester.pumpAndSettle();
      await shot('6_low_energy');
      await tester.tap(find.text("Show what's later").hitTestable().first);
      await tester.pumpAndSettle();
      await shot('7_later');
      await tester.tap(find.text("Hide what's later").hitTestable().first);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Propose').hitTestable().first);
      await tester.pumpAndSettle();
      await shot('8_propose');
      await tester.tap(find.text('Discard').hitTestable().first);
      await tester.pumpAndSettle();
      toggleLowEnergy(screen(tester), on: false);
      await tester.pumpAndSettle();
    });
  }
}
