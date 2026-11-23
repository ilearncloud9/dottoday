// Time states on Today (docs/09 M20.6 part 2; E-R2-26 §1, ED-329): at
// 10:42 Draft memo ended 7 min ago unticked: its row reads "· not done",
// muted, never late; "Need more time?" floats at the foot above the tab
// bar. Catch up opens the Running late form (Cancel · Running late ·
// Done, How late, a radio list); Cancel changes nothing; Skip then Done
// writes with Undo. In-memory data:
//   tool/device_tests.sh ios <udid> time_states       (DEVICE_SHOT)
//   tool/device_tests.sh android <serial> time_states
//   SWEEP_TARGET=integration_test/time_states_test.dart tool/mac_sweep.sh
//   flutter build web -t integration_test/time_states_test.dart \
//     --dart-define=SWEEP_HOST_SHOTS=true, served, then
//   SHOTS=time_states node tool/slice/web_journey.mjs <url> compact|expanded <b>
import 'package:dottoday/core/router/app_routes.dart';
import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:dottoday/shared/sheets/sheet_nav_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:timezone/data/latest.dart' as tz_data;

import '../test/domain/fixtures.dart';
import '../test/features/timeline/calendar/calendar_world.dart';
import 'support/device_shot.dart';

/// The month, with Draft memo from 9:35 to 10:35 not ticked.
List<Occurrence> _rows() => [
  ...calendarMonth(),
  occurrenceFixture().copyWith(
    id: 'late memo', // l10n-ignore: fixture id
    title: 'Draft memo', // l10n-ignore: data
    colorKey: 'sky',
    iconKey: 'mail',
    startUtc: DateTime.utc(2026, 11, 3, 8, 35),
    tzId: 'Europe/Berlin',
    durationMin: 60,
  ),
];

final _done = find.descendant(
  of: find.byType(SheetNavBar),
  matching: find.text('Done'), // l10n-ignore
);

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(tz_data.initializeTimeZones);

  for (final mode in [ThemeMode.dark, ThemeMode.light]) {
    testWidgets('time states, ${mode.name}', (tester) async {
      Future<void> shot(String step) =>
          deviceShot(binding, tester, 'time_${mode.name}_$step');
      final router = await pumpCalendar(tester, mode: mode, rows: _rows());
      router.go(AppRoutes.today);
      await tester.pumpAndSettle();

      // 1 · The row past its end, and the card at the foot.
      final memo = find.text('Draft memo').first; // l10n-ignore
      await Scrollable.ensureVisible(tester.element(memo), alignment: 0.3);
      await tester.pumpAndSettle();
      expect(find.text('Need more time?'), findsOneWidget); // l10n-ignore
      await shot('1_past_end');

      // 2 · Catch up: the Running late form; Cancel changes nothing.
      await tester.tap(find.text('Catch up')); // l10n-ignore
      await tester.pumpAndSettle();
      expect(_done, findsOneWidget);
      await shot('2_running_late');
      // iPhone: Cancel; elsewhere Material's ×.
      final cancel = find.descendant(
        of: find.byType(SheetNavBar),
        matching: find.byWidgetPredicate(
          (w) => w is TextButton || w is IconButton,
        ),
      );
      await tester.tap(cancel.first);
      await tester.pumpAndSettle();
      expect(_done, findsNothing);

      // 3 · Again: Skip, then Done, with Undo.
      await tester.tap(find.text('Catch up')); // l10n-ignore
      await tester.pumpAndSettle();
      await tester.tap(find.textContaining('Skip').last); // l10n-ignore
      await tester.pumpAndSettle();
      await shot('3_skip_picked');
      await tester.tap(_done);
      for (var k = 0; k < 30 && find.text('Undo').evaluate().isEmpty; k++) {
        await tester.pump(const Duration(milliseconds: 100));
      }
      expect(find.text('Undo'), findsWidgets); // l10n-ignore
      await shot('4_skipped');
      await tester.pumpAndSettle(const Duration(seconds: 2));
    });
  }
}
