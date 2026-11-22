// Search or run on the Mac and the web (docs/09 M20.2 part 3, E-R2-30):
// ⌘K (the web's k) opens the palette over Today, "road" finds tasks and
// commands, and "go to date" runs Go to Date…, on a fixed day with
// in-memory data. Shots as the Calendar's:
//   SWEEP_TARGET=integration_test/search_or_run_test.dart tool/mac_sweep.sh
//   flutter build web -t integration_test/search_or_run_test.dart \
//     --dart-define=SWEEP_HOST_SHOTS=true, served, then
//   SHOTS=search_or_run node tool/slice/web_journey.mjs <url> <width> <browser>
import 'package:dottoday/core/router/app_routes.dart';
import 'package:dottoday/features/search/widgets/search_or_run.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:timezone/data/latest.dart' as tz_data;

import '../test/features/timeline/calendar/calendar_world.dart';
import '../test/support/sample_inbox.dart';
import 'support/device_shot.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(tz_data.initializeTimeZones);

  /// ⌘K on the Mac, k on the web.
  Future<void> openPalette(WidgetTester tester) async {
    if (kIsWeb) {
      await tester.sendKeyEvent(LogicalKeyboardKey.keyK);
    } else {
      await tester.sendKeyDownEvent(LogicalKeyboardKey.metaLeft);
      await tester.sendKeyEvent(LogicalKeyboardKey.keyK);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.metaLeft);
    }
    await tester.pumpAndSettle();
  }

  for (final mode in [ThemeMode.light, ThemeMode.dark]) {
    testWidgets('Search or run, ${mode.name}', (tester) async {
      Future<void> shot(String step) =>
          deviceShot(binding, tester, 'search_or_run_${mode.name}_$step');
      final rows = [...calendarMonth(), ...sampleInbox()];
      final router = await pumpCalendar(tester, mode: mode, rows: rows);
      router.go(AppRoutes.today);
      await tester.pumpAndSettle();
      await openPalette(tester);
      expect(find.byType(SearchOrRun), findsOneWidget);
      await shot('1_open');
      final field = find.descendant(
        of: find.byType(SearchOrRun),
        matching: find.byType(TextField),
      );
      await tester.enterText(field, 'road');
      await tester.pumpAndSettle();
      await shot('2_road');
      await tester.enterText(field, 'go to date');
      await tester.pumpAndSettle();
      // "Search for …" first, then Go to Date….
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();
      expect(find.byType(SearchOrRun), findsNothing);
      await shot('3_ran');
    });
  }
}
