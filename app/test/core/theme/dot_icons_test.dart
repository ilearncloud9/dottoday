import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/core/theme/svg_path.dart';
import 'package:dottoday/domain/entities/icon_keys.dart';
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

  group('task icons (docs/10 §3)', () {
    test('the 26 picker icons in order, then the no-icon default', () {
      expect(
        TaskIcon.picker.map((i) => i.key).join(' '),
        'code run mail call meal book list language heart travel cart home '
        'tv bag music meds water pet gym car money gift camera star '
        'people document',
      );
      expect(TaskIcon.picker, hasLength(26));
      expect(TaskIcon.fallback.key, defaultIconKey);
      expect(TaskIcon.fallback.glyph, isNull);
    });

    for (final icon in TaskIcon.picker) {
      test('${icon.key} has a glyph on the grid', () {
        expect(iconKeyPattern.hasMatch(icon.key), isTrue);
        _expectOnGrid(icon.glyph!);
      });
    }

    test('fromKey: current, pre-Concept A and unknown keys', () {
      expect(TaskIcon.fromKey('gym'), TaskIcon.gym);
      expect(TaskIcon.fromKey('meeting'), TaskIcon.people);
      expect(TaskIcon.fromKey('flight'), TaskIcon.travel);
      expect(TaskIcon.fromKey('shopping'), TaskIcon.cart);
      expect(TaskIcon.fromKey('from_a_newer_app'), TaskIcon.circle);
      expect(TaskIcon.fromKey(null), TaskIcon.circle);
    });
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
