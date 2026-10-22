import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:dottoday/shared/dot/colour_icon_block.dart';
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
      find.semantics.byLabel('Go for a run, 1 h'),
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

  testWidgets('dragging the handle reorders', (tester) async {
    final repo = await pumpInbox(tester);
    final handle = find.bySemanticsLabel('Reorder Go for a run');
    final g = await tester.startGesture(tester.getCenter(handle));
    await tester.pump(const Duration(milliseconds: 50));
    for (var i = 0; i < 10; i++) {
      await g.moveBy(const Offset(0, 20));
      await tester.pump();
    }
    await g.up();
    await tester.pumpAndSettle();
    expect(_stored(repo).indexOf('Go for a run'), greaterThan(0));
  });

  testWidgets('no handles while a filter is on', (tester) async {
    await pumpInbox(tester);
    expect(find.bySemanticsLabel(RegExp('^Reorder ')), findsWidgets);
    await tester.tap(find.text('Under 30 min'));
    await tester.pumpAndSettle();
    expect(find.bySemanticsLabel(RegExp('^Reorder ')), findsNothing);
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
    expect(find.bySemanticsLabel(RegExp('^Reorder ')), findsNothing);
    return repo;
  }

  testWidgets('select two, Colour them, with Undo', (tester) async {
    final repo = await pickTwo(tester);
    await tester.tap(find.text('Colour'));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(ColourDot).first);
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
