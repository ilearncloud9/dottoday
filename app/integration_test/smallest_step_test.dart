// Smallest step and Unstick on a device (docs/09 M20.4 part 3, E-R2-23
// §2, ED-324): Deep work (on now, started over 10 min ago, steps not
// started) shows "Just … · 15 min?" with Start; Call with Sam, moved
// three times with no steps, asks for its first step; an answer writes
// step 1 at once ("Step 1 added to …", Undo). In-memory data:
//   tool/device_tests.sh ios <udid> smallest_step       (DEVICE_SHOT)
//   tool/device_tests.sh android <serial> smallest_step
//   SWEEP_TARGET=integration_test/smallest_step_test.dart tool/mac_sweep.sh
//   flutter build web -t integration_test/smallest_step_test.dart \
//     --dart-define=SWEEP_HOST_SHOTS=true, served, then
//   SHOTS=smallest_step node tool/slice/web_journey.mjs <url> <width> <browser>
import 'package:dottoday/core/router/app_routes.dart';
import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:dottoday/domain/entities/subtask.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:timezone/data/latest.dart' as tz_data;

import '../test/domain/fixtures.dart';
import '../test/features/timeline/calendar/calendar_world.dart';
import 'support/device_shot.dart';

/// The world's day with Call with Sam moved three times.
List<Occurrence> _rows() => [
  for (final o in [...calendarMonth(), ...pastYear()])
    o.title == 'Call with Sam' && o.startUtc?.day == 3
        ? o.copyWith(moveCount: 3)
        : o,
];

/// Deep work's steps, none started.
List<Subtask> _steps(List<Occurrence> rows) {
  final deep = rows.firstWhere(
    (o) => o.title == 'Deep work: roadmap' && o.startUtc?.day == 3,
  );
  return [
    // l10n-ignore-start: test data
    for (final (i, (title, len)) in [
      ("Pull last quarter's notes", 15),
      ('Draft three themes', 30),
    ].indexed)
      subtaskFixture().copyWith(
        id: '01928c3e-0000-7000-8000-00000000e0${i}1',
        userId: deep.userId,
        occurrenceId: deep.id,
        title: title,
        durationMin: len,
        sortOrder: i.toDouble(),
      ),
    // l10n-ignore-end
  ];
}

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(tz_data.initializeTimeZones);

  for (final mode in [ThemeMode.dark, ThemeMode.light]) {
    testWidgets('smallest step and unstick, ${mode.name}', (tester) async {
      Future<void> shot(String step) =>
          deviceShot(binding, tester, 'smallest_step_${mode.name}_$step');
      final rows = _rows();
      final router = await pumpCalendar(
        tester,
        mode: mode,
        rows: rows,
        subtasks: _steps(rows),
      );
      router.go(AppRoutes.today);
      await tester.pumpAndSettle();
      expect(
        find.textContaining("Just Pull last quarter's notes"),
        findsWidgets,
      );
      await shot('1_smallest');
      final ask = find.text("What's the very first thing you'd physically do?");
      // A short window hasn't built Call with Sam's row yet: scroll to it.
      final middle = tester.getCenter(find.byType(Scaffold).first);
      for (var i = 0; i < 12 && ask.evaluate().isEmpty; i++) {
        await tester.dragFrom(middle, const Offset(0, -200));
        await tester.pumpAndSettle();
      }
      await tester.ensureVisible(ask.first);
      await tester.pumpAndSettle();
      await shot('2_unstick');
      await tester.enterText(
        find
            .ancestor(
              of: find.text('e.g. Open the folder'),
              matching: find.byType(TextField),
            )
            .first,
        'Open the deck', // l10n-ignore: test data
      );
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();
      expect(find.textContaining('Step 1 added'), findsOneWidget);
      await shot('3_added');
    });
  }
}
