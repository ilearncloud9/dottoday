// Mac/web Settings pages as forms (docs/09 M20.7 part 5b, ED-450): the
// drawn pages in the detail pane as "Label:" forms; a checkbox and a
// pop-up write what the phone rows did; Reminders opens Sounds and
// Notification health in the pane; Export and Account. Run on the Mac and
// the web at 1280 (tablets keep the phone rows, covered by settings_panes).
// In-memory data:
//   SWEEP_TARGET=integration_test/settings_forms_test.dart tool/mac_sweep.sh
//   flutter build web -t integration_test/settings_forms_test.dart \
//     --dart-define=SWEEP_HOST_SHOTS=true, served, then
//   SHOTS=settings_forms node tool/slice/web_journey.mjs <url> expanded <b>
import 'package:dottoday/core/router/app_routes.dart';
import 'package:dottoday/features/settings/panes/settings_pane_scope.dart';
import 'package:dottoday/shared/settings/settings_form.dart';
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
    testWidgets('settings forms, ${mode.name}', (tester) async {
      Future<void> shot(String step) =>
          deviceShot(binding, tester, 'settings_forms_${mode.name}_$step');
      final router = await pumpCalendar(tester, mode: mode);

      // 1 · Planning: labels, checkboxes, pop-ups.
      router.go(AppRoutes.settings);
      await tester.pumpAndSettle();
      await tester.tap(_list(find.text('Planning')).first); // l10n-ignore
      await tester.pumpAndSettle();
      expect(_detail(find.byType(FormLine)), findsWidgets);
      final roll = _detail(
        find.widgetWithText(
          FormCheck,
          'Roll unfinished to tomorrow', // l10n-ignore
        ),
      );
      final before = tester.widget<FormCheck>(roll).value;
      await tester.tap(roll);
      await tester.pumpAndSettle();
      expect(tester.widget<FormCheck>(roll).value, !before);
      await tester.tap(roll);
      await tester.pumpAndSettle();
      await shot('1_planning');

      // 2 · Reminders, then All sounds… in the pane.
      await tester.tap(_list(find.text('Reminders')).first); // l10n-ignore
      await tester.pumpAndSettle();
      await shot('2_reminders');
      await tester.tap(_detail(find.text('All sounds…'))); // l10n-ignore
      await tester.pumpAndSettle();
      expect(_detail(find.byType(FormRadio)), findsWidgets);
      await shot('3_sounds');

      // 3 · Export, from Data and privacy.
      await tester.tap(
        _list(find.text('Data and privacy')).first, // l10n-ignore
      );
      await tester.pumpAndSettle();
      await tester.tap(_detail(find.text('Export')).first); // l10n-ignore
      await tester.pumpAndSettle();
      expect(_detail(find.text('Export…')), findsNWidgets(3)); // l10n-ignore
      await shot('4_export');
      router.go(AppRoutes.today);
      await tester.pumpAndSettle();
    });
  }
}
