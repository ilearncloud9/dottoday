// Touch drag on a phone (docs/09 M20.5 part 1, E-R2-25 §1, ED-328): hold
// Lunch to lift it, move it over the day (the dot with its time, the
// landing preview), Shift later tasks, the All day cap, the Trash bin and
// the Inbox tab, then let it go on the day: the toast with Undo.
// In-memory data:
//   tool/device_tests.sh ios <udid> touch_drag       (DEVICE_SHOT)
//   tool/device_tests.sh android <serial> touch_drag
//   flutter build web -t integration_test/touch_drag_test.dart \
//     --dart-define=SWEEP_HOST_SHOTS=true, served, then
//   SHOTS=touch_drag node tool/slice/web_journey.mjs <url> compact <browser>
import 'package:dottoday/core/router/app_routes.dart';
import 'package:dottoday/shared/navigation/drag_targets.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:timezone/data/latest.dart' as tz_data;

import '../test/features/timeline/calendar/calendar_world.dart';
import 'support/device_shot.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(tz_data.initializeTimeZones);

  /// Moves the held finger to [to] in small steps, as a hand would.
  Future<void> glide(
    WidgetTester tester,
    TestGesture g,
    Offset from,
    Offset to,
  ) async {
    const steps = 12;
    for (var i = 1; i <= steps; i++) {
      await g.moveTo(Offset.lerp(from, to, i / steps)!);
      await tester.pump(const Duration(milliseconds: 16));
    }
    await tester.pump(const Duration(milliseconds: 300));
  }

  for (final mode in [ThemeMode.dark, ThemeMode.light]) {
    testWidgets('touch drag, ${mode.name}', (tester) async {
      Future<void> shot(String step) =>
          deviceShot(binding, tester, 'drag_${mode.name}_$step');
      final router = await pumpCalendar(tester, mode: mode);
      router.go(AppRoutes.today);
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(
        find.text('Lunch'), // l10n-ignore: data
        120,
        scrollable: _onScreenList(tester),
      );
      // A third of the way down, with room to move under it.
      await Scrollable.ensureVisible(
        tester.element(find.text('Lunch').first), // l10n-ignore: data
        alignment: 0.3,
      );
      await tester.pumpAndSettle();
      final lunch = find.text('Lunch').hitTestable(); // l10n-ignore: data
      var at = tester.getCenter(lunch.first);
      final g = await tester.startGesture(at, kind: PointerDeviceKind.touch);
      // The 250 ms hold lifts it.
      await tester.pump(const Duration(milliseconds: 400));
      // Down over the free time after it: the time and the preview.
      var next = at.translate(0, 110);
      await glide(tester, g, at, next);
      at = next;
      final over = at;
      await shot('1_lifted');
      await tester.tap(find.text('Shift later tasks')); // l10n-ignore
      await tester.pump(const Duration(milliseconds: 300));
      await shot('2_shift');
      final bin = find.byType(TrashDropZone);
      if (bin.evaluate().isNotEmpty) {
        next = tester.getCenter(bin);
        await glide(tester, g, at, next);
        at = next;
        await shot('3_bin');
      }
      final tab = find.byType(TaskDropTab);
      if (tab.evaluate().isNotEmpty) {
        next = tester.getCenter(tab.first);
        await glide(tester, g, at, next);
        at = next;
        await shot('4_inbox');
      }
      // Back where the preview was, and let go: one move, with Undo.
      await glide(tester, g, at, over);
      await g.up();
      await tester.pump(const Duration(milliseconds: 600));
      expect(find.text('Undo'), findsWidgets);
      await shot('5_dropped');
      await tester.pumpAndSettle(const Duration(seconds: 2));
      // The Wake Up cap is the All day drop: from the day's top, hold the
      // first task that can move and bring it onto the cap.
      await tester.fling(_onScreenList(tester), const Offset(0, 3000), 3000);
      await tester.pumpAndSettle();
      final wake = find.textContaining('Wake Up').hitTestable(); // l10n-ignore
      Finder? task;
      for (final title in ['Deep work: roadmap', 'Call with Sam', 'Lunch']) {
        final f = find.text(title).hitTestable(); // l10n-ignore: finder
        if (f.evaluate().isNotEmpty) {
          task = f;
          break;
        }
      }
      if (task != null && wake.evaluate().isNotEmpty) {
        at = tester.getCenter(task.first);
        final h = await tester.startGesture(at);
        await tester.pump(const Duration(milliseconds: 400));
        next = tester.getCenter(wake.first);
        await glide(tester, h, at, next);
        await shot('6_all_day');
        await glide(tester, h, next, at);
        await h.up();
        await tester.pumpAndSettle(const Duration(seconds: 2));
      }
    });
  }
}

/// The widest vertical list on screen: offstage branches keep theirs
/// mounted, and the rail has its own.
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
