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

  /// The Inbox tab's solid tray (ADR-0015, bold nav icons): the lid and
  /// the tray with its notch, as two filled shapes.
  static const inboxSolid = DotGlyph(
    'M5.45 5.11L2.55 11h18.9l-2.9-5.89A2 2 0 0 0 16.76 4H7.24'
    'a2 2 0 0 0-1.79 1.11z'
    'M2 13h5.4l2 3h5.2l2-3H22v5a2 2 0 0 1-2 2H4a2 2 0 0 1-2-2z',
  );
  static const week = DotGlyph('M7 5v14M12 5v14M17 5v14');
  static final search = DotGlyph('${_c(11, 11, 7)}M20.5 20.5l-4.6-4.6');
  static final settings = DotGlyph('${_c(12, 12, 3)}$_gear');
  static const add = DotGlyph('M12 5v14M5 12h14');
  static const minus = DotGlyph('M5 12h14');

  /// Custom colour…'s eyedropper (ED-156).
  static const eyedropper = DotGlyph(
    'M2 22l1-1h3l9-9M3 21v-3l9-9M15 6l3.4-3.4a2.1 2.1 0 1 1 3 3L18 9l.4.4a2.1 2.1 0 1 1-3 3l-3.8-3.8a2.1 2.1 0 1 1 3-3l.4.4Z',
  );

  /// Two bars: a row's drag handle (reorder).
  static const dragHandle = DotGlyph('M5 9h14M5 15h14');

  // Interface.
  static const check = DotGlyph('M5 12.5l4.5 4.5L19 7.5');

  /// Changes not yet in the account (CR-160 A2): a cloud with an arrow
  /// into it.
  static const cloudSync = DotGlyph(
    'M6.5 17h10.4a3.8 3.8 0 0 0 .4-7.6A5.5 5.5 0 0 0 6.9 8.3 4.4 4.4 0 0 0 '
    '6.5 17zM12 10.5v4.5M9.8 12.8l2.2 2.2 2.2-2.2',
  );

  /// Sync in Today's top row (E-Phones): two arrows round a circle.
  static const sync = DotGlyph(
    'M20 11a8 8 0 0 0-14.3-4.9L4 8M4 3.5V8h4.5'
    'M4 13a8 8 0 0 0 14.3 4.9L20 16M20 20.5V16h-4.5',
  );
  static const chevronDown = DotGlyph('M6 9l6 6 6-6');
  static const chevronUp = DotGlyph('M6 15l6-6 6 6');
  static const chevronLeft = DotGlyph('M15 6l-6 6 6 6');
  static const chevronRight = DotGlyph('M9 6l6 6-6 6');
  static const arrowLeft = DotGlyph('M19 12H5M12 19l-7-7 7-7');
  static const arrowRight = DotGlyph('M5 12h14M12 5l7 7-7 7');
  static const arrowUp = DotGlyph('M12 19V5M5 12l7-7 7 7');
  static const arrowDown = DotGlyph('M12 5v14M19 12l-7 7-7-7');
  static const close = DotGlyph('M6 6l12 12M18 6L6 18');
  static const more = DotGlyph('M5 12h.01M12 12h.01M19 12h.01');
  static const moreVertical = DotGlyph('M12 5h.01M12 12h.01M12 19h.01');
  static final lock = DotGlyph(
    '${_r(5, 11, 14, 10, 2)}M8 11V7a4 4 0 0 1 8 0v4',
  );

  /// Lines shortening down: Settings › Learning's step lengths
  /// (E-R2-23 §4).
  static const stepLines = DotGlyph('M5 7h14M5 12h10M5 17h6');

  /// Settings › Privacy (E-R2-23 §3).
  static const shield = DotGlyph(
    'M20 13c0 5-3.5 7.5-7.66 8.95a1 1 0 0 1-.67-.01C7.5 20.5 4 18 4 13V6'
    'a1 1 0 0 1 1-1c2 0 4.5-1.2 6.24-2.72a1.17 1.17 0 0 1 1.52 0'
    'C14.51 3.81 17 5 19 5a1 1 0 0 1 1 1z',
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

  /// Settings › Reminders › Quiet hours (M8.4d): the bell, struck through.
  static const bellOff = DotGlyph(
    'M6 8a6 6 0 0 1 12 0c0 7 3 9 3 9H3c0 0 3-2 3-9M10.3 21a1.94 1.94 0 0 0 '
    '3.4 0M3 3l18 18',
  );

  /// Settings › Reminders › Sound (M8.4d): a speaker with two waves.
  // Dictation and Siri (M14.3, M14.5): a stroke mic on the 24 grid.
  static final mic = DotGlyph(
    '${_r(9, 2, 6, 12, 3)}M19 10v1a7 7 0 0 1-14 0v-1M12 18v4M8 22h8',
  );
  static const sound = DotGlyph(
    'M11 5L6 9H2v6h4l5 4V5zM15.5 8.5q2 3.5 0 7M18.5 5.5q4 6.5 0 13',
  );
  // Settings › Sounds › Haptics in app: a phone between two buzz marks.
  static final haptics = DotGlyph(
    '${_r(8, 3, 8, 18, 2)}M11 18h2M4 9q-1.5 3 0 6M20 9q1.5 3 0 6',
  );
  // Create task's colour-and-icon badge (ED-140): a painter's palette.
  static const palette = DotGlyph(
    'M12 21a9 9 0 1 1 9-9c0 2-1.6 2.7-3.2 2.7h-2.3a1.8 1.8 0 0 0-1.3 3 '
    '1.5 1.5 0 0 1-1.1 3.3zM7.5 10.5h.01M10.5 7h.01M15 8h.01',
  );
  static final clock = DotGlyph('${_c(12, 12, 9)}M12 7v5l3 2');
  static final timer = DotGlyph('${_c(12, 14, 8)}M12 14v-4M10 2h4');
  // Minimal's Now (E-PhonesMinimal): the dot in its ring.
  static final now = DotGlyph('${_c(12, 12, 9)}${_c(12, 12, 3)}');
  static final calendar = DotGlyph(
    '${_r(3, 4, 18, 18, 2)}M16 2v4M8 2v4M3 10h18',
  );
  static final globe = DotGlyph(
    '${_c(12, 12, 9)}M3 12h18M12 3a14 14 0 0 1 0 18M12 3a14 14 0 0 0 0 18',
  );
  static final keyboard = DotGlyph(
    '${_r(2, 5, 20, 14, 2)}M6 9h.01M10 9h.01M14 9h.01M18 9h.01M7 15h10',
  );
  // Settings sub-pages (M3f.7): account, export, help, about.
  static final person = DotGlyph('${_c(12, 8, 4)}M4 21a8 8 0 0 1 16 0');
  static const share = DotGlyph(
    'M12 15V3M7 8l5-5 5 5M5 15v4a2 2 0 0 0 2 2h10a2 2 0 0 0 2-2v-4',
  );
  // Links in a task's notes (M7.2, R-02).
  static const link = DotGlyph(
    'M10 13a5 5 0 0 0 7.54.54l3-3a5 5 0 0 0-7.07-7.07l-1.72 1.71'
    'M14 11a5 5 0 0 0-7.54-.54l-3 3a5 5 0 0 0 7.07 7.07l1.71-1.71',
  );
  static final help = DotGlyph(
    '${_c(12, 12, 9)}M9.5 9a2.5 2.5 0 1 1 3.5 2.3c-.6.3-1 .8-1 1.5v.7M12 17h.01',
  );

  /// Settled, nothing to do (CR-160 G1b): a check in a ring.
  static final checkCircle = DotGlyph('${_c(12, 12, 9)}M8 12.5l2.8 2.8L16 9.8');
  static final info = DotGlyph('${_c(12, 12, 9)}M12 11v6M12 7h.01');
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

  /// The Workspace's Plan place (E-FullA-v2): a window with its panel.
  static final plan = DotGlyph(
    '${_r(3.5, 4.5, 17, 15, 2.5)}M9.5 4.5v15M3.5 9.5h6',
  );

  /// The Workspace's Review place (E-FullA-v2): bars on a baseline.
  static const review = DotGlyph('M4 20V10M10 20V4M16 20v-7M22 20H2');

  /// Show or hide the sidebar (iPad, Mac and web; E-R2-1).
  static final sidebar = DotGlyph('${_r(3, 5, 18, 14, 2.5)}M9 5v14');

  /// Show or hide the Workspace inspector (E-FullA-v2's last toolbar
  /// button): the pane on the other side.
  static final inspector = DotGlyph('${_r(3, 5, 18, 14, 2.5)}M15 5v14');

  /// The Android rail's menu: opens the drawer (E-R2-1).
  static const menu = DotGlyph('M4 7h16M4 12h16M4 17h16');

  /// A bulleted list: Minimal Add's "Several lines?" hint (E-PhonesMinimal
  /// frame 3).
  static const list = DotGlyph(
    'M9 7h11M9 12h11M9 17h11M4.5 7h.01M4.5 12h.01M4.5 17h.01',
  );
  static const undo = DotGlyph('M9 14L4 9l5-5M4 9h11a5 5 0 0 1 0 10h-4');

  /// A row of dots: a week of days ("Pick from the week").
  static const dottedRow = DotGlyph(
    'M4 12h.01M8 12h.01M12 12h.01M16 12h.01M20 12h.01',
  );

  /// A ring of dots: free time ("Free until 19:30 · no overlap").
  static const freeRing = DotGlyph(
    'M12 4h.01M17.66 6.34h.01M20 12h.01M17.66 17.66h.01M12 20h.01'
    'M6.34 17.66h.01M4 12h.01M6.34 6.34h.01',
  );

  /// Triangle with "!": an overlap or a conflict to look at.
  static const warning = DotGlyph(
    'M12 3.5L2.5 20h19L12 3.5zM12 10v4M12 17h.01',
  );
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
