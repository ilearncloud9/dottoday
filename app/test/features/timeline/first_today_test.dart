import 'package:dottoday/data/onboarding/first_today_store.dart';
import 'package:dottoday/domain/entities/enums.dart';
import 'package:dottoday/domain/entities/settings.dart';
import 'package:dottoday/features/timeline/first_today/first_today_look.dart';
import 'package:dottoday/features/timeline/today_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest.dart' as tz_data;

import '../../support/a11y.dart';
import '../../support/today_harness.dart';
import '../../support/youre_in_rows.dart';

// You're in (M20.11 part 5, prototype `vToday`; ED-490): the first Today
// after onboarding.

const _fresh = FirstTodayState(rise: true, hint: true, sync: true);
const _hint = 'Tap the circle when it’s done';

FirstTodayState _state(WidgetTester tester) => ProviderScope.containerOf(
  tester.element(find.byType(TodayScreen)),
).read(firstTodayProvider).requireValue;

void main() {
  setUpAll(tz_data.initializeTimeZones);

  test('the hint points at the next task not done, else the first', () {
    final rows = youreInRows();
    // 9:22 in Berlin: the run is past, Read is next.
    expect(
      firstTodayHintTarget(rows, DateTime.utc(2026, 10, 21, 7, 22)),
      rows.last.id,
    );
    // After Read: back to the first not done.
    expect(
      firstTodayHintTarget(rows, DateTime.utc(2026, 10, 21, 21)),
      rows.first.id,
    );
    final done = [
      for (final o in rows) o.copyWith(status: OccurrenceStatus.done),
    ];
    expect(firstTodayHintTarget(done, DateTime.utc(2026, 10, 21, 7)), isNull);
  });

  testWidgets('the hint, the sync card, and the rows rising', (tester) async {
    await pumpToday(tester, rows: youreInRows(), firstToday: _fresh);
    expect(find.text(_hint), findsOneWidget);
    expect(find.text('Sign in to sync'), findsOneWidget);
    expect(
      find.text('Use Dottoday on all your devices with a copy kept safe.'),
      findsOneWidget,
    );
    // Risen once, for good.
    expect(_state(tester).rise, isFalse);
  });

  testWidgets('the first tap anywhere ends the hint for good', (tester) async {
    await pumpToday(tester, rows: youreInRows(), firstToday: _fresh);
    await tester.tapAt(const Offset(200, 20));
    await tester.pumpAndSettle();
    expect(find.text(_hint), findsNothing);
    expect(_state(tester).hint, isFalse);
  });

  testWidgets('✕ dismisses the sync card for good', (tester) async {
    await pumpToday(tester, rows: youreInRows(), firstToday: _fresh);
    await tester.tap(find.byTooltip('Dismiss sign in to sync'));
    await tester.pumpAndSettle();
    expect(find.text('Sign in to sync'), findsNothing);
    expect(_state(tester).sync, isFalse);
  });

  testWidgets('a device that never onboarded shows none of it', (tester) async {
    await pumpToday(tester, rows: youreInRows());
    expect(find.text(_hint), findsNothing);
    expect(find.text('Sign in to sync'), findsNothing);
  });

  testWidgets('Minimal shows none of it (docs/14 §3)', (tester) async {
    await pumpToday(
      tester,
      rows: youreInRows(),
      firstToday: _fresh,
      settings: const Settings(use24h: false, uiLayout: UiLayout.minimal),
    );
    expect(find.text(_hint), findsNothing);
    expect(find.text('Sign in to sync'), findsNothing);
  });

  testWidgets('meets a11y guidelines (R-12)', (tester) async {
    await pumpToday(tester, rows: youreInRows(), firstToday: _fresh);
    await expectA11yGuidelines(tester);
  });
}
