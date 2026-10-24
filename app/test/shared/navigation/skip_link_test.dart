import 'package:dottoday/shared/navigation/skip_link.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/test_app.dart';

// docs/07 Web "skip-to-content link" (docs/09 M5.7).
void main() {
  Future<void> pump(WidgetTester tester) => tester.pumpWidget(
    testApp(
      SkipLink(
        label: 'Skip to content',
        builder: (content) => Row(
          children: [
            Column(
              children: [
                TextButton(onPressed: () {}, child: const Text('Today')),
                TextButton(onPressed: () {}, child: const Text('Inbox')),
              ],
            ),
            Expanded(
              child: Focus(
                focusNode: content,
                child: Center(
                  child: TextButton(
                    onPressed: () {},
                    child: const Text('First task'),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );

  double opacity(WidgetTester tester) => tester
      .widget<Opacity>(
        find.ancestor(
          of: find.text('Skip to content'),
          matching: find.byType(Opacity),
        ),
      )
      .opacity;

  bool focused(WidgetTester tester, String label) =>
      Focus.of(tester.element(find.text(label))).hasFocus;

  testWidgets('hidden until Tab reaches it first', (tester) async {
    await pump(tester);
    expect(opacity(tester), 0);
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pump();
    expect(opacity(tester), 1);
    expect(focused(tester, 'Skip to content'), isTrue);
  });

  testWidgets('Enter skips the navigation into the page', (tester) async {
    await pump(tester);
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pump();
    expect(focused(tester, 'First task'), isTrue);
    expect(focused(tester, 'Today'), isFalse);
    expect(opacity(tester), 0);
  });

  // Today and Week hold focus on an autofocused key catcher at load; the
  // first Tab must still reach the link (found in real Chromium, M8.7).
  testWidgets('first Tab from a key catcher reaches the link', (tester) async {
    await tester.pumpWidget(
      testApp(
        SkipLink(
          label: 'Skip to content',
          builder: (content) => Focus(
            focusNode: content,
            child: Focus(
              autofocus: true,
              skipTraversal: true,
              child: Column(
                children: [
                  TextButton(onPressed: () {}, child: const Text('Late')),
                ],
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pump();
    expect(focused(tester, 'Skip to content'), isTrue);
    expect(focused(tester, 'Late'), isFalse);
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pump();
    expect(focused(tester, 'Late'), isTrue);
  });
}
