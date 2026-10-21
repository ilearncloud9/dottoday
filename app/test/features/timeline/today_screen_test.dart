import 'dart:async';

import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/domain/entities/enums.dart';
import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:dottoday/domain/entities/settings.dart';
import 'package:dottoday/features/timeline/today_screen.dart';
import 'package:dottoday/features/timeline/widgets/today_week_strip.dart';
import 'package:dottoday/shared/dot/day_card.dart';
import 'package:dottoday/shared/dot/month_grid.dart';
import 'package:dottoday/shared/dot/week_strip.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest.dart' as tz_data;

import '../../support/a11y.dart';
import '../../support/timeline_fakes.dart';

final _date = DateTime(2026, 10, 21);

/// 09:22 in Berlin: Deep work (9:00–11:00) is live.
final _now = DateTime.utc(2026, 10, 21, 7, 22);

Future<void> _pump(
  WidgetTester tester, {
  List<Occurrence>? rows,
  FakeOccurrenceRepository? repo,
  Size size = const Size(390, 844),
  ThemeMode mode = ThemeMode.light,
  DateTime? date,
  String? name = 'Kody',
  int firstDayOfWeek = 7,
  Settings? settings,
  Stream<DateTime>? ticks,
}) async {
  tester.view
    ..physicalSize = size
    ..devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  final profile = testProfile(
    settings:
        settings ?? Settings(use24h: false, firstDayOfWeek: firstDayOfWeek),
  ).copyWith(displayName: name);
  await tester.pumpWidget(
    ProviderScope(
      overrides: timelineOverrides(
        now: _now,
        occurrences:
            repo ?? FakeOccurrenceRepository(rows ?? demoDayRows(_date)),
        profile: profile,
        minuteTicks: ticks,
      ),
      child: MaterialApp(
        theme: DotTheme.light(),
        darkTheme: DotTheme.dark(),
        themeMode: mode,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: TodayScreen(date: date),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  setUpAll(tz_data.initializeTimeZones);

  testWidgets('opens on today: caption, greeting, day dot, today card', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await _pump(tester);
    expect(find.text('WED, OCT 21'), findsOneWidget);
    expect(find.text('Good morning, Kody'), findsOneWidget);
    expect(find.text('Wednesday · Today'), findsOneWidget);
    expect(
      find.bySemanticsLabel(RegExp(r'^Day \d+ % through$')),
      findsOneWidget,
    );
    expect(
      find.bySemanticsLabel(
        RegExp(r'Deep work: roadmap, live, \d+ minutes left'),
      ),
      findsOneWidget,
    );
    handle.dispose();
  });

  testWidgets('no name: plain greeting', (tester) async {
    await _pump(tester, name: null);
    expect(find.text('Good morning'), findsOneWidget);
  });

  testWidgets('the week starts on the profile setting', (tester) async {
    await _pump(tester, firstDayOfWeek: 1);
    final mon = tester.getCenter(find.text('Mon')).dx;
    final sun = tester.getCenter(find.text('Sun')).dx;
    expect(mon, lessThan(sun));
    expect(weekStart(DateTime(2026, 10, 21), 1), DateTime(2026, 10, 19));
    expect(weekStart(DateTime(2026, 10, 21), 7), DateTime(2026, 10, 18));
  });

  testWidgets('a strip tap pages to that day; the header follows', (
    tester,
  ) async {
    await _pump(tester);
    await tester.tap(find.text('Fri'));
    await tester.pumpAndSettle();
    expect(find.text('Friday'), findsWidgets);
    expect(find.text('FRI, OCT 23'), findsOneWidget);
  });

  testWidgets('swiping the pager changes the day', (tester) async {
    await _pump(tester);
    await tester.fling(find.byType(DayCard).at(1), const Offset(-300, 0), 1000);
    await tester.pumpAndSettle();
    expect(find.text('THU, OCT 22'), findsOneWidget);
  });

  testWidgets('/day/:date opens that day', (tester) async {
    await _pump(tester, date: DateTime(2026, 12, 14));
    expect(find.text('MON, DEC 14'), findsOneWidget);
    expect(find.text('Monday, December 14'), findsWidgets);
  });

  testWidgets('the caption chevron and the strip handle open the month', (
    tester,
  ) async {
    await _pump(tester);
    await tester.tap(find.text('WED, OCT 21'));
    await tester.pumpAndSettle();
    expect(find.byType(MonthGrid), findsOneWidget);
    expect(find.byType(WeekStrip), findsNothing);
    await tester.tap(find.bySemanticsLabel('Hide month').last);
    await tester.pumpAndSettle();
    expect(find.byType(MonthGrid), findsNothing);
    await tester.drag(find.byType(PullHandle), const Offset(0, 120));
    await tester.pumpAndSettle();
    expect(find.byType(MonthGrid), findsOneWidget);
  });

  testWidgets('month: data dots, footer, Today link; nav to another month', (
    tester,
  ) async {
    await _pump(tester, size: const Size(390, 1000));
    await tester.tap(find.text('WED, OCT 21'));
    await tester.pumpAndSettle();
    expect(find.text('October · 1 of 31 days planned'), findsOneWidget);
    expect(find.text('Sep · Oct · Nov'), findsOneWidget);
    expect(
      find.bySemanticsLabel(RegExp(r'^Wednesday, October 21, \d+ of 13 done$')),
      findsOneWidget,
    );
    await tester.tap(find.byTooltip('Next month'));
    await tester.pumpAndSettle();
    expect(find.text('November 2026'), findsOneWidget);
    expect(find.text('Oct · Nov · Dec'), findsOneWidget);
  });

  testWidgets('a future free day: Today pill and the empty-day actions', (
    tester,
  ) async {
    await _pump(
      tester,
      date: DateTime(2026, 12, 14),
      size: const Size(390, 1000),
    );
    expect(find.text('Today'), findsWidgets);
    expect(find.text('Add to this day'), findsWidgets);
    expect(find.text('Copy a day…'), findsWidgets);
    await tester.tap(find.widgetWithText(OutlinedButton, 'Today'));
    await tester.pumpAndSettle();
    expect(find.text('WED, OCT 21'), findsOneWidget);
  });

  testWidgets('Copy a day copies the picked day’s one-offs, with Undo', (
    tester,
  ) async {
    await _pump(
      tester,
      date: DateTime(2026, 10, 24),
      size: const Size(390, 1000),
    );
    final copy = find.text('Copy a day…').hitTestable();
    await tester.ensureVisible(copy.first);
    await tester.tap(copy.first);
    await tester.pumpAndSettle();
    expect(find.text('Copy which day?'), findsOneWidget);
    await tester.tap(
      find.descendant(of: find.byType(BottomSheet), matching: find.text('21')),
    );
    await tester.pumpAndSettle();
    expect(find.text('Copied 12 tasks'), findsOneWidget);
    expect(find.text('Morning run'), findsWidgets);
    await tester.tap(find.text('Undo'));
    await tester.pumpAndSettle();
    expect(find.text('Add to this day'), findsWidgets);
  });

  testWidgets('reduced motion: the month opens without animating', (
    tester,
  ) async {
    tester.platformDispatcher.accessibilityFeaturesTestValue =
        const FakeAccessibilityFeatures(disableAnimations: true);
    addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);
    await _pump(tester);
    await tester.tap(find.text('WED, OCT 21'));
    await tester.pump();
    await tester.pump();
    expect(find.byType(MonthGrid), findsOneWidget);
    // No AnimatedSize at all: a zero-duration one asserts during layout.
    expect(find.byType(AnimatedSize), findsNothing);
    expect(tester.takeException(), isNull);
  });

  group('done, live and shift (M3b.3)', () {
    testWidgets('a dot marks done with Undo', (tester) async {
      await _pump(tester);
      await tester.tap(find.bySemanticsLabel('Team standup, missed'));
      await tester.pumpAndSettle();
      expect(find.text('Team standup done'), findsOneWidget);
      expect(find.bySemanticsLabel('Team standup, done'), findsOneWidget);
      await tester.tap(find.text('Undo'));
      await tester.pumpAndSettle();
      expect(find.bySemanticsLabel('Team standup, missed'), findsOneWidget);
    });

    testWidgets('minutes left follow the minute tick', (tester) async {
      final ticks = StreamController<DateTime>();
      addTearDown(ticks.close);
      await _pump(tester, ticks: ticks.stream);
      ticks.add(_now);
      await tester.pumpAndSettle();
      expect(find.text('98 min left'), findsOneWidget);
      ticks.add(_now.add(const Duration(minutes: 1)));
      await tester.pumpAndSettle();
      expect(find.text('97 min left'), findsOneWidget);
    });

    testWidgets('+15 min extends the live task, with Undo', (tester) async {
      await _pump(tester, size: const Size(390, 1200));
      await tester.tap(find.text('+15 min'));
      await tester.pumpAndSettle();
      expect(
        find.text('Deep work: roadmap now ends at 11:15 AM'),
        findsOneWidget,
      );
      expect(find.text('9:00 AM – 11:15 AM · 2 h 15'), findsOneWidget);
      await tester.tap(find.text('Undo'));
      await tester.pumpAndSettle();
      expect(find.text('9:00 AM – 11:00 AM · 2 h'), findsOneWidget);
    });

    testWidgets('Shift the rest moves later tasks up to the pinned one', (
      tester,
    ) async {
      await _pump(tester, size: const Size(390, 1400));
      // Design review (10:30) sits 30 min inside Deep work (until 11:00).
      await tester.tap(find.text('Shift the rest'));
      await tester.pumpAndSettle();
      expect(
        find.text('Moved 2 tasks · stopped at Lunch with Sam (pinned)'),
        findsOneWidget,
      );
      expect(find.text('11:00 AM – 11:45 AM'), findsOneWidget);
      expect(find.text('12:00 PM – 12:30 PM'), findsOneWidget);
    });

    testWidgets('Shift the rest is off when nothing overlaps', (tester) async {
      final rows = [
        for (final o in demoDayRows(_date))
          if (o.title != 'Design review') o,
      ];
      await _pump(tester, rows: rows, size: const Size(390, 1200));
      final shift = tester.widget<OutlinedButton>(
        find.widgetWithText(OutlinedButton, 'Shift the rest'),
      );
      expect(shift.onPressed, isNull);
    });
  });

  group('drag (R-05)', () {
    Future<TestGesture> lift(WidgetTester tester, String title) async {
      final g = await tester.startGesture(tester.getCenter(find.text(title)));
      await tester.pump(DotTouch.liftDelay + const Duration(milliseconds: 50));
      return g;
    }

    testWidgets('dropping on a free gap moves the task, with Undo', (
      tester,
    ) async {
      await _pump(tester, size: const Size(390, 1400));
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
      await _pump(
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

    testWidgets('dropping on a week-strip day keeps the time', (tester) async {
      final repo = FakeOccurrenceRepository(demoDayRows(_date));
      await _pump(tester, repo: repo, size: const Size(390, 1400));
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
      await _pump(tester, size: const Size(390, 1400));
      tester.semantics.increase(
        find.semantics.byLabel('Change how long Team standup takes'),
      );
      await tester.pumpAndSettle();
      expect(find.text('Team standup now ends at 8:20 AM'), findsOneWidget);
      handle.dispose();
    });
  });

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
      await _pump(tester, size: const Size(390, 1400));
      await pick(tester, ['Team standup', 'Design review']);
      expect(find.text('2 selected'), findsOneWidget);
      expect(said, ['1 selected', '2 selected']);
      await tester.tap(find.byTooltip('Done selecting'));
      await tester.pumpAndSettle();
      expect(find.text('2 selected'), findsNothing);
    });

    testWidgets('Duplicate copies them, with Undo', (tester) async {
      final repo = FakeOccurrenceRepository(demoDayRows(_date));
      await _pump(tester, repo: repo, size: const Size(390, 1400));
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
      final repo = FakeOccurrenceRepository(demoDayRows(_date));
      await _pump(tester, repo: repo, size: const Size(390, 1400));
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
      await _pump(tester, size: const Size(390, 1400));
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
      final repo = FakeOccurrenceRepository(demoDayRows(_date));
      await _pump(tester, repo: repo, size: const Size(390, 1400));
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
      await _pump(tester, size: const Size(390, 1400));
      await pick(tester, ['Team standup']);
      final popped = await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(popped, isTrue);
      expect(find.text('1 selected'), findsNothing);
      expect(find.byType(TodayScreen), findsOneWidget);
    });
  });

  testWidgets('an empty day says what to do', (tester) async {
    await _pump(tester, rows: const []);
    expect(
      find.text('Nothing planned · pull the strip to plan or tap +'),
      findsWidgets,
    );
  });

  testWidgets('tapping a dot marks the task done', (tester) async {
    await _pump(tester);
    await tester.tap(find.bySemanticsLabel('Team standup, missed'));
    await tester.pumpAndSettle();
    expect(find.bySemanticsLabel('Team standup, done'), findsOneWidget);
  });

  for (final (name, size) in [
    ('compact', const Size(390, 844)),
    ('expanded', const Size(1280, 800)),
  ]) {
    for (final mode in [ThemeMode.light, ThemeMode.dark]) {
      testWidgets('meets a11y guidelines ($name, ${mode.name})', (
        tester,
      ) async {
        await _pump(tester, size: size, mode: mode);
        await expectA11yGuidelines(tester);
      });
    }
  }
}
