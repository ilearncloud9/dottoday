// Rebalance on a device (docs/09 M20.3 part 5, R2-35, ED-341): the plan
// with each line's faded ring and proposed dot, a rule changed (the plan
// made again), and Accept with "Plan accepted" and Undo; a sheet on
// phones, a dialog at medium width, a centred panel on the Mac and the
// web; then Minimal's before and after only. In-memory data on a fixed
// day:
//   tool/device_tests.sh ios <udid> rebalance       (DEVICE_SHOT)
//   tool/device_tests.sh android <serial> rebalance
//   SWEEP_TARGET=integration_test/rebalance_test.dart tool/mac_sweep.sh
//   flutter build web -t integration_test/rebalance_test.dart \
//     --dart-define=SWEEP_HOST_SHOTS=true, served, then
//   SHOTS=rebalance node tool/slice/web_journey.mjs <url> <width> <browser>
import 'dart:async';

import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/router/app_routes.dart';
import 'package:dottoday/domain/entities/enums.dart';
import 'package:dottoday/features/timeline/state/rebalance_flow.dart';
import 'package:dottoday/shared/proposals/proposal_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:timezone/data/latest.dart' as tz_data;

import '../test/acceptance/slice_world.dart';
import '../test/features/timeline/calendar/calendar_world.dart';
import 'support/device_shot.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(tz_data.initializeTimeZones);

  /// Deep work ran 15 min over at 11:00 on the world's day.
  Future<void> open(WidgetTester tester) async {
    final screen = tester.element(find.byType(Scaffold).hitTestable().first);
    unawaited(
      openRebalance(
        ProviderScope.containerOf(screen, listen: false),
        screen.l10n,
        today: DateTime(2026, 11, 3),
        fromUtc: sliceAt(10),
        deltaMin: 15,
        // l10n-ignore: test data, the world's task and overrun
        subtitle: screen.l10n.rebalanceRanOver('Deep work: roadmap', '15 min'),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byType(ProposalSheet), findsOneWidget);
  }

  for (final mode in [ThemeMode.dark, ThemeMode.light]) {
    testWidgets('rebalance, ${mode.name}', (tester) async {
      Future<void> shot(String step) =>
          deviceShot(binding, tester, 'rebalance_${mode.name}_$step');
      final router = await pumpCalendar(tester, mode: mode);
      router.go(AppRoutes.today);
      await tester.pumpAndSettle();
      await open(tester);
      await shot('1_plan');
      // A rule changes the plan: it is made again, still unwritten.
      final rule = find.text('Push past Wind Down');
      await tester.ensureVisible(rule);
      await tester.pumpAndSettle();
      await tester.tap(rule);
      await tester.pumpAndSettle();
      await shot('2_rule');
      final accept = find.text('Accept plan');
      await tester.ensureVisible(accept);
      await tester.tap(accept);
      await tester.pumpAndSettle();
      expect(find.byType(ProposalSheet), findsNothing);
      expect(find.text('Plan accepted'), findsOneWidget);
      await shot('3_accepted');
      await tester.tap(find.text('Undo'));
      await tester.pumpAndSettle();
    });
  }

  testWidgets('rebalance in Minimal', (tester) async {
    final router = await pumpCalendar(tester, layout: UiLayout.minimal);
    router.go(AppRoutes.today);
    await tester.pumpAndSettle();
    await open(tester);
    expect(find.text('Shift followers'), findsNothing);
    await deviceShot(binding, tester, 'rebalance_minimal');
    await tester.tap(find.text('Discard'));
    await tester.pumpAndSettle();
    expect(find.byType(ProposalSheet), findsNothing);
  });
}
