import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

// M12 in the design sweep (docs/09 M12.6): This week, low-energy mode,
// Search › Past days, and a brain dump with its proposal, on the demo day
// and the M11 sample.

/// The M12 screens, each captured with [shot] once [until] finds it.
Future<void> sweepM12(
  WidgetTester tester, {
  required Future<void> Function(String name) shot,
  required Future<void> Function(Finder finder) until,
  required Future<void> Function() rest,
}) async {
  final router = GoRouter.of(tester.element(find.byType(Scaffold).first));
  Future<void> menu(String item) async {
    await tester.tap(find.byTooltip('More options').first);
    await until(find.text(item));
    await tester.pump(const Duration(milliseconds: 600));
    await tester.tap(find.text(item).last);
    await rest();
  }

  void closeSheets() => Navigator.of(
    tester.element(find.byType(Scaffold).first),
    rootNavigator: true,
  ).popUntil((r) => r.isFirst);

  router.go('/today');
  await rest();
  await menu('This week');
  await until(find.text('No streaks here — just what happened.'));
  await rest();
  await shot('week_review');
  closeSheets();
  await rest();

  await menu('Low-energy mode');
  await until(find.text('Low-energy · on'));
  await rest();
  await shot('low_energy');
  await menu('Turn off low-energy mode');

  // The sweep searched earlier: Past days shows while nothing is typed.
  router.go('/search');
  await until(find.byType(TextField));
  await tester.enterText(find.byType(TextField).first, '');
  await until(find.text('Past days'));
  await tester.tap(find.text('Past days'));
  await until(find.text('When did I last…'));
  await rest();
  await shot('past_days');
  await tester.pageBack();
  await rest();

  router.go('/today');
  await rest();
  await menu('Brain dump');
  await until(find.text('Plan it'));
  // By its hint: the wide inbox and Earlier dumps' search are fields too.
  await tester.enterText(
    find.widgetWithText(
      TextField,
      'Everything on your mind, one thing per line',
    ),
    'Email Sam\nTaxes 45m\nCall the bank 4pm',
  );
  await rest();
  await shot('brain_dump');
  await tester.tap(find.text('Plan it'));
  await until(find.text('Add to day'));
  await rest();
  await shot('brain_dump_proposal');
  await tester.tap(find.text('Discard'));
  await rest();
  closeSheets();
  await rest();
}
