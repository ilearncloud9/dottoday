import 'dart:ui' show Brightness, Color;

import 'package:dottoday/core/theme/colour_math.dart';
import 'package:dottoday/core/theme/dot_colors.dart';
import 'package:dottoday/core/theme/task_palette.dart';
import 'package:dottoday/domain/entities/settings.dart';

/// The App colour (ED-221) as the native surfaces draw it, light and dark
/// (M20.9 parts 3–4; owner: widgets and the Live Activity follow it):
/// `dot` for rings, bars and the day dot; `text` for words in it (the
/// accent on teal, as E-R2-17 draws "Now", the contrast-safe ink on any
/// other); `fill` and `on` for a filled button and its tick.
///
/// ```dart
/// appColourTones(profile)['light'] // {dot: #11615C, text: …, fill: …, on: #FFFFFF}
/// ```
Map<String, Map<String, String>> appColourTones(Profile profile) {
  final custom = profile.accentHex == null
      ? null
      : parseHex(profile.accentHex!);
  final key = DotAccent.fromKey(profile.settings.accent);
  final teal = custom == null && key == DotAccent.teal;
  Map<String, String> tones(Brightness b) {
    final c = custom != null
        ? DotColors.custom(b, custom)
        : b == Brightness.dark
        ? DotColors.dark(key)
        : DotColors.light(key);
    final Color text = teal ? c.accent : c.accentInk;
    return {
      'dot': colourHex(c.accent),
      'text': colourHex(text),
      'fill': colourHex(c.accentFill),
      'on': colourHex(c.onAccent),
    };
  }

  return {'light': tones(Brightness.light), 'dark': tones(Brightness.dark)};
}

/// "#RRGGBB" for a native surface.
String colourHex(Color c) =>
    '#${(c.toARGB32() & 0xFFFFFF).toRadixString(16).padLeft(6, '0').toUpperCase()}';
