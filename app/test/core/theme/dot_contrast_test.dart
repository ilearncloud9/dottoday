import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Increase Contrast's roles (ED-248 C, E-G4-7-States D4, ED-502):
/// secondary text a step further from the ground in both themes, the
/// thread ahead and every edge at 3:1 or more.
void main() {
  final themes = {
    'light': DotColors.light(),
    'dark': DotColors.dark(),
    'custom light': DotColors.custom(Brightness.light, const Color(0xFF8B5CF6)),
    'custom dark': DotColors.custom(Brightness.dark, const Color(0xFF8B5CF6)),
  };

  test('secondary text is one step stronger, as drawn', () {
    expect(DotColors.light().moreContrast().secondary, const Color(0xFF4E4757));
    expect(DotColors.dark().moreContrast().secondary, const Color(0xFFDDD5D9));
  });

  for (final MapEntry(key: name, value: c) in themes.entries) {
    test('$name: text at 4.5:1, edges and the thread at 3:1', () {
      final m = c.moreContrast();
      for (final ground in [m.ground, m.card]) {
        expect(contrastRatio(m.secondary, ground), greaterThan(4.5));
        expect(
          contrastRatio(m.secondary, ground),
          greaterThan(contrastRatio(c.secondary, ground)),
        );
        for (final edge in [
          m.hairline,
          m.hairlineStrong,
          m.controlOutline,
          m.blockEdge,
          m.threadAhead,
          m.threadOnRaised,
        ]) {
          expect(contrastRatio(edge, ground), greaterThanOrEqualTo(3));
        }
      }
      // The accent and the hour grid keep their standard values.
      expect(m.accent, c.accent);
      expect(m.gridLine, c.gridLine);
    });
  }

  testWidgets('DotTheme.of gives the stronger roles and styles', (
    tester,
  ) async {
    late DotTheme seen;
    tester.platformDispatcher.accessibilityFeaturesTestValue =
        const FakeAccessibilityFeatures(highContrast: true);
    addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);
    await tester.pumpWidget(
      MaterialApp(
        theme: DotTheme.light(),
        home: Builder(
          builder: (context) {
            seen = DotTheme.of(context);
            return const SizedBox();
          },
        ),
      ),
    );
    expect(seen.colors.secondary, const Color(0xFF4E4757));
    expect(seen.styles.rowMeta.color, const Color(0xFF4E4757));
  });
}
