// Settings › Planning, Sounds and Siri & Shortcuts (docs/09 M20.7 part 2;
// E-R2-33, ED-338): Planning's two groups, the Shift later tasks sheet,
// Sounds, the Start sound sheet, and Siri & Shortcuts (iPhone only).
// In-memory data:
//   tool/device_tests.sh ios <udid> settings_pages        (DEVICE_SHOT)
//   tool/device_tests.sh android <serial> settings_pages
//   SWEEP_TARGET=integration_test/settings_pages_test.dart tool/mac_sweep.sh
//   flutter build web -t integration_test/settings_pages_test.dart \
//     --dart-define=SWEEP_HOST_SHOTS=true, served, then
//   SHOTS=settings_pages node tool/slice/web_journey.mjs <url> compact|expanded <b>
import 'package:dottoday/core/router/app_routes.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:timezone/data/latest.dart' as tz_data;

import '../test/features/timeline/calendar/calendar_world.dart';
import 'support/device_shot.dart';

Future<void> _tapRow(WidgetTester tester, String text) async {
  final row = find.text(text).hitTestable();
  if (row.evaluate().isEmpty) {
    await tester.scrollUntilVisible(
      find.text(text),
      300,
      scrollable: _onScreenList(tester),
    );
  }
  await tester.tap(find.text(text).hitTestable().first);
  await tester.pumpAndSettle();
}

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
    testWidgets('settings pages, ${mode.name}', (tester) async {
      Future<void> shot(String step) =>
          deviceShot(binding, tester, 'settings_pages_${mode.name}_$step');
      final router = await pumpCalendar(tester, mode: mode);

      // 1–2 · Planning, then its Shift later tasks sheet.
      router.go(AppRoutes.settingsPage(SettingsPage.planning));
      await tester.pumpAndSettle();
      await shot('1_planning');
      await _tapRow(tester, 'Shift later tasks'); // l10n-ignore: finder
      await shot('2_shift_sheet');
      await tester.tap(find.text('Ask each time').last); // l10n-ignore
      await tester.pumpAndSettle();

      // 3–4 · Sounds, then the Start sound sheet.
      router.go(AppRoutes.settingsPage(SettingsPage.sounds));
      await tester.pumpAndSettle();
      await shot('3_sounds');
      await _tapRow(tester, 'Start sound'); // l10n-ignore: finder
      await shot('4_start_sound');
      await tester.tap(find.text('Done').last); // l10n-ignore: finder
      await tester.pumpAndSettle();

      // 5 · Siri & Shortcuts: iPhone and iPad only (ED-338).
      if (defaultTargetPlatform == TargetPlatform.iOS) {
        router.go(AppRoutes.settingsPage(SettingsPage.siri));
        await tester.pumpAndSettle();
        await shot('5_siri');
      }
      router.go(AppRoutes.today);
      await tester.pumpAndSettle();
    });
  }
}
