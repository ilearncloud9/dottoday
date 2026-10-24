// Accessibility tree checks on a device (docs/08 §3 and §6.2, R-12): the
// same target and label floor the widget tests assert (test/support/a11y.dart),
// read from the semantics tree the OS screen reader gets on a simulator,
// emulator or the Mac. Contrast stays with the goldens and the widget tests:
// it needs a layer capture that integration_test doesn't give on every
// target.
import 'package:dottoday/core/theme/dot_metrics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';

const _guidelines = <String, AccessibilityGuideline>{
  'target44': MinimumTapTargetGuideline(
    size: Size.square(DotTouch.min),
    link: 'docs/03-ux-spec.md §1',
  ),
  'android48': androidTapTargetGuideline,
  'labelled': labeledTapTargetGuideline,
};

/// Collects one line per failed guideline, so a sweep reports every screen
/// before it fails (see [expectNoA11yFindings]).
final a11yFindings = <String>[];

/// Checks the screen on show now and prints `A11Y <screen> PASS|FAIL`.
Future<void> checkA11yTree(WidgetTester tester, String screen) async {
  final handle = tester.ensureSemantics();
  try {
    await tester.pump();
    final failed = <String>[];
    for (final MapEntry(:key, :value) in _guidelines.entries) {
      final result = await value.evaluate(tester);
      if (!result.passed) failed.add('$key: ${result.reason}');
    }
    debugPrint('A11Y $screen ${failed.isEmpty ? 'PASS' : 'FAIL'}');
    a11yFindings.addAll(failed.map((f) => '$screen — $f'));
  } finally {
    handle.dispose();
  }
}

/// Fails with every finding [checkA11yTree] collected.
void expectNoA11yFindings() {
  expect(a11yFindings, isEmpty, reason: a11yFindings.join('\n'));
}
