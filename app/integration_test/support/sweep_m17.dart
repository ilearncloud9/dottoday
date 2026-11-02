import 'package:dottoday/shared/learning/wake_up_explain_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

// M17 in the design sweep (docs/15 W1): Settings › Day shape with the
// Wake Up alarm switched on (its tier line, and Allow where something is
// in the way), its Wake Up options page (M17.2), the Wake Up card (M17.3),
// How it works (M17.6) and Sounds to vary, a mission screen (Breathe,
// M17.7a: still until touched), the one-thing pick (M17.7b), then
// Notification health's Wake Up row. The switch goes back off, so later runs start as
// an upgrade does.

/// The Wake Up alarm's screens, each captured with [shot].
Future<void> sweepM17(
  WidgetTester tester, {
  required Future<void> Function(String name) shot,
  required Future<void> Function(Finder finder) until,
  required Future<void> Function() rest,
}) async {
  final router = GoRouter.of(tester.element(find.byType(Scaffold).first));
  final alarm = find.text('Wake Up alarm');
  // Settings may be scrolled down by an earlier leg; Day shape is at the
  // top of its lazy list.
  Future<void> open() async {
    router.go('/settings');
    await until(find.text('Settings'));
    await tester.dragUntilVisible(
      alarm,
      find.byType(Scrollable).first,
      const Offset(0, 300),
    );
    await rest();
  }

  await open();
  await tester.tap(alarm);
  await rest();
  await shot('settings_wake_up');

  router.go('/settings/wakeUp');
  await until(find.text('Snooze length'));
  await rest();
  await shot('wake_up_options');

  // Discovery's explain sheet (M17.6) and the sounds that rotate.
  await tester.tap(find.text('How it works'));
  await rest();
  await shot('wake_up_explain');
  Navigator.of(tester.element(find.byType(WakeUpExplain))).pop();
  await rest();
  // Sounds to vary shows once Vary the sound is on; it goes back off.
  final vary = find.text('Vary the sound');
  await tester.dragUntilVisible(
    vary,
    find.byType(Scrollable).first,
    const Offset(0, -300),
  );
  // A run stopped midway may have left it on: flip it only when off.
  final wasOff = find.text('Sounds to vary').evaluate().isEmpty;
  if (wasOff) {
    await tester.tap(vary);
    await rest();
  }
  await tester.dragUntilVisible(
    find.text('Sounds to vary'),
    find.byType(Scrollable).first,
    const Offset(0, -300),
  );
  await tester.tap(find.text('Sounds to vary'));
  await rest();
  await shot('wake_up_rotation');
  Navigator.of(tester.element(find.text('Dawn chorus').last)).pop();
  await rest();
  if (wasOff) {
    await tester.tap(vary);
    await rest();
  }

  // The Wake Up card (M17.3); once shown it doesn't open by itself again
  // today, so later legs see Today.
  router.go('/wake-up');
  await until(find.text('Later'));
  await rest();
  await shot('wake_up_card');

  // A mission (docs/15 §8). Breathe needs no sensor and holds still until
  // touched; leaving it ends nothing, so no alarm is touched.
  router.go('/wake-up/mission/2099-01-01/breathe');
  await until(find.text('Breathe with the ring'));
  await rest();
  await shot('wake_up_mission');

  // Pick today's one thing (M17.7b), from its mission route.
  router.go('/wake-up/mission/2099-01-01/oneThing');
  await rest();
  await shot('wake_up_one_thing');

  router.go('/settings/notifications');
  await rest();
  await shot('health_wake_up');

  await open();
  await tester.tap(alarm);
  await rest();
}
