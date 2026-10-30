import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest.dart' as tz_data;

import '../../support/timeline_fakes.dart';
import '../../support/today_harness.dart';

// Unstick on Today (docs/09 M10.7, 11 B3): a task moved three times with
// no steps asks under its title; the answer becomes step 1 (with Undo),
// the count starts over, and the question goes away. Two moves: nothing.

void main() {
  setUpAll(tz_data.initializeTimeZones);

  Future<FakeOccurrenceRepository> pump(WidgetTester tester, int moves) async {
    final rows = [
      for (final o in demoDayRows(todayTestDate))
        o.title == 'Spanish lesson' ? o.copyWith(moveCount: moves) : o,
    ];
    final repo = FakeOccurrenceRepository(rows);
    await pumpToday(tester, repo: repo, size: const Size(390, 2400));
    return repo;
  }

  testWidgets('three moves, no steps: it asks; the answer is step 1', (
    tester,
  ) async {
    final repo = await pump(tester, 3);
    final prompt = find.text(
      "What's the very first thing you'd physically do?",
    );
    expect(prompt, findsOneWidget);
    await tester.ensureVisible(find.byType(TextField).last);
    await tester.enterText(find.byType(TextField).last, 'Open the textbook');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();
    expect(find.text('Step 1 added to Spanish lesson'), findsOneWidget);
    expect(
      repo.rows.firstWhere((o) => o.title == 'Spanish lesson').moveCount,
      0,
    );
    expect(prompt, findsNothing);
  });

  testWidgets('two moves: never asks yet', (tester) async {
    await pump(tester, 2);
    expect(
      find.text("What's the very first thing you'd physically do?"),
      findsNothing,
    );
  });
}
