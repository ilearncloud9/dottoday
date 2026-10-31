import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

// M17 in the design sweep (docs/15 W1): Settings › Day shape with the
// Wake Up alarm switched on (its tier line, and Allow where something is
// in the way), its Wake Up options page (M17.2), the Wake Up card (M17.3),
// then Notification
// health's Wake Up row. The switch goes back off, so later runs start as
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

  // The Wake Up card (M17.3); once shown it doesn't open by itself again
  // today, so later legs see Today.
  router.go('/wake-up');
  await until(find.text('Later'));
  await rest();
  await shot('wake_up_card');

  router.go('/settings/notifications');
  await rest();
  await shot('health_wake_up');

  await open();
  await tester.tap(alarm);
  await rest();
}
