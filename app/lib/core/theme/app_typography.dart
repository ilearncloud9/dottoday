import 'package:flutter/painting.dart';

/// Type scale from docs/03-ux-spec.md §1 (size/line-height weight).
///
/// Sizes are unscaled logical pixels; the system text scaler (up to 200 %)
/// is applied by Flutter at render time, so never clamp it here.
final class AppTypography {
  const AppTypography({
    required this.display,
    required this.title,
    required this.body,
    required this.label,
    required this.mono,
  });

  factory AppTypography.withColor(Color color) => AppTypography(
    display: _inter(28, 34, 600, color),
    title: _inter(20, 26, 600, color),
    body: _inter(16, 22, 400, color),
    label: _inter(13, 18, 500, color),
    // `mono 13` for times: Inter with tabular figures so digits align
    // without bundling a second font (decision recorded in M0.4).
    mono: _inter(
      13,
      18,
      400,
      color,
    ).copyWith(fontFeatures: const [FontFeature.tabularFigures()]),
  );

  static const fontFamily = 'Inter';

  final TextStyle display;
  final TextStyle title;
  final TextStyle body;
  final TextStyle label;
  final TextStyle mono;

  /// Interpolates every style; used by theme animations.
  AppTypography lerp(AppTypography other, double t) => AppTypography(
    display: TextStyle.lerp(display, other.display, t)!,
    title: TextStyle.lerp(title, other.title, t)!,
    body: TextStyle.lerp(body, other.body, t)!,
    label: TextStyle.lerp(label, other.label, t)!,
    mono: TextStyle.lerp(mono, other.mono, t)!,
  );
}

TextStyle _inter(double size, double lineHeight, int weight, Color color) {
  return TextStyle(
    fontFamily: AppTypography.fontFamily,
    fontSize: size,
    height: lineHeight / size,
    // Variable font: set the wght axis explicitly as well as fontWeight so
    // every renderer picks the right instance.
    fontWeight: FontWeight.values[(weight ~/ 100) - 1],
    fontVariations: [FontVariation.weight(weight.toDouble())],
    color: color,
  );
}
