// Settings in two panes (docs/09 M20.7 part 5a; E-R2-11, ED-291; E-R2-18,
// ED-311; E-FullA-v2 "Web · Settings, two panes"): the list beside Your
// day; a group picked in the list; a sub-page pushed in the detail and
// back; Minimal's short list and Everything else. Run on wide windows
// (iPad and Android tablet in landscape, the Mac, the web at 1280).
// In-memory data:
//   tool/device_tests.sh ios <udid> settings_panes        (DEVICE_SHOT)
//   tool/device_tests.sh android <serial> settings_panes
//   SWEEP_TARGET=integration_test/settings_panes_test.dart tool/mac_sweep.sh
//   flutter build web -t integration_test/settings_panes_test.dart \
//     --dart-define=SWEEP_HOST_SHOTS=true, served, then
//   SHOTS=settings_panes node tool/slice/web_journey.mjs <url> expanded <b>
import 'package:dottoday/core/router/app_routes.dart';
import 'package:dottoday/domain/entities/enums.dart';
import 'package:dottoday/features/settings/panes/settings_pane_scope.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:timezone/data/latest.dart' as tz_data;

import '../test/features/timeline/calendar/calendar_world.dart';
import 'support/device_shot.dart';

Finder _list(Finder f) => find.descendant(
  of: find.byWidgetPredicate(
    (w) => w is SettingsPaneScope && w.pane == SettingsPane.list,
  ),
  matching: f,
);

Finder _detail(Finder f) => find.descendant(
  of: find.byWidgetPredicate(
    (w) => w is SettingsPaneScope && w.pane == SettingsPane.detail,
  ),
  matching: f,
);

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(tz_data.initializeTimeZones);

  for (final mode in [ThemeMode.dark, ThemeMode.light]) {
    testWidgets('settings panes, ${mode.name}', (tester) async {
      Future<void> shot(String step) =>
          deviceShot(binding, tester, 'settings_panes_${mode.name}_$step');
      final router = await pumpCalendar(tester, mode: mode);

      // 1 · The list beside Your day.
      router.go(AppRoutes.settings);
      await tester.pumpAndSettle();
      expect(_list(find.text('Search settings')), findsWidgets); // l10n-ignore
      await shot('1_your_day');

      // 2 · Appearance picked in the list.
      await tester.tap(_list(find.text('Appearance')).first); // l10n-ignore
      await tester.pumpAndSettle();
      await shot('2_appearance');

      // 3 · Your day, then Wake Up and Wind Down pushed in the detail.
      await tester.tap(_list(find.text('Your day')).first); // l10n-ignore
      await tester.pumpAndSettle();
      await tester.tap(
        _detail(find.text('Wake Up and Wind Down')).first, // l10n-ignore
      );
      await tester.pumpAndSettle();
      await shot('3_wake_wind');

      // 4 · Data and privacy.
      await tester.tap(
        _list(find.text('Data and privacy')).first, // l10n-ignore
      );
      await tester.pumpAndSettle();
      await shot('4_data_privacy');
      router.go(AppRoutes.today);
      await tester.pumpAndSettle();
    });
  }

  testWidgets('settings panes, minimal', (tester) async {
    Future<void> shot(String step) =>
        deviceShot(binding, tester, 'settings_panes_minimal_$step');
    final router = await pumpCalendar(tester, layout: UiLayout.minimal);
    router.go(AppRoutes.settings);
    await tester.pumpAndSettle();
    await shot('1_account');
    await tester.tap(_list(find.text('Everything else…')).first); // l10n-ignore
    await tester.pumpAndSettle();
    expect(_list(find.text('Planning')), findsOneWidget); // l10n-ignore
    await shot('2_everything');
    router.go(AppRoutes.today);
    await tester.pumpAndSettle();
  });
}
