import 'package:dottoday/core/theme/dot_colors.dart';
import 'package:dottoday/core/theme/dot_type.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/widgets.dart' show Brightness;

/// Increase Contrast's secondary text (ED-248 C, E-G4-7-States D4): light
/// one step darker (#4E4757, 8.3:1 on the ground); dark one step lighter
/// (#DDD5D9, 12.7:1), so it differs from the standard role as Apple asks
/// of every custom colour's increased-contrast variant (owner, ED-502).
abstract final class DotContrast {
  static const _light = Color(0xFF4E4757);
  static const _dark = Color(0xFFDDD5D9);

  static Color secondary(Brightness b) => b == Brightness.dark ? _dark : _light;

  /// [c]'s text styles, recoloured once per set of roles.
  static DotType styles(DotColors c) =>
      _styles[c] ??= DotType.withColors(text: c.ink, muted: c.secondary);

  static final _styles = Expando<DotType>();
}
