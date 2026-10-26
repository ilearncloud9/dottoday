import 'package:dottoday/domain/entities/enums.dart';
import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest.dart' as tz_data;

import '../../support/timeline_fakes.dart';
import 'add_harness.dart';

// Learning in Add (docs/09 M11.3, 11 C3): a title with four real runs
// pre-selects its usual length ("usually 1 h 20") and says when it tends
// to start; a typed length still wins.

/// "Write report" planned 9:00 for 60 min on 13–16 Oct, really started
/// 15 min after and took 80.
List<Occurrence> _history() => [
  for (var d = 13; d <= 16; d++)
    demoTimed().first.copyWith(
      id: '01928c3e-0000-7000-8000-0000000d00$d',
      title: 'Write report',
      seriesId: null,
      startUtc: DateTime.utc(2026, 10, d, 7),
      durationMin: 60,
      actualStartUtc: DateTime.utc(2026, 10, d, 7, 15),
      actualEndUtc: DateTime.utc(2026, 10, d, 8, 35),
      status: OccurrenceStatus.done,
    ),
];

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
      rows: [...demoTimed(), ..._history()],
      size: const Size(390, 1400),
    );
    await _toWhen(tester, 'Write report');
    expect(find.text('usually 1 h 20'), findsOneWidget);
    expect(
      find.text('you tend to start this ~15 min after plan'),
      findsOneWidget,
    );
    await tester.tap(find.text('Add'));
    await tester.pumpAndSettle();
    expect(_added(repo).durationMin, 80);
  });

  testWidgets('a typed length wins over the usual one', (tester) async {
    final repo = await pumpAddHost(
      tester,
      rows: [...demoTimed(), ..._history()],
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
    expect(_history().every((o) => o.actualEndUtc != null), isTrue);
    expect(demoDayRows(DateTime(2026, 10, 21)), isNotEmpty);
  });
}
