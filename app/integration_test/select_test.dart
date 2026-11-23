// Multi-select and the selection bar (docs/09 M20.5 part 4, E-R2-6,
// ED-278, ED-279). Phones: a hold on Call with Sam picks it, taps add
// Deep work and Lunch, the card floats above the bottom row; Duplicate
// writes with Undo. Tablets, the Mac and the web: on the week grid a hold
// picks Tuesday's Lunch, taps add Wednesday's Lunch and Dentist (picks
// across days), the card centred under the grid with Save as routine
// greyed; Duplicate with Undo. In-memory data:
//   tool/device_tests.sh ios <udid> select       (DEVICE_SHOT)
//   tool/device_tests.sh android <serial> select
//   SWEEP_TARGET=integration_test/select_test.dart tool/mac_sweep.sh
//   flutter build web -t integration_test/select_test.dart \
//     --dart-define=SWEEP_HOST_SHOTS=true, served, then
//   SHOTS=select node tool/slice/web_journey.mjs <url> compact|expanded <b>
import 'package:dottoday/core/router/app_routes.dart';
import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:timezone/data/latest.dart' as tz_data;

import '../test/domain/fixtures.dart';
import '../test/features/timeline/calendar/calendar_world.dart';
import 'support/device_shot.dart';

/// The month, with a Lunch on Wednesday too (the board's tablet sample).
List<Occurrence> _rows() => [
  ...calendarMonth(),
  occurrenceFixture().copyWith(
    id: 'cal 4 Lunch', // l10n-ignore: test fixture id
    title: 'Lunch', // l10n-ignore: data
    colorKey: 'rose',
    iconKey: 'meal',
    startUtc: DateTime.utc(2026, 11, 4, 11, 30),
    tzId: 'Europe/Berlin',
    durationMin: 45,
  ),
];

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(tz_data.initializeTimeZones);

  /// Holds [at] without moving, then lets go: a pick.
  Future<void> hold(WidgetTester tester, Offset at) async {
    final g = await tester.startGesture(at);
    await tester.pump(const Duration(milliseconds: 500));
    await g.up();
    await tester.pumpAndSettle();
  }

  /// [title]'s [i]th match on screen from the start (leftmost first),
  /// scrolled to a third of the way down first.
  Future<Finder> nth(WidgetTester tester, String title, int i) async {
    final any = find.text(title).first;
    await Scrollable.ensureVisible(tester.element(any), alignment: 0.3);
    await tester.pumpAndSettle();
    // While picking, rows absorb their children's hits: on screen is
    // enough.
    final view = tester.view;
    final screen = Offset.zero & view.physicalSize / view.devicePixelRatio;
    final all = find.text(title);
    final order =
        [
          for (var k = 0; k < all.evaluate().length; k++)
            if (screen.contains(tester.getCenter(all.at(k)))) k,
        ]..sort(
          (a, b) => tester
              .getCenter(all.at(a))
              .dx
              .compareTo(tester.getCenter(all.at(b)).dx),
        );
    return all.at(order[i]);
  }

  for (final mode in [ThemeMode.dark, ThemeMode.light]) {
    testWidgets('select, ${mode.name}', (tester) async {
      Future<void> shot(String step) =>
          deviceShot(binding, tester, 'select_${mode.name}_$step');
      final router = await pumpCalendar(tester, mode: mode, rows: _rows());
      final width =
          tester.view.physicalSize.width / tester.view.devicePixelRatio;
      final phone = width < 600;
      // l10n-ignore-start: data
      final picks = phone
          ? [('Call with Sam', 0), ('Deep work: roadmap', 0), ('Lunch', 0)]
          : [('Lunch', 0), ('Lunch', 1), ('Dentist', 0)];
      // l10n-ignore-end
      router.go(
        phone ? AppRoutes.today : AppRoutes.weekOf(DateTime(2026, 11, 3)),
      );
      await tester.pumpAndSettle();

      // 1 · A hold picks the first; taps add the rest.
      final (first, i) = picks.first;
      await hold(tester, tester.getCenter(await nth(tester, first, i)));
      for (final (title, at) in picks.skip(1)) {
        await tester.tap(await nth(tester, title, at));
        await tester.pumpAndSettle();
      }
      expect(find.text('3 selected'), findsOneWidget); // l10n-ignore
      await shot('1_picked');

      // 2 · Duplicate: one write, with Undo; selecting ends.
      await tester.tap(find.text('Duplicate')); // l10n-ignore
      for (var k = 0; k < 30 && find.text('Undo').evaluate().isEmpty; k++) {
        await tester.pump(const Duration(milliseconds: 100));
      }
      expect(find.text('Undo'), findsWidgets); // l10n-ignore
      expect(find.text('3 selected'), findsNothing); // l10n-ignore
      await shot('2_duplicated');
      await tester.pumpAndSettle(const Duration(seconds: 2));
    });
  }
}
