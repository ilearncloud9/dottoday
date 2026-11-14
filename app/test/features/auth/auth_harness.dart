import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/account_screen_fakes.dart';
import '../../support/test_l10n.dart';

/// [home] at [size] with the real theme and l10n, the account actions
/// faked by [actions] (CR-160 screen tests).
Future<void> pumpAccountScreen(
  WidgetTester tester,
  Widget home, {
  required FakeAccountActions actions,
  Size size = const Size(390, 844),
  TargetPlatform platform = TargetPlatform.iOS,
  bool browser = false,
  int pending = 0,
  List<Override> overrides = const [],
}) async {
  tester.view
    ..physicalSize = size
    ..devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        ...accountScreenOverrides(actions, pending: pending, browser: browser),
        ...overrides,
      ],
      child: MaterialApp(
        theme: DotTheme.light().copyWith(platform: platform),
        localizationsDelegates: testL10nDelegates,
        supportedLocales: testL10nLocales,
        locale: testL10nLocale,
        home: home,
      ),
    ),
  );
  await tester.pumpAndSettle();
}

/// Whether the button with [label] can be pressed.
bool enabled(WidgetTester tester, String label) {
  final button = tester.widget<ButtonStyleButton>(
    find.ancestor(
      of: find.text(label),
      matching: find.byWidgetPredicate((w) => w is ButtonStyleButton),
    ),
  );
  return button.onPressed != null;
}

/// Scrolls [finder] into view (long screens, 200 % text), then taps it.
Future<void> tapIn(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
  await tester.tap(finder);
}
