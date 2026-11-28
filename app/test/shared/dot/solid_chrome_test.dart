import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/features/timeline/widgets/day_menu_chip.dart';
import 'package:dottoday/shared/dot/solid_chrome.dart';
import 'package:dottoday/shared/navigation/glass_capsule.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/test_app.dart';

/// Glass turns solid with a 1.5 outline under Reduce Transparency or
/// Increase Contrast (ED-248 C, E-G4-7-States D4).
void main() {
  Future<void> pump(
    WidgetTester tester, {
    bool reduce = false,
    bool contrast = false,
  }) async {
    tester.platformDispatcher.accessibilityFeaturesTestValue =
        FakeAccessibilityFeatures(highContrast: contrast);
    addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);
    await tester.pumpWidget(
      testApp(
        ReduceTransparencyScope(
          on: reduce,
          child: const Column(
            children: [
              GlassCapsule(child: SizedBox(width: 80, height: 44)),
              DayMenuChip(),
            ],
          ),
        ),
      ),
    );
  }

  Border? border(WidgetTester tester, Finder of) {
    final boxes = tester.widgetList<DecoratedBox>(
      find.descendant(of: of, matching: find.byType(DecoratedBox)),
    );
    for (final b in boxes) {
      final d = b.decoration;
      if (d is BoxDecoration && d.border is Border) return d.border! as Border;
    }
    final c = tester.widget<Container>(
      find.descendant(of: of, matching: find.byType(Container)).first,
    );
    return (c.decoration as BoxDecoration?)?.border as Border?;
  }

  testWidgets('standard: the capsule is glass, Day ▾ has no outline', (
    tester,
  ) async {
    await pump(tester);
    expect(find.byType(BackdropFilter), findsOneWidget);
    expect(border(tester, find.byType(DayMenuChip)), isNull);
  });

  for (final (name, reduce, contrast) in [
    ('Reduce Transparency', true, false),
    ('Increase Contrast', false, true),
  ]) {
    testWidgets('$name: solid, with a 1.5 outline in secondary', (
      tester,
    ) async {
      await pump(tester, reduce: reduce, contrast: contrast);
      expect(find.byType(BackdropFilter), findsNothing);
      final c = DotTheme.of(tester.element(find.byType(DayMenuChip))).colors;
      for (final of in [find.byType(GlassCapsule), find.byType(DayMenuChip)]) {
        final b = border(tester, of)!;
        expect(b.top.width, DotSize.solidOutline);
        expect(b.top.color, c.secondary);
      }
    });
  }

  testWidgets('Reduce Transparency alone keeps the standard colours', (
    tester,
  ) async {
    await pump(tester, reduce: true);
    final c = DotTheme.of(tester.element(find.byType(DayMenuChip))).colors;
    expect(c.secondary, DotColors.light().secondary);
  });
}
