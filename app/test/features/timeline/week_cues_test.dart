import 'package:dottoday/core/editing/focus_task.dart';
import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/domain/entities/settings.dart';
import 'package:dottoday/features/timeline/week/week_card.dart';
import 'package:dottoday/features/timeline/week_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest.dart' as tz_data;

import '../../support/timeline_fakes.dart';
import '../../support/week_cue_fixtures.dart';

// Smallest step and Unstick on the Week board (docs/09 M10.6, M10.7; the
// M10.7 follow-up): a card carries the cue as its last line; Smallest
// step's opens Focus, Unstick's asks in a sheet and the answer is step 1.

final _now = weekCueNow;
const _prompt = "What's the very first thing you'd physically do?";

Future<(FakeOccurrenceRepository, ProviderContainer)> _pump(
  WidgetTester tester, {
  int moves = 3,
  int minutes = 150,
}) async {
  tester.view
    ..physicalSize = const Size(1280, 1000)
    ..devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  final repo = FakeOccurrenceRepository([
    weekCueTask(21, 'Tax forms'),
    weekCueTask(22, 'Garage', moves: moves, minutes: minutes),
  ]);
  final steps = FakeSubtaskRepository(weekCueSteps());
  final container = ProviderContainer(
    overrides: timelineOverrides(
      now: _now,
      occurrences: repo,
      subtasks: steps,
      profile: testProfile(
        settings: const Settings(use24h: false, firstDayOfWeek: 7),
      ),
    ),
  );
  addTearDown(container.dispose);
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: MaterialApp(
        theme: DotTheme.light(),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const WeekScreen(),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return (repo, container);
}

void main() {
  setUpAll(tz_data.initializeTimeZones);

  testWidgets('Smallest step: the cue line opens Focus', (tester) async {
    final (_, container) = await _pump(tester);
    final cue = find.text('Just Gather documents · 10 min?');
    expect(cue, findsOneWidget);
    await tester.tap(cue);
    await tester.pumpAndSettle();
    expect(container.read(focusTaskProvider), 'cue-21');
  });

  testWidgets('Unstick: the cue asks in a sheet; the answer is step 1', (
    tester,
  ) async {
    final (repo, _) = await _pump(tester);
    await tester.tap(find.text(_prompt));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Open the door');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();
    expect(find.text('Step 1 added to Garage'), findsOneWidget);
    expect(repo.rows.firstWhere((o) => o.id == 'cue-22').moveCount, 0);
    expect(find.text(_prompt), findsNothing);
  });

  testWidgets('two moves: the card never asks', (tester) async {
    await _pump(tester, moves: 2);
    expect(find.text(_prompt), findsNothing);
  });

  testWidgets('a card too short for the line keeps the cue as an action', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    await _pump(tester, minutes: 45);
    expect(find.text(_prompt), findsNothing);
    final card = find.ancestor(
      of: find.text('Garage'),
      matching: find.byType(WeekCard),
    );
    final data = tester.getSemantics(card).getSemanticsData();
    expect(data.customSemanticsActionIds, isNotEmpty);
    semantics.dispose();
  });
}
