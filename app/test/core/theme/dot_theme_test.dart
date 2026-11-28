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
        [l.ground, l.card, l.ink, l.secondary, l.threadAhead],
        // Concept E light; every role is checked against the boards in
        // concept_e_board_values_test.dart (ED-360).
        const [
          Color(0xFFFBF7F1),
          Color(0xFFFFFDF9),
          Color(0xFF241F2B),
          Color(0xFF6A6273),
          Color(0xFFBEB6C7),
        ],
      );
      // The edge is Concept E's 8 % ink hairline over the card colour.
      expect(l.hairline, Color.alphaBlend(const Color(0x14241F2B), l.card));
      expect(
        [d.ground, d.card, d.ink, d.secondary, d.threadAhead],
        // Concept E dark, P1 Warm Charcoal: cards are #28232A as the
        // approved dark boards draw them (ED-181, ED-360).
        const [
          Color(0xFF171416),
          Color(0xFF28232A),
          Color(0xFFF3ECE4),
          Color(0xFFC7BEC4),
          Color(0xFF6B6369),
        ],
      );
      expect(d.hairline, Color.alphaBlend(const Color(0x1AFFF5EB), d.card));
      expect(l.accent, const Color(0xFF11615C));
      expect(l.onAccent, const Color(0xFFFFFFFF));
      expect(d.accent, const Color(0xFF5BC4B8));
      expect(d.onAccent, const Color(0xFF0C2523));
      // Teal's own Concept E text and tonal pair (ED-174).
      expect(l.accentText, const Color(0xFF0B4642));
      expect(d.accentText, const Color(0xFFA3E2D9));
      expect(l.tonal, const Color(0xFFE2EFEC));
      expect(d.tonal, const Color(0xFF1E3A37));
      expect(l.success, const Color(0xFF2FA37A));
    });

    for (final a in DotAccent.values) {
      for (final c in [DotColors.light(a), DotColors.dark(a)]) {
        test('${a.key} ${c.brightness.name}: text roles reach 4.5:1', () {
          final tint = Color.alphaBlend(c.tonal, c.card);
          for (final bg in [c.ground, c.card]) {
            expect(contrastRatio(c.ink, bg), greaterThanOrEqualTo(4.5));
            expect(contrastRatio(c.secondary, bg), greaterThanOrEqualTo(4.5));
            expect(contrastRatio(c.accentText, bg), greaterThanOrEqualTo(4.5));
          }
          expect(contrastRatio(c.accentText, tint), greaterThanOrEqualTo(4.5));
          expect(
            contrastRatio(c.onAccent, c.accentFill),
            greaterThanOrEqualTo(5),
          );
          // Text on a button sits on accentFill (above); the accent itself
          // is a graphic and reaches 3:1 on the page (ED-161, ED-360).
          expect(contrastRatio(c.accent, c.ground), greaterThanOrEqualTo(3));
        });
      }
    }

    test('the default light accent is its own ink on raised cards', () {
      final l = DotColors.light();
      expect(contrastRatio(l.accent, l.card), greaterThanOrEqualTo(4.5));
    });
  });

  group('type, shape and size tokens (docs/10 §2.2–2.3)', () {
    final t = DotType.withColors(text: Colors.black, muted: Colors.grey);

    // Material's desktop default (compact, shrink-wrapped) took Mac/web
    // buttons under the 44 pt floor (03 §1; found on the Mac in M8.7).
    test('targets keep full size on every platform', () {
      final theme = DotTheme.light();
      expect(theme.visualDensity, VisualDensity.standard);
      expect(theme.materialTapTargetSize, MaterialTapTargetSize.padded);
    });

    test('type roles', () {
      expect(
        [t.pageTitle.fontSize, t.pageTitle.fontWeight],
        [28, FontWeight.w700],
      );
      // Chrome is in the platform's own face (decision C, ED-360).
      expect(t.pageTitle.fontFamily, isNull);
      expect(t.pageTitleExpanded.fontSize, 30);
      expect(
        [t.topBarTitle.fontSize, t.topBarTitle.fontWeight],
        [24, FontWeight.w400],
      );
      expect([t.caption.fontSize, t.caption.fontWeight], [13, FontWeight.w600]);
      expect(t.caption.color, Colors.grey);
      expect(
        [t.cardTitle.fontSize, t.cardTitle.fontWeight],
        [15, FontWeight.w700],
      );
      expect(
        [t.rowTitle.fontSize, t.rowTitle.fontWeight],
        [17, FontWeight.w700],
      );
      expect(
        [t.liveRowTitle.fontSize, t.liveRowTitle.fontWeight],
        [19, FontWeight.w700],
      );
      expect([t.rowMeta.fontSize, t.rowMeta.color], [13, Colors.grey]);
      expect(
        [t.tabLabel.fontSize, t.tabLabelActive.fontWeight],
        [10, FontWeight.w600],
      );
      expect(t.androidTab(t.tabLabel).fontSize, 12);
      expect(
        t.rowMeta.fontFeatures,
        contains(const FontFeature.tabularFigures()),
      );
      expect(t.rowTitle.fontFamily, 'Manrope');
    });

    test('radii and sizes', () {
      expect([DotRadii.card, DotRadii.cardLarge, DotRadii.sheet], [20, 24, 28]);
      expect(
        [DotRadii.fabAndroid, DotRadii.railItem, DotRadii.pill],
        [16, 16, 999],
      );
      expect(
        [DotSize.rowDot, DotSize.liveDot, DotSize.liveRing, DotSize.dayDot],
        [36, 45, 5.5, 44],
      );
      expect(
        [DotSize.macRowDot, DotSize.pickerDot, DotSize.weekDot],
        [26, 22, 8],
      );
      // Concept E: a 4 px thread, 4 px dots ahead (E rules §5.2).
      expect([DotSize.segment, DotSize.freeLine], [4, 4]);
      expect([DotSize.nowMarker, DotSize.nowHalo], [16, 1]);
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
        DotTheme.light().extension<DotTheme>()!.colors.ground,
        DotColors.light().ground,
      );
    });
  });
}
