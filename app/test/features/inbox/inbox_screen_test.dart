import 'package:dottoday/domain/entities/enums.dart';
import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:dottoday/shared/dot/thread_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest.dart' as tz_data;

import '../../support/a11y.dart';
import '../../support/inbox_harness.dart';
import '../../support/sample_inbox.dart';
import '../../support/timeline_fakes.dart';

Future<FakeOccurrenceRepository> _pump(
  WidgetTester tester, {
  List<Occurrence>? inbox,
  Size size = const Size(390, 1200),
  ThemeMode mode = ThemeMode.light,
}) => pumpInbox(tester, inbox: inbox, size: size, mode: mode);

Occurrence _row(FakeOccurrenceRepository repo, String title) =>
    repo.rows.singleWhere((o) => o.title == title);

void main() {
  setUpAll(tz_data.initializeTimeZones);

  testWidgets('header, rows, next free slot and the completed group', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await _pump(tester);
    expect(find.text('Inbox'), findsOneWidget);
    expect(find.text('5 unscheduled · 5 h 30 of work'), findsOneWidget);
    expect(find.bySemanticsLabel('5 tasks in the Inbox'), findsOneWidget);
    expect(find.text('Go for a run'), findsOneWidget);
    expect(
      find.text('Next free slot today: 11:15 AM – 11:30 AM · fits Call Mum'),
      findsOneWidget,
    );
    expect(find.text('Completed · 2'), findsOneWidget);
    expect(find.text('Renew passport'), findsNothing);
    await tester.tap(find.text('Completed · 2'));
    await tester.pumpAndSettle();
    expect(find.text('Renew passport'), findsOneWidget);
    handle.dispose();
  });

  testWidgets('Completed group: not done and Clear, with Undo (M3f.6)', (
    tester,
  ) async {
    // Tall enough that Clear sits above the first Undo snackbar.
    final repo = await _pump(tester, size: const Size(390, 2000));
    await tester.tap(find.text('Completed · 2'));
    await tester.pumpAndSettle();
    expect(find.text('Done Wed, Oct 21'), findsNWidgets(2));
    await tester.tap(find.byTooltip('Mark “Renew passport” not done'));
    await tester.pumpAndSettle();
    expect(_row(repo, 'Renew passport').status, OccurrenceStatus.planned);
    expect(find.text('“Renew passport” is back in the Inbox'), findsOneWidget);
    expect(find.text('Completed · 1'), findsOneWidget);
    await tester.tap(find.text('Clear completed'));
    await tester.pumpAndSettle();
    expect(_row(repo, 'Buy stamps').deletedAt, isNotNull);
    expect(find.text('1 completed task moved to Trash'), findsOneWidget);
    await tester.tap(find.text('Undo'));
    await tester.pumpAndSettle();
    expect(_row(repo, 'Buy stamps').deletedAt, isNull);
  });

  testWidgets('empty: "Inbox is clear"', (tester) async {
    await _pump(tester, inbox: const []);
    expect(find.text('Inbox is clear'), findsOneWidget);
  });

  testWidgets('filters: Under 30 min, Fits today', (tester) async {
    await _pump(tester);
    await tester.tap(find.text('Under 30 min'));
    await tester.pumpAndSettle();
    expect(find.text('Call Mum'), findsOneWidget);
    expect(find.text('Go for a run'), findsNothing);
    await tester.tap(find.text('Fits today'));
    await tester.pumpAndSettle();
    // No two free hours are left today; 90 minutes still fit.
    expect(find.text('Do taxes'), findsOneWidget);
    expect(find.text('Build new app'), findsNothing);
  });

  testWidgets('quick add: no time → Inbox; a time → the timeline', (
    tester,
  ) async {
    final repo = await _pump(tester);
    await tester.enterText(find.byType(TextField), 'Water plants 20m');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();
    expect(find.text('Water plants added to the Inbox'), findsOneWidget);
    expect(_row(repo, 'Water plants').durationMin, 20);
    expect(find.text('Water plants'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'Call Dad tomorrow 3pm');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();
    expect(find.text('Call Dad added for 3:00 PM'), findsOneWidget);
    expect(_row(repo, 'Call Dad').startUtc, DateTime.utc(2026, 10, 22, 13));
  });

  testWidgets('a pasted list asks first, like Add (M3c.5)', (tester) async {
    final repo = await _pump(tester);
    await tester.enterText(find.byType(TextField), 'Milk\nEggs');
    await tester.pump();
    expect(find.text('Add 2 tasks?'), findsOneWidget);
    await tester.tap(find.text('Add 2'));
    await tester.pumpAndSettle();
    expect(find.text('2 tasks added'), findsOneWidget);
    expect(
      repo.rows.where((o) => ['Milk', 'Eggs'].contains(o.title)),
      hasLength(2),
    );
  });

  testWidgets('a pasted list adds one task per line (R-07)', (tester) async {
    final repo = await _pump(tester);
    await tester.enterText(find.byType(TextField), '- Milk\n- Eggs\n- Bread');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();
    expect(find.text('3 tasks added'), findsOneWidget);
    expect(
      repo.rows.where((o) => ['Milk', 'Eggs', 'Bread'].contains(o.title)),
      hasLength(3),
    );
  });

  testWidgets('+ offers free slots; picking one schedules it, with Undo', (
    tester,
  ) async {
    final repo = await _pump(tester);
    await tester.tap(find.byTooltip('Schedule').at(1)); // Call Mum
    await tester.pumpAndSettle();
    expect(find.text('Schedule Call Mum'), findsOneWidget);
    await tester.tap(find.textContaining('Tomorrow, '));
    await tester.pumpAndSettle();
    expect(find.textContaining('Call Mum scheduled for Tomorrow'), findsOne);
    expect(_row(repo, 'Call Mum').startUtc, isNotNull);
    expect(find.text('Call Mum'), findsNothing);
    await tester.tap(find.text('Undo'));
    await tester.pumpAndSettle();
    expect(find.text('Call Mum'), findsOneWidget);
  });

  testWidgets('"Pick a time…" places it anywhere on the thread (M3c.2)', (
    tester,
  ) async {
    final repo = await _pump(tester);
    await tester.tap(find.byTooltip('Schedule').at(1)); // Call Mum, 15 min
    await tester.pumpAndSettle();
    await tester.tap(find.text('Pick a time…'));
    await tester.pumpAndSettle();
    // Today's first free 15 minutes after 11:00: 11:15, after Design review.
    expect(find.text('11:15 AM – 11:30 AM'), findsOneWidget);
    expect(find.text('Free until 11:30 AM · no overlap'), findsOneWidget);
    await tester.tap(find.text('Tomorrow'));
    await tester.pumpAndSettle();
    expect(find.text('7:00 AM – 7:15 AM'), findsOneWidget);
    await tester.tap(find.byType(ThreadPicker));
    for (var i = 0; i < 3; i++) {
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    }
    await tester.pump();
    await tester.tap(
      find.descendant(
        of: find.byType(BottomSheet),
        matching: find.text('Place'),
      ),
    );
    await tester.pumpAndSettle();
    expect(_row(repo, 'Call Mum').startUtc, DateTime.utc(2026, 10, 22, 5, 15));
    expect(
      find.text('Call Mum scheduled for Tomorrow, 7:15 AM – 7:30 AM'),
      findsOneWidget,
    );
  });

  for (final mode in [ThemeMode.light, ThemeMode.dark]) {
    for (final (name, size) in [
      ('compact', const Size(390, 1200)),
      ('expanded', const Size(1280, 1000)),
    ]) {
      testWidgets('Pick a time a11y ${mode.name} $name', (tester) async {
        await _pump(tester, mode: mode, size: size);
        await tester.tap(find.byTooltip('Schedule').at(1));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Pick a time…'));
        await tester.pumpAndSettle();
        expect(find.byType(ThreadPicker), findsOneWidget);
        await expectA11yGuidelines(tester);
      });
    }
  }

  testWidgets('Place puts the fitting task in the next free slot', (
    tester,
  ) async {
    final repo = await _pump(tester);
    await tester.tap(find.text('Place'));
    await tester.pumpAndSettle();
    final placed = repo.rows.where(
      (o) => sampleInbox().any((s) => s.id == o.id) && o.startUtc != null,
    );
    expect(placed, hasLength(1));
    expect(placed.single.title, 'Call Mum');
    expect(placed.single.startUtc, DateTime.utc(2026, 10, 21, 9, 15));
  });

  testWidgets('swipes: toward the end trashes (Undo), toward the start '
      'schedules', (tester) async {
    final repo = await _pump(tester);
    await tester.drag(find.text('Do taxes'), const Offset(500, 0));
    await tester.pumpAndSettle();
    expect(find.text('Do taxes moved to Trash'), findsOneWidget);
    expect(_row(repo, 'Do taxes').deletedAt, isNotNull);
    await tester.drag(find.text('Book flights'), const Offset(-500, 0));
    await tester.pumpAndSettle();
    expect(find.text('Schedule Book flights'), findsOneWidget);
  });

  testWidgets('without swiping: screen-reader actions and a long-press menu '
      '(R-12)', (tester) async {
    final handle = tester.ensureSemantics();
    final repo = await _pump(tester);
    tester.semantics.performAction(
      find.semantics.byLabel('Do taxes, 1 h 30'),
      SemanticsAction.customAction,
      args: CustomSemanticsAction.getIdentifier(
        const CustomSemanticsAction(label: 'Move to Trash'),
      ),
      checkForAction: false,
    );
    await tester.pumpAndSettle();
    expect(_row(repo, 'Do taxes').deletedAt, isNotNull);

    await tester.longPress(find.text('Book flights'));
    await tester.pumpAndSettle();
    // The menu sits above the swipe hint's own "Move to Trash".
    await tester.tap(find.text('Move to Trash').last);
    await tester.pumpAndSettle();
    expect(_row(repo, 'Book flights').deletedAt, isNotNull);
    handle.dispose();
  });

  for (final mode in [ThemeMode.light, ThemeMode.dark]) {
    testWidgets('meets a11y guidelines (${mode.name})', (tester) async {
      await _pump(tester, mode: mode);
      await expectA11yGuidelines(tester);
    });
  }
}
