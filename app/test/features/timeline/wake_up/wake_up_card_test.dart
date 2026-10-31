import 'package:dottoday/data/writes/write_providers.dart';
import 'package:dottoday/domain/entities/enums.dart';
import 'package:dottoday/domain/wake_up/wake_up_day.dart';
import 'package:dottoday/features/timeline/wake_up/wake_up_card_screen.dart';
import 'package:dottoday/shared/proposals/proposal_sheet.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest.dart' as tz_data;

import '../../../support/a11y.dart';
import '../../../support/timeline_fakes.dart';
import '../../../support/today_harness.dart';
import 'wake_up_harness.dart';

// The Wake Up card (docs/15 §5, §10, M17.3) on the demo day: at 09:22 in
// Berlin Deep work: roadmap (9:00–11:00) is under way; Wake Up is 07:00.

const _date = '2026-10-21';

String _id(String title) =>
    demoDayRows(todayTestDate).firstWhere((o) => o.title == title).id;

Future<void> _tap(WidgetTester tester, String text) async {
  await tester.ensureVisible(find.text(text));
  await tester.tap(find.text(text));
  await tester.pumpAndSettle();
}

void main() {
  setUpAll(tz_data.initializeTimeZones);

  testWidgets('the day: greeting, first dot, next dots; shown once', (
    tester,
  ) async {
    final h = await pumpWakeUp(tester);
    expect(find.text('Good morning. Wednesday, October 21.'), findsOneWidget);
    expect(find.text('FIRST'), findsOneWidget);
    expect(find.text('Deep work: roadmap'), findsOneWidget);
    expect(find.text('NEXT'), findsOneWidget);
    expect(h.days[_date]?.cardShownAtUtc, todayTestNow);
  });

  testWidgets('Start the day: Focus on a dot under way', (tester) async {
    await pumpWakeUp(tester);
    await _tap(tester, 'Start the day');
    expect(find.text('focus ${_id('Deep work: roadmap')}'), findsOneWidget);
  });

  testWidgets('Start the day before the first dot: the day is marked', (
    tester,
  ) async {
    // 07:30 in Berlin: the standup is at 08:00, more than 15 min away.
    final now = DateTime.utc(2026, 10, 21, 5, 30);
    final h = await pumpWakeUp(tester, now: now);
    await _tap(tester, 'Start the day');
    expect(h.days[_date]?.startedAtUtc, now);
    expect(find.text('today'), findsOneWidget);
  });

  testWidgets('up after plan: the line and Shift the rest, as set', (
    tester,
  ) async {
    final up = WakeUpDay(
      date: _date,
      stoppedAtUtc: DateTime.utc(2026, 10, 21, 5, 25),
    );
    await pumpWakeUp(tester, days: [up]);
    expect(find.text("You're up 25 min after plan."), findsOneWidget);
    expect(find.text('Shift the rest?'), findsOneWidget);
    await pumpWakeUp(
      tester,
      days: [up],
      settings: wakeUpOn.copyWith(wakeUpLateOffer: false),
    );
    expect(find.text('Shift the rest?'), findsNothing);
  });

  // The proposal rule (CLAUDE.md §11): Shift the rest? opens Rebalance's
  // ProposalSheet over Today, and nothing is written before Accept.
  testWidgets('Shift the rest: nothing is written before Accept', (
    tester,
  ) async {
    // Pushed over Today by the gate, as in the app.
    await pumpWakeUp(
      tester,
      location: '/today',
      days: [
        WakeUpDay(date: _date, stoppedAtUtc: DateTime.utc(2026, 10, 21, 5, 25)),
      ],
    );
    final container = ProviderScope.containerOf(
      tester.element(find.byType(WakeUpCardScreen)),
    );
    final writes = container.read(writeUseCaseProvider) as FakeWriteUseCase;
    await tester.ensureVisible(find.text('Shift the rest?'));
    await tester.tap(find.text('Shift the rest?'));
    await tester.pumpAndSettle();
    expect(find.byType(ProposalSheet), findsOneWidget);
    expect(find.text('today'), findsOneWidget, reason: 'over Today');
    expect(writes.applied, isEmpty, reason: 'on open');
    await tester.tap(find.text('Discard'));
    await tester.pumpAndSettle();
    expect(find.byType(ProposalSheet), findsNothing);
    expect(writes.applied, isEmpty, reason: 'on Discard');
  });

  testWidgets('minimal: first dot and Start; the rest behind Show my day', (
    tester,
  ) async {
    await pumpWakeUp(
      tester,
      settings: wakeUpOn.copyWith(uiLayout: UiLayout.minimal),
    );
    expect(find.text('Deep work: roadmap'), findsOneWidget);
    expect(find.text('NEXT'), findsNothing);
    await _tap(tester, 'Show my day');
    expect(find.text('NEXT'), findsOneWidget);
  });

  testWidgets('low energy: the first dot and Start only', (tester) async {
    await pumpWakeUp(
      tester,
      settings: wakeUpOn.copyWith(
        lowEnergyUntil: DateTime.utc(2026, 10, 21, 22),
      ),
    );
    expect(find.text('Deep work: roadmap'), findsOneWidget);
    expect(find.text('NEXT'), findsNothing);
    expect(find.text('Show my day'), findsNothing);
    expect(find.text('Start the day'), findsOneWidget);
  });

  testWidgets('an empty day: Nothing planned yet, Plan today opens Add', (
    tester,
  ) async {
    await pumpWakeUp(tester, rows: const []);
    expect(find.text('Nothing planned yet'), findsOneWidget);
    expect(find.text('Start the day'), findsNothing);
    await _tap(tester, 'Plan today');
    expect(find.text('add'), findsOneWidget);
  });

  testWidgets('Later closes it', (tester) async {
    await pumpWakeUp(tester);
    await _tap(tester, 'Later');
    expect(find.text('today'), findsOneWidget);
  });

  testWidgets('meets a11y guidelines (R-12)', (tester) async {
    final handle = tester.ensureSemantics();
    await pumpWakeUp(tester);
    await expectA11yGuidelines(tester);
    handle.dispose();
  });

  group('opens by itself', () {
    testWidgets('on the first open after Wake Up, once', (tester) async {
      final h = await pumpWakeUp(tester, location: '/today');
      expect(find.text('Good morning. Wednesday, October 21.'), findsOneWidget);
      await _tap(tester, 'Later');
      expect(find.text('today'), findsOneWidget);
      expect(h.days[_date]?.cardShownAtUtc, isNotNull);
    });

    testWidgets('never for anyone who has not said yes to Wake Up', (
      tester,
    ) async {
      await pumpWakeUp(
        tester,
        location: '/today',
        settings: wakeUpOn.copyWith(wakeUpAlarm: false),
      );
      expect(find.text('today'), findsOneWidget);
    });

    testWidgets("minimal: only after I'm up", (tester) async {
      final minimal = wakeUpOn.copyWith(uiLayout: UiLayout.minimal);
      await pumpWakeUp(tester, location: '/today', settings: minimal);
      expect(find.text('today'), findsOneWidget);
      await pumpWakeUp(
        tester,
        location: '/today',
        settings: minimal,
        days: [
          WakeUpDay(
            date: _date,
            stoppedAtUtc: DateTime.utc(2026, 10, 21, 7, 10),
          ),
        ],
      );
      expect(find.text('Start the day'), findsOneWidget);
    });
  });
}
