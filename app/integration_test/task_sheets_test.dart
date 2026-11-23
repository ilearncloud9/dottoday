// Task sheets (docs/09 M20.6 part 4; E-R2-27 §2, ED-330): on a past day a
// done task (its tile reads Not done) and one not done (Shift the rest
// off); today a calendar event (editable, no Pinned row); and a task with
// five alerts, its Alerts list with every Add chip off and "Up to 5
// alerts". In-memory data:
//   tool/device_tests.sh ios <udid> task_sheets       (DEVICE_SHOT)
//   tool/device_tests.sh android <serial> task_sheets
//   SWEEP_TARGET=integration_test/task_sheets_test.dart tool/mac_sweep.sh
//   flutter build web -t integration_test/task_sheets_test.dart \
//     --dart-define=SWEEP_HOST_SHOTS=true, served, then
//   SHOTS=task_sheets node tool/slice/web_journey.mjs <url> compact|expanded <b>
import 'package:dottoday/core/router/app_routes.dart';
import 'package:dottoday/domain/entities/alert.dart';
import 'package:dottoday/domain/entities/enums.dart';
import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:timezone/data/latest.dart' as tz_data;

import '../test/domain/fixtures.dart';
import '../test/features/timeline/calendar/calendar_world.dart';
import 'support/device_shot.dart';

// l10n-ignore-start: fixture data
/// A real id: a task link (`?task=`) takes only UUIDs (deep_link_guard).
String _uuid(int n) => '01928c3e-0000-7000-8000-0000000000a$n';

/// The month, with Monday's Deep work not done, today's Dentist from a
/// calendar and today's Deep work carrying five alerts; the four opened
/// here get real ids.
List<Occurrence> _rows() => [
  for (final o in calendarMonth())
    switch (o.id) {
      'cal 2 Run' => o.copyWith(id: _uuid(1)),
      'cal 3 Dentist' => o.copyWith(
        id: _uuid(2),
        source: OccurrenceSource.calendar,
      ),
      'cal 3 Deep work: roadmap' => o.copyWith(
        id: _uuid(3),
        alerts: const [
          Alert(kind: AlertKind.before, offsetMin: 60),
          Alert(kind: AlertKind.before, offsetMin: 30),
          Alert(kind: AlertKind.before, offsetMin: 10),
          Alert(kind: AlertKind.atStart),
          Alert(kind: AlertKind.atEnd),
        ],
      ),
      _ => o,
    },
  occurrenceFixture().copyWith(
    id: _uuid(4),
    title: 'Deep work: roadmap',
    colorKey: 'indigo',
    iconKey: 'focus_block',
    startUtc: DateTime.utc(2026, 11, 2, 8),
    tzId: 'Europe/Berlin',
    durationMin: 120,
  ),
];
// l10n-ignore-end

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(tz_data.initializeTimeZones);

  /// Opens [title]'s sheet (the [at]th on screen), shoots it, closes it.
  Future<void> sheet(
    WidgetTester tester,
    String title,
    Future<void> Function() shot, {
    Future<void> Function()? inside,
  }) async {
    // Maybe off screen: drag the day towards it until it can be tapped.
    final row = find.text(title).hitTestable();
    final height =
        tester.view.physicalSize.height / tester.view.devicePixelRatio;
    for (var i = 0; i < 15 && row.evaluate().isEmpty; i++) {
      final any = find.text(title, skipOffstage: false);
      final below =
          any.evaluate().isEmpty || tester.getCenter(any.first).dy > height / 2;
      await tester.drag(_onScreenList(tester), Offset(0, below ? -250 : 250));
      await tester.pumpAndSettle();
    }
    await tester.tap(find.text(title).hitTestable().first);
    await tester.pumpAndSettle();
    await shot();
    if (inside != null) await inside();
    // Back closes the sheet (or the editor's panel).
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
  }

  for (final mode in [ThemeMode.dark, ThemeMode.light]) {
    testWidgets('task sheets, ${mode.name}', (tester) async {
      Future<void> shot(String step) =>
          deviceShot(binding, tester, 'sheet_${mode.name}_$step');
      final router = await pumpCalendar(tester, mode: mode, rows: _rows());

      // 1, 2 · A past day: a done task, one not done.
      router.go(AppRoutes.day(DateTime(2026, 11, 2)));
      await tester.pumpAndSettle();
      // Wider windows edit in the panel or the inspector (M19.4, not this
      // board's phone sheet): the done task there, then stop.
      final width =
          tester.view.physicalSize.width / tester.view.devicePixelRatio;
      if (width >= 600) {
        await tester.tap(find.text('Run').hitTestable().first); // l10n-ignore
        await tester.pumpAndSettle();
        await shot('1_done');
        return;
      }
      await sheet(tester, 'Run', () => shot('1_done')); // l10n-ignore
      await sheet(
        tester,
        'Deep work: roadmap', // l10n-ignore
        () => shot('2_past_not_done'),
      );

      // 3 · Today: a calendar event.
      router.go(AppRoutes.today);
      await tester.pumpAndSettle();
      await sheet(tester, 'Dentist', () => shot('3_event')); // l10n-ignore

      // 4 · Five alerts: the Alerts list.
      await sheet(
        tester,
        'Deep work: roadmap', // l10n-ignore
        () => shot('4_sheet'),
        inside: () async {
          // Pulled up (phones; wider windows show the whole editor): the
          // When card's alerts row opens the editor.
          final pull = find.text('Pull up for date, alerts, steps and notes');
          if (pull.evaluate().isNotEmpty) {
            await tester.drag(pull, const Offset(0, -300));
            await tester.pumpAndSettle();
          }
          final row = find.textContaining('60 min before'); // l10n-ignore
          if (row.evaluate().isEmpty) return;
          await tester.ensureVisible(row.first);
          await tester.pumpAndSettle();
          await tester.tap(row.first);
          await tester.pumpAndSettle();
          expect(find.text('Up to 5 alerts'), findsOneWidget); // l10n-ignore
          await shot('5_alerts');
          await tester.binding.handlePopRoute();
          await tester.pumpAndSettle();
        },
      );
    });
  }
}

/// The widest vertical list on screen: offstage branches keep theirs
/// mounted.
Finder _onScreenList(WidgetTester tester) {
  final lists = find
      .byWidgetPredicate(
        (w) => w is Scrollable && w.axisDirection == AxisDirection.down,
      )
      .hitTestable();
  var best = 0;
  for (var i = 1; i < lists.evaluate().length; i++) {
    if (tester.getSize(lists.at(i)).width >
        tester.getSize(lists.at(best)).width) {
      best = i;
    }
  }
  return lists.at(best);
}
