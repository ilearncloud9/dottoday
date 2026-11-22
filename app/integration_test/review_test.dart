// Day review and Week in review on a device (docs/09 M20.3 part 4, ED-099,
// ED-297): the one review where each layout keeps it (the sheet on phones,
// a dialog at medium, the pane beside the day on tablets, the Review place
// on the Mac and the web), Week in review pushed where it has a row, and
// Minimal's review (the Day column wide, the sheet without Week in review
// on phones). In-memory data on a fixed day:
//   tool/device_tests.sh ios <udid> review       (DEVICE_SHOT)
//   tool/device_tests.sh android <serial> review
//   SWEEP_TARGET=integration_test/review_test.dart tool/mac_sweep.sh
//   flutter build web -t integration_test/review_test.dart \
//     --dart-define=SWEEP_HOST_SHOTS=true, served, then
//   SHOTS=review node tool/slice/web_journey.mjs <url> <width> <browser>
import 'dart:async';

import 'package:dottoday/core/router/app_routes.dart';
import 'package:dottoday/domain/entities/enums.dart';
import 'package:dottoday/features/timeline/review/review_panel.dart';
import 'package:dottoday/features/timeline/review/review_presenter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:timezone/data/latest.dart' as tz_data;

import '../test/features/timeline/calendar/calendar_world.dart';
import 'support/device_shot.dart';

/// The fixed day the world's clock sits on.
final _day = DateTime(2026, 11, 3);

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(tz_data.initializeTimeZones);

  Future<void> open(WidgetTester tester) async {
    final screen = tester.element(find.byType(Scaffold).hitTestable().first);
    unawaited(openReview(screen, day: _day));
    await tester.pumpAndSettle();
  }

  /// Closes a sheet, dialog, pane or column; the Review place stays.
  Future<void> close(WidgetTester tester) async {
    final panel = find.byType(ReviewPanel);
    if (panel.evaluate().isEmpty) return;
    await tester.tap(
      find.descendant(of: panel, matching: find.byTooltip('Close')).first,
    );
    await tester.pumpAndSettle();
  }

  for (final mode in [ThemeMode.dark, ThemeMode.light]) {
    testWidgets('the review, ${mode.name}', (tester) async {
      Future<void> shot(String step) =>
          deviceShot(binding, tester, 'review_${mode.name}_$step');
      final router = await pumpCalendar(tester, mode: mode);
      router.go(AppRoutes.today);
      await tester.pumpAndSettle();
      await open(tester);
      await shot('1_day');
      // Week in review pushes where it has a row (sheet, dialog, pane);
      // the Review place shows it beside the day already.
      final row = find.textContaining('done so far');
      if (row.evaluate().isNotEmpty) {
        await tester.tap(row);
        await tester.pumpAndSettle();
        expect(find.byType(ReviewPanel), findsOneWidget);
        await shot('2_week');
      }
      await close(tester);
      // The Wind Down notification's address lands on the same surface.
      router.go(AppRoutes.review);
      await tester.pumpAndSettle();
      await shot('3_link');
      await close(tester);
      router.go(AppRoutes.today);
      await tester.pumpAndSettle();
    });
  }

  testWidgets('the review in Minimal', (tester) async {
    final router = await pumpCalendar(tester, layout: UiLayout.minimal);
    router.go(AppRoutes.today);
    await tester.pumpAndSettle();
    await open(tester);
    expect(find.byType(ReviewPanel), findsOneWidget);
    expect(find.textContaining('done so far'), findsNothing);
    await deviceShot(binding, tester, 'review_minimal');
    await close(tester);
    expect(find.byType(ReviewPanel), findsNothing);
  });
}
