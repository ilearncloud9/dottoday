import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest.dart' as tz_data;

import '../../support/a11y.dart';
import 'add_harness.dart';

const _list = '- Milk\n- Eggs 7pm 15m\n\n- Call Mum tomorrow';

void main() {
  setUpAll(tz_data.initializeTimeZones);

  testWidgets('a pasted list asks "Add 3 tasks?" and adds them (R-07)', (
    tester,
  ) async {
    final repo = await pumpAddHost(tester);
    await tester.enterText(addTitle, _list);
    await tester.pump();
    expect(find.text('Add 3 tasks?'), findsOneWidget);
    // The footer waits for the answer.
    final cont = tester.widget<FilledButton>(
      find.ancestor(
        of: find.text('Continue'),
        matching: find.byType(FilledButton),
      ),
    );
    expect(cont.onPressed, isNull);
    await tester.tap(find.text('Add 3'));
    await tester.pumpAndSettle();
    expect(addedRow(repo, 'Milk')!.isInbox, isTrue);
    expect(addedRow(repo, 'Eggs')!.startUtc, DateTime.utc(2026, 10, 21, 17));
    expect(
      addedRow(repo, 'Call Mum')!.startUtc,
      isNull, // tomorrow, no time: the inbox
    );
    expect(find.text('3 tasks added'), findsOneWidget);
    expect(find.text('Continue'), findsNothing);
  });

  testWidgets('Enter confirms the list; "Keep as one" joins it', (
    tester,
  ) async {
    final repo = await pumpAddHost(tester);
    await tester.enterText(addTitle, 'Milk\nEggs');
    await tester.pump();
    await tester.tap(find.text('Keep as one'));
    await tester.pump();
    expect(find.text('Add 2 tasks?'), findsNothing);
    expect(find.widgetWithText(TextField, 'Milk Eggs'), findsOneWidget);
    await tester.enterText(addTitle, 'Bread\nButter');
    await tester.pump();
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();
    expect(addedRow(repo, 'Bread'), isNotNull);
    expect(addedRow(repo, 'Butter'), isNotNull);
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
    expect(find.text('Continue'), findsOneWidget);
    expect(find.widgetWithText(TextField, 'Pack 8pm 30m'), findsNothing);
    await tester.enterText(addTitle, 'Shower');
    await tester.pump();
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
    expect(find.text('8:30 PM – 9:00 PM'), findsOneWidget);
  });

  testWidgets('"add here": Add opens at the gap\'s time (R-17)', (
    tester,
  ) async {
    await pumpAddHost(tester, startUtc: DateTime.utc(2026, 10, 21, 10, 2));
    await tester.enterText(addTitle, 'Stretch');
    await tester.pump();
    await tester.tap(find.text('Continue'));
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
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Tomorrow · 5:00 PM'), findsOneWidget);
  });

  testWidgets('"Add to this day": Add opens on that day', (tester) async {
    await pumpAddHost(tester, day: DateTime(2026, 10, 24));
    await tester.enterText(addTitle, 'Hike');
    await tester.pump();
    await tester.tap(find.text('Continue'));
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
