import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';

/// Our touch-target floor from docs/03 §1 (44 × 44 pt), read from the token.
const _minTouchTarget = MinimumTapTargetGuideline(
  size: Size.square(DotTouch.min),
  link: 'docs/03-ux-spec.md §1 "Touch targets ≥ 44×44 pt"',
);

/// The pointer floor (WCAG 2.2 · 2.5.8, 24 px): the Mac and a
/// mouse-driven browser draw the Workspace at pointer sizes (ED-260,
/// ED-261, owner M19.2). Touch keeps 44 / 48.
const _minPointerTarget = MinimumTapTargetGuideline(
  size: Size.square(DotTouch.pointer),
  link: 'WCAG 2.2 · 2.5.8; ED-260, ED-261',
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
/// node labelled, and WCAG text contrast (4.5:1 / 3:1 large). On the Mac
/// (no touch) the target floor is the pointer's, 24 px.
Future<void> expectA11yGuidelines(WidgetTester tester) async {
  final handle = tester.ensureSemantics();
  try {
    if (defaultTargetPlatform == TargetPlatform.macOS) {
      await expectLater(tester, meetsGuideline(_minPointerTarget));
    } else {
      await expectLater(tester, meetsGuideline(_minTouchTarget));
      await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
    }
    await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
    await expectLater(tester, meetsGuideline(textContrastGuideline));
  } finally {
    handle.dispose();
  }
}
