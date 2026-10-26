import 'package:dottoday/shared/learning/learned_line.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

// M13 in the design sweep (docs/13 §11, docs/09 M13.8): Settings ›
// Learning, and a learned value's explanation open on the reality thread.
// The day-card caption shows only before the reveal, which the M11 sample
// has passed; its goldens cover it.

/// The M13 screens, each captured with [shot] once [until] finds it.
Future<void> sweepM13(
  WidgetTester tester, {
  required Future<void> Function(String name) shot,
  required Future<void> Function(Finder finder) until,
  required Future<void> Function() rest,
}) async {
  final router = GoRouter.of(tester.element(find.byType(Scaffold).first));
  router.go('/settings');
  await rest();
  await until(find.text('Send feedback'));
  // Settings keeps its scroll position from earlier legs: LEARNING may be
  // above or below.
  final list = find.byType(Scrollable).first;
  for (final step in [-300.0, 300.0]) {
    if (find.text('LEARNING').evaluate().isNotEmpty) break;
    await tester
        .scrollUntilVisible(
          find.text('LEARNING'),
          step,
          scrollable: list,
          maxScrolls: 20,
        )
        // Not this way: the other direction tries next, and ensureVisible
        // below fails loudly if neither found it.
        .catchError((Object _) {});
  }
  await Scrollable.ensureVisible(tester.element(find.text('LEARNING')));
  await rest();
  await shot('settings_learning');

  router.go('/today');
  await until(find.text('Reality'));
  await tester.tap(find.text('Reality').first);
  await rest();
  final learned = find.byType(LearnedLine);
  await until(learned);
  await tester.ensureVisible(learned.first);
  await rest();
  await tester.tap(learned.first);
  await rest();
  await shot('learned_explained');
  await tester.tap(learned.first);
  await tester.tap(find.text('Plan').first);
  await rest();
}
