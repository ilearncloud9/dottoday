import 'package:dottoday/core/editing/pending_brain_dump.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest.dart' as tz_data;

import '../../support/a11y.dart';
import 'add_harness.dart';

const _list = '- Milk\n- Eggs 7pm 15m\n\n- Call Mum tomorrow';

void main() {
  setUpAll(tz_data.initializeTimeZones);

  // Minimal's Add (docs/14 §3 B4): a list goes to Brain dump's proposal,
  // nothing written before Accept. Full adds it at once: the popover
  // (add_popover_test) and Create task (create_task_test).
  testWidgets('a pasted list asks "Add 3 tasks?"; Brain dump plans it', (
    tester,
  ) async {
    final repo = await pumpAddHost(tester);
    final before = repo.rows.length;
    await tester.enterText(addTitle, _list);
    await tester.pump();
    expect(find.text('Add 3 tasks?'), findsOneWidget);
    // The footer waits for the answer.
    final add = tester.widget<FilledButton>(
      find.ancestor(
        of: find.text('Add').last,
        matching: find.byType(FilledButton),
      ),
    );
    expect(add.onPressed, isNull);
    final container = ProviderScope.containerOf(
      tester.element(find.text('open')),
    );
    await tester.tap(find.text('Add 3'));
    await tester.pumpAndSettle();
    expect(container.read(pendingBrainDumpProvider), _list);
    expect(repo.rows, hasLength(before), reason: 'nothing before Accept');
    expect(find.text('More'), findsNothing, reason: 'Add closed');
  });

  testWidgets('"Keep as one" joins the list into one title', (tester) async {
    await pumpAddHost(tester);
    await tester.enterText(addTitle, 'Milk\nEggs');
    await tester.pump();
    await tester.tap(find.text('Keep as one'));
    await tester.pump();
    expect(find.text('Add 2 tasks?'), findsNothing);
    expect(find.widgetWithText(TextField, 'Milk Eggs'), findsOneWidget);
  });

  testWidgets('Shift+Enter adds and starts the next on the same sheet', (
    tester,
  ) async {
    final repo = await pumpAddHost(tester);
    await tester.enterText(addTitle, 'Pack 8pm 30m');
    await tester.pump();
    await tester.sendKeyDownEvent(LogicalKeyboardKey.shift);
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.shift);
    await tester.pumpAndSettle();
    expect(addedRow(repo, 'Pack'), isNotNull);
    expect(find.text('More'), findsOneWidget);
    expect(find.widgetWithText(TextField, 'Pack 8pm 30m'), findsNothing);
    await tester.enterText(addTitle, 'Shower');
    await tester.pump();
    await tester.tap(find.text('More'));
    await tester.pumpAndSettle();
    expect(find.text('8:30 PM – 9:00 PM'), findsOneWidget);
  });

  testWidgets('"add here": Add opens at the gap\'s time (R-17)', (
    tester,
  ) async {
    await pumpAddHost(tester, startUtc: DateTime.utc(2026, 10, 21, 10, 2));
    await tester.enterText(addTitle, 'Stretch');
    await tester.pump();
    await tester.tap(find.text('More'));
    await tester.pumpAndSettle();
    // 12:02 Berlin, rounded up to the 5-min grid.
    expect(find.text('12:05 PM – 12:35 PM'), findsOneWidget);
  });

  testWidgets('a time typed after "add here" wins over the gap', (
    tester,
  ) async {
    await pumpAddHost(tester, startUtc: DateTime.utc(2026, 10, 21, 6, 15));
    await tester.enterText(addTitle, 'Go shopping 5pm tomorrow');
    await tester.pump();
    await tester.tap(find.text('More'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Tomorrow · 5:00 PM'), findsOneWidget);
  });

  testWidgets('"Add to this day": Add opens on that day', (tester) async {
    await pumpAddHost(tester, day: DateTime(2026, 10, 24));
    await tester.enterText(addTitle, 'Hike');
    await tester.pump();
    await tester.tap(find.text('More'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Sat, Oct 24 ·'), findsOneWidget);
  });

  for (final mode in [ThemeMode.light, ThemeMode.dark]) {
    for (final (name, size) in [
      ('compact', const Size(390, 844)),
      ('expanded', const Size(1280, 800)),
    ]) {
      testWidgets('paste confirm a11y ${mode.name} $name', (tester) async {
        await pumpAddHost(tester, size: size, mode: mode);
        await tester.enterText(addTitle, _list);
        await tester.pump();
        await expectA11yGuidelines(tester);
      });
    }
  }
}
