// Break it down on a device (docs/09 M20.4 part 2, E-R2-23 §1, ED-324):
// from the task's own sheet, the proposal (the lead row in the card, the
// steps with their rings and lengths, Add a step, Total), a step's
// length picker, then Discard: nothing written. A sheet on phones, a
// dialog at medium width, the panel beside the day when wide. The
// on-device model answers where the device has one (the Mac's Apple
// Intelligence), else simple rules. In-memory data:
//   tool/device_tests.sh ios <udid> breakdown       (DEVICE_SHOT)
//   tool/device_tests.sh android <serial> breakdown
//   SWEEP_TARGET=integration_test/breakdown_test.dart tool/mac_sweep.sh
//   flutter build web -t integration_test/breakdown_test.dart \
//     --dart-define=SWEEP_HOST_SHOTS=true, served, then
//   SHOTS=breakdown node tool/slice/web_journey.mjs <url> <width> <browser>
import 'dart:async';

import 'package:dottoday/core/router/app_routes.dart';
import 'package:dottoday/features/task_editor/breakdown/breakdown_flow.dart';
import 'package:dottoday/shared/duration/step_length_chip.dart';
import 'package:dottoday/shared/proposals/proposal_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:timezone/data/latest.dart' as tz_data;

import '../test/features/timeline/calendar/calendar_world.dart';
import 'support/device_shot.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(tz_data.initializeTimeZones);

  /// Waits for the proposal: the on-device model is a platform call.
  Future<void> waitForPlan(WidgetTester tester) async {
    for (var i = 0; i < 300; i++) {
      await tester.pump(const Duration(milliseconds: 100));
      if (find.byType(ProposalSheet).evaluate().isNotEmpty) break;
    }
    await tester.pumpAndSettle();
  }

  for (final mode in [ThemeMode.dark, ThemeMode.light]) {
    testWidgets('break it down, ${mode.name}', (tester) async {
      Future<void> shot(String step) =>
          deviceShot(binding, tester, 'breakdown_${mode.name}_$step');
      final router = await pumpCalendar(
        tester,
        mode: mode,
        rows: [...calendarMonth(), ...pastYear()],
      );
      router.go(AppRoutes.today);
      await tester.pumpAndSettle();
      final screen = tester.element(find.byType(Scaffold).hitTestable().first);
      unawaited(
        breakDown(
          screen,
          const BreakdownTarget(
            title: 'Write the Q4 report', // l10n-ignore: test data
            durationMin: 120,
            colorKey: 'indigo',
            iconKey: 'document',
          ),
        ),
      );
      await waitForPlan(tester);
      expect(find.byType(ProposalSheet), findsOneWidget);
      await shot('1_plan');
      // A step's length: the chips and No time.
      final chip = find.descendant(
        of: find.byType(ProposalSheet),
        matching: find.byType(StepLengthChip),
      );
      await tester.tap(chip.first);
      await tester.pumpAndSettle();
      await shot('2_length');
      Navigator.of(tester.element(find.text('No time'))).pop();
      await tester.pumpAndSettle();
      final discard = find.text('Discard');
      await tester.ensureVisible(discard);
      await tester.tap(discard);
      await tester.pumpAndSettle();
      expect(find.byType(ProposalSheet), findsNothing);
    });
  }
}
