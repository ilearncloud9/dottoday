import 'package:dottoday/features/inbox/inbox_sidebar.dart';
import 'package:dottoday/features/timeline/today_screen.dart';
import 'package:dottoday/shared/dot/inbox_row.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest.dart' as tz_data;

import '../../support/a11y.dart';
import '../../support/inbox_harness.dart';
import '../../support/timeline_fakes.dart';

// The Mac/web Inbox and its sidebar (docs/09 M3e.2, `A-mac-inbox`).
// 11:00 in Berlin on the demo day; tests run on Android, so Ctrl.
const _wide = Size(1280, 900);

DateTime? _start(FakeOccurrenceRepository repo, String title) =>
    repo.rows.singleWhere((o) => o.title == title).startUtc;

/// Titles of the Inbox rows, top to bottom.
List<String> _order(WidgetTester tester) {
  final rows = tester.widgetList<InboxRow>(find.byType(InboxRow)).toList()
    ..sort(
      (a, b) => tester
          .getTopLeft(find.byWidget(a))
          .dy
          .compareTo(tester.getTopLeft(find.byWidget(b)).dy),
    );
  return [for (final r in rows) r.title];
}

Future<void> _mouseDrag(WidgetTester tester, Finder from, Finder to) async {
  final g = await tester.startGesture(
    tester.getCenter(from),
    kind: PointerDeviceKind.mouse,
  );
  await g.moveBy(const Offset(0, 20));
  await tester.pump();
  await g.moveTo(tester.getCenter(to));
  await tester.pump();
  await g.up();
  await tester.pumpAndSettle();
}

void main() {
  setUpAll(tz_data.initializeTimeZones);

  testWidgets('where each task fits, beside Drop onto today', (tester) async {
    await pumpInbox(tester, size: _wide);
    expect(find.text('Drop onto today'), findsOneWidget);
    expect(find.text('Fits today 11:15 AM'), findsOneWidget);
    expect(find.text('Fits Thu 7:00 AM'), findsOneWidget);
    expect(find.textContaining('Call Mum fits'), findsWidgets);
    expect(find.text('Sort: added'), findsOneWidget);
    expect(find.textContaining('Auto-plan the week'), findsOneWidget);
  });

  testWidgets('keyboard only: Tab to a row, Ctrl+Enter places it', (
    tester,
  ) async {
    final repo = await pumpInbox(tester, size: _wide);
    bool onCallMum() {
      final ctx = FocusManager.instance.primaryFocus?.context;
      final row = ctx?.findAncestorWidgetOfExactType<InboxRow>();
      return row?.title == 'Call Mum';
    }

    for (var i = 0; i < 40 && !onCallMum(); i++) {
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
    }
    expect(onCallMum(), isTrue, reason: 'Tab reaches the row');
    await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
    await tester.pumpAndSettle();
    expect(_start(repo, 'Call Mum'), DateTime.utc(2026, 10, 21, 9, 15));
    expect(find.textContaining('Call Mum'), findsWidgets);
  });

  testWidgets('Sort: duration puts the shortest first', (tester) async {
    await pumpInbox(tester, size: _wide);
    await tester.tap(find.text('Sort: added'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('duration'));
    await tester.pumpAndSettle();
    expect(find.text('Sort: duration'), findsOneWidget);
    expect(_order(tester).first, 'Call Mum');
    expect(_order(tester).last, 'Build new app');
  });

  testWidgets('Ctrl+Shift+P plans the week in one Undo', (tester) async {
    final repo = await pumpInbox(tester, size: _wide);
    await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
    await tester.sendKeyDownEvent(LogicalKeyboardKey.shiftLeft);
    await tester.sendKeyEvent(LogicalKeyboardKey.keyP);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.shiftLeft);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
    await tester.pumpAndSettle();
    expect(find.text('5 tasks planned this week'), findsOneWidget);
    for (final t in ['Go for a run', 'Call Mum', 'Do taxes', 'Book flights']) {
      expect(_start(repo, t), isNotNull, reason: t);
    }
    await tester.tap(find.text('Undo'));
    await tester.pumpAndSettle();
    expect(_start(repo, 'Call Mum'), isNull);
    expect(_start(repo, 'Build new app'), isNull);
  });

  testWidgets('a row dragged onto a gap of today is placed there', (
    tester,
  ) async {
    final repo = await pumpInbox(tester, size: _wide);
    await _mouseDrag(
      tester,
      find.text('Book flights'),
      find.textContaining('Call Mum fits').first,
    );
    expect(find.textContaining('Book flights'), findsWidgets);
    expect(_start(repo, 'Book flights')!.day, 21);
  });

  testWidgets('Today gets the Inbox sidebar; a row drops onto a day', (
    tester,
  ) async {
    final repo = await pumpInbox(
      tester,
      size: _wide,
      home: const InboxSidebarFrame(child: TodayScreen()),
    );
    expect(find.text('5 unscheduled'), findsOneWidget);
    await _mouseDrag(
      tester,
      find.text('Book flights'),
      find.text('drop here to plan'),
    );
    expect(_start(repo, 'Book flights')!.day, 22);
  });

  testWidgets('no sidebar below the expanded width', (tester) async {
    await pumpInbox(
      tester,
      size: const Size(800, 900),
      home: const InboxSidebarFrame(child: TodayScreen()),
    );
    expect(find.text('5 unscheduled'), findsNothing);
  });

  testWidgets('meets a11y guidelines in both themes', (tester) async {
    for (final mode in [ThemeMode.light, ThemeMode.dark]) {
      await pumpInbox(tester, size: _wide, mode: mode);
      await expectA11yGuidelines(tester);
    }
  });
}
