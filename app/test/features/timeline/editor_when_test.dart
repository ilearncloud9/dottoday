import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:dottoday/shared/dot/month_cells.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest.dart' as tz_data;

import '../../support/editor_harness.dart';
import '../../support/timeline_fakes.dart';

// The editor's WHEN (docs/09 M3f.4): Change day shows what is planned on
// each day; Time zone keeps the wall clock. Wed 21 Oct, 09:22 in Berlin.

late FakeOccurrenceRepository _repo;

Occurrence _deep() =>
    _repo.rows.firstWhere((o) => o.title == 'Deep work: roadmap');

Future<void> _pump(WidgetTester tester) async {
  _repo = FakeOccurrenceRepository(demoDayRows(DateTime(2026, 10, 21)));
  await pumpEditor(tester, id: _deep().id, repo: _repo);
}

CompactMonthCell _cell(WidgetTester tester, String date) => tester
    .widgetList<CompactMonthCell>(find.byType(CompactMonthCell))
    .firstWhere((c) => c.day.date == date);

void main() {
  setUpAll(tz_data.initializeTimeZones);

  testWidgets('Change day shows planned dots and keeps the time', (
    tester,
  ) async {
    await _pump(tester);
    final start = _deep().startUtc!;
    await tester.tap(inEditor(find.text('Wed, Oct 21')));
    await tester.pumpAndSettle();
    expect(_cell(tester, '21').day.planned, isNotEmpty);
    expect(_cell(tester, '23').day.planned, isEmpty);
    await tester.tap(find.byWidget(_cell(tester, '23')));
    await tester.pumpAndSettle();
    await tester.pump(const Duration(seconds: 1));
    expect(_deep().startUtc, start.add(const Duration(days: 2)));
    expect(_deep().moveCount, 0, reason: 'an edit is not a move (M10.7)');
  });

  testWidgets('Time zone keeps the wall clock and moves the instant', (
    tester,
  ) async {
    await _pump(tester);
    final start = _deep().startUtc!;
    await tester.tap(inEditor(find.text('Time zone · Berlin')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).last, 'new york');
    await tester.pumpAndSettle();
    await tester.tap(find.text('New York'));
    await tester.pumpAndSettle();
    await tester.pump(const Duration(seconds: 1));
    expect(_deep().tzId, 'America/New_York');
    // Berlin is UTC+2 and New York UTC−4 on 21 Oct: the same 9:00 is 6 h
    // later.
    expect(_deep().startUtc, start.add(const Duration(hours: 6)));
    expect(inEditor(find.text('Time zone · New York')), findsOneWidget);
  });
}
