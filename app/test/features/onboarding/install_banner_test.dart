import 'package:dottoday/data/pwa/install_prompt.dart';
import 'package:dottoday/features/onboarding/install_banner.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/a11y.dart';
import '../../support/test_app.dart';

final class _Prompt implements InstallPrompt {
  var installs = 0;
  var dismissals = 0;

  @override
  Future<bool> install() async {
    installs++;
    return true;
  }

  @override
  void dismiss() => dismissals++;
}

// docs/07 Web: install prompt after the 2nd visit (docs/09 M5.7).
void main() {
  late _Prompt prompt;
  late bool available;

  Future<void> pump(WidgetTester tester) async {
    prompt = _Prompt();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          installPromptProvider.overrideWithValue(prompt),
          installAvailableProvider.overrideWith(
            (ref) => Stream.value(available),
          ),
        ],
        child: testApp(
          const Scaffold(body: Column(children: [InstallBanner()])),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('nothing before the browser offers it', (tester) async {
    available = false;
    await pump(tester);
    expect(find.text('Install'), findsNothing);
  });

  testWidgets('Install opens the browser dialog', (tester) async {
    available = true;
    await pump(tester);
    expect(
      find.text('Install Dottoday: opens like an app and works offline'),
      findsOneWidget,
    );
    await expectA11yGuidelines(tester);
    await tester.tap(find.text('Install'));
    await tester.pumpAndSettle();
    expect(prompt.installs, 1);
  });

  testWidgets('Not now hides it for good', (tester) async {
    available = true;
    await pump(tester);
    await tester.tap(find.text('Not now'));
    available = false;
    await tester.pumpAndSettle();
    expect(prompt.dismissals, 1);
    expect(find.text('Install'), findsNothing);
  });
}
