import 'package:dottoday/data/profile/settings_actions.dart';
import 'package:dottoday/domain/entities/enums.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

// M11 in the design sweep (docs/09 M11.6): the Reality thread, the
// Routines page, a routine drop's proposal and the routine editor, on the
// debug menu's M11 sample.

/// `SWEEP_THEME=dark` runs the whole sweep dark through Settings › Theme,
/// so the device's own appearance is never touched.
const sweepTheme = String.fromEnvironment('SWEEP_THEME', defaultValue: 'light');

ProviderContainer _container(WidgetTester tester) =>
    ProviderScope.containerOf(tester.element(find.byType(Scaffold).first));

/// Applies [sweepTheme] (light leaves the device default alone).
Future<void> applySweepTheme(WidgetTester tester) async {
  if (sweepTheme != 'dark') return;
  await updateSettings(
    _container(tester),
    (s) => s.copyWith(theme: ThemePreference.dark),
  );
}

/// The M11 sample from the debug menu (real times, routines; the same
/// data the web sweep loads).
Future<void> seedM11(
  WidgetTester tester, {
  required Future<void> Function(Finder finder) until,
}) async {
  await tester.tap(find.byTooltip('More options').first);
  await until(find.text('Load M11 sample (debug)'));
  await tester.pump(const Duration(milliseconds: 600));
  await tester.tap(find.text('Load M11 sample (debug)'));
  await until(find.text('Reality'));
  await tester.pump(const Duration(seconds: 5)); // the snackbar leaves
}

/// The M11 screens, each captured with [shot] once [until] finds it.
Future<void> sweepM11(
  WidgetTester tester, {
  required Future<void> Function(String name) shot,
  required Future<void> Function(Finder finder) until,
  required Future<void> Function() rest,
}) async {
  final router = GoRouter.of(tester.element(find.byType(Scaffold).first));
  router.go('/today');
  await until(find.text('Reality'));
  await tester.tap(find.text('Reality').first);
  await rest();
  await shot('reality');
  await tester.tap(find.text('Plan').first);
  await rest();

  router.go('/settings/routines');
  await until(find.text('Reusable slices of thread'));
  await rest();
  await shot('routines');
  await tester.tap(find.text('Drop on today').first);
  await until(find.text('Add to day'));
  await rest();
  await shot('routine_drop');
  await tester.tap(find.text('Discard'));
  await rest();
  await tester.tap(find.text('Edit').first);
  await until(find.text('Edit routine'));
  await rest();
  await shot('routine_editor');
  Navigator.of(
    tester.element(find.byType(Scaffold).first),
    rootNavigator: true,
  ).popUntil((r) => r.isFirst);
  await rest();
}
