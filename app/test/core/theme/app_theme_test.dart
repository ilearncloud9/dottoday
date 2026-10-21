import 'package:dottoday/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// WCAG 2.x contrast ratio between two opaque colours.
double _contrast(Color a, Color b) {
  final la = a.computeLuminance();
  final lb = b.computeLuminance();
  final (hi, lo) = la > lb ? (la, lb) : (lb, la);
  return (hi + 0.05) / (lo + 0.05);
}

Future<AppTheme> _resolve(
  WidgetTester tester, {
  required bool reduceMotion,
}) async {
  late AppTheme resolved;
  await tester.pumpWidget(
    MediaQuery(
      data: MediaQueryData(disableAnimations: reduceMotion),
      child: Theme(
        data: AppTheme.light(),
        child: Builder(
          builder: (context) {
            resolved = AppTheme.of(context);
            return const SizedBox();
          },
        ),
      ),
    ),
  );
  return resolved;
}

void main() {
  group('tokens (docs/03 §1)', () {
    test('spacing is a 4-pt grid and radii match spec', () {
      const grid = [
        AppSpacing.xs,
        AppSpacing.s,
        AppSpacing.m,
        AppSpacing.l,
        AppSpacing.xl,
        AppSpacing.xxl,
      ];
      expect(grid, [4, 8, 12, 16, 24, 32]);
      expect([AppRadii.block, AppRadii.card, AppRadii.sheet], [10, 14, 20]);
      expect(AppSpacing.minTouchTarget, greaterThanOrEqualTo(44));
    });

    test('type scale sizes, line heights and weights', () {
      final t = AppTypography.withColor(const Color(0xFF000000));
      expect(t.display.fontSize, 28);
      expect(t.display.fontSize! * t.display.height!, closeTo(34, 0.01));
      expect(t.title.fontWeight, FontWeight.w600);
      expect(t.body.fontSize, 16);
      expect(t.label.fontWeight, FontWeight.w500);
      expect(t.mono.fontFeatures, contains(const FontFeature.tabularFigures()));
    });

    for (final (name, c) in [
      ('light', AppColors.light),
      ('dark', AppColors.dark),
    ]) {
      test('$name: muted and primary text reach 4.5:1 on surfaces', () {
        for (final bg in [c.surface, c.surfaceRaised]) {
          expect(_contrast(c.onSurface, bg), greaterThanOrEqualTo(4.5));
          expect(_contrast(c.onSurfaceMuted, bg), greaterThanOrEqualTo(4.5));
        }
      });
    }
  });

  group('AppTheme.of', () {
    testWidgets('standard motion by default', (tester) async {
      final t = await _resolve(tester, reduceMotion: false);
      expect(t.motion.base, const Duration(milliseconds: 200));
      expect(t.motion.curve, Curves.easeOutCubic);
    });

    testWidgets('zero durations when reduced motion is on', (tester) async {
      final t = await _resolve(tester, reduceMotion: true);
      expect(
        [t.motion.fast, t.motion.base, t.motion.slow],
        [Duration.zero, Duration.zero, Duration.zero],
      );
    });

    testWidgets('asserts when the extension is missing', (tester) async {
      await tester.pumpWidget(
        Theme(
          data: ThemeData(),
          child: Builder(
            builder: (context) {
              AppTheme.of(context);
              return const SizedBox();
            },
          ),
        ),
      );
      expect(tester.takeException(), isA<AssertionError>());
    });

    test('light and dark ThemeData carry their own tokens', () {
      expect(AppTheme.light().extension<AppTheme>()!.colors, AppColors.light);
      expect(AppTheme.dark().extension<AppTheme>()!.colors, AppColors.dark);
      expect(AppTheme.dark().colorScheme.brightness, Brightness.dark);
    });
  });
}
