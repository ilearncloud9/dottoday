import 'package:dottoday/core/theme/contrast.dart';
import 'package:dottoday/core/theme/dot_colors.dart';
import 'package:dottoday/core/theme/task_palette.dart';
import 'package:dottoday/core/theme/tokens.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';

/// Custom task colours (ED-220): any `#RRGGBB` in `color_key`, drawn with
/// derived ring and dark shades (ED-161, ED-175); M19.4 part 4c-1.
void main() {
  test('a hex key parses, upper-cased; anything else falls back', () {
    final c = TaskColor.fromKey('#1a2b3c');
    expect(c.isCustom, isTrue);
    expect(c.key, '#1A2B3C');
    expect(c.color, const Color(0xFF1A2B3C));
    expect(c.index, -1);
    expect(TaskColor.fromKey('#1A2B3C'), c);
    for (final bad in ['#12345', '#1234567', 'ocean', '', null]) {
      expect(TaskColor.fromKey(bad), TaskColor.fallback, reason: '$bad');
    }
  });

  test('TaskColor.custom is opaque and round-trips through its key', () {
    final c = TaskColor.custom(const Color(0x80C0FFEE));
    expect(c.key, '#C0FFEE');
    expect(TaskColor.fromKey(c.key), c);
    expect(c.color.a, 1);
  });

  test('the named keys still win over the hex form', () {
    expect(TaskColor.fromKey('brown'), TaskColor.brown);
    expect(TaskColor.brown.isCustom, isFalse);
    expect(TaskColor.values.last, TaskColor.olive);
    expect(TaskColor.values.indexed.every((e) => e.$2.index == e.$1), isTrue);
  });

  test('derived ring ≥ 3:1 on light; dark fill ≥ 3.5:1 on dark', () {
    const l = DotPalette.light;
    const d = DotPalette.dark;
    for (final hex in ['#FFF59D', '#101010', '#7F7F7F', '#00FFFF']) {
      final c = TaskColor.fromKey(hex);
      for (final bg in [l.ground, l.card]) {
        expect(contrastRatio(c.ring, bg), greaterThanOrEqualTo(3), reason: hex);
      }
      for (final bg in [d.ground, d.card, d.chip]) {
        expect(contrastRatio(c.dark, bg), greaterThanOrEqualTo(3.5));
      }
    }
  });

  test('the palette resolves a custom swatch; a pale one gets an ink tick', () {
    final light = TaskPalette.resolve(DotColors.light());
    final pale = light[TaskColor.fromKey('#FFF59D')];
    expect(pale.color, const Color(0xFFFFF59D));
    expect(pale.check, DotColors.light().ink);
    final deep = light[TaskColor.fromKey('#203040')];
    expect(deep.check, DotPrimitives.white);
    final dark = TaskPalette.resolve(DotColors.dark());
    expect(dark[TaskColor.fromKey('#203040')].color, isNot(deep.color));
  });
}
