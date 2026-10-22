import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest.dart' as tz_data;

import '../../support/a11y.dart';
import 'add_harness.dart';

Future<void> _menu(WidgetTester tester, {String text = 'Pack 5pm 1h'}) async {
  await tester.enterText(addTitle, text);
  await tester.pump();
  await tester.tap(find.text('Continue'));
  await tester.pumpAndSettle();
  await tester.tap(find.byTooltip('More time options'));
  await tester.pumpAndSettle();
}

void main() {
  setUpAll(tz_data.initializeTimeZones);

  testWidgets('the six items, with the day and zone shown', (tester) async {
    await pumpAddHost(tester);
    await _menu(tester);
    for (final item in [
      'Change day',
      'Pick from the week',
      'Make it all-day',
      'Send to Inbox',
      'Time zone',
      'Type a time',
    ]) {
      expect(find.text(item), findsOneWidget);
    }
    expect(find.text('Berlin'), findsOneWidget);
    expect(find.widgetWithText(MenuItemButton, 'Today'), findsOneWidget);
  });

  testWidgets('Change day moves the task, keeping its time', (tester) async {
    final repo = await pumpAddHost(tester);
    await _menu(tester);
    await tester.tap(find.text('Change day'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('23'));
    await tester.pumpAndSettle();
    expect(find.text('Fri, Oct 23 · 5:00 PM – 6:00 PM · 1 h'), findsOneWidget);
    await tester.tap(find.text('Add'));
    await tester.pumpAndSettle();
    expect(addedRow(repo, 'Pack')!.startUtc, DateTime.utc(2026, 10, 23, 15));
  });

  testWidgets('Pick from the week', (tester) async {
    await pumpAddHost(tester);
    await _menu(tester);
    await tester.tap(find.text('Pick from the week'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('22'));
    await tester.pumpAndSettle();
    expect(find.text('Tomorrow · 5:00 PM – 6:00 PM · 1 h'), findsOneWidget);
  });

  testWidgets('Make it all-day: no picker, midnight for 24 h', (tester) async {
    final repo = await pumpAddHost(tester);
    await _menu(tester);
    await tester.tap(find.text('Make it all-day'));
    await tester.pumpAndSettle();
    expect(find.text('Today · All day'), findsOneWidget);
    expect(find.text('TIME'), findsOneWidget);
    expect(find.text('DURATION'), findsNothing);
    expect(find.textContaining('all day', findRichText: true), findsWidgets);
    await tester.tap(find.text('Add'));
    await tester.pumpAndSettle();
    final o = addedRow(repo, 'Pack')!;
    expect(o.startUtc, DateTime.utc(2026, 10, 20, 22));
    expect(o.durationMin, 1440);
  });

  testWidgets('Send to Inbox saves without a time and closes', (tester) async {
    final repo = await pumpAddHost(tester);
    await _menu(tester);
    await tester.tap(find.text('Send to Inbox'));
    await tester.pumpAndSettle();
    expect(addedRow(repo, 'Pack')!.isInbox, isTrue);
    expect(find.text('Add another'), findsNothing);
  });

  testWidgets('Time zone keeps the wall clock in the new zone', (tester) async {
    final repo = await pumpAddHost(tester);
    await _menu(tester);
    await tester.tap(find.text('Time zone'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).last, 'london');
    await tester.pump();
    await tester.tap(find.text('London'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Add'));
    await tester.pumpAndSettle();
    final o = addedRow(repo, 'Pack')!;
    expect(
      (o.tzId, o.startUtc),
      ('Europe/London', DateTime.utc(2026, 10, 21, 16)),
    );
  });

  testWidgets('Type a time (R-20): typed, never moves the day', (tester) async {
    await pumpAddHost(tester);
    await _menu(tester);
    await tester.tap(find.text('Type a time'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).last, '1830');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pump();
    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle();
    expect(find.text('Today · 6:30 PM – 7:30 PM · 1 h'), findsOneWidget);
  });

  testWidgets('keyboard: the menu opens and runs with keys', (tester) async {
    await pumpAddHost(tester);
    await tester.enterText(addTitle, 'Pack 5pm 1h');
    await tester.pump();
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
    final button = tester.widget<IconButton>(
      find.ancestor(
        of: find.byTooltip('More time options'),
        matching: find.byType(IconButton),
      ),
    );
    button.focusNode!.requestFocus();
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pumpAndSettle();
    expect(find.text('Change day'), findsOneWidget);
    // Change day has focus; down twice is "Make it all-day".
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pumpAndSettle();
    expect(find.text('Today · All day'), findsOneWidget);
  });

  testWidgets('Edit on the Lands-on row changes the day', (tester) async {
    await pumpAddHost(tester, size: const Size(390, 1100));
    await tester.enterText(addTitle, 'Pack 5pm');
    await tester.pump();
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Edit'));
    await tester.tap(find.text('Edit'));
    await tester.pumpAndSettle();
    expect(find.text('October 2026'), findsOneWidget);
  });

  for (final mode in [ThemeMode.light, ThemeMode.dark]) {
    for (final (name, size) in [
      ('compact', const Size(390, 844)),
      ('expanded', const Size(1280, 800)),
    ]) {
      testWidgets('A4 a11y ${mode.name} $name', (tester) async {
        await pumpAddHost(tester, size: size, mode: mode);
        await _menu(tester);
        await expectA11yGuidelines(tester);
      });
    }
  }
}
