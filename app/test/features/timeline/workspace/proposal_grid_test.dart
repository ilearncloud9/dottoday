@Tags(['golden'])
library;

import 'package:dottoday/app_screens.dart';
import 'package:dottoday/core/editing/active_proposal.dart';
import 'package:dottoday/core/router/app_router.dart';
import 'package:dottoday/data/tips/siri_tip_due.dart';
import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:dottoday/domain/proposals/proposal.dart';
import 'package:dottoday/domain/snapshot/day_snapshot.dart';
import 'package:dottoday/features/timeline/week/week_day_column.dart';
import 'package:dottoday/shared/proposals/proposal_sheet.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:timezone/data/latest.dart' as tz_data;

import '../../../support/a11y.dart';
import '../../../support/test_app.dart';
import '../../../support/timeline_fakes.dart';

/// The proposal beside the day (E-R2-3 1c, 2c; M19.3 part 3d): while a
/// proposal is open beside the Workspace, the tasks it would add or move
/// show dashed on the hour grid where they would land, on every Workspace
/// (owner). Nothing is written before Accept.
final _day = DateTime(2026, 10, 21);

/// Two new tasks on Wed 21 Oct (Berlin): Email Sam 12:00, Taxes 13:15.
Proposal _brainDump(List<Occurrence> rows) {
  Occurrence task(String id, String title, int hourUtc, int minute, int len) =>
      rows.first.copyWith(
        id: '01928c3e-0000-7000-8000-00000000f$id',
        title: title,
        startUtc: DateTime.utc(2026, 10, 21, hourUtc, minute),
        durationMin: len,
        colorKey: 'teal',
        iconKey: 'mail',
      );
  final email = task('001', 'Email Sam', 10, 0, 30);
  final taxes = task('002', 'Taxes', 11, 15, 45);
  return Proposal(
    userId: rows.first.userId,
    before: DaySnapshot(
      generatedAtUtc: DateTime.utc(2026, 10, 21, 8),
      wakeUtc: DateTime.utc(2026, 10, 21, 5),
      bedUtc: DateTime.utc(2026, 10, 21, 20),
      dots: const [],
      inboxCount: 0,
      dayDone: 0,
      dayTotal: 0,
    ),
    edits: [
      for (final (i, o) in [email, taxes].indexed)
        ProposalEdit(
          id: 'e$i',
          change: ProposalChange.added,
          after: SnapshotDot.fromOccurrence(o),
          occurrences: [o],
        ),
    ],
  );
}

Future<(FakeOccurrenceRepository, ProviderContainer)> _pump(
  WidgetTester tester, {
  ThemeMode mode = ThemeMode.light,
  Size size = const Size(1180, 820),
}) async {
  tester.view
    ..physicalSize = size
    ..devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  final repo = FakeOccurrenceRepository(demoDayRows(_day));
  final router = buildRouter(appScreens);
  addTearDown(router.dispose);
  await tester.pumpWidget(
    testRouterApp(
      router,
      themeMode: mode,
      overrides: [
        ...timelineOverrides(
          now: DateTime.utc(2026, 10, 21, 8),
          occurrences: repo,
        ),
        siriTipDueProvider.overrideWith((ref) => Stream.value(false)),
      ],
    ),
  );
  await tester.pumpAndSettle();
  router.go('/week/2026-10-21');
  await tester.pumpAndSettle();
  final container = ProviderScope.containerOf(
    tester.element(find.byType(WeekDayColumn).first),
  );
  container
      .read(activeProposalProvider.notifier)
      .open(
        ProposalRequest(
          proposal: _brainDump(repo.rows),
          title: 'Brain dump',
          acceptedMessage: 'Added',
        ),
      );
  await tester.pumpAndSettle();
  return (repo, container);
}

Finder _onGrid(String text) =>
    find.descendant(of: find.byType(WeekDayColumn), matching: find.text(text));

Future<void> _on(TargetPlatform p, Future<void> Function() body) async {
  debugDefaultTargetPlatformOverride = p;
  debugDisableShadows = false;
  try {
    await body();
  } finally {
    debugDefaultTargetPlatformOverride = null;
    debugDisableShadows = true;
  }
}

void main() {
  setUpAll(tz_data.initializeTimeZones);
  setUpAll(loadAppFonts);

  for (final p in [TargetPlatform.iOS, TargetPlatform.android]) {
    testWidgets('${p.name}: the panel beside, dashed "new" blocks', (
      tester,
    ) async {
      await _on(p, () async {
        final (repo, container) = await _pump(tester);
        final before = repo.rows.length;
        expect(find.byType(ProposalSheet), findsOneWidget);
        expect(_onGrid('Email Sam'), findsOneWidget);
        expect(_onGrid('Taxes'), findsOneWidget);
        expect(_onGrid('new'), findsNWidgets(2));
        expect(repo.rows, hasLength(before), reason: 'nothing before Accept');
        await expectA11yGuidelines(tester);
        // Discard: the blocks go with the proposal, nothing written.
        await tester.tap(find.text('Discard'));
        await tester.pumpAndSettle();
        expect(_onGrid('Email Sam'), findsNothing);
        expect(repo.rows, hasLength(before));
        expect(container.read(activeProposalProvider), isNull);
      });
    });
  }

  testWidgets('the Mac Workspace shows them too (owner, M19.3 part 3d)', (
    tester,
  ) async {
    await _on(TargetPlatform.macOS, () async {
      await _pump(tester, size: const Size(1280, 800));
      expect(_onGrid('Email Sam'), findsOneWidget);
    });
  });

  for (final mode in [ThemeMode.light, ThemeMode.dark]) {
    for (final p in [TargetPlatform.iOS, TargetPlatform.android]) {
      testWidgets('golden: proposal beside the day, ${p.name}, ${mode.name}', (
        tester,
      ) async {
        await _on(p, () async {
          await _pump(tester, mode: mode);
          await expectLater(
            find.byType(MaterialApp),
            matchesGoldenFile(
              'goldens/proposal_beside_${p.name}_${mode.name}.png',
            ),
          );
        });
      });
    }
  }
}
