import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

// M14 in the design sweep (docs/09 M14.7): Settings › Privacy's AI status,
// Settings › Siri & Shortcuts (iPhone), Brain dump with its mic and its
// proposal with the path's origin. What each shows depends on the device
// (a model, an on-device recognizer); listening and the first-use tip
// need the microphone prompt, which a sweep never answers, and the
// editor's NOTES sits in a lazy list that differs by width (two Mac runs
// lost it mid-scroll), so their goldens at every width cover them.

/// The M14 screens, each captured with [shot] once [until] finds it.
Future<void> sweepM14(
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

  router.go('/settings/privacy');
  await until(find.text('Help with thinking'));
  await Scrollable.ensureVisible(
    tester.element(find.text('Clear thinking history')),
  );
  await rest();
  await shot('privacy_ai_status');

  if (!kIsWeb && Platform.isIOS) {
    router.go('/settings/siri');
    await until(find.text('WHAT YOU CAN SAY'));
    await rest();
    await shot('siri_page');
  }

  router.go('/today');
  await rest();
  await menu('Brain dump');
  await until(find.text('Plan it'));
  await tester.enterText(dumpField(), 'Email Sam\nTaxes 45m');
  await rest();
  // "brain_dump_mic" where this device dictates on-device, else the
  // plain sheet again (D2: no mic).
  await shot(
    find.byTooltip('Dictate').evaluate().isEmpty
        ? 'brain_dump_no_mic'
        : 'brain_dump_mic',
  );
  await tester.tap(find.text('Plan it'));
  await until(find.text('Add to day'));
  await rest();
  await shot('proposal_origin');
  await tester.tap(find.text('Discard'));
  await rest();

  closeSheets();
  router.go('/today');
  await rest();
}

/// Brain dump's text field by its hint, with or without the mic (M14.5):
/// the wide inbox and Earlier dumps' search are fields too.
Finder dumpField() => find.byWidgetPredicate(
  (w) =>
      w is TextField &&
      const {
        'Everything on your mind, one thing per line',
        'Type or tap the mic. One thing per line.',
      }.contains(w.decoration?.hintText),
);
