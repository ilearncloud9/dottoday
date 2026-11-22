// The Day menu on a device (docs/09 M20.3 part 1, ED-093): Today with its
// Day ▾, the menu open, and (where Flutter draws the menu: Android, the
// web) Need more time ▸ +15 run. The system's own menus (iPhone, iPad,
// the Mac) can't be tapped by a test, so their run ends on the open
// menu, which the run's end closes. In-memory data on a fixed day:
//   tool/device_tests.sh ios <udid> day_menu            (DEVICE_SHOT)
//   tool/device_tests.sh android <serial> day_menu
//   SWEEP_TARGET=integration_test/day_menu_test.dart tool/mac_sweep.sh
//   flutter build web -t integration_test/day_menu_test.dart \
//     --dart-define=SWEEP_HOST_SHOTS=true, served, then
//   SHOTS=day_menu node tool/slice/web_journey.mjs <url> <width> <browser>
import 'dart:io';

import 'package:dottoday/core/router/app_routes.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:timezone/data/latest.dart' as tz_data;

import '../test/features/timeline/calendar/calendar_world.dart';
import 'support/device_shot.dart';

/// Whether the system draws the menu (NSMenu, UIMenu).
bool get _native => !kIsWeb && (Platform.isIOS || Platform.isMacOS);

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(tz_data.initializeTimeZones);

  Future<void> openMenu(WidgetTester tester) async {
    await tester.tap(find.byTooltip('More options').hitTestable().first);
    await tester.pumpAndSettle();
  }

  // Dark first: on the system's menus the light run ends with it open.
  for (final mode in [ThemeMode.dark, ThemeMode.light]) {
    testWidgets('the Day menu, ${mode.name}', (tester) async {
      Future<void> shot(String step) =>
          deviceShot(binding, tester, 'day_menu_${mode.name}_$step');
      final router = await pumpCalendar(tester, mode: mode);
      router.go(AppRoutes.today);
      await tester.pumpAndSettle();
      await shot('1_today');
      if (_native && mode == ThemeMode.dark) return;
      await openMenu(tester);
      await shot('2_menu');
      if (_native) return;
      if (!kIsWeb) {
        // Android: Need more time ▸ opens its own menu.
        await tester.tap(find.text('Need more time'));
        await tester.pumpAndSettle();
        await shot('3_more_time');
      }
      await tester.tap(find.text('+15 min').last);
      await tester.pumpAndSettle();
      await shot('4_extended');
    });
  }
}
