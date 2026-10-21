import 'package:dottoday/app_screens.dart';
import 'package:dottoday/core/router/app_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/a11y.dart';
import '../support/test_app.dart';

/// Compact (bottom bar) and expanded (rail) × light and dark (docs/08 §3).
void main() {
  for (final size in [const Size(400, 800), const Size(1000, 700)]) {
    for (final mode in [ThemeMode.light, ThemeMode.dark]) {
      testWidgets('shell meets a11y guidelines ($size, ${mode.name})', (
        tester,
      ) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.reset);
        final router = buildRouter(appScreens);
        addTearDown(router.dispose);
        await tester.pumpWidget(testRouterApp(router, themeMode: mode));
        await tester.pumpAndSettle();

        await expectA11yGuidelines(tester);
      });
    }
  }
}
