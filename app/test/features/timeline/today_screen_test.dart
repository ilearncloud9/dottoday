import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:dottoday/domain/entities/settings.dart';
import 'package:dottoday/features/timeline/today_screen.dart';
import 'package:dottoday/features/timeline/widgets/today_week_strip.dart';
import 'package:dottoday/shared/dot/day_card.dart';
import 'package:dottoday/shared/dot/month_grid.dart';
import 'package:flutter/material.dart';
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
  Size size = const Size(390, 844),
  ThemeMode mode = ThemeMode.light,
  DateTime? date,
  String? name = 'Kody',
  int firstDayOfWeek = 7,
}) async {
  tester.view
    ..physicalSize = size
    ..devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  final profile = testProfile(
    settings: Settings(use24h: false, firstDayOfWeek: firstDayOfWeek),
  ).copyWith(displayName: name);
  await tester.pumpWidget(
    ProviderScope(
      overrides: timelineOverrides(
        now: _now,
        occurrences: FakeOccurrenceRepository(rows ?? demoDayRows(_date)),
        profile: profile,
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
    await tester.tap(find.bySemanticsLabel('Hide month').last);
    await tester.pumpAndSettle();
    expect(find.byType(MonthGrid), findsNothing);
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
