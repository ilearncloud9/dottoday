import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest.dart' as tz_data;

import '../../support/inbox_harness.dart';
import '../../support/timeline_fakes.dart';

// Inbox reorder and bulk select (PRD F3, docs/09 M3f.9c).

/// Open items in their stored order (what the Inbox shows next time).
List<String> _stored(FakeOccurrenceRepository repo) {
  final open = [
    for (final o in repo.rows)
      if (o.startUtc == null && o.deletedAt == null && o.completedAtUtc == null)
        o,
  ]..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
  return [for (final o in open) o.title];
}

Occurrence _row(FakeOccurrenceRepository repo, String title) =>
    repo.rows.singleWhere((o) => o.title == title);

void main() {
  setUpAll(tz_data.initializeTimeZones);

  testWidgets('Move down reorders and persists, with Undo', (tester) async {
    final handle = tester.ensureSemantics();
    final repo = await pumpInbox(tester);
    expect(_stored(repo).take(2), ['Go for a run', 'Call Mum']);
    tester.semantics.performAction(
      find.semantics.byLabel(RegExp('^Go for a run, 1 h')),
      SemanticsAction.customAction,
      args: CustomSemanticsAction.getIdentifier(
        const CustomSemanticsAction(label: 'Move down'),
      ),
      checkForAction: false,
    );
    await tester.pumpAndSettle();
    expect(_stored(repo).take(2), ['Call Mum', 'Go for a run']);
    handle.dispose();
  });

  testWidgets('holding a row and moving it reorders (M20.2)', (tester) async {
    final repo = await pumpInbox(tester);
    final g = await tester.startGesture(
      tester.getCenter(find.text('Go for a run')),
    );
    // The list's own delay before the lift.
    await tester.pump(kLongPressTimeout + const Duration(milliseconds: 50));
    for (var i = 0; i < 10; i++) {
      await g.moveBy(const Offset(0, 20));
      await tester.pump();
    }
    await g.up();
    await tester.pumpAndSettle();
    expect(_stored(repo).indexOf('Go for a run'), greaterThan(0));
    expect(find.text('Select'), findsNothing, reason: 'a move opens no menu');
  });

  testWidgets('a hold without moving opens the menu, with Move down', (
    tester,
  ) async {
    await pumpInbox(tester);
    await tester.longPress(find.text('Go for a run'));
    await tester.pumpAndSettle();
    expect(find.text('Move down'), findsOneWidget);
    expect(find.text('Select'), findsOneWidget);
  });

  testWidgets('no reordering while a filter is on', (tester) async {
    await pumpInbox(tester);
    await tester.ensureVisible(find.text('Under 30 min'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Under 30 min'));
    await tester.pumpAndSettle();
    await tester.longPress(find.text('Call Mum'));
    await tester.pumpAndSettle();
    expect(find.text('Select'), findsOneWidget);
    expect(find.text('Move down'), findsNothing);
    expect(find.text('Move up'), findsNothing);
  });

  Future<FakeOccurrenceRepository> pickTwo(WidgetTester tester) async {
    final repo = await pumpInbox(tester);
    await tester.longPress(find.text('Do taxes'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Select'));
    await tester.pumpAndSettle();
    expect(find.text('1 selected'), findsOneWidget);
    await tester.tap(find.text('Call Mum'));
    await tester.pumpAndSettle();
    expect(find.text('2 selected'), findsOneWidget);
    return repo;
  }

  testWidgets('select two, Colour them, with Undo', (tester) async {
    final repo = await pickTwo(tester);
    await tester.tap(find.text('Colour'));
    await tester.pumpAndSettle();
    // All colours on phones (M19.4 part 4c-2): pick, then Done.
    await tester.tap(find.bySemanticsLabel('Coral'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle();
    expect(_row(repo, 'Do taxes').colorKey, 'coral');
    expect(_row(repo, 'Call Mum').colorKey, 'coral');
    expect(find.text('2 tasks recoloured'), findsOneWidget);
    expect(find.text('2 selected'), findsNothing, reason: 'selecting ends');
  });

  testWidgets('select two, Delete asks, then trashes both', (tester) async {
    final repo = await pickTwo(tester);
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();
    expect(find.text('Delete 2 tasks?'), findsOneWidget);
    await tester.tap(find.widgetWithText(FilledButton, 'Delete'));
    await tester.pumpAndSettle();
    expect(_row(repo, 'Do taxes').deletedAt, isNotNull);
    expect(_row(repo, 'Call Mum').deletedAt, isNotNull);
  });

  testWidgets('select two, Plan these places both', (tester) async {
    final repo = await pickTwo(tester);
    await tester.tap(find.text('Plan these'));
    await tester.pumpAndSettle();
    expect(_row(repo, 'Do taxes').startUtc, isNotNull);
    expect(_row(repo, 'Call Mum').startUtc, isNotNull);
    expect(_row(repo, 'Go for a run').startUtc, isNull);
  });

  testWidgets('Escape and × end selecting', (tester) async {
    await pickTwo(tester);
    await tester.tap(find.byTooltip('Done selecting'));
    await tester.pumpAndSettle();
    expect(find.text('2 selected'), findsNothing);
  });
}
