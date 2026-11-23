// Moving on tablets and with a pointer (docs/09 M20.5 part 2, E-R2-25 §2,
// ED-328), on the Week grid at the wide widths: a pointer's hover (a flat
// tint), a touch hold dragging Lunch onto Wednesday (the drop box with
// "Wed · …"), the drop and its toast, a pointer drag, and an Inbox task
// from the Plan panel dragged onto Thursday. In-memory data:
//   tool/device_tests.sh ios <ipad udid> tablet_drag       (DEVICE_SHOT)
//   tool/device_tests.sh android <tablet serial> tablet_drag
//   SWEEP_TARGET=integration_test/tablet_drag_test.dart tool/mac_sweep.sh
//   flutter build web -t integration_test/tablet_drag_test.dart \
//     --dart-define=SWEEP_HOST_SHOTS=true, served, then
//   SHOTS=tablet_drag node tool/slice/web_journey.mjs <url> expanded <browser>
import 'package:dottoday/core/router/app_routes.dart';
import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:timezone/data/latest.dart' as tz_data;

import '../test/domain/fixtures.dart';
import '../test/features/timeline/calendar/calendar_world.dart';
import 'support/device_shot.dart';

/// Two tasks waiting in the Inbox, beside the month's.
List<Occurrence> _rows() => [
  ...calendarMonth(),
  for (final (i, title) in [
    'Book the car service',
    'Buy a birthday gift',
  ].indexed)
    occurrenceFixture().copyWith(
      id: 'inbox $i', // l10n-ignore: test fixture id
      title: title,
      startUtc: null,
      durationMin: 30,
      colorKey: i == 0 ? 'sky' : 'coral',
    ),
];

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(tz_data.initializeTimeZones);

  /// Moves [g] to [to] in small steps, as a hand would.
  Future<void> glide(
    WidgetTester tester,
    TestGesture g,
    Offset from,
    Offset to,
  ) async {
    const steps = 12;
    for (var i = 1; i <= steps; i++) {
      await g.moveTo(Offset.lerp(from, to, i / steps)!);
      await tester.pump(const Duration(milliseconds: 16));
    }
    await tester.pump(const Duration(milliseconds: 300));
  }

  /// [title]'s card on the grid, the one furthest left (Tuesday's).
  Finder card(WidgetTester tester, String title) {
    final all = find.text(title).hitTestable();
    var best = 0;
    for (var i = 1; i < all.evaluate().length; i++) {
      if (tester.getCenter(all.at(i)).dx < tester.getCenter(all.at(best)).dx) {
        best = i;
      }
    }
    return all.at(best);
  }

  for (final mode in [ThemeMode.dark, ThemeMode.light]) {
    testWidgets('tablet drag, ${mode.name}', (tester) async {
      Future<void> shot(String step) =>
          deviceShot(binding, tester, 'tablet_${mode.name}_$step');
      final router = await pumpCalendar(tester, mode: mode, rows: _rows());
      router.go(AppRoutes.weekOf(DateTime(2026, 11, 3)));
      await tester.pumpAndSettle();
      final lunch = card(tester, 'Lunch'); // l10n-ignore: data
      final from = tester.getCenter(lunch);
      // A column's width, from the day headers: Wednesday is one to the
      // right.
      final step =
          tester
              .getCenter(find.text('Thu').hitTestable().first)
              .dx - // l10n-ignore
          tester
              .getCenter(find.text('Wed').hitTestable().first)
              .dx; // l10n-ignore
      final dentist = card(tester, 'Dentist'); // l10n-ignore: data

      // 1 · A pointer over a card: a flat tint, no lift.
      final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
      await mouse.addPointer(location: Offset.zero);
      await mouse.moveTo(tester.getCenter(dentist));
      await tester.pump(const Duration(milliseconds: 300));
      await shot('1_hover');
      await mouse.moveTo(Offset.zero);
      await tester.pump();

      // 2 · Touch: hold Lunch, drop it on Wednesday an hour earlier.
      final touch = await tester.startGesture(from);
      await tester.pump(const Duration(milliseconds: 400));
      final wed = from.translate(step, -60);
      await glide(tester, touch, from, wed);
      await shot('2_touch');
      await touch.up();
      await tester.pump(const Duration(milliseconds: 600));
      expect(find.text('Undo'), findsWidgets);
      await shot('3_dropped');
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // 4 · A pointer drags at once, with the same drop box.
      final call = card(tester, 'Dentist'); // l10n-ignore: data
      final at = tester.getCenter(call);
      await mouse.moveTo(at);
      await mouse.down(at);
      await glide(tester, mouse, at, at.translate(step, 40));
      await shot('4_pointer');
      await glide(tester, mouse, at.translate(step, 40), at);
      await mouse.up();
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // 5 · An Inbox task from the Plan panel onto Thursday.
      final gift = find
          .text('Buy a birthday gift')
          .hitTestable(); // l10n-ignore
      if (gift.evaluate().isEmpty) {
        final header = find.text('Inbox').hitTestable(); // l10n-ignore
        if (header.evaluate().isNotEmpty) await tester.tap(header.last);
        await tester.pumpAndSettle();
      }
      if (gift.evaluate().isNotEmpty) {
        final start = tester.getCenter(gift.first);
        final thu = from.translate(step * 2, -120);
        final h = await tester.startGesture(start);
        await tester.pump(const Duration(milliseconds: 400));
        await glide(tester, h, start, thu);
        await shot('5_inbox');
        await h.up();
        await tester.pump(const Duration(milliseconds: 600));
        await shot('6_scheduled');
        await tester.pumpAndSettle(const Duration(seconds: 2));
      }
      await mouse.removePointer();
    });
  }
}
