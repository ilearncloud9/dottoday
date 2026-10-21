import 'dart:ui' show Brightness;

import 'package:dottoday/core/theme/contrast.dart';
import 'package:dottoday/core/theme/task_palette.dart';
import 'package:dottoday/core/theme/tokens.dart';
import 'package:flutter/painting.dart';

/// Semantic colour roles of Concept A (docs/10-ui-concept-a.md §2.1) for
/// one brightness and one accent.
///
/// ```dart
/// final c = DotTheme.of(context).colors;
/// Text('Today', style: TextStyle(color: c.accentInk));
/// ```
final class DotColors {
  const DotColors._({
    required this.brightness,
    required this.surface,
    required this.raised,
    required this.text,
    required this.muted,
    required this.outline,
    required this.hairline,
    required this.accent,
    required this.accentInk,
    required this.onAccent,
    required this.accentFill,
    required this.accentTint,
    required this.success,
  });

  /// Light roles with [accent] (Settings › Look).
  factory DotColors.light([DotAccent accent = DotAccent.fallback]) =>
      _resolve(Brightness.light, accent.light);

  /// Dark roles with [accent] (Settings › Look).
  factory DotColors.dark([DotAccent accent = DotAccent.fallback]) =>
      _resolve(Brightness.dark, accent.dark);

  final Brightness brightness;

  /// Page background.
  final Color surface;

  /// Cards, sheets, bars.
  final Color raised;
  final Color text;
  final Color muted;

  /// Hairline outline around cards and pills (instead of borders, §2.3).
  final Color outline;

  /// Free-time dots on the thread and empty rings.
  final Color hairline;

  /// Fills, rings, the now-marker, selected states.
  final Color accent;

  /// [accent] as text on [surface], [raised] and [accentTint]: the spec hue
  /// when it reaches 4.5:1, else a deeper (light) or brighter (dark) tone.
  final Color accentInk;

  /// Text and icons on an [accent] fill.
  final Color onAccent;

  /// Fill of buttons with text on them: [accent] deepened (light) or
  /// brightened (dark) until [onAccent] text reaches 5:1. The spec's
  /// white on #3B6CF6 is 4.50:1 on paper and renders at 4.31 (§7.4 wins).
  final Color accentFill;

  /// Selected pills and tab indicators (12 % light, 22 % dark), opaque.
  final Color accentTint;

  /// Done check on a completed day (§2.1).
  final Color success;

  bool get isDark => brightness == Brightness.dark;

  /// Interpolates every role; used by theme animations.
  DotColors lerp(DotColors other, double t) {
    Color l(Color a, Color b) => Color.lerp(a, b, t)!;
    return DotColors._(
      brightness: t < 0.5 ? brightness : other.brightness,
      surface: l(surface, other.surface),
      raised: l(raised, other.raised),
      text: l(text, other.text),
      muted: l(muted, other.muted),
      outline: l(outline, other.outline),
      hairline: l(hairline, other.hairline),
      accent: l(accent, other.accent),
      accentInk: l(accentInk, other.accentInk),
      onAccent: l(onAccent, other.onAccent),
      accentFill: l(accentFill, other.accentFill),
      accentTint: l(accentTint, other.accentTint),
      success: l(success, other.success),
    );
  }
}

DotColors _resolve(Brightness brightness, Color accent) {
  final dark = brightness == Brightness.dark;
  final surface = dark ? DotPrimitives.night12 : DotPrimitives.paper;
  final raised = dark ? DotPrimitives.night1C : DotPrimitives.white;
  final text = dark ? DotPrimitives.snow : DotPrimitives.ink;
  // White on the default light accent and navy on the dark one (§2.1); the
  // other accents take whichever of the two reads better on them.
  final onAccent =
      contrastRatio(DotPrimitives.white, accent) >=
          contrastRatio(DotPrimitives.navy, accent)
      ? DotPrimitives.white
      : DotPrimitives.navy;
  final tint = accent.withValues(alpha: dark ? 0.22 : 0.12);
  final inkBackgrounds = [
    surface,
    raised,
    Color.alphaBlend(tint, surface),
    Color.alphaBlend(tint, raised),
  ];
  return DotColors._(
    brightness: brightness,
    surface: surface,
    raised: raised,
    text: text,
    muted: dark ? DotPrimitives.grey9A : DotPrimitives.grey6B,
    outline: dark ? DotPrimitives.night2C : DotPrimitives.stoneE2,
    hairline: dark ? DotPrimitives.night3A : DotPrimitives.stoneC9,
    accent: accent,
    accentInk: inkFor(accent, backgrounds: inkBackgrounds, toward: text),
    onAccent: onAccent,
    accentFill: inkFor(
      accent,
      backgrounds: [onAccent],
      toward: onAccent == DotPrimitives.white ? text : surface,
      // Bold white glyphs on a coloured fill anti-alias darker than the
      // nominal colour; aim higher so the rendered text clears 4.5.
      minRatio: 5,
    ),
    accentTint: tint,
    success: DotPrimitives.green2F,
  );
}
