import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';

/// Our touch-target floor from docs/03 §1 (44 × 44 pt), read from the token.
const _minTouchTarget = MinimumTapTargetGuideline(
  size: Size.square(DotTouch.min),
  link: 'docs/03-ux-spec.md §1 "Touch targets ≥ 44×44 pt"',
);

/// Asserts the currently pumped UI meets the accessibility floor (docs/08 §3,
/// R-12). Every screen test calls this once per state it renders:
///
/// ```dart
/// await tester.pumpWidget(testRouterApp(router));
/// await expectA11yGuidelines(tester);
/// ```
///
/// Checks: ≥ 44 pt targets (token), Android 48 dp targets, every tappable
/// node labelled, and WCAG text contrast (4.5:1 / 3:1 large).
Future<void> expectA11yGuidelines(WidgetTester tester) async {
  final handle = tester.ensureSemantics();
  try {
    await expectLater(tester, meetsGuideline(_minTouchTarget));
    await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
    await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
    await expectLater(tester, meetsGuideline(textContrastGuideline));
  } finally {
    handle.dispose();
  }
}
