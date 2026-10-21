import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Future<DotTheme> _resolve(
  WidgetTester tester, {
  required bool reduceMotion,
}) async {
  late DotTheme resolved;
  await tester.pumpWidget(
    MediaQuery(
      data: MediaQueryData(disableAnimations: reduceMotion),
      child: Theme(
        data: DotTheme.light(),
        child: Builder(
          builder: (context) {
            resolved = DotTheme.of(context);
            return const SizedBox();
          },
        ),
      ),
    ),
  );
  return resolved;
}

void main() {
  group('colour roles (docs/10 §2.1)', () {
    test('default light and dark values', () {
      final l = DotColors.light();
      final d = DotColors.dark();
      expect(
        [l.surface, l.raised, l.text, l.muted, l.outline, l.hairline],
        const [
          Color(0xFFFAFAF8),
          Color(0xFFFFFFFF),
          Color(0xFF1A1A1C),
          Color(0xFF6B6B70),
          Color(0xFFE2E2DE),
          Color(0xFFC9C9C4),
        ],
      );
      expect(
        [d.surface, d.raised, d.text, d.muted, d.outline, d.hairline],
        const [
          Color(0xFF121214),
          Color(0xFF1C1C20),
          Color(0xFFF2F2F0),
          Color(0xFF9A9AA0),
          Color(0xFF2C2C32),
          Color(0xFF3A3A40),
        ],
      );
      expect(l.accent, const Color(0xFF3B6CF6));
      expect(l.onAccent, const Color(0xFFFFFFFF));
      expect(d.accent, const Color(0xFF7FA0FF));
      expect(d.onAccent, const Color(0xFF0B1020));
      expect(l.accentTint.a, closeTo(0.12, 0.01));
      expect(d.accentTint.a, closeTo(0.22, 0.01));
      expect(l.success, const Color(0xFF2FA37A));
    });

    for (final a in DotAccent.values) {
      for (final c in [DotColors.light(a), DotColors.dark(a)]) {
        test('${a.key} ${c.brightness.name}: text roles reach 4.5:1', () {
          final tint = Color.alphaBlend(c.accentTint, c.raised);
          for (final bg in [c.surface, c.raised]) {
            expect(contrastRatio(c.text, bg), greaterThanOrEqualTo(4.5));
            expect(contrastRatio(c.muted, bg), greaterThanOrEqualTo(4.5));
            expect(contrastRatio(c.accentInk, bg), greaterThanOrEqualTo(4.5));
          }
          expect(contrastRatio(c.accentInk, tint), greaterThanOrEqualTo(4.5));
          expect(
            contrastRatio(c.onAccent, c.accent),
            greaterThanOrEqualTo(4.5),
          );
        });
      }
    }

    test('the default light accent is its own ink on raised cards', () {
      final l = DotColors.light();
      expect(contrastRatio(l.accent, l.raised), greaterThanOrEqualTo(4.5));
    });
  });

  group('type, shape and size tokens (docs/10 §2.2–2.3)', () {
    final t = DotType.withColors(text: Colors.black, muted: Colors.grey);

    test('type roles', () {
      expect(
        [t.pageTitle.fontSize, t.pageTitle.fontWeight],
        [28, FontWeight.w700],
      );
      expect(t.pageTitle.letterSpacing, closeTo(-0.56, 1e-9));
      expect(t.pageTitleExpanded.fontSize, 30);
      expect(
        [t.topBarTitle.fontSize, t.topBarTitle.fontWeight],
        [22, FontWeight.w600],
      );
      expect([t.caption.fontSize, t.caption.fontWeight], [12, FontWeight.w600]);
      expect(t.caption.color, Colors.grey);
      expect(
        [t.cardTitle.fontSize, t.cardTitle.fontWeight],
        [15, FontWeight.w700],
      );
      expect(
        [t.rowTitle.fontSize, t.rowTitle.fontWeight],
        [16, FontWeight.w500],
      );
      expect(
        [t.liveRowTitle.fontSize, t.liveRowTitle.fontWeight],
        [17, FontWeight.w600],
      );
      expect([t.rowMeta.fontSize, t.rowMeta.color], [12, Colors.grey]);
      expect(
        [t.tabLabel.fontSize, t.tabLabelActive.fontWeight],
        [10, FontWeight.w600],
      );
      expect(t.androidTab(t.tabLabel).fontSize, 12);
      expect(
        t.rowMeta.fontFeatures,
        contains(const FontFeature.tabularFigures()),
      );
      expect(t.rowTitle.fontFamily, 'Inter');
    });

    test('radii and sizes', () {
      expect([DotRadii.card, DotRadii.cardLarge, DotRadii.sheet], [16, 18, 28]);
      expect(
        [DotRadii.fabAndroid, DotRadii.railItem, DotRadii.pill],
        [16, 16, 999],
      );
      expect(
        [DotSize.rowDot, DotSize.liveDot, DotSize.liveRing, DotSize.dayDot],
        [36, 42, 5, 44],
      );
      expect(
        [DotSize.macRowDot, DotSize.pickerDot, DotSize.weekDot],
        [26, 22, 8],
      );
      expect([DotSize.segment, DotSize.freeLine], [6, 2]);
      expect([DotSize.nowMarker, DotSize.nowHalo], [16, 4]);
      expect([DotTouch.min, DotTouch.android], [44, 48]);
    });

    test('width classes (docs/10 §4)', () {
      expect(WidthClass.of(390), WidthClass.compact);
      expect(WidthClass.of(599.9), WidthClass.compact);
      expect(WidthClass.of(600), WidthClass.medium);
      expect(WidthClass.of(839), WidthClass.medium);
      expect(WidthClass.of(840), WidthClass.expanded);
      expect(WidthClass.of(1280), WidthClass.expanded);
    });
  });

  group('DotTheme.of (docs/10 §2.4)', () {
    testWidgets('motion is 180–240 ms ease-out', (tester) async {
      final t = await _resolve(tester, reduceMotion: false);
      for (final d in [t.motion.fast, t.motion.base, t.motion.slow]) {
        expect(d.inMilliseconds, inInclusiveRange(180, 240));
      }
      expect(t.motion.curve, Curves.easeOut);
      expect(t.motion.isReduced, isFalse);
    });

    testWidgets('all animation collapses to 0 under reduced motion', (
      tester,
    ) async {
      final t = await _resolve(tester, reduceMotion: true);
      expect([
        t.motion.fast,
        t.motion.base,
        t.motion.slow,
      ], everyElement(Duration.zero));
      expect(t.motion.isReduced, isTrue);
    });

    testWidgets('asserts when the extension is missing', (tester) async {
      await tester.pumpWidget(
        Theme(
          data: ThemeData(),
          child: Builder(
            builder: (context) {
              DotTheme.of(context);
              return const SizedBox();
            },
          ),
        ),
      );
      expect(tester.takeException(), isA<AssertionError>());
    });

    test('ThemeData carries tokens for its brightness and accent', () {
      final dark = DotTheme.dark(DotAccent.teal);
      final ext = dark.extension<DotTheme>()!;
      expect(dark.colorScheme.brightness, Brightness.dark);
      expect(ext.colors.accent, DotAccent.teal.dark);
      expect(dark.colorScheme.primary, DotAccent.teal.dark);
      expect(ext.tasks[TaskColor.rose].color, TaskColor.rose.color);
      expect(
        DotTheme.light().extension<DotTheme>()!.colors.surface,
        DotColors.light().surface,
      );
    });
  });
}
