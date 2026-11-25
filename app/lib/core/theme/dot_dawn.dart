import 'dart:ui' show Brightness;

import 'package:dottoday/core/theme/contrast.dart';
import 'package:flutter/animation.dart' show Cubic;
import 'package:flutter/painting.dart';

/// The dawn sky behind Wake Up's missions (E-R2-19-B "The thread wakes
/// up", ED-314; dark mode E-R2-19-B-Dark, ED-459): night plum at the top
/// through rose to the first light at the bottom, deeper in dark mode.
/// [DawnSky.of] gives the one the app's theme calls for.
final class DawnSky {
  const DawnSky._(this.top, this.middle, this.bottom, {required this.night});

  /// E-R2-19-B's dawn and E-R2-19-B-Dark's.
  static const light = DawnSky._(
    Color(0xFF2E3A6B),
    Color(0xFFB86B6B),
    Color(0xFFF2B27A),
    night: false,
  );
  static const dark = DawnSky._(
    Color(0xFF121833),
    Color(0xFF5E3442),
    Color(0xFF9A5A3A),
    night: true,
  );

  final Color top;
  final Color middle;
  final Color bottom;

  /// Whether this is dark mode's dawn.
  final bool night;

  /// Where [middle] sits down the sky.
  static const middleStop = 0.55;

  /// The sky for [brightness], the app's own theme.
  static DawnSky of(Brightness brightness) =>
      brightness == Brightness.dark ? dark : light;

  LinearGradient get gradient => LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [top, middle, bottom],
    stops: const [0, middleStop, 1],
  );

  /// The sky's colour [t] of the way down (0 top, 1 bottom).
  Color at(double t) => t <= middleStop
      ? Color.lerp(top, middle, t / middleStop)!
      : Color.lerp(middle, bottom, (t - middleStop) / (1 - middleStop))!;

  /// A ring's colour on this sky (E-R2-19-B "The ring follows your App
  /// colour"): the App colour's dark-surface [accent], lightened toward
  /// white until it reaches 3:1 against the sky at [height].
  ///
  /// ```dart
  /// DawnSky.light.ring(const Color(0xFF5BC4B8), 0.3); // teal as it is
  /// ```
  Color ring(Color accent, double height) => inkFor(
    accent,
    backgrounds: [at(height)],
    toward: const Color(0xFFFFFFFF),
    minRatio: DotDawn.graphicContrast,
  );

  /// The words and outline at the foot of the sky (Can't right now): dark
  /// ink on the light dawn's first light, where white is 2.1:1; white on
  /// the dark dawn, as drawn (5.3:1; dark ink would be 3.1:1).
  Color get foot => night ? DotDawn.ink : DotDawn.inkDark;
}

/// The dawn's shared marks: the same on either sky.
abstract final class DotDawn {
  /// WCAG's 3:1 for graphics (the ring).
  static const graphicContrast = 3.0;

  /// The ring's empty track and the ground line: white at low opacity.
  static const track = Color(0x2EFFFFFF);
  static const ground = Color(0x47FFFFFF);

  /// Walk's walker and the words on the sky's buttons.
  static const ink = Color(0xFFFFFFFF);

  /// A shape on a light dot (Catch the dot's amber square).
  static const inkDark = Color(0xFF1E1B22);

  /// Light: the bulb's warm glow, and the room brightening round it
  /// (E-R2-19-B `ms-glow`, `ms-lit`).
  static const bulbGlow = Color(0xFFFFD27A);
  static const roomLight = Color(0xE6FFE2AA);
  static const roomLightClear = Color(0x00FFE2AA);

  /// Breathe: the press under the fingertip (`ms-press`).
  static const press = Color(0x59FFFFFF);

  /// A shape's shadow on the sky (`ct-dot`).
  static const dotShadow = Color(0x40000000);

  /// Catch the dot's four dots (E-R2-19-B; ED-336: no red).
  static const catchBlue = Color(0xFF3B82F6);
  static const catchViolet = Color(0xFF8B5CF6);
  static const catchYellow = Color(0xFFFACC15);
  static const catchGreen = Color(0xFF22C55E);

  /// The square dot's mark's corner (the board's 1.6 in a 24 box).
  static const catchSquareCorner = Radius.circular(1.6);
}

/// The motion on the dawn sky, as E-R2-19-B times it (its `@keyframes`).
/// Reduce Motion stops all of it at a still state.
abstract final class DotDawnMotion {
  /// Walk: one crossing of the sky (`wkCross`, three in 12 s), one gait
  /// cycle of legs and arms (`wkLegA`), one bob and one ring pulse per
  /// step (`wkBob`, `wkPulse`), and how long the walker stands with its
  /// check before the morning goes on.
  static const walkCross = Duration(seconds: 4);
  static const walkGait = Duration(seconds: 1);
  static const walkStep = Duration(milliseconds: 500);
  static const walkDone = Duration(seconds: 1);

  /// Stand up's tilt to upright and Light's glow (`msTilt`, `msGlow`).
  static const settle = Duration(seconds: 3);
  static const glow = Duration(milliseconds: 900);

  /// Breathe: the fingertip lifting away or pressing (`msFinger`) and the
  /// press ripple (`msPress`).
  static const finger = Duration(milliseconds: 480);
  static const press = Duration(milliseconds: 240);

  /// Catch the dot: the ring that spreads from a catch (`ctTap`).
  static const catchTap = Duration(milliseconds: 400);

  /// The board's easing for the tilt and the finger: cubic(.3, 0, .2, 1).
  static const ease = Cubic(0.3, 0, 0.2, 1);

  /// CSS `ease-in-out` (the walker's stride and bob, Light's glow) and
  /// `ease-out` (the ring's pulse), as the board writes them.
  static const easeInOut = Cubic(0.42, 0, 0.58, 1);
  static const easeOut = Cubic(0, 0, 0.58, 1);
}
