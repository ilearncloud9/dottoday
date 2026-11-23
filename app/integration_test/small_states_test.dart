// Small states (docs/09 M20.6 part 5; E-R2-28, ED-331): Move to (the month
// with each day's colours), Search with no results, a quiet week's review
// ("A quiet week: nothing was planned."), and the mission picker with its
// icons (owner, part 5; a mission this phone can't run stays listed,
// dimmed, saying why). In-memory data:
//   tool/device_tests.sh ios <udid> small_states       (DEVICE_SHOT)
//   tool/device_tests.sh android <serial> small_states
//   SWEEP_TARGET=integration_test/small_states_test.dart tool/mac_sweep.sh
//   flutter build web -t integration_test/small_states_test.dart \
//     --dart-define=SWEEP_HOST_SHOTS=true, served, then
//   SHOTS=small_states node tool/slice/web_journey.mjs <url> compact|expanded <b>
import 'dart:async';

import 'package:dottoday/core/router/app_routes.dart';
import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:dottoday/features/timeline/review/review_presenter.dart';
import 'package:dottoday/features/timeline/review/review_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:timezone/data/latest.dart' as tz_data;

import '../test/features/timeline/calendar/calendar_world.dart';
import 'support/device_shot.dart';

/// The month, with today's Deep work on a real id: a task link (`?task=`)
/// takes only UUIDs.
const _deep = '01928c3e-0000-7000-8000-0000000000b1';
List<Occurrence> _rows() => [
  for (final o in calendarMonth())
    o.id ==
            'cal 3 Deep work: roadmap' // l10n-ignore: fixture id
        ? o.copyWith(id: _deep)
        : o,
];

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(tz_data.initializeTimeZones);

  for (final mode in [ThemeMode.dark, ThemeMode.light]) {
    testWidgets('small states, ${mode.name}', (tester) async {
      Future<void> shot(String step) =>
          deviceShot(binding, tester, 'small_${mode.name}_$step');
      final router = await pumpCalendar(tester, mode: mode, rows: _rows());
      final width =
          tester.view.physicalSize.width / tester.view.devicePixelRatio;

      // 1 · Move to: the task's Move opens the month (phones' sheet).
      if (width < 600) {
        router.go(AppRoutes.today);
        await tester.pumpAndSettle();
        await tester.tap(find.text('Deep work: roadmap').hitTestable().first);
        await tester.pumpAndSettle();
        await tester.tap(find.text('Move').hitTestable().last); // l10n-ignore
        await tester.pumpAndSettle();
        await shot('1_move_to');
        // The month: the picker's Date… step (ED-099).
        final date = find.text('Date…').hitTestable(); // l10n-ignore
        if (date.evaluate().isNotEmpty) {
          await tester.tap(date.first);
          await tester.pumpAndSettle();
          await shot('1b_month');
          await tester.binding.handlePopRoute();
          await tester.pumpAndSettle();
        }
        await tester.binding.handlePopRoute();
        await tester.pumpAndSettle();
        await tester.binding.handlePopRoute();
        await tester.pumpAndSettle();
      }

      // 2 · Search with no results.
      router.go(AppRoutes.search);
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byType(EditableText).hitTestable().first,
        'car service invoice', // l10n-ignore: typed
      );
      await tester.pumpAndSettle();
      expect(
        find.textContaining('No matches'), // l10n-ignore
        findsWidgets,
      );
      await shot('2_no_results');

      // 3 · A quiet week: the review of Nov 30 – Dec 6, nothing planned.
      router.go(AppRoutes.today);
      await tester.pumpAndSettle();
      // Not awaited: it returns when the review closes.
      unawaited(
        openReview(
          tester.element(find.byType(Scaffold).hitTestable().first),
          day: DateTime(2026, 12, 6),
          page: ReviewPage.week,
        ),
      );
      await tester.pumpAndSettle();
      await shot('3_quiet_week');
      // No Back here: on wide windows the review is a pane, and Back at the
      // root would leave the app.
    });
  }
}
