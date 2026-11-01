import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/core/theme/svg_path.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';

/// Every interface glyph, by name, so a failure names the icon.
final _glyphs = <String, DotGlyph>{
  'today': DotGlyphs.today,
  'inbox': DotGlyphs.inbox,
  'week': DotGlyphs.week,
  'search': DotGlyphs.search,
  'settings': DotGlyphs.settings,
  'add': DotGlyphs.add,
  'check': DotGlyphs.check,
  'chevronDown': DotGlyphs.chevronDown,
  'chevronUp': DotGlyphs.chevronUp,
  'chevronLeft': DotGlyphs.chevronLeft,
  'chevronRight': DotGlyphs.chevronRight,
  'arrowLeft': DotGlyphs.arrowLeft,
  'arrowRight': DotGlyphs.arrowRight,
  'close': DotGlyphs.close,
  'more': DotGlyphs.more,
  'moreVertical': DotGlyphs.moreVertical,
  'lock': DotGlyphs.lock,
  'repeat': DotGlyphs.repeat,
  'sun': DotGlyphs.sun,
  'moon': DotGlyphs.moon,
  'sunrise': DotGlyphs.sunrise,
  'bell': DotGlyphs.bell,
  'bellOff': DotGlyphs.bellOff,
  'sound': DotGlyphs.sound,
  'haptics': DotGlyphs.haptics,
  'clock': DotGlyphs.clock,
  'timer': DotGlyphs.timer,
  'calendar': DotGlyphs.calendar,
  'globe': DotGlyphs.globe,
  'keyboard': DotGlyphs.keyboard,
  'trash': DotGlyphs.trash,
  'edit': DotGlyphs.edit,
  'move': DotGlyphs.move,
  'bolt': DotGlyphs.bolt,
  'rollForward': DotGlyphs.rollForward,
  'dottedLine': DotGlyphs.dottedLine,
  'sort': DotGlyphs.sort,
  'undo': DotGlyphs.undo,
  'person': DotGlyphs.person,
  'share': DotGlyphs.share,
  'help': DotGlyphs.help,
  'info': DotGlyphs.info,
};

void main() {
  group('svg path subset', () {
    test('absolute, relative, arcs and implicit line-tos', () {
      final p = parseSvgPath('M2 2h4v4H2zM10 10l2 2 2-2a2 2 0 0 1 4 0');
      final b = p.getBounds();
      expect(b.left, 2);
      expect(b.top, closeTo(2, 1e-6));
      expect(b.right, closeTo(18, 1e-6));
    });

    test('circle and rect helpers stay on the grid', () {
      expect(
        parseSvgPath(svgCircle(12, 12, 5)).getBounds(),
        const Rect.fromLTRB(7, 7, 17, 17),
      );
      final r = parseSvgPath(svgRect(3, 4, 18, 16, 2)).getBounds();
      expect([r.left, r.top, r.right, r.bottom], [3, 4, 21, 20]);
    });

    test('smooth curves reflect the previous control point', () {
      // S/T mirror the last C/Q control point (Lucide and Tabler use them).
      final s = parseSvgPath('M2 12C2 6 8 6 8 12S14 18 14 12').getBounds();
      final c = parseSvgPath('M2 12C2 6 8 6 8 12C8 18 14 18 14 12').getBounds();
      expect(s, c);
      final t = parseSvgPath('M2 12Q5 6 8 12T14 12').getBounds();
      final q = parseSvgPath('M2 12Q5 6 8 12Q11 18 14 12').getBounds();
      expect(t, q);
      // Without a previous curve the control point is the current point.
      expect(
        parseSvgPath('M2 2S8 2 8 8').getBounds(),
        parseSvgPath('M2 2C2 2 8 2 8 8').getBounds(),
      );
    });

    test('malformed data throws instead of drawing half a glyph', () {
      expect(() => parseSvgPath('L2 2'), throwsFormatException);
      expect(() => parseSvgPath('M2 2 L3'), throwsFormatException);
      expect(() => parseSvgPath('M2 2 X3 3'), throwsFormatException);
    });
  });

  group('interface glyphs parse and fit the 24-unit grid', () {
    for (final MapEntry(key: name, value: glyph) in _glyphs.entries) {
      test(name, () => _expectOnGrid(glyph));
    }
  });
}

void _expectOnGrid(DotGlyph glyph) {
  final b = glyph.path.getBounds();
  expect(b.isEmpty && b.width == 0 && b.height == 0, isFalse);
  // Stroke 2 needs 1 unit of room: geometry stays within 0.5…23.5.
  expect(b.left, greaterThanOrEqualTo(0.5));
  expect(b.top, greaterThanOrEqualTo(0.5));
  expect(b.right, lessThanOrEqualTo(23.5));
  expect(b.bottom, lessThanOrEqualTo(23.5));
}
