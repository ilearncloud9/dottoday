// Settings › Appearance (docs/09 M20.7 part 3; E-G3-9b, ED-161): the
// pinned preview, Layout's Everything · Less (the preview morphs), App
// colour's suggestions and Edit palette. In-memory data:
//   tool/device_tests.sh ios <udid> settings_appearance   (DEVICE_SHOT)
//   tool/device_tests.sh android <serial> settings_appearance
//   SWEEP_TARGET=integration_test/settings_appearance_test.dart tool/mac_sweep.sh
//   flutter build web -t integration_test/settings_appearance_test.dart \
//     --dart-define=SWEEP_HOST_SHOTS=true, served, then
//   SHOTS=settings_appearance node tool/slice/web_journey.mjs <url> compact|expanded <b>
import 'package:dottoday/core/router/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:timezone/data/latest.dart' as tz_data;

import '../test/features/timeline/calendar/calendar_world.dart';
import 'support/device_shot.dart';

Future<void> _tap(WidgetTester tester, Finder f) async {
  await tester.ensureVisible(f.first);
  await tester.pumpAndSettle();
  await tester.tap(f.first);
  await tester.pumpAndSettle(const Duration(milliseconds: 400));
}

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(tz_data.initializeTimeZones);

  for (final mode in [ThemeMode.dark, ThemeMode.light]) {
    testWidgets('settings appearance, ${mode.name}', (tester) async {
      Future<void> shot(String step) =>
          deviceShot(binding, tester, 'settings_appearance_${mode.name}_$step');
      final router = await pumpCalendar(tester, mode: mode);
      router.go(AppRoutes.settingsPage(SettingsPage.appearance));
      await tester.pumpAndSettle();
      await shot('1_appearance');

      // 2 · Less: the preview becomes the Now ring; back to Everything.
      await _tap(tester, find.text('Less')); // l10n-ignore: finder
      await shot('2_less');
      await _tap(tester, find.text('Everything')); // l10n-ignore: finder

      // 3 · A suggestion: Blush first, ticked.
      await _tap(tester, find.bySemanticsLabel('Blush')); // l10n-ignore
      await shot('3_blush');

      // 4 · Edit palette.
      await _tap(tester, find.text('Edit palette')); // l10n-ignore: finder
      await shot('4_edit_palette');
      await _tap(tester, find.text('Done').last); // l10n-ignore: finder

      // Back to Teal for the next run.
      await _tap(tester, find.bySemanticsLabel('Teal')); // l10n-ignore
      router.go(AppRoutes.today);
      await tester.pumpAndSettle();
    });
  }
}
