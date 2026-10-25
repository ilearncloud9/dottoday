import 'package:dottoday/domain/entities/enums.dart';
import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:dottoday/domain/entities/settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest.dart' as tz_data;

import '../../support/timeline_fakes.dart';
import '../../support/today_harness.dart';

// The Running late sheet, the Day review at Bedtime and the running-late
// nudge (docs/09 M3f.5, R-04). The demo day in Berlin: Deep work 9–11
// (live at 9:22), Reply to email 11:00, Lunch with Sam 12:30 (pinned).

late FakeOccurrenceRepository _repo;

Occurrence _row(String title) => _repo.rows.firstWhere((o) => o.title == title);

Future<void> _pump(
  WidgetTester tester, {
  DateTime? at,
  Settings settings = const Settings(use24h: false),
}) async {
  _repo = FakeOccurrenceRepository(demoDayRows(todayTestDate));
  await pumpToday(
    tester,
    repo: _repo,
    settings: settings,
    ticks: at == null ? null : Stream.value(at),
  );
}

Future<void> _openSheet(WidgetTester tester) async {
  await tester.tap(find.byTooltip('More options'));
  await tester.pumpAndSettle();
  await tester.tap(find.text('Running late…'));
  await tester.pumpAndSettle();
}

void main() {
  setUpAll(tz_data.initializeTimeZones);

  group('Running late sheet', () {
    testWidgets('the preview names the pin that stops the shift', (
      tester,
    ) async {
      await _pump(tester);
      final lunch = _row('Lunch with Sam').startUtc;
      final mail = _row('Reply to email').startUtc!;
      await _openSheet(tester);
      expect(
        find.textContaining('Lunch with Sam stays put'),
        findsOneWidget,
        reason: 'partial before anything moves (R-17)',
      );
      await tester.tap(find.text('Shift the rest').last);
      await tester.pumpAndSettle();
      expect(find.textContaining('Lunch with Sam stays put'), findsOneWidget);
      expect(_row('Lunch with Sam').startUtc, lunch);
      expect(
        _row('Reply to email').startUtc,
        mail.add(const Duration(minutes: 15)),
      );
      // Running late is a move for what it shifts; the pin stays at 0.
      expect(_row('Reply to email').moveCount, 1);
      expect(_row('Lunch with Sam').moveCount, 0);
    });

    testWidgets('Skip skips the live task only, with Undo', (tester) async {
      await _pump(tester);
      final mail = _row('Reply to email').startUtc;
      await _openSheet(tester);
      await tester.tap(find.text('Skip “Deep work: roadmap”'));
      await tester.pumpAndSettle();
      expect(_row('Deep work: roadmap').status, OccurrenceStatus.skipped);
      expect(
        _row('Reply to email').startUtc,
        mail,
        reason: 'nothing else moves',
      );
      await tester.tap(find.text('Undo'));
      await tester.pumpAndSettle();
      expect(_row('Deep work: roadmap').status, OccurrenceStatus.planned);
    });

    testWidgets('Shorten +30 starts it later and keeps its end', (
      tester,
    ) async {
      await _pump(tester);
      await _openSheet(tester);
      await tester.tap(find.widgetWithText(ChoiceChip, '+30 min'));
      await tester.pumpAndSettle();
      expect(
        find.text('Starts 30 min later, still ends at 11:00 AM'),
        findsOneWidget,
      );
      await tester.tap(find.text('Shorten “Deep work: roadmap”'));
      await tester.pumpAndSettle();
      final deep = _row('Deep work: roadmap');
      expect(deep.startUtc, DateTime.utc(2026, 10, 21, 7, 30));
      expect(deep.endUtc, DateTime.utc(2026, 10, 21, 9));
    });
  });

  group('Day review at Bedtime', () {
    // 23:30 in Berlin, after the default Bedtime.
    final bedtime = DateTime.utc(2026, 10, 21, 21, 30);

    testWidgets('sends the rest to the Inbox by default, with Undo', (
      tester,
    ) async {
      await _pump(tester, at: bedtime);
      expect(find.text('DAY REVIEW'), findsOneWidget);
      expect(find.text('Send the rest to the Inbox?'), findsOneWidget);
      await tester.tap(find.textContaining('to Inbox'));
      await tester.pumpAndSettle();
      expect(_row('Reply to email').startUtc, isNull);
      expect(find.textContaining('sent to the Inbox'), findsOneWidget);
      expect(find.text('DAY REVIEW'), findsNothing);
    });

    testWidgets('moves the rest to tomorrow when Roll is on', (tester) async {
      await _pump(
        tester,
        at: bedtime,
        settings: const Settings(use24h: false, rollUnfinished: true),
      );
      final mail = _row('Reply to email').startUtc!;
      await tester.tap(find.textContaining('to tomorrow').last);
      await tester.pumpAndSettle();
      expect(
        _row('Reply to email').startUtc,
        mail.add(const Duration(days: 1)),
      );
    });

    testWidgets('Not now puts it away; not shown before Bedtime', (
      tester,
    ) async {
      await _pump(tester, at: bedtime);
      await tester.tap(find.text('Not now'));
      await tester.pumpAndSettle();
      expect(find.text('DAY REVIEW'), findsNothing);
      await _pump(tester);
      expect(find.text('DAY REVIEW'), findsNothing);
    });
  });

  group('running-late nudge', () {
    // 11:45 in Berlin: Design review ended 30 min ago unticked.
    final late = DateTime.utc(2026, 10, 21, 9, 45);

    testWidgets('offers to catch up', (tester) async {
      await _pump(tester, at: late);
      expect(find.text('NEED MORE TIME?'), findsOneWidget);
      expect(find.text('“Design review” ended 30 min ago'), findsOneWidget);
      await tester.tap(find.text('Catch up'));
      await tester.pumpAndSettle();
      expect(find.text('Shift the rest'), findsWidgets);
    });

    testWidgets('stays away when the setting is off', (tester) async {
      await _pump(
        tester,
        at: late,
        settings: const Settings(use24h: false, runningLateNudge: false),
      );
      expect(find.text('NEED MORE TIME?'), findsNothing);
    });
  });

  testWidgets('sheet and prompt meet a11y guidelines (R-12)', (tester) async {
    final handle = tester.ensureSemantics();
    await _pump(tester, at: DateTime.utc(2026, 10, 21, 9, 45));
    await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
    await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
    await expectLater(tester, meetsGuideline(textContrastGuideline));
    await tester.tap(find.text('Catch up'));
    await tester.pumpAndSettle();
    await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
    await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
    await expectLater(tester, meetsGuideline(textContrastGuideline));
    handle.dispose();
  });
}
