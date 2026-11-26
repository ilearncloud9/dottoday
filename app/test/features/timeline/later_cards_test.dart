import 'package:dottoday/data/layout/layout_providers.dart';
import 'package:dottoday/data/onboarding/first_today_store.dart';
import 'package:dottoday/data/onboarding/later_cards_store.dart';
import 'package:dottoday/domain/entities/enums.dart';
import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:dottoday/domain/entities/series.dart';
import 'package:dottoday/features/timeline/today_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest.dart' as tz_data;

import '../../support/a11y.dart';
import '../../support/timeline_fakes.dart';
import '../../support/today_harness.dart';
import '../../support/youre_in_rows.dart';

// Later, when it helps (M20.11 part 6, ED-491): one card at a time at the
// foot of Today, each once.

final _onboarded = DateTime.utc(2026, 10, 12, 8);

ProviderContainer _c(WidgetTester tester) =>
    ProviderScope.containerOf(tester.element(find.byType(TodayScreen)));

LaterCardsState _state(WidgetTester tester) =>
    _c(tester).read(laterCardsProvider).requireValue;

final _gym = Series(
  id: 'gym-series',
  userId: testUserId,
  title: 'Gym',
  durationMin: 60,
  rrule: 'FREQ=DAILY',
  dtstartLocal: '2026-10-12T18:00',
  tzId: 'Europe/Berlin',
  colorKey: 'violet',
  iconKey: 'gym',
  createdAt: DateTime.utc(2026, 10, 12),
  updatedAt: DateTime.utc(2026, 10, 12),
);

Occurrence _gymOn(int d, {bool done = true}) => Occurrence(
  id: 'gym-$d',
  userId: testUserId,
  seriesId: _gym.id,
  title: 'Gym',
  colorKey: 'violet',
  iconKey: 'gym',
  startUtc: DateTime.utc(2026, 10, d, 16),
  tzId: 'Europe/Berlin',
  durationMin: 60,
  status: done ? OccurrenceStatus.done : OccurrenceStatus.planned,
  createdAt: DateTime.utc(2026, 10, 12),
  updatedAt: DateTime.utc(2026, 10, 12),
);

void main() {
  setUpAll(tz_data.initializeTimeZones);

  testWidgets('day 2: Want it simpler? Try Less switches to Less', (
    tester,
  ) async {
    await pumpToday(
      tester,
      rows: youreInRows(),
      laterCards: LaterCardsState(onboardedUtc: _onboarded),
    );
    expect(find.text('Want it simpler?'), findsOneWidget);
    await tester.tap(find.text('Try Less'));
    await tester.pumpAndSettle();
    // The card leaves over 300 ms, then is marked done.
    await tester.pump(const Duration(milliseconds: 400));
    expect(_state(tester).simpler, isTrue);
    expect(_c(tester).read(uiLayoutProvider), UiLayout.minimal);
  });

  testWidgets('not on the day onboarding finished', (tester) async {
    await pumpToday(
      tester,
      rows: youreInRows(),
      laterCards: LaterCardsState(onboardedUtc: DateTime.utc(2026, 10, 21, 5)),
    );
    expect(find.text('Want it simpler?'), findsNothing);
  });

  testWidgets('three days done: Make it a habit, through the proposal', (
    tester,
  ) async {
    await pumpToday(
      tester,
      rows: [
        ...youreInRows(),
        _gymOn(12),
        _gymOn(14),
        _gymOn(16),
        _gymOn(22, done: false),
      ],
      series: [_gym],
      laterCards: LaterCardsState(onboardedUtc: _onboarded, habits: [_gym.id]),
    );
    expect(find.text('Repeat Gym every Mon, Wed, Fri?'), findsOneWidget);
    await tester.tap(find.text('Repeat'));
    await tester.pumpAndSettle();
    // Nothing is written before Accept (the proposal rule).
    final undo = writesOf(_c(tester));
    expect(undo.applied, isEmpty);
    expect(find.text('Most days → every Mon, Wed, Fri'), findsOneWidget);
    await tester.tap(find.text('Accept'));
    await tester.pumpAndSettle();
    await tester.pump(const Duration(milliseconds: 400));
    final written = undo.applied.single.series;
    expect(written.map((s) => s.rrule), contains('FREQ=WEEKLY;BYDAY=MO,WE,FR'));
    expect(_state(tester).habitsOffered, contains(_gym.id));
  });

  testWidgets('the first Wind Down: Close the day, once', (tester) async {
    await pumpToday(
      tester,
      rows: youreInRows(),
      // 22:30 in Berlin, past Wind Down (22:00).
      now: DateTime.utc(2026, 10, 21, 20, 30),
      laterCards: LaterCardsState(onboardedUtc: _onboarded),
    );
    expect(find.text('Move what’s left to tomorrow, kindly.'), findsOneWidget);
    await tester.tap(find.byTooltip('Not now'));
    await tester.pumpAndSettle();
    expect(_state(tester).close, isTrue);
  });

  testWidgets('a week on without an account: Sign in to sync once more', (
    tester,
  ) async {
    await pumpToday(
      tester,
      rows: youreInRows(),
      laterCards: LaterCardsState(onboardedUtc: _onboarded, simpler: true),
    );
    expect(find.text('Sign in to sync'), findsOneWidget);
    await tester.tap(find.byTooltip('Dismiss sign in to sync'));
    await tester.pumpAndSettle();
    expect(_state(tester).sync, isTrue);
  });

  testWidgets('not while the first Today still offers it', (tester) async {
    await pumpToday(
      tester,
      rows: youreInRows(),
      firstToday: const FirstTodayState(sync: true),
      laterCards: LaterCardsState(onboardedUtc: _onboarded, simpler: true),
    );
    // One card: the first Today's.
    expect(find.text('Sign in to sync'), findsOneWidget);
  });

  testWidgets('meets a11y guidelines (R-12)', (tester) async {
    await pumpToday(
      tester,
      rows: youreInRows(),
      laterCards: LaterCardsState(onboardedUtc: _onboarded),
    );
    await expectA11yGuidelines(tester);
  });
}
