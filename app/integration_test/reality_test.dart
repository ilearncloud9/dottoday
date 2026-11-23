// The Reality thread and Learn my day on a device (docs/09 M20.4 part 5,
// E-R2-23 §4, ED-324): Today while still learning (the boxed caption
// with ×), then after the reveal: Plan | Reality at the start, the rows
// where they really ran ("· took 50 min", "· 1 h 7 in · usually 2 h 20"),
// the insight with OK, the explanation on tap, and Settings › Learning.
// In-memory data:
//   tool/device_tests.sh ios <udid> reality       (DEVICE_SHOT)
//   tool/device_tests.sh android <serial> reality
//   SWEEP_TARGET=integration_test/reality_test.dart tool/mac_sweep.sh
//   flutter build web -t integration_test/reality_test.dart \
//     --dart-define=SWEEP_HOST_SHOTS=true, served, then
//   SHOTS=reality node tool/slice/web_journey.mjs <url> <width> <browser>
import 'package:dottoday/core/router/app_routes.dart';
import 'package:dottoday/domain/entities/enums.dart';
import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:timezone/data/latest.dart' as tz_data;

import '../test/features/timeline/calendar/calendar_world.dart';
import '../test/support/timeline_fakes.dart';
import 'support/device_shot.dart';

/// Today (3 Nov) as it really went: Morning run ran 5:50–6:40 against a
/// 5:45 plan, Deep work started at 8:35; four earlier Deep works took
/// 140 min against 120, so it "usually" takes 2 h 20.
List<Occurrence> _realDay() {
  final rows = [
    for (final o in calendarMonth())
      switch (o.title) {
        'Morning run' when o.startUtc?.day == 3 => o.copyWith(
          actualStartUtc: DateTime.utc(2026, 11, 3, 5, 50),
          actualEndUtc: DateTime.utc(2026, 11, 3, 6, 40),
        ),
        'Deep work: roadmap' => o.copyWith(
          actualStartUtc: DateTime.utc(2026, 11, 3, 8, 35),
        ),
        _ => o,
      },
  ];
  final deep = rows.firstWhere((o) => o.title == 'Deep work: roadmap');
  return [
    ...rows,
    for (var d = 26; d <= 29; d++)
      deep.copyWith(
        id: 'history $d', // l10n-ignore: test fixture id
        startUtc: DateTime.utc(2026, 10, d, 8),
        actualStartUtc: DateTime.utc(2026, 10, d, 8),
        actualEndUtc: DateTime.utc(2026, 10, d, 10, 20),
        status: OccurrenceStatus.done,
      ),
  ];
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

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(tz_data.initializeTimeZones);

  for (final mode in [ThemeMode.dark, ThemeMode.light]) {
    testWidgets('still learning, ${mode.name}', (tester) async {
      final router = await pumpCalendar(tester, mode: mode, rows: _realDay());
      router.go(AppRoutes.today);
      await tester.pumpAndSettle();
      expect(find.textContaining('so far'), findsOneWidget);
      await deviceShot(binding, tester, 'reality_${mode.name}_1_learning');
    });

    testWidgets('reality on, ${mode.name}', (tester) async {
      Future<void> shot(String step) =>
          deviceShot(binding, tester, 'reality_${mode.name}_$step');
      final router = await pumpCalendar(
        tester,
        mode: mode,
        rows: _realDay(),
        learningMeta: realityRevealedMeta,
      );
      router.go(AppRoutes.today);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Reality').hitTestable().first);
      await tester.pumpAndSettle();
      // Back to the day's top: the finished run, then the live row.
      await tester.drag(_onScreenList(tester), const Offset(0, 600));
      await tester.pumpAndSettle();
      // Then just far enough for the live row's time line.
      await tester.scrollUntilVisible(
        find.textContaining('· usually 2 h 20'),
        100,
        scrollable: _onScreenList(tester),
      );
      // Clear of the pinned Plan | Reality switch.
      await tester.drag(_onScreenList(tester), const Offset(0, 140));
      await tester.pumpAndSettle();
      final usual = find.textContaining('· usually 2 h 20').hitTestable();
      expect(usual, findsWidgets);
      await shot('2_reality');
      await tester.tap(usual.first);
      await tester.pumpAndSettle();
      expect(find.textContaining('based on your last'), findsWidgets);
      await shot('3_usually');
      router.go(AppRoutes.settings);
      await tester.pumpAndSettle();
      final row = find.text('Reality thread'); // l10n-ignore: finder
      await tester.scrollUntilVisible(
        row,
        200,
        scrollable: _onScreenList(tester),
      );
      await tester.ensureVisible(row);
      await tester.drag(_onScreenList(tester), const Offset(0, 90));
      await tester.pumpAndSettle();
      await shot('4_learning');
    });
  }
}
