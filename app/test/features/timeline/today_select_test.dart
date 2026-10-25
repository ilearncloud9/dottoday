import 'package:dottoday/data/trash/trash_providers.dart';
import 'package:dottoday/domain/entities/enums.dart';
import 'package:dottoday/features/timeline/today_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest.dart' as tz_data;

import '../../support/timeline_fakes.dart';
import '../../support/today_harness.dart';

void main() {
  setUpAll(tz_data.initializeTimeZones);

  group('multi-select (R-05)', () {
    Future<void> pick(WidgetTester tester, List<String> titles) async {
      await tester.longPress(find.text(titles.first));
      await tester.pumpAndSettle();
      for (final t in titles.skip(1)) {
        await tester.tap(find.text(t));
        await tester.pumpAndSettle();
      }
    }

    testWidgets('long-press, then tap others; the count is announced', (
      tester,
    ) async {
      final said = <String>[];
      tester.binding.defaultBinaryMessenger
          .setMockDecodedMessageHandler<dynamic>(SystemChannels.accessibility, (
            message,
          ) async {
            final event = message as Map;
            if (event['type'] == 'announce') {
              said.add((event['data'] as Map)['message'] as String);
            }
          });
      addTearDown(
        () => tester.binding.defaultBinaryMessenger
            .setMockDecodedMessageHandler<dynamic>(
              SystemChannels.accessibility,
              null,
            ),
      );
      await pumpToday(tester, size: const Size(390, 1400));
      await pick(tester, ['Team standup', 'Design review']);
      expect(find.text('2 selected'), findsOneWidget);
      expect(said, ['1 selected', '2 selected']);
      await tester.tap(find.byTooltip('Done selecting'));
      await tester.pumpAndSettle();
      expect(find.text('2 selected'), findsNothing);
    });

    testWidgets('Save as routine keeps order, lengths and gaps (M11.4)', (
      tester,
    ) async {
      await pumpToday(tester, size: const Size(700, 1400));
      await pick(tester, ['Team standup', 'Design review']);
      await tester.tap(find.text('Save as routine'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'Office morning');
      await tester.pump();
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();
      expect(find.text('Saved “Office morning” as a routine'), findsOneWidget);
      final undo =
          ProviderScope.containerOf(
                tester.element(find.byType(TodayScreen)),
              ).read(undoServiceProvider)
              as FakeUndoService;
      final routine = undo.applied.last.routines.single;
      expect(routine.title, 'Office morning');
      // Standup 8:00 (15 min), Design review 10:30 (45 min), Berlin.
      expect(routine.items.map((i) => i.title), [
        'Team standup',
        'Design review',
      ]);
      expect(routine.items.map((i) => i.offsetMin), [0, 150]);
      expect(routine.items.map((i) => i.durationMin), [15, 45]);
      expect(routine.anchor, RoutineAnchor.time);
      expect(routine.anchorMinute, 8 * 60);
      expect(find.text('2 selected'), findsNothing);
    });

    testWidgets('Duplicate copies them, with Undo', (tester) async {
      final repo = FakeOccurrenceRepository(demoDayRows(todayTestDate));
      await pumpToday(tester, repo: repo, size: const Size(390, 1400));
      final before = repo.rows.length;
      await pick(tester, ['Team standup', 'Design review']);
      await tester.tap(find.text('Duplicate'));
      await tester.pumpAndSettle();
      expect(find.text('2 tasks duplicated'), findsOneWidget);
      expect(repo.rows.length, before + 2);
      expect(find.text('2 selected'), findsNothing);
      await tester.tap(find.text('Undo'));
      await tester.pumpAndSettle();
      expect(repo.rows.where((o) => o.deletedAt == null), hasLength(before));
    });

    testWidgets('Colour recolours them all', (tester) async {
      final repo = FakeOccurrenceRepository(demoDayRows(todayTestDate));
      await pumpToday(tester, repo: repo, size: const Size(390, 1400));
      await pick(tester, ['Team standup', 'Design review']);
      await tester.tap(find.text('Colour'));
      await tester.pumpAndSettle();
      await tester.tap(find.bySemanticsLabel('Mint'));
      await tester.pumpAndSettle();
      expect(find.text('2 tasks recoloured'), findsOneWidget);
      final picked = repo.rows.where(
        (o) => o.title == 'Team standup' || o.title == 'Design review',
      );
      expect(picked.map((o) => o.colorKey).toSet(), {'mint'});
    });

    testWidgets('Delete asks first, then goes to Trash with Undo', (
      tester,
    ) async {
      await pumpToday(tester, size: const Size(390, 1400));
      await pick(tester, ['Team standup', 'Design review']);
      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();
      expect(find.text('Delete 2 tasks?'), findsOneWidget);
      await tester.tap(find.widgetWithText(FilledButton, 'Delete'));
      await tester.pumpAndSettle();
      expect(find.text('2 tasks moved to Trash'), findsOneWidget);
      expect(find.text('Design review'), findsNothing);
      await tester.tap(find.text('Undo'));
      await tester.pumpAndSettle();
      expect(find.text('Design review'), findsOneWidget);
    });

    testWidgets('Move puts them on the picked day', (tester) async {
      final repo = FakeOccurrenceRepository(demoDayRows(todayTestDate));
      await pumpToday(tester, repo: repo, size: const Size(390, 1400));
      await pick(tester, ['Team standup', 'Design review']);
      await tester.tap(find.text('Move'));
      await tester.pumpAndSettle();
      await tester.tap(
        find.bySemanticsLabel(RegExp('^Friday, October 23')).last,
      );
      await tester.pumpAndSettle();
      expect(find.text('2 tasks moved to Friday, October 23'), findsOneWidget);
      final standup = repo.rows.singleWhere((o) => o.title == 'Team standup');
      expect(standup.startUtc, DateTime.utc(2026, 10, 23, 6));
    });

    testWidgets('Back ends selecting first', (tester) async {
      await pumpToday(tester, size: const Size(390, 1400));
      await pick(tester, ['Team standup']);
      final popped = await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(popped, isTrue);
      expect(find.text('1 selected'), findsNothing);
      expect(find.byType(TodayScreen), findsOneWidget);
    });
  });
}
