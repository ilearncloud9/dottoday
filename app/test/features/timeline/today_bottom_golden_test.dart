// Goldens are baselined on macOS; CI runs them on a macOS runner (docs/09 M0.8).
@Tags(['golden'])
library;

import 'package:dottoday/domain/entities/enums.dart';
import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:dottoday/domain/entities/settings.dart';
import 'package:dottoday/features/timeline/today_screen.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import '../../support/dot_golden.dart';
import '../../support/timeline_fakes.dart';

final _date = DateTime(2026, 10, 21);

/// The latest Bedtime a day can have: the slider's last step (a window end
/// of `24:00` is not valid, `checkTimeWindow`), so the thread runs to the
/// very end of the calendar day (docs/02 F1.16, R-14).
const _lateDay = TimeWindow(start: '07:00', end: '23:55');

DateTime _berlin(int h, int m) =>
    tz.TZDateTime(tz.getLocation('Europe/Berlin'), 2026, 10, 21, h, m).toUtc();

/// The demo day plus an imported 20:00 event and a 23:30 task.
List<Occurrence> _rows() {
  final demo = demoDayRows(_date);
  final base = demo.firstWhere((o) => o.startUtc != null);
  return [
    ...demo,
    base.copyWith(
      id: '0192b3a0-0000-7000-8000-00000000c0c1',
      seriesId: null,
      title: 'Concert',
      colorKey: 'violet',
      iconKey: 'music',
      startUtc: _berlin(20, 0),
      durationMin: 120,
      status: OccurrenceStatus.planned,
      source: OccurrenceSource.calendar,
    ),
    base.copyWith(
      id: '0192b3a0-0000-7000-8000-00000000c0c2',
      seriesId: null,
      title: 'Night walk',
      colorKey: 'teal',
      iconKey: 'run',
      startUtc: _berlin(23, 30),
      durationMin: 25,
      status: OccurrenceStatus.planned,
    ),
  ];
}

Widget _today() => ProviderScope(
  overrides: timelineOverrides(
    now: DateTime.utc(2026, 10, 21, 7, 22),
    occurrences: FakeOccurrenceRepository(_rows()),
    subtasks: FakeSubtaskRepository(demoDaySubtasks(_date)),
    profile: testProfile(
      settings: Settings(
        use24h: false,
        dayBoundaries: {for (final d in Weekday.values) d: _lateDay},
      ),
    ),
  ),
  child: const TodayScreen(),
);

/// Every vertical list on the page, scrolled to its end.
Future<void> _toEnd(WidgetTester tester) async {
  final lists = find.byWidgetPredicate(
    (w) => w is Scrollable && w.axisDirection == AxisDirection.down,
  );
  for (final state in tester.stateList<ScrollableState>(lists)) {
    state.position.jumpTo(state.position.maxScrollExtent);
  }
  await tester.pumpAndSettle();
}

void main() {
  setUpAll(() async {
    tz_data.initializeTimeZones();
    await loadAppFonts();
  });

  // F1.16 (R-14): the bottom of the day renders — the 23:30 task and the
  // Bedtime cap, with nothing blank or cut below them.
  goldenMatrix(
    'today_bottom',
    height: 844,
    widths: const {'compact', 'expanded'},
    build: (_) => _today(),
    act: _toEnd,
  );

  testWidgets('scrolled to the end, the last task and Bedtime show', (
    tester,
  ) async {
    tester.view
      ..physicalSize = const Size(390, 844)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(goldenApp(_today(), theme: 'light'));
    await tester.pumpAndSettle();
    await _toEnd(tester);
    for (final text in ['Night walk', 'Bedtime · 11:55 PM']) {
      expect(find.text(text).hitTestable(), findsOneWidget, reason: text);
    }
  });
}
