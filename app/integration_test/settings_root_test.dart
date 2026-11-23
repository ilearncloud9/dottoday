// Settings root and group pages (docs/09 M20.7 part 1; E-Phones
// Settings): the root with Your account, Search settings and six groups;
// a search; Your day; Wake Up and Wind Down; Appearance. In-memory data:
//   tool/device_tests.sh ios <udid> settings_root        (DEVICE_SHOT)
//   tool/device_tests.sh android <serial> settings_root
//   SWEEP_TARGET=integration_test/settings_root_test.dart tool/mac_sweep.sh
//   flutter build web -t integration_test/settings_root_test.dart \
//     --dart-define=SWEEP_HOST_SHOTS=true, served, then
//   SHOTS=settings_root node tool/slice/web_journey.mjs <url> compact|expanded <b>
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

  for (final mode in [ThemeMode.dark, ThemeMode.light]) {
    testWidgets('settings root, ${mode.name}', (tester) async {
      Future<void> shot(String step) =>
          deviceShot(binding, tester, 'settings_root_${mode.name}_$step');
      final router = await pumpCalendar(tester, mode: mode);

      // 1 · The root: Your account, Search settings, six groups.
      router.go(AppRoutes.settings);
      await tester.pumpAndSettle();
      expect(find.text('Search settings'), findsWidgets); // l10n-ignore
      await shot('1_root');

      // 2 · A search: "week" finds Week starts, on Appearance.
      await tester.enterText(
        find.byType(EditableText).hitTestable().first,
        'week', // l10n-ignore: typed
      );
      await tester.pumpAndSettle();
      await shot('2_search');
      await tester.enterText(find.byType(EditableText).hitTestable().first, '');
      FocusManager.instance.primaryFocus?.unfocus();
      await tester.pumpAndSettle();

      // 3–5 · Your day, Wake Up and Wind Down, Appearance.
      for (final (step, page) in [
        ('3_your_day', SettingsPage.yourDay),
        ('4_wake_wind', SettingsPage.wakeWindDown),
        ('5_appearance', SettingsPage.appearance),
        ('6_data_privacy', SettingsPage.dataPrivacy),
      ]) {
        router.go(AppRoutes.settingsPage(page));
        await tester.pumpAndSettle();
        await shot(step);
      }
      router.go(AppRoutes.today);
      await tester.pumpAndSettle();
    });
  }
}
