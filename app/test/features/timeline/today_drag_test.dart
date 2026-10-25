import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/domain/entities/enums.dart';
import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:dottoday/domain/entities/settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest.dart' as tz_data;

import '../../support/timeline_fakes.dart';
import '../../support/today_harness.dart';

void main() {
  setUpAll(tz_data.initializeTimeZones);

  group('drag (R-05)', () {
    Future<TestGesture> lift(WidgetTester tester, String title) async {
      final g = await tester.startGesture(tester.getCenter(find.text(title)));
      await tester.pump(DotTouch.liftDelay + const Duration(milliseconds: 50));
      return g;
    }

    testWidgets('dropping on a free gap moves the task, with Undo', (
      tester,
    ) async {
      await pumpToday(tester, size: const Size(390, 1400));
      final g = await lift(tester, 'Team standup');
      await g.moveTo(tester.getCenter(find.text('45 min free')));
      await tester.pump();
      expect(find.textContaining('→ '), findsOneWidget);
      await g.up();
      await tester.pumpAndSettle();
      expect(find.textContaining('Team standup moved to'), findsOneWidget);
      expect(find.textContaining('8:15 AM – 8:30 AM'), findsOneWidget);
      await tester.tap(find.text('Undo'));
      await tester.pumpAndSettle();
      expect(find.textContaining('8:00 AM – 8:15 AM'), findsOneWidget);
    });

    testWidgets('with Shift later tasks on, the rest follows up to the pin '
        '(R-04, R-17)', (tester) async {
      await pumpToday(
        tester,
        size: const Size(390, 1400),
        settings: const Settings(
          use24h: false,
          firstDayOfWeek: 7,
          shiftFollowers: ShiftFollowersPolicy.always,
        ),
      );
      final g = await lift(tester, 'Team standup');
      expect(find.text('Shift later tasks'), findsOneWidget);
      await g.moveTo(tester.getCenter(find.text('45 min free')));
      await tester.pump();
      await g.up();
      await tester.pumpAndSettle();
      expect(
        find.textContaining('stopped at Lunch with Sam (pinned)'),
        findsOneWidget,
      );
      expect(find.text('9:00 AM – 11:00 AM · 2 h'), findsNothing);
      await tester.tap(find.text('Undo'));
      await tester.pumpAndSettle();
      expect(find.text('9:00 AM – 11:00 AM · 2 h'), findsOneWidget);
    });

    group('"Calendar events too" (M7.6)', () {
      // The demo's 9:00–11:00 block, imported from a calendar.
      final nineBerlin = DateTime.utc(2026, 10, 21, 7);
      List<Occurrence> rows() => [
        for (final o in demoDayRows(todayTestDate))
          o.startUtc == nineBerlin
              ? o.copyWith(source: OccurrenceSource.calendar)
              : o,
      ];
      const settings = Settings(
        use24h: false,
        firstDayOfWeek: 7,
        shiftFollowers: ShiftFollowersPolicy.always,
        includeCalendarInShift: true,
      );

      /// Drags the standup into the free time; returns whether the chip
      /// showed during the drag.
      Future<bool> dragStandup(WidgetTester tester) async {
        final g = await lift(tester, 'Team standup');
        await g.moveTo(tester.getCenter(find.text('45 min free')));
        await tester.pump();
        final chip = find.text('Calendar events too').evaluate().isNotEmpty;
        await g.up();
        await tester.pumpAndSettle();
        return chip;
      }

      testWidgets('a writable event moves with the rest', (tester) async {
        await pumpToday(
          tester,
          rows: rows(),
          size: const Size(390, 1400),
          settings: settings,
        );
        expect(await dragStandup(tester), isTrue);
        expect(find.text('9:00 AM – 11:00 AM · 2 h'), findsNothing);
      });

      testWidgets('a read-only or repeating one stays, and no chip shows', (
        tester,
      ) async {
        final day = rows();
        final event = day.firstWhere((o) => o.startUtc == nineBerlin);
        await pumpToday(
          tester,
          rows: day,
          size: const Size(390, 1400),
          settings: settings,
          readOnlyCalendarIds: {event.id},
        );
        expect(await dragStandup(tester), isFalse);
        expect(find.text('9:00 AM – 11:00 AM · 2 h'), findsOneWidget);
      });
    });

    testWidgets('dropping on a week-strip day keeps the time', (tester) async {
      final repo = FakeOccurrenceRepository(demoDayRows(todayTestDate));
      await pumpToday(tester, repo: repo, size: const Size(390, 1400));
      final g = await lift(tester, 'Team standup');
      await g.moveTo(tester.getCenter(find.text('Thu')));
      await tester.pump();
      await g.up();
      await tester.pumpAndSettle();
      expect(
        find.text('Team standup moved to Thursday, October 22'),
        findsOneWidget,
      );
      final moved = repo.rows.singleWhere((o) => o.title == 'Team standup');
      // 08:00 Berlin on Thursday 22 October.
      expect(moved.startUtc, DateTime.utc(2026, 10, 22, 6));
    });

    testWidgets('the grip lengthens a task by the snap step', (tester) async {
      final handle = tester.ensureSemantics();
      await pumpToday(tester, size: const Size(390, 1400));
      tester.semantics.increase(
        find.semantics.byLabel('Change how long Team standup takes'),
      );
      await tester.pumpAndSettle();
      expect(find.text('Team standup now ends at 8:20 AM'), findsOneWidget);
      handle.dispose();
    });
  });
}
