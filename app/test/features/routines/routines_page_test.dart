import 'package:dottoday/core/clock/minute_tick.dart';
import 'package:dottoday/core/editing/pending_routine_drop.dart';
import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:dottoday/domain/writes/write_batch.dart';
import 'package:dottoday/features/proposals/proposal_host.dart';
import 'package:dottoday/features/routines/routine_drop_host.dart';
import 'package:dottoday/features/routines/routines_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest.dart' as tz_data;

import '../../domain/fixtures.dart';
import '../../support/a11y.dart';
import '../../support/proposal_harness.dart';
import '../../support/rebalance_fixtures.dart';
import '../../support/routine_samples.dart';
import '../../support/test_app.dart';

// The Routines page (docs/09 M11.4, `B-ios-routines`) over a real
// database and write path: cards, a drop is a proposal and nothing is
// written before Accept, Accept writes one task per step with the first
// ringing loud, the week strip moves the drop to another day, and the
// editor saves a new routine.

Future<ProposalHarness> _pump(WidgetTester tester, {DateTime? dropOn}) async {
  tester.view
    ..physicalSize = const Size(390, 2000)
    ..devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  final h = ProposalHarness(rebalanceNow);
  addTearDown(() => h.dispose(tester));
  await h.seed(
    tester,
    WriteBatch(
      userId: userId,
      profile: profileFixture(),
      occurrences: rebalanceDayRows(),
      routines: sampleRoutines(),
    ),
  );
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        ...h.overrides,
        minuteTickProvider.overrideWith((ref) => const Stream.empty()),
      ],
      child: testApp(
        Scaffold(
          body: ProposalHost(child: RoutinesPage(dropOn: dropOn)),
        ),
      ),
    ),
  );
  await _settle(tester);
  return h;
}

/// Lets the database's queries run (real time) between frames.
Future<void> _settle(WidgetTester tester) async {
  for (var i = 0; i < 8; i++) {
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 80)),
    );
    await tester.pump();
  }
  await tester.pumpAndSettle();
}

/// Unmounts so drift's stream timers run for real, inside the test.
Future<void> _unmount(WidgetTester tester) => tester.runAsync(() async {
  await tester.pumpWidget(const SizedBox());
  await Future<void>.delayed(const Duration(milliseconds: 50));
});

/// Tasks the drop wrote (anything not seeded), in start order.
Future<List<Occurrence>> _gymTasks(
  WidgetTester tester,
  ProposalHarness h,
) async {
  final rows = (await tester.runAsync(
    () => h.base.db.select(h.base.db.occurrences).get(),
  ))!;
  final seeded = {for (final o in rebalanceDayRows()) o.id};
  return [
    for (final r in rows)
      if (!seeded.contains(r.id))
        Occurrence(
          id: r.id,
          userId: r.userId,
          title: r.title,
          startUtc: r.startUtc == null
              ? null
              : DateTime.fromMillisecondsSinceEpoch(r.startUtc!, isUtc: true),
          tzId: r.tzId,
          durationMin: r.durationMin,
          routineStart: r.routineStart,
          createdAt: t0,
          updatedAt: t0,
        ),
  ]..sort((a, b) => a.startUtc!.compareTo(b.startUtc!));
}

void main() {
  setUpAll(tz_data.initializeTimeZones);

  testWidgets('cards say what each routine is', (tester) async {
    await _pump(tester);
    expect(find.text('Morning'), findsOneWidget);
    expect(find.text('4 steps · 1 h 15 · starts at Wake Up'), findsOneWidget);
    expect(find.text('3 steps · 40 min · ends at Bedtime'), findsOneWidget);
    expect(find.text('3 steps · 1 h 15 · starts at 5:30 PM'), findsOneWidget);
    expect(find.text('Drop on today'), findsNWidgets(3));
    expect(find.text('Routine-start dots ring loud, like an alarm'), findsOne);
    await _unmount(tester);
  });

  testWidgets('a drop proposes; nothing is written before Accept', (
    tester,
  ) async {
    final h = await _pump(tester);
    await expectNothingWrittenBeforeAccept(
      tester,
      h,
      open: () async {
        await tester.tap(find.text('Drop on today').last);
        await _settle(tester);
        expect(find.text('Gym day on Today · from 5:30 PM'), findsOneWidget);
      },
      edit: () => tester.tap(find.byTooltip('Keep Protein as it is')),
      leave: () => tester.tap(find.text('Discard')),
    );
    expect(await _gymTasks(tester, h), isEmpty);
    await _unmount(tester);
  });

  testWidgets('Accept writes one task per step; the first rings loud', (
    tester,
  ) async {
    final h = await _pump(tester);
    await tester.tap(find.text('Drop on today').last);
    await _settle(tester);
    final before = h.writes.batches.length;
    final accept = find.text('Add to day');
    await tester.ensureVisible(accept);
    // The write runs on the real database: tap with real time passing.
    await tester.runAsync(() async {
      await tester.tap(accept);
      await Future<void>.delayed(const Duration(milliseconds: 300));
    });
    await _settle(tester);
    expect(h.writes.batches.length, before + 1, reason: 'one batch');
    final tasks = await _gymTasks(tester, h);
    expect(tasks.map((o) => o.title), ['Pack bag', 'Gym', 'Protein']);
    // 5:30 PM New York (EDT) is 21:30 UTC.
    expect(tasks.first.startUtc, DateTime.utc(2026, 10, 21, 21, 30));
    expect(tasks.map((o) => o.routineStart), [true, false, false]);
    expect(find.text('Routine added'), findsOneWidget);
    await _unmount(tester);
  });

  testWidgets('the week strip drops on another day', (tester) async {
    await _pump(tester);
    await tester.tap(find.text('22'));
    await _settle(tester);
    expect(find.text('Drop on Tomorrow'), findsNWidgets(3));
    await tester.tap(find.text('Drop on Tomorrow').first);
    await _settle(tester);
    expect(find.text('Morning on Tomorrow · from 7:00 AM'), findsOneWidget);
    await _unmount(tester);
  });

  testWidgets('New routine: name and a step, then Save', (tester) async {
    final h = await _pump(tester);
    await tester.tap(find.text('New routine'));
    await _settle(tester);
    expect(
      find.text('Give the routine a name and at least one step'),
      findsOne,
    );
    await tester.enterText(
      find.widgetWithText(TextField, 'Name'),
      'Lunch walk',
    );
    await tester.enterText(find.widgetWithText(TextField, 'Step name'), 'Walk');
    await tester.pump();
    await tester.runAsync(() async {
      await tester.tap(find.text('Save'));
      await Future<void>.delayed(const Duration(milliseconds: 300));
    });
    await _settle(tester);
    expect(find.text('Saved “Lunch walk” as a routine'), findsOneWidget);
    expect(find.text('Lunch walk'), findsOneWidget);
    expect(h.writes.batches.last.routines.single.items.single.title, 'Walk');
    await _unmount(tester);
  });

  testWidgets('a drop asked from Add opens the proposal (host)', (
    tester,
  ) async {
    final h = await _pump(tester);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          ...h.overrides,
          minuteTickProvider.overrideWith((ref) => const Stream.empty()),
        ],
        child: testApp(
          const Scaffold(
            body: ProposalHost(child: RoutineDropHost(child: SizedBox())),
          ),
        ),
      ),
    );
    final container = ProviderScope.containerOf(
      tester.element(find.byType(RoutineDropHost)),
    );
    await expectNothingWrittenBeforeAccept(
      tester,
      h,
      open: () async {
        container
            .read(pendingRoutineDropProvider.notifier)
            .request(
              RoutineDropRequest(
                routine: sampleRoutines().first,
                date: DateTime(2026, 10, 22),
                today: DateTime(2026, 10, 21),
              ),
            );
        await _settle(tester);
        expect(find.text('Morning on Tomorrow · from 7:00 AM'), findsOne);
      },
      leave: () => tester.tap(find.text('Discard')),
    );
    expect(container.read(pendingRoutineDropProvider), isNull);
    await _unmount(tester);
  });

  testWidgets('meets a11y guidelines (R-12)', (tester) async {
    final handle = tester.ensureSemantics();
    await _pump(tester);
    await expectA11yGuidelines(tester);
    handle.dispose();
    await _unmount(tester);
  });
}
