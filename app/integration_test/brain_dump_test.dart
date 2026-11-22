// Brain dump on a device (docs/09 M20.4 part 1, E-Phones-2, R2-37,
// ED-343): the lines typed in the filled box, "Put it on" Today, the
// caption, then the plan (nothing written before Add to day) and
// Discard; a sheet on phones, a dialog from medium width. Wide, the
// Plan panel's block with Dictate. The microphone itself needs the
// system's own dialogs, so its states are goldens. In-memory data:
//   tool/device_tests.sh ios <udid> brain_dump       (DEVICE_SHOT)
//   tool/device_tests.sh android <serial> brain_dump
//   SWEEP_TARGET=integration_test/brain_dump_test.dart tool/mac_sweep.sh
//   flutter build web -t integration_test/brain_dump_test.dart \
//     --dart-define=SWEEP_HOST_SHOTS=true, served, then
//   SHOTS=brain_dump node tool/slice/web_journey.mjs <url> <width> <browser>
import 'dart:async';

import 'package:dottoday/core/router/app_routes.dart';
import 'package:dottoday/features/timeline/brain_dump/brain_dump_plan_section.dart';
import 'package:dottoday/features/timeline/brain_dump/brain_dump_sheet.dart';
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

  for (final mode in [ThemeMode.dark, ThemeMode.light]) {
    testWidgets('brain dump, ${mode.name}', (tester) async {
      Future<void> shot(String step) =>
          deviceShot(binding, tester, 'brain_dump_${mode.name}_$step');
      final router = await pumpCalendar(tester, mode: mode);
      router.go(AppRoutes.today);
      await tester.pumpAndSettle();
      // Wide: the Plan panel's block, when the panel is out.
      if (find.byType(BrainDumpPlanSection).evaluate().isNotEmpty) {
        await tester.ensureVisible(find.byType(BrainDumpPlanSection));
        await tester.pumpAndSettle();
        await shot('0_block');
      }
      final screen = tester.element(find.byType(Scaffold).hitTestable().first);
      unawaited(showBrainDump(screen, DateTime(2026, 11, 3)));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.descendant(
          of: find.byType(BrainDumpBody),
          matching: find.byType(TextField),
        ),
        // l10n-ignore: test data, the board's lines
        'Email Sam\nTaxes 45m\nCall the bank 4pm\nPaint the hall',
      );
      await tester.pumpAndSettle();
      await shot('1_lines');
      final plan = find.text('Plan it').last;
      await tester.ensureVisible(plan);
      await tester.tap(plan);
      // The on-device model may answer (Apple Intelligence on the Mac):
      // a platform call, so wait for the plan rather than for frames.
      for (var i = 0; i < 300; i++) {
        await tester.pump(const Duration(milliseconds: 100));
        if (find.byType(ProposalSheet).evaluate().isNotEmpty) break;
      }
      await tester.pumpAndSettle();
      expect(find.byType(ProposalSheet), findsOneWidget);
      await shot('2_plan');
      final discard = find.text('Discard');
      await tester.ensureVisible(discard);
      await tester.tap(discard);
      await tester.pumpAndSettle();
      expect(find.byType(ProposalSheet), findsNothing);
    });
  }
}
