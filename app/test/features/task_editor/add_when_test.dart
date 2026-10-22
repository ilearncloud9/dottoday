import 'package:dottoday/shared/dot/thread_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest.dart' as tz_data;

import '../../support/a11y.dart';
import 'add_harness.dart';

Future<void> _toWhen(WidgetTester tester, String text) async {
  await tester.enterText(addTitle, text);
  await tester.pump();
  await tester.tap(find.text('Continue'));
  await tester.pumpAndSettle();
}

void main() {
  setUpAll(tz_data.initializeTimeZones);

  testWidgets('a typed time: the window sits on it and warns of overlap', (
    tester,
  ) async {
    final repo = await pumpAddHost(tester);
    await _toWhen(tester, 'Go shopping 5pm 1h');
    expect(find.text('5:00 PM – 6:00 PM'), findsOneWidget); // the pill
    expect(find.text('Today · 5:00 PM – 6:00 PM · 1 h'), findsOneWidget);
    expect(find.text('Overlaps Gym · you can still add it'), findsOneWidget);
    await tester.tap(find.text('30'));
    await tester.pump();
    expect(find.text('Free until 5:30 PM · no overlap'), findsOneWidget);
    expect(
      find.textContaining('the slot is free', findRichText: true),
      findsOneWidget,
    );
    await tester.tap(find.text('Add'));
    await tester.pumpAndSettle();
    final o = addedRow(repo, 'Go shopping')!;
    expect(o.startUtc, DateTime.utc(2026, 10, 21, 15));
    expect(o.durationMin, 30);
  });

  testWidgets('no time typed: starts in the first free slot', (tester) async {
    await pumpAddHost(tester);
    await _toWhen(tester, 'Plan trip');
    // Design review ends 11:15, email 11:30–12:00, Lunch 12:30: the first
    // 30 free minutes from 11:00 are 12:00–12:30.
    expect(find.text('12:00 PM – 12:30 PM'), findsOneWidget);
    expect(find.text('Free until 12:30 PM · no overlap'), findsOneWidget);
  });

  testWidgets('keyboard: arrows move the start by the snap step', (
    tester,
  ) async {
    final repo = await pumpAddHost(tester);
    await _toWhen(tester, 'Swim 4pm 30m');
    await tester.tap(find.byType(ThreadPicker));
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.pump();
    expect(find.text('4:10 PM – 4:40 PM'), findsOneWidget);
    await tester.sendKeyEvent(LogicalKeyboardKey.pageUp);
    await tester.pump();
    expect(find.text('3:10 PM – 3:40 PM'), findsOneWidget);
    await tester.tap(find.text('Add'));
    await tester.pumpAndSettle();
    expect(
      addedRow(repo, 'Swim')!.startUtc,
      DateTime.utc(2026, 10, 21, 13, 10),
    );
  });

  testWidgets('dragging the slice picks a later time', (tester) async {
    await pumpAddHost(tester);
    await _toWhen(tester, 'Swim 4pm 30m');
    // 42 pt per hour: dragging up by 42 pt (past the touch slop) is one
    // hour later.
    await tester.drag(
      find.byType(ThreadPicker),
      const Offset(0, -(42 + kDragSlopDefault)),
    );
    await tester.pumpAndSettle();
    expect(find.text('5:00 PM – 5:30 PM'), findsOneWidget);
  });

  testWidgets('screen reader: increase / decrease step the start', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await pumpAddHost(tester);
    await _toWhen(tester, 'Swim 4pm 30m');
    final picker = find.bySemanticsLabel('Start time');
    expect(
      tester.getSemantics(picker),
      matchesSemantics(
        label: 'Start time',
        value: '4:00 PM – 4:30 PM',
        increasedValue: '4:05 PM – 4:35 PM',
        decreasedValue: '3:55 PM – 4:25 PM',
        isSlider: true,
        hasIncreaseAction: true,
        hasDecreaseAction: true,
        isFocusable: true,
        hasTapAction: true,
        hasFocusAction: true,
      ),
    );
    tester.semantics.increase(find.semantics.byLabel('Start time'));
    await tester.pump();
    expect(find.text('4:05 PM – 4:35 PM'), findsOneWidget);
    handle.dispose();
  });

  testWidgets('Add another keeps the sheet and starts at the last end', (
    tester,
  ) async {
    final repo = await pumpAddHost(tester);
    await _toWhen(tester, 'Pack 8pm 30m');
    await tester.tap(find.text('Add another'));
    await tester.pumpAndSettle();
    expect(addedRow(repo, 'Pack'), isNotNull);
    expect(find.text('Continue'), findsOneWidget);
    expect(find.text('Pack added for 8:00 PM'), findsOneWidget);
    await _toWhen(tester, 'Shower');
    expect(find.text('8:30 PM – 9:00 PM'), findsOneWidget);
  });

  testWidgets('Back returns to What with the title kept', (tester) async {
    await pumpAddHost(tester);
    await _toWhen(tester, 'Pack 8pm');
    await tester.tap(find.text('Back'));
    await tester.pumpAndSettle();
    expect(find.widgetWithText(TextField, 'Pack 8pm'), findsOneWidget);
  });

  for (final mode in [ThemeMode.light, ThemeMode.dark]) {
    for (final (name, size) in [
      ('compact', const Size(390, 844)),
      ('expanded', const Size(1280, 800)),
    ]) {
      testWidgets('A2 a11y ${mode.name} $name', (tester) async {
        await pumpAddHost(tester, size: size, mode: mode);
        await _toWhen(tester, 'Go shopping 5pm 1h');
        await expectA11yGuidelines(tester);
      });
    }
  }

  testWidgets('A2 at 200 % text: nothing overflows', (tester) async {
    await pumpAddHost(tester, textScale: 2);
    await _toWhen(tester, 'Go shopping 5pm 1h');
    expect(tester.takeException(), isNull);
    expect(find.text('Add another'), findsOneWidget);
  });
}
