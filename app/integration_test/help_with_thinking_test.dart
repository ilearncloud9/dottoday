// Help with thinking on a device (docs/09 M20.4 part 4, E-R2-23 §3,
// ED-324): Settings' Privacy group after Data, Settings › Privacy with
// this device's own status in the tinted box (Open Settings where the
// OS has a link), then Clear thinking history and its toast. In-memory
// data, so clearing touches nothing real:
//   tool/device_tests.sh ios <udid> help_with_thinking       (DEVICE_SHOT)
//   tool/device_tests.sh android <serial> help_with_thinking
//   SWEEP_TARGET=integration_test/help_with_thinking_test.dart \
//     tool/mac_sweep.sh
//   flutter build web -t integration_test/help_with_thinking_test.dart \
//     --dart-define=SWEEP_HOST_SHOTS=true, served, then
//   SHOTS=help_with_thinking node tool/slice/web_journey.mjs <url> <width>
//     <browser>
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
    testWidgets('help with thinking, ${mode.name}', (tester) async {
      Future<void> shot(String step) =>
          deviceShot(binding, tester, 'thinking_${mode.name}_$step');
      final router = await pumpCalendar(tester, mode: mode);
      router.go(AppRoutes.settings);
      await tester.pumpAndSettle();
      // The Privacy group, straight after Data.
      final row = find.text('Help with thinking'); // l10n-ignore: finder
      final list = _onScreenList(tester);
      await tester.scrollUntilVisible(row, 200, scrollable: list);
      await tester.drag(list, const Offset(0, -160));
      await tester.pumpAndSettle();
      await shot('1_settings');
      await tester.tap(row);
      await tester.pumpAndSettle();
      // The status is the platform's answer: let it arrive.
      for (var i = 0; i < 30; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }
      final clear = find.text('Clear thinking history'); // l10n-ignore
      final page = _onScreenList(tester);
      await tester.scrollUntilVisible(clear, 200, scrollable: page);
      await tester.pumpAndSettle();
      await shot('2_privacy');
      await tester.tap(clear);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.text('Thinking history cleared'), findsOneWidget);
      await shot('3_cleared');
      await tester.pumpAndSettle(const Duration(seconds: 5));
    });
  }
}

/// The widest vertical list on screen: offstage branches keep theirs
/// mounted, and the rail has its own.
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
