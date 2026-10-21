import 'package:flutter/painting.dart';

/// WCAG 2.x contrast ratio between two opaque colours.
///
/// ```dart
/// contrastRatio(const Color(0xFF000000), const Color(0xFFFFFFFF)); // 21.0
/// ```
double contrastRatio(Color a, Color b) {
  final la = a.computeLuminance();
  final lb = b.computeLuminance();
  final (hi, lo) = la > lb ? (la, lb) : (lb, la);
  return (hi + 0.05) / (lo + 0.05);
}

/// [color] mixed toward [toward] in 2 % steps until it reaches [minRatio]
/// against every one of [backgrounds]; [color] itself when it already does.
///
/// Concept A draws titles, chips and "Today" in task and accent colours, but
/// several of those hues are below 4.5:1 on the light surfaces (docs/10
/// §7.4 wins over the renders), so text uses this derived tone and graphics
/// keep the spec hue.
Color inkFor(
  Color color, {
  required List<Color> backgrounds,
  required Color toward,
  double minRatio = 4.5,
}) {
  for (var step = 0; step <= 50; step++) {
    final ink = Color.lerp(color, toward, step / 50)!;
    if (backgrounds.every((bg) => contrastRatio(ink, bg) >= minRatio)) {
      return ink;
    }
  }
  return toward;
}
