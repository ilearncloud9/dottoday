// Multi-select (docs/09 M20.5 part 4, E-R2-6): on a phone a hold on the
// thread picks and taps add; at the wide width a still touch hold on the
// week grid picks and taps add across days. Duplicate writes with Undo.
import 'package:dottoday/core/router/app_routes.dart';
import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:timezone/data/latest.dart' as tz_data;

import '../../domain/fixtures.dart';
import 'calendar/calendar_world.dart';

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

  for (final size in [const Size(390, 844), const Size(1280, 800)]) {
    testWidgets('select, ${size.width}', (tester) async {
      const mode = ThemeMode.light;
      final router = await pumpCalendar(
        tester,
        mode: mode,
        rows: _rows(),
        size: size,
      );
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

      // 2 · Duplicate: one write, with Undo; selecting ends.
      await tester.tap(find.text('Duplicate')); // l10n-ignore
      for (var k = 0; k < 30 && find.text('Undo').evaluate().isEmpty; k++) {
        await tester.pump(const Duration(milliseconds: 100));
      }
      expect(find.text('Undo'), findsWidgets); // l10n-ignore
      expect(find.text('3 selected'), findsNothing); // l10n-ignore
      await tester.pumpAndSettle(const Duration(seconds: 2));
    });
  }
}
