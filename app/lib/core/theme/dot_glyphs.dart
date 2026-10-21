import 'dart:math' as math;
import 'dart:ui';

import 'package:dottoday/core/theme/svg_path.dart';

/// One stroke icon on the 24-unit grid (docs/10 §3 "Icon set"): stroke 2,
/// round caps and joins, drawn by `DotIcon`. A zero-length segment
/// (`h.01`) draws a round dot.
final class DotGlyph {
  const DotGlyph(this._data);

  final String _data;

  static final _cache = Expando<Path>();

  /// The parsed path in grid units (0–24).
  Path get path => _cache[this] ??= parseSvgPath(_data);
}

String _c(double cx, double cy, double r) => svgCircle(cx, cy, r);
String _r(double x, double y, double w, double h, double r) =>
    svgRect(x, y, w, h, r);

/// Navigation and interface glyphs (docs/10 §3: nav icons are fixed).
/// Task icons are `TaskIcon`.
abstract final class DotGlyphs {
  // Navigation (TabBar / NavigationBar / Rail).
  static final today = DotGlyph(_c(12, 12, 5));
  static const inbox = DotGlyph(
    'M22 12h-6l-2 3h-4l-2-3H2'
    'M5.45 5.11L2 12v6a2 2 0 0 0 2 2h16a2 2 0 0 0 2-2v-6l-3.45-6.89'
    'A2 2 0 0 0 16.76 4H7.24a2 2 0 0 0-1.79 1.11z',
  );
  static const week = DotGlyph('M7 5v14M12 5v14M17 5v14');
  static final search = DotGlyph('${_c(11, 11, 7)}M20.5 20.5l-4.6-4.6');
  static final settings = DotGlyph('${_c(12, 12, 3)}$_gear');
  static const add = DotGlyph('M12 5v14M5 12h14');

  // Interface.
  static const check = DotGlyph('M5 12.5l4.5 4.5L19 7.5');
  static const chevronDown = DotGlyph('M6 9l6 6 6-6');
  static const chevronUp = DotGlyph('M6 15l6-6 6 6');
  static const chevronLeft = DotGlyph('M15 6l-6 6 6 6');
  static const chevronRight = DotGlyph('M9 6l6 6-6 6');
  static const arrowLeft = DotGlyph('M19 12H5M12 19l-7-7 7-7');
  static const arrowRight = DotGlyph('M5 12h14M12 5l7 7-7 7');
  static const close = DotGlyph('M6 6l12 12M18 6L6 18');
  static const more = DotGlyph('M5 12h.01M12 12h.01M19 12h.01');
  static const moreVertical = DotGlyph('M12 5h.01M12 12h.01M12 19h.01');
  static final lock = DotGlyph(
    '${_r(5, 11, 14, 10, 2)}M8 11V7a4 4 0 0 1 8 0v4',
  );
  static const repeat = DotGlyph(
    'M17 2l4 4-4 4M3 11v-1a4 4 0 0 1 4-4h14'
    'M7 22l-4-4 4-4M21 13v1a4 4 0 0 1-4 4H3',
  );
  static final sun = DotGlyph(
    '${_c(12, 12, 4)}M12 2v2M12 20v2M4.93 4.93l1.41 1.41M17.66 17.66l1.41 1.41'
    'M2 12h2M20 12h2M6.34 17.66l-1.41 1.41M19.07 4.93l-1.41 1.41',
  );
  static const moon = DotGlyph('M12 3a6 6 0 0 0 9 9 9 9 0 1 1-9-9z');
  static const sunrise = DotGlyph(
    'M12 2v6M4.93 10.93l1.41 1.41M2 18h2M20 18h2M19.07 10.93l-1.41 1.41'
    'M22 22H2M8 6l4-4 4 4M16 18a4 4 0 0 0-8 0',
  );
  static const bell = DotGlyph(
    'M6 8a6 6 0 0 1 12 0c0 7 3 9 3 9H3c0 0 3-2 3-9M10.3 21a1.94 1.94 0 0 0 3.4 0',
  );
  static final clock = DotGlyph('${_c(12, 12, 9)}M12 7v5l3 2');
  static final timer = DotGlyph('${_c(12, 14, 8)}M12 14v-4M10 2h4');
  static final calendar = DotGlyph(
    '${_r(3, 4, 18, 18, 2)}M16 2v4M8 2v4M3 10h18',
  );
  static final globe = DotGlyph(
    '${_c(12, 12, 9)}M3 12h18M12 3a14 14 0 0 1 0 18M12 3a14 14 0 0 0 0 18',
  );
  static final keyboard = DotGlyph(
    '${_r(2, 5, 20, 14, 2)}M6 9h.01M10 9h.01M14 9h.01M18 9h.01M7 15h10',
  );
  static const trash = DotGlyph(
    'M3 6h18M19 6v14a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2V6'
    'M8 6V4a2 2 0 0 1 2-2h4a2 2 0 0 1 2 2v2',
  );
  static const edit = DotGlyph(
    'M17 3a2.83 2.83 0 1 1 4 4L7.5 20.5 2 22l1.5-5.5z',
  );
  static const move = DotGlyph('M3 6h13M3 12h9M3 18h7M16 14l4 4-4 4M12 18h8');
  static const bolt = DotGlyph('M13 2L3 14h9l-1 8 10-12h-9l1-8z');
  static const rollForward = DotGlyph('M3 12h14M13 7l5 5-5 5M21 5v14');
  static const dottedLine = DotGlyph('M12 4h.01M12 9h.01M12 14h.01M12 19h.01');
  static const sort = DotGlyph('M3 6h18M6 12h12M10 18h4');
  static const undo = DotGlyph('M9 14L4 9l5-5M4 9h11a5 5 0 0 1 0 10h-4');
}

/// An 8-tooth gear outline around the centre hole: alternating 7.2 / 9.5
/// radii, two points per tooth top and two per gap.
final String _gear = () {
  final b = StringBuffer();
  const points = 8 * 4;
  for (var i = 0; i < points; i++) {
    final r = (i % 4 == 1 || i % 4 == 2) ? 9.5 : 7.2;
    final a = (i - 0.5) / points * 2 * math.pi;
    final x = (12 + r * math.cos(a)).toStringAsFixed(2);
    final y = (12 + r * math.sin(a)).toStringAsFixed(2);
    b.write('${i == 0 ? 'M' : 'L'}$x $y');
  }
  b.write('z');
  return b.toString();
}();
