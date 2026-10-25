import 'package:dottoday/core/clock/minute_tick.dart';
import 'package:dottoday/data/export/export_providers.dart';
import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:dottoday/domain/entities/settings.dart';
import 'package:dottoday/domain/writes/write_batch.dart';
import 'package:dottoday/features/proposals/proposal_host.dart';
import 'package:dottoday/features/timeline/review/week_review_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest.dart' as tz_data;

import '../../domain/fixtures.dart';
import '../../support/a11y.dart';
import '../../support/export_fakes.dart';
import '../../support/proposal_harness.dart';
import '../../support/test_app.dart';
import '../../support/timeline_fakes.dart';
import '../../support/week_review_fixtures.dart';

// The weekly review (docs/09 M12.1, 11 D1, `B-ios-week-review`) over a
// real database and write path: the counts and chips, a day's thread,
// "Place" proposes and writes nothing before Accept, "Leave in Inbox"
// writes with Undo, and the share image goes to the OS sheet only on tap.

Future<(ProposalHarness, FakeFileGateway)> _pump(WidgetTester tester) async {
  tester.view
    ..physicalSize = const Size(390, 2400)
    ..devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  final profile = testProfile(
    settings: const Settings(use24h: false, firstDayOfWeek: 7),
  );
  final h = ProposalHarness(reviewNow, profile: profile);
  final files = FakeFileGateway();
  addTearDown(() => h.dispose(tester));
  await h.seed(
    tester,
    WriteBatch(
      userId: userId,
      profile: profile,
      series: [seriesFixture()],
      occurrences: weekReviewRows(),
    ),
  );
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        ...h.overrides,
        fileGatewayProvider.overrideWithValue(files),
        minuteTickProvider.overrideWith((ref) => const Stream.empty()),
      ],
      child: testApp(
        Scaffold(
          body: ProposalHost(
            child: SingleChildScrollView(
              child: WeekReviewBody(today: DateTime(2026, 10, 25)),
            ),
          ),
        ),
      ),
    ),
  );
  await _settle(tester);
  return (h, files);
}

Future<void> _settle(WidgetTester tester) async {
  for (var i = 0; i < 8; i++) {
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 80)),
    );
    await tester.pump();
  }
  await tester.pumpAndSettle();
}

Future<void> _unmount(WidgetTester tester) => tester.runAsync(() async {
  await tester.pumpWidget(const SizedBox());
  await Future<void>.delayed(const Duration(milliseconds: 50));
});

Future<List<int?>> _starts(WidgetTester tester, ProposalHarness h) async {
  final rows = (await tester.runAsync(
    () => h.base.db.select(h.base.db.occurrences).get(),
  ))!;
  return [
    for (final id in ['wk-2-4', 'wk-4-5', 'wk-6-1'])
      rows.firstWhere((r) => r.id == id).startUtc,
  ];
}

void main() {
  setUpAll(tz_data.initializeTimeZones);

  testWidgets('the week in seven dots, its counts and its sentence', (
    tester,
  ) async {
    await _pump(tester);
    expect(find.text('October 18 – October 24'), findsOneWidget);
    expect(find.text('29 of 34 done'), findsOneWidget);
    expect(find.text('Busiest · Thu'), findsOneWidget);
    expect(find.text('Lightest · Sat'), findsOneWidget);
    expect(find.text('5/7'), findsOneWidget);
    expect(
      find.text(
        'Mornings mostly went to plan. '
        'Thursday carried the most; Saturday breathed.',
      ),
      findsOneWidget,
    );
    expect(find.text('3 unfinished · move them to next week?'), findsOne);
    expect(find.text('No streaks here — just what happened.'), findsOne);
    expect(
      find.bySemanticsLabel(
        'Thursday, October 22: 5 of 7 done, 7 h 35 planned',
      ),
      findsOneWidget,
    );
    await _unmount(tester);
  });

  testWidgets('tapping a day shows its thread; again closes it', (
    tester,
  ) async {
    await _pump(tester);
    await tester.tap(find.text('5/7'));
    await tester.pumpAndSettle();
    expect(find.text('Task 5.1'), findsOneWidget);
    expect(find.text('7 h 35 · busiest'), findsOneWidget);
    expect(find.text('+4 more'), findsOneWidget);
    await tester.tap(find.text('5/7'));
    await tester.pumpAndSettle();
    expect(find.text('Task 5.1'), findsNothing);
    await _unmount(tester);
  });

  testWidgets('Place proposes next week; nothing is written before Accept', (
    tester,
  ) async {
    final (h, _) = await _pump(tester);
    final before = await _starts(tester, h);
    await expectNothingWrittenBeforeAccept(
      tester,
      h,
      open: () async {
        await tester.tap(find.text('Place'));
        await _settle(tester);
        expect(find.text('Next week'), findsOneWidget);
      },
      edit: () => tester.tap(find.byTooltip('Keep Task 7.2 as it is')),
      leave: () => tester.tap(find.text('Discard')),
    );
    expect(await _starts(tester, h), before);
    await _unmount(tester);
  });

  testWidgets('Accept places them in one batch, after now', (tester) async {
    final (h, _) = await _pump(tester);
    await tester.tap(find.text('Place'));
    await _settle(tester);
    final batches = h.writes.batches.length;
    final accept = find.text('Place them');
    await tester.ensureVisible(accept);
    await tester.runAsync(() async {
      await tester.tap(accept);
      await Future<void>.delayed(const Duration(milliseconds: 300));
    });
    await _settle(tester);
    expect(h.writes.batches.length, batches + 1);
    final moved = h.writes.batches.last.occurrences;
    expect(moved.map((o) => o.id), ['wk-2-4', 'wk-4-5', 'wk-6-1']);
    for (final Occurrence o in moved) {
      expect(o.startUtc!.isAfter(reviewNow), isTrue, reason: o.id);
    }
    await _unmount(tester);
  });

  testWidgets('Leave in Inbox sends the three one-offs there, with Undo', (
    tester,
  ) async {
    final (h, _) = await _pump(tester);
    // The write runs on the real database: tap with real time passing.
    await tester.runAsync(() async {
      await tester.tap(find.text('Leave in Inbox'));
      await Future<void>.delayed(const Duration(milliseconds: 300));
    });
    await _settle(tester);
    expect(await _starts(tester, h), [null, null, null]);
    expect(find.text('Undo'), findsOneWidget);
    await _unmount(tester);
  });

  testWidgets('Share image hands a PNG over only on tap; titles start off', (
    tester,
  ) async {
    final (_, files) = await _pump(tester);
    expect(files.images, isEmpty);
    expect(find.text('Thu · Task 5.1, Task 5.2'), findsNothing);
    final share = find.text('Share image');
    await tester.ensureVisible(share);
    await tester.runAsync(() async {
      await tester.tap(share);
      await Future<void>.delayed(const Duration(milliseconds: 300));
    });
    await tester.pumpAndSettle();
    final png = files.images['dottoday-week-2026-10-18.png']!;
    expect(png.sublist(1, 4), 'PNG'.codeUnits);
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
