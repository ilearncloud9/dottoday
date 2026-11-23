// Swipes on phone Inbox rows (docs/09 M20.5 part 3, E-R2-25 §3, ED-328):
// start → end shows Move to Trash (coral, the trash icon), end → start
// Schedule (tinted, the calendar); a full swipe to the end moves the task
// to Trash with Undo, a full swipe to the start opens the schedule sheet.
// The first row carries the hint. In-memory data:
//   tool/device_tests.sh ios <udid> inbox_swipe       (DEVICE_SHOT)
//   tool/device_tests.sh android <serial> inbox_swipe
//   flutter build web -t integration_test/inbox_swipe_test.dart \
//     --dart-define=SWEEP_HOST_SHOTS=true, served, then
//   SHOTS=inbox_swipe node tool/slice/web_journey.mjs <url> compact <browser>
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

/// Three tasks waiting in the Inbox, beside the month's.
List<Occurrence> _rows() => [
  ...calendarMonth(),
  for (final (i, (title, color)) in [
    ('Buy a birthday gift', 'coral'),
    ('Book the car service', 'sky'),
    ('Call Mum', 'teal'),
  ].indexed)
    occurrenceFixture().copyWith(
      id: 'inbox $i', // l10n-ignore: test fixture id
      title: title,
      startUtc: null,
      durationMin: 30,
      colorKey: color,
    ),
];

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(tz_data.initializeTimeZones);

  /// Slides the row under [title] by [dx], held there for a shot.
  Future<TestGesture> slide(
    WidgetTester tester,
    String title,
    double dx,
  ) async {
    final at = tester.getCenter(find.text(title).hitTestable().first);
    final g = await tester.startGesture(at, kind: PointerDeviceKind.touch);
    const steps = 10;
    for (var i = 1; i <= steps; i++) {
      await g.moveTo(at.translate(dx * i / steps, 0));
      await tester.pump(const Duration(milliseconds: 16));
    }
    await tester.pump(const Duration(milliseconds: 300));
    return g;
  }

  for (final mode in [ThemeMode.dark, ThemeMode.light]) {
    testWidgets('inbox swipe, ${mode.name}', (tester) async {
      Future<void> shot(String step) =>
          deviceShot(binding, tester, 'swipe_${mode.name}_$step');
      final router = await pumpCalendar(tester, mode: mode, rows: _rows());
      router.go(AppRoutes.inbox);
      await tester.pumpAndSettle();
      final width =
          tester.view.physicalSize.width / tester.view.devicePixelRatio;
      const gift = 'Buy a birthday gift'; // l10n-ignore: data
      const car = 'Book the car service'; // l10n-ignore: data

      // Start → end, partway: Move to Trash.
      var g = await slide(tester, gift, width * 0.4);
      await shot('1_trash');
      await g.moveBy(Offset(-width * 0.4, 0));
      await g.up();
      await tester.pumpAndSettle();

      // End → start, partway: Schedule.
      g = await slide(tester, car, -width * 0.4);
      await shot('2_schedule');
      await g.moveBy(Offset(width * 0.4, 0));
      await g.up();
      await tester.pumpAndSettle();

      // A full swipe to the end: to Trash, with Undo.
      await tester.fling(
        find.text(gift).hitTestable().first,
        Offset(width * 0.8, 0),
        2000,
      );
      for (var i = 0; i < 30 && find.text('Undo').evaluate().isEmpty; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }
      expect(find.text('Undo'), findsWidgets);
      await shot('3_trashed');
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // A full swipe to the start: the schedule sheet.
      await tester.fling(
        find.text(car).hitTestable().first,
        Offset(-width * 0.8, 0),
        2000,
      );
      await tester.pumpAndSettle();
      await shot('4_sheet');
    });
  }
}
