import 'package:dottoday/core/theme/look_metrics.dart';
import 'package:flutter/painting.dart';

// Colour maths for the colour pickers (ED-156, ED-220): hex text, and
// Colour (hue) and Shade (lightness) as one model.

/// [c] as `#RRGGBB`.
String hexOf(Color c) =>
    '#${(c.toARGB32() & 0xFFFFFF).toRadixString(16).padLeft(6, '0').toUpperCase()}';

/// The characters a typed hex may hold, and its longest form (`#RRGGBB`).
final hexCharacters = RegExp('[#0-9A-Fa-f]');
const hexLength = 7;

final _hex = RegExp(r'^#?[0-9A-Fa-f]{6}$');

/// A typed `#RRGGBB` (the # optional) as a colour, or null.
Color? parseHex(String text) {
  final t = text.trim();
  if (!_hex.hasMatch(t)) return null;
  final v = int.parse(t.replaceFirst('#', ''), radix: 16);
  return Color(0xFF000000 | v);
}

/// Colour and Shade as one model (ED-156): Colour is the hue, Shade the
/// lightness from black through the colour to white; saturation is kept.
/// A grey picks up colour once its hue moves.
({double hue, double shade}) hueShadeOf(Color c) {
  final h = HSLColor.fromColor(c);
  return (hue: h.hue / 360, shade: h.lightness);
}

/// [c] with its hue at [hue] (0–1).
Color withHue(Color c, double hue) {
  final h = HSLColor.fromColor(c);
  final sat = h.saturation < _grey ? _greyLift : h.saturation;
  return h.withHue((hue * 360).clamp(0, 359.9)).withSaturation(sat).toColor();
}

/// [c] with its lightness at [shade] (0–1).
Color withShade(Color c, double shade) =>
    HSLColor.fromColor(c).withLightness(shade.clamp(0, 1)).toColor();

/// Under this saturation a colour is a grey, so a hue change also lifts it.
const _grey = 0.05;
const _greyLift = 0.7;

/// The Colour track: every hue at [c]'s saturation and a mid lightness.
List<Color> hueTrack(Color c) {
  final h = HSLColor.fromColor(c);
  final sat = h.saturation < _grey ? _greyLift : h.saturation;
  return [
    for (var i = 0; i < DotLook.hueStops; i++)
      HSLColor.fromAHSL(
        1,
        360 * i / (DotLook.hueStops - 1) % 360,
        sat,
        0.55,
      ).toColor(),
  ];
}

/// The Shade track: black, [c] at mid lightness, white (as drawn).
List<Color> shadeTrack(Color c) => [
  withShade(c, 0),
  withShade(c, 0.5),
  withShade(c, 1),
];
