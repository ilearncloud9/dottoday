// Settings › Your day › Wake Up and Wind Down (docs/09 M20.7 part 4a and
// its fix; E-Phones, ED-084): Tonight, the week as schedules, Add a
// schedule, the night, the Wake Up alarm and reminders; Wake Up options,
// Missions and Vary the sound; the schedule sheet (part 4b). In-memory
// data:
//   tool/device_tests.sh ios <udid> settings_wake_wind   (DEVICE_SHOT)
//   tool/device_tests.sh android <serial> settings_wake_wind
//   SWEEP_TARGET=integration_test/settings_wake_wind_test.dart tool/mac_sweep.sh
//   flutter build web -t integration_test/settings_wake_wind_test.dart \
//     --dart-define=SWEEP_HOST_SHOTS=true, served, then
//   SHOTS=settings_wake_wind node tool/slice/web_journey.mjs <url> compact|expanded <b>
import 'package:dottoday/core/router/app_routes.dart';
import 'package:dottoday/features/settings/wake_wind/schedule_sheet/schedule_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:timezone/data/latest.dart' as tz_data;

import '../test/features/timeline/calendar/calendar_world.dart';
import 'support/device_shot.dart';

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
    testWidgets('wake up and wind down, ${mode.name}', (tester) async {
      Future<void> shot(String step) =>
          deviceShot(binding, tester, 'settings_wake_wind_${mode.name}_$step');
      final router = await pumpCalendar(tester, mode: mode);
      router.go(AppRoutes.settingsPage(SettingsPage.wakeWindDown));
      await tester.pumpAndSettle();
      await shot('1_tonight_week');

      // 2 · The night and the Wake Up alarm, off (E-Phones "alarm off").
      Future<void> scrollTo(String text, {bool up = false}) async {
        // From the top when asked: the cards sit above the alarm group.
        if (up) {
          await tester.drag(_onScreenList(tester), const Offset(0, 20000));
          await tester.pumpAndSettle();
        }
        // Several matches (each card's Edit) are fine: the first in view.
        for (var i = 0; i < 40; i++) {
          if (find.text(text).hitTestable().evaluate().isNotEmpty) break;
          await tester.drag(_onScreenList(tester), const Offset(0, -300));
          await tester.pumpAndSettle();
        }
        await tester.ensureVisible(find.text(text).hitTestable().first);
        await tester.pumpAndSettle();
      }

      await scrollTo('Send a test alarm'); // l10n-ignore: finder
      await shot('2_alarm_off');

      // 3 · On (an in-memory alarm gateway: no system prompt), then the
      // rest of the group and Reminders.
      await tester.tap(find.text('Ring like an alarm')); // l10n-ignore: finder
      await tester.pumpAndSettle();
      await scrollTo('Ring like an alarm'); // l10n-ignore: finder
      await shot('3_alarm_on');
      await scrollTo('Check after 10 min'); // l10n-ignore: finder
      await shot('4_reminders');

      // 8–12 · The schedule sheet (M20.7 part 4b): Edit Every day, Wake
      // Up 30 min later, Saturday and Sunday out; its lower half; Save.
      // Then Add a schedule asks before taking Saturday; Remove the
      // Weekend with Undo. The system alert answers "no bridge" here, so
      // the in-app copy of it shows on every target.
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        const MethodChannel('dottoday/alert'),
        (_) async => null,
      );
      final semantics = tester.ensureSemantics();
      await scrollTo('Edit', up: true); // l10n-ignore: finder
      await tester.tap(find.text('Edit').first); // l10n-ignore: finder
      await tester.pumpAndSettle();
      final wake = find.semantics.byPredicate(
        (n) =>
            n.label == 'Wake Up' &&
            n.flagsCollection.isSlider, // l10n-ignore: finder
      );
      for (var i = 0; i < 6; i++) {
        tester.semantics.increase(wake);
        await tester.pumpAndSettle();
      }
      for (final day in ['Saturday', 'Sunday']) {
        // l10n-ignore: finder
        await tester.tap(find.bySemanticsLabel(RegExp('^$day')).last);
        await tester.pumpAndSettle();
      }
      await shot('8_schedule_edit');
      final sheetList = find
          .descendant(
            of: find.byType(ScheduleSheet),
            matching: find.byType(Scrollable),
          )
          .first;
      await tester.scrollUntilVisible(
        find.text('Remove this schedule'), // l10n-ignore: finder
        300,
        scrollable: sheetList,
      );
      await tester.pumpAndSettle();
      await shot('9_schedule_lower');
      await tester.tap(find.text('Save')); // l10n-ignore: finder
      await tester.pumpAndSettle();
      await scrollTo('Add a schedule', up: true); // l10n-ignore: finder
      await shot('10_two_schedules');
      await tester.tap(find.text('Add a schedule')); // l10n-ignore: finder
      await tester.pumpAndSettle();
      await tester.tap(
        find.bySemanticsLabel(RegExp('^Saturday')).last,
      ); // l10n-ignore: finder
      await tester.pumpAndSettle();
      await shot('11_day_taken');
      await tester.tap(find.text('Change')); // l10n-ignore: finder
      await tester.pumpAndSettle();
      await shot('12_new_schedule');
      // Cancel on iPhone; × elsewhere.
      final cancel = find.text('Cancel').hitTestable(); // l10n-ignore: finder
      await tester.tap(
        cancel.evaluate().isNotEmpty
            ? cancel.first
            : find.byTooltip('Close').first, // l10n-ignore: finder
      );
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Edit').last); // l10n-ignore: finder
      await tester.pumpAndSettle();
      await tester.tap(find.text('Edit').last); // l10n-ignore: finder
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(
        find.text('Remove this schedule'), // l10n-ignore: finder
        300,
        scrollable: find
            .descendant(
              of: find.byType(ScheduleSheet),
              matching: find.byType(Scrollable),
            )
            .first,
      );
      await tester.tap(
        find.text('Remove this schedule'),
      ); // l10n-ignore: finder
      await tester.pumpAndSettle();
      await shot('13_removed');
      await tester.tap(find.text('Undo')); // l10n-ignore: finder
      await tester.pumpAndSettle();
      semantics.dispose();
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        const MethodChannel('dottoday/alert'),
        null,
      );

      // 5 · Wake Up options (E-R2-32, E-R2-38), from the Wake Up card row.
      await scrollTo('Wake Up card'); // l10n-ignore: finder
      await tester.tap(find.text('Wake Up card')); // l10n-ignore: finder
      await tester.pumpAndSettle();
      await shot('5_wake_up_options');

      // 6 · Missions (E-R2-28): Every time, then the list.
      router.go(AppRoutes.settingsPage(SettingsPage.missions));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Off').first); // l10n-ignore: finder
      await tester.pumpAndSettle();
      await tester.tap(find.text('Every time')); // l10n-ignore: finder
      await tester.pumpAndSettle();
      await shot('6_missions');

      // 7 · Vary the sound, on.
      router.go(AppRoutes.settingsPage(SettingsPage.varySound));
      await tester.pumpAndSettle();
      await tester.tap(
        // l10n-ignore: finder
        find.text(
          'A different alarm sound each day, so it stays easy to hear.',
        ),
      );
      await tester.pumpAndSettle();
      await shot('7_vary_sound');
      router.go(AppRoutes.today);
      await tester.pumpAndSettle();
    });
  }
}
