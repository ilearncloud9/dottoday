import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/domain/entities/enums.dart';
import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:dottoday/features/timeline/timeline_screen.dart';
import 'package:dottoday/features/timeline/widgets/block_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import '../../support/a11y.dart';
import '../../support/timeline_fakes.dart';

final _now = DateTime.utc(2026, 10, 21, 11); // 13:00 Berlin
final _date = DateTime(2026, 10, 21);

Future<FakeOccurrenceRepository> _pump(
  WidgetTester tester, {
  List<Occurrence>? rows,
  Size size = const Size(420, 800),
  ThemeMode mode = ThemeMode.light,
  double textScale = 1,
  DateTime? date,
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  final repo = FakeOccurrenceRepository(rows ?? demoDayRows(_date));
  await tester.pumpWidget(
    ProviderScope(
      overrides: timelineOverrides(now: _now, occurrences: repo),
      child: MaterialApp(
        theme: DotTheme.light(),
        darkTheme: DotTheme.dark(),
        themeMode: mode,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: TextScaler.linear(textScale)),
          child: child!,
        ),
        home: TimelineScreen(date: date),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return repo;
}

double _scrollOffset(WidgetTester tester) => tester
    .state<ScrollableState>(find.byType(Scrollable).first)
    .position
    .pixels;

void main() {
  setUpAll(tz_data.initializeTimeZones);

  testWidgets('shows the date header and blocks with semantics', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await _pump(tester, size: const Size(420, 2000));
    expect(find.textContaining('October 21'), findsOneWidget);
    expect(
      find.bySemanticsLabel('Design review, 10:30 to 11:15, not done yet'),
      findsOneWidget,
    );
    expect(find.bySemanticsLabel('Now, 13:00'), findsOneWidget);
    handle.dispose();
  });

  testWidgets('opens scrolled to an hour before now', (tester) async {
    await _pump(tester);
    expect(_scrollOffset(tester), greaterThan(0));
    final review = tester.getTopLeft(find.text('Lunch with Sam'));
    expect(review.dy, inInclusiveRange(0, 800));
  });

  testWidgets('another day has no now-line and starts at the day start', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await _pump(
      tester,
      date: DateTime(2026, 10, 22),
      rows: demoDayRows(DateTime(2026, 10, 22)),
    );
    expect(find.bySemanticsLabel(RegExp('^Now')), findsNothing);
    expect(find.text('Morning run'), findsOneWidget);
    handle.dispose();
  });

  testWidgets('overlapping pair renders side by side', (tester) async {
    await _pump(tester, size: const Size(420, 2000));
    final deep = tester.getRect(
      find.ancestor(
        of: find.text('Deep work: roadmap'),
        matching: find.byType(BlockTile),
      ),
    );
    final review = tester.getRect(
      find.ancestor(
        of: find.text('Design review'),
        matching: find.byType(BlockTile),
      ),
    );
    expect(review.left, greaterThanOrEqualTo(deep.right));
    expect(review.top, lessThan(deep.bottom));
  });

  testWidgets('the block crossing midnight shows on the next day too', (
    tester,
  ) async {
    await _pump(tester, date: DateTime(2026, 10, 22), rows: demoDayRows(_date));
    expect(find.text('Night train to Berlin'), findsOneWidget);
  });

  testWidgets('outside-hours zone expands and collapses', (tester) async {
    await _pump(tester, size: const Size(420, 2000));
    final before = tester.getTopLeft(find.text('Morning run')).dy;
    await tester.tap(find.text('Before 07:00'));
    await tester.pumpAndSettle();
    final expanded = tester.getTopLeft(find.text('Morning run')).dy;
    expect(expanded, greaterThan(before + 400));
    await tester.tap(find.text('Before 07:00'));
    await tester.pumpAndSettle();
    expect(tester.getTopLeft(find.text('Morning run')).dy, before);
  });

  testWidgets('all-day items go to the strip, not the timeline', (
    tester,
  ) async {
    final berlin = tz.getLocation('Europe/Berlin');
    final allDay = demoDayRows(_date).first.copyWith(
      id: '01928c3e-0000-7000-8000-00000000a11d',
      title: 'Holiday',
      startUtc: tz.TZDateTime(berlin, 2026, 10, 21).toUtc(),
      durationMin: 1440,
    );
    await _pump(tester, rows: [allDay]);
    expect(find.text('All day'), findsOneWidget);
    expect(find.text('Holiday'), findsOneWidget);
    expect(find.byType(BlockTile), findsNothing);
  });

  testWidgets('builds only blocks near the viewport (lazy, R-15)', (
    tester,
  ) async {
    final base = demoDayRows(_date).first;
    final start = DateTime.utc(2026, 10, 20, 22);
    final rows = [
      for (var i = 0; i < 200; i++)
        base.copyWith(
          id: '01928c3e-0000-7000-8000-${i.toString().padLeft(12, '0')}',
          title: 'B$i',
          startUtc: start.add(Duration(minutes: i * 7)),
          durationMin: 5,
        ),
    ];
    await _pump(tester, rows: rows);
    final built = tester.widgetList(find.byType(BlockTile)).length;
    expect(built, greaterThan(0));
    expect(built, lessThan(120));
  });

  testWidgets('more than 3 overlaps show a +n marker listing the rest', (
    tester,
  ) async {
    final base = demoDayRows(_date)[6]; // 14:00 Spanish lesson
    final rows = [
      for (var i = 0; i < 5; i++)
        base.copyWith(
          id: '01928c3e-0000-7000-8000-00000000000$i',
          title: 'Overlap $i',
        ),
    ];
    await _pump(tester, rows: rows, size: const Size(420, 2000));
    expect(find.text('+2'), findsOneWidget);
    await tester.tap(find.text('+2'));
    await tester.pumpAndSettle();
    expect(find.text('2 more blocks'), findsOneWidget);
  });

  testWidgets('new blocks appear live from the repository stream', (
    tester,
  ) async {
    final repo = await _pump(tester, rows: const []);
    expect(find.byType(BlockTile), findsNothing);
    repo.put([demoDayRows(_date)[7]]); // 15:30
    await tester.pumpAndSettle();
    expect(find.text('Call the dentist'), findsOneWidget);
  });

  testWidgets('tapping the icon circle completes, and Undo reverts', (
    tester,
  ) async {
    final repo = await _pump(tester, size: const Size(420, 2000));
    await tester.tap(find.bySemanticsLabel('Mark Spanish lesson done'));
    await tester.pumpAndSettle();
    final lesson = repo.rows.firstWhere((o) => o.title == 'Spanish lesson');
    expect(lesson.status, OccurrenceStatus.done);
    expect(lesson.completedAtUtc, _now);
    expect(find.text('Marked done'), findsOneWidget);
    expect(find.bySemanticsLabel('Mark Spanish lesson not done'), findsOne);

    await tester.tap(find.text('Undo'));
    await tester.pumpAndSettle();
    final back = repo.rows.firstWhere((o) => o.title == 'Spanish lesson');
    expect(back.status, OccurrenceStatus.planned);
  });

  testWidgets('labels carry state, progress and badges (03 §4)', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(const SizedBox());
    await tester.pumpWidget(
      ProviderScope(
        overrides: timelineOverrides(
          now: _now,
          occurrences: FakeOccurrenceRepository(demoDayRows(_date)),
          subtasks: FakeSubtaskRepository(demoDaySubtasks(_date)),
        ),
        child: MaterialApp(
          theme: DotTheme.light(),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const TimelineScreen(),
        ),
      ),
    );
    tester.view.physicalSize = const Size(420, 2200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpAndSettle();
    for (final label in [
      'Morning run, 06:45 to 07:30, done',
      'Team standup, 08:00 to 08:15, not done yet, recurring',
      'Deep work: roadmap, 09:00 to 11:00, 1 of 3 subtasks done, '
          'not done yet',
      'Lunch with Sam, 12:30 to 13:15, pinned',
      'Call the dentist, 15:30 to 15:45, 2 alerts',
      'Night train to Berlin, 23:30 to 00:45, continues into the next day',
    ]) {
      expect(find.bySemanticsLabel(label), findsOneWidget, reason: label);
    }
    handle.dispose();
  });

  testWidgets('large text keeps the date and hides the pill text', (
    tester,
  ) async {
    await _pump(tester, textScale: 2);
    expect(find.textContaining('Wednesday'), findsOneWidget);
    expect(find.text('On this device'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  for (final mode in [ThemeMode.light, ThemeMode.dark]) {
    for (final size in [const Size(420, 800), const Size(1000, 700)]) {
      for (final scale in [1.0, 2.0]) {
        testWidgets('a11y guidelines (${mode.name}, $size, ${scale}x)', (
          tester,
        ) async {
          await _pump(tester, mode: mode, size: size, textScale: scale);
          await expectA11yGuidelines(tester);
        });
      }
    }
  }
}
