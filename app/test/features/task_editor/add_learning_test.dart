import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest.dart' as tz_data;

import '../../support/learning_history.dart';
import '../../support/timeline_fakes.dart';
import 'add_harness.dart';

// Learning in Add (docs/09 M11.3, 11 C3): a title with four real runs
// pre-selects its usual length ("usually 1 h 20") and says when it tends
// to start; a typed length still wins.

/// The new row (the history's rows share the title).
Occurrence _added(FakeOccurrenceRepository repo) => repo.rows.singleWhere(
  (o) => o.title == 'Write report' && o.actualStartUtc == null,
);

Future<void> _toWhen(WidgetTester tester, String text) async {
  await tester.enterText(addTitle, text);
  await tester.pump();
  await tester.tap(find.text('Continue'));
  await tester.pumpAndSettle();
}

void main() {
  setUpAll(tz_data.initializeTimeZones);

  testWidgets('the usual length is pre-selected and saved', (tester) async {
    final repo = await pumpAddHost(
      tester,
      rows: [...demoTimed(), ...writeReportHistory()],
      size: const Size(390, 1400),
    );
    await _toWhen(tester, 'Write report');
    expect(find.text('usually 1 h 20'), findsOneWidget);
    expect(find.text('usually starts ~15 min after plan'), findsOneWidget);
    await tester.tap(find.text('Add'));
    await tester.pumpAndSettle();
    expect(_added(repo).durationMin, 80);
  });

  testWidgets('docs/13 §6: explained on tap; in the sheet, reset asks once', (
    tester,
  ) async {
    await pumpAddHost(
      tester,
      rows: [...demoTimed(), ...writeReportHistory()],
      size: const Size(390, 1400),
    );
    await _toWhen(tester, 'Write report');
    await tester.tap(find.text('usually starts ~15 min after plan'));
    await tester.pumpAndSettle();
    expect(find.text('based on your last 4 times · median'), findsOneWidget);
    await tester.tap(find.text('usually 1 h 20'));
    await tester.pumpAndSettle();
    expect(find.text('based on your last 4 times · median'), findsNWidgets(2));
    // A snackbar would sit under the sheet: ask inline instead.
    await tester.tap(find.text('Reset for this task on this device').last);
    await tester.pumpAndSettle();
    expect(
      find.text('Forget what Write report taught, on this device?'),
      findsOneWidget,
    );
    await tester.tap(find.text('Keep'));
    await tester.pumpAndSettle();
    expect(find.text('usually 1 h 20'), findsOneWidget, reason: 'kept');
    await tester.tap(find.text('Reset for this task on this device').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Reset'));
    await tester.pumpAndSettle();
    expect(find.text('usually 1 h 20'), findsNothing);
    expect(find.text('usually starts ~15 min after plan'), findsNothing);
  });

  testWidgets('a typed length wins over the usual one', (tester) async {
    final repo = await pumpAddHost(
      tester,
      rows: [...demoTimed(), ...writeReportHistory()],
      size: const Size(390, 1400),
    );
    await _toWhen(tester, 'Write report 45m');
    expect(find.text('usually 1 h 20'), findsOneWidget);
    await tester.tap(find.text('Add'));
    await tester.pumpAndSettle();
    expect(_added(repo).durationMin, 45);
  });

  testWidgets('no history: nothing is said', (tester) async {
    await pumpAddHost(tester, size: const Size(390, 1400));
    await _toWhen(tester, 'Write report');
    expect(find.textContaining('usually'), findsNothing);
    expect(find.textContaining('you tend to start'), findsNothing);
  });

  test('history fixture really ran', () {
    expect(writeReportHistory().every((o) => o.actualEndUtc != null), isTrue);
    expect(demoDayRows(DateTime(2026, 10, 21)), isNotEmpty);
  });
}
