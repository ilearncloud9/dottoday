// Focus on every platform (docs/09 M20.6 part 1; E-R2-9, ED-284 to
// ED-286; E-R2-26 §3, ED-329): Deep work in Focus, step 3 of 4 (the whole
// window in two columns on expanded windows, one column below); ‹ Today
// leaves; then a task past its planned end: the ring full, "0 min left",
// nothing ended; +15 min with its toast. In-memory data:
//   tool/device_tests.sh ios <udid> focus       (DEVICE_SHOT)
//   tool/device_tests.sh android <serial> focus
//   SWEEP_TARGET=integration_test/focus_test.dart tool/mac_sweep.sh
//   flutter build web -t integration_test/focus_test.dart \
//     --dart-define=SWEEP_HOST_SHOTS=true, served, then
//   SHOTS=focus node tool/slice/web_journey.mjs <url> compact|expanded <b>
import 'dart:async';

import 'package:dottoday/core/router/app_routes.dart';
import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:dottoday/domain/entities/subtask.dart';
import 'package:dottoday/features/focus/focus_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:timezone/data/latest.dart' as tz_data;

import '../test/domain/fixtures.dart';
import '../test/features/timeline/calendar/calendar_world.dart';
import 'support/device_shot.dart';

// UUIDs: Focus's address takes only real ids (deep_link_guard).
const _deep = '01928c3e-0000-7000-8000-00000000f0c1';
const _memo = '01928c3e-0000-7000-8000-00000000f0c2';

/// The month, with Draft memo from 9 to 10 AM not ticked: at 10:42 it is
/// past its planned end.
List<Occurrence> _rows() => [
  for (final o in calendarMonth())
    o.id ==
            'cal 3 Deep work: roadmap' // l10n-ignore: fixture id
        ? o.copyWith(id: _deep)
        : o,
  occurrenceFixture().copyWith(
    id: _memo,
    title: 'Draft memo', // l10n-ignore: data
    colorKey: 'sky',
    iconKey: 'focus_block',
    startUtc: DateTime.utc(2026, 11, 3, 8),
    tzId: 'Europe/Berlin',
    durationMin: 60,
  ),
];

/// Deep work's four steps, the first two done (the board's sample).
List<Subtask> _steps() => [
  for (final (i, (title, done)) in [
    ("Pull last quarter's notes", true), // l10n-ignore: data
    ('Draft three themes', true), // l10n-ignore: data
    ('Size each theme', false), // l10n-ignore: data
    ('Share with Sam', false), // l10n-ignore: data
  ].indexed)
    subtaskFixture().copyWith(
      id: 'step $i', // l10n-ignore: fixture id
      occurrenceId: _deep,
      title: title,
      done: done,
      sortOrder: i.toDouble(),
      durationMin: 20,
    ),
];

/// Pumps through a second of frames: transitions end, the tick goes on.
Future<void> settle(WidgetTester tester) async {
  for (var i = 0; i < 10; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(tz_data.initializeTimeZones);

  for (final mode in [ThemeMode.dark, ThemeMode.light]) {
    testWidgets('focus, ${mode.name}', (tester) async {
      Future<void> shot(String step) =>
          deviceShot(binding, tester, 'focus_${mode.name}_$step');
      final router = await pumpCalendar(
        tester,
        mode: mode,
        rows: _rows(),
        subtasks: _steps(),
      );
      router.go(AppRoutes.today);
      await tester.pumpAndSettle();

      // 1 · Deep work in Focus.
      unawaited(router.push(AppRoutes.focus(_deep)));
      // Focus ticks each second: it never settles.
      await settle(tester);
      expect(find.byType(FocusView), findsOneWidget);
      await shot('1_focus');

      // ‹ Today leaves, back where it came from.
      await tester.tap(find.text('Today').hitTestable().first); // l10n-ignore
      await settle(tester);
      expect(find.byType(FocusView), findsNothing);

      // 2 · A task past its planned end: nothing ends by itself.
      unawaited(router.push(AppRoutes.focus(_memo)));
      await settle(tester);
      expect(find.text('0 min left'), findsWidgets); // l10n-ignore
      await shot('2_past_end');

      // 3 · +15 min: it stays, with its toast.
      final more = find.text('+15 min'); // l10n-ignore
      await tester.ensureVisible(more);
      await settle(tester);
      await tester.tap(more);
      for (var k = 0; k < 30 && find.text('Undo').evaluate().isEmpty; k++) {
        await tester.pump(const Duration(milliseconds: 100));
      }
      expect(find.text('Undo'), findsWidgets); // l10n-ignore
      await shot('3_extended');
      await settle(tester);
    });
  }
}
