import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/data/calendar/travel_providers.dart';
import 'package:dottoday/domain/entities/enums.dart';
import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:dottoday/domain/entities/settings.dart';
import 'package:dottoday/features/timeline/task_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest.dart' as tz_data;

import '../../support/a11y.dart';
import '../../support/timeline_fakes.dart';

// Travel time before an imported event with a place (docs/02 F5,
// docs/09 M7.5, R-17): suggested in its sheet, written only on Add
// (CLAUDE.md §11 proposal rule).

final _now = DateTime.utc(2026, 10, 21, 6);

final _dentist = Occurrence(
  id: 'imported-1',
  userId: testUserId,
  title: 'Dentist',
  colorKey: 'sky',
  startUtc: DateTime.utc(2026, 10, 21, 8),
  tzId: 'Europe/Berlin',
  durationMin: 45,
  source: OccurrenceSource.calendar,
  calendarLinkId: 'link-1',
  createdAt: DateTime.utc(2026),
  updatedAt: DateTime.utc(2026),
);

Future<FakeOccurrenceRepository> _pump(
  WidgetTester tester, {
  bool suggest = true,
  String? place = 'Main St 4',
  Occurrence? event,
  ThemeMode mode = ThemeMode.light,
  double width = 390,
}) async {
  tester.view
    ..physicalSize = Size(width, 1400)
    ..devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  final repo = FakeOccurrenceRepository([event ?? _dentist]);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        ...timelineOverrides(
          now: _now,
          occurrences: repo,
          profile: testProfile(
            settings: Settings(suggestTravelTime: suggest, travelTimeMin: 20),
          ),
        ),
        calendarEventLocationProvider.overrideWith(
          (ref, linkId) => Stream.value(linkId == 'link-1' ? place : null),
        ),
      ],
      child: MaterialApp(
        theme: DotTheme.light(),
        darkTheme: DotTheme.dark(),
        themeMode: mode,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: TaskScreen(id: (event ?? _dentist).id),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return repo;
}

int _buffer(FakeOccurrenceRepository repo) => repo.rows.single.travelBufferMin;

void main() {
  setUpAll(tz_data.initializeTimeZones);

  testWidgets('suggests travel time and writes nothing before Add', (
    tester,
  ) async {
    final repo = await _pump(tester);
    expect(find.text('TRAVEL TIME'), findsOneWidget);
    expect(
      find.text('At Main St 4. Keep 20 min before it for getting there?'),
      findsOneWidget,
    );
    expect(_buffer(repo), 0, reason: 'a suggestion is not a write');

    await tester.tap(find.text('Add 20 min before'));
    await tester.pumpAndSettle();
    expect(_buffer(repo), 20);
    expect(find.text('Travel time added before “Dentist”'), findsOneWidget);
    expect(find.text('TRAVEL TIME'), findsNothing, reason: 'it is set now');
    expect(find.text('20 min before'), findsOneWidget, reason: 'detail row');
  });

  testWidgets('Undo takes the travel time away again', (tester) async {
    final repo = await _pump(tester);
    await tester.tap(find.text('Add 20 min before'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Undo'));
    await tester.pumpAndSettle();
    expect(_buffer(repo), 0);
  });

  testWidgets('Not now puts it away without writing', (tester) async {
    final repo = await _pump(tester);
    await tester.tap(find.text('Not now'));
    await tester.pumpAndSettle();
    expect(find.text('TRAVEL TIME'), findsNothing);
    expect(_buffer(repo), 0);
  });

  testWidgets('nothing is suggested with the setting off', (tester) async {
    await _pump(tester, suggest: false);
    expect(find.text('TRAVEL TIME'), findsNothing);
  });

  testWidgets('nothing is suggested without a place', (tester) async {
    await _pump(tester, place: null);
    expect(find.text('TRAVEL TIME'), findsNothing);
  });

  testWidgets('nothing is suggested once the event has begun', (tester) async {
    await _pump(tester, event: _dentist.copyWith(startUtc: _now));
    expect(find.text('TRAVEL TIME'), findsNothing);
  });

  for (final mode in [ThemeMode.light, ThemeMode.dark]) {
    for (final width in [390.0, 1280.0]) {
      testWidgets('the card meets the a11y guidelines ($mode, $width)', (
        tester,
      ) async {
        await _pump(tester, mode: mode, width: width);
        expect(find.text('TRAVEL TIME'), findsOneWidget);
        await expectA11yGuidelines(tester);
      });
    }
  }
}
