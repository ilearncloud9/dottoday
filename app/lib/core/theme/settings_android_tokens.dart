import 'package:dottoday/core/theme/dot_colors.dart';
import 'package:dottoday/core/theme/dot_type.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';

/// Android's Settings frame, as E-R2-29 draws it (ED-499): cards 16 from
/// the edge with 20 corners and no lines between rows; one-line rows 56
/// tall, two-line rows 72, 16 between the icon's 40 circle and the words;
/// the page's icon beside its title in a 32 circle.
abstract final class SettingsAndroidSize {
  static const double side = 16;
  static const double cardRadius = 20;
  static const double rowOne = 56;
  static const double rowTwo = 72;
  static const double rowPadH = 16;
  static const double rowPadV = 8;
  static const double gap = 16;
  static const double icon = 40;
  static const double glyph = 20;
  static const double headerIcon = 32;
  static const double headerGlyph = 16;
}

/// Android's Settings type (E-R2-29, ED-499), in Roboto as the board
/// names it (the bundled copy on the web, as Account's buttons do).
abstract final class SettingsAndroidType {
  static TextStyle _roboto(
    double size,
    double line,
    FontWeight weight,
    Color color,
  ) => TextStyle(
    fontFamily: kIsWeb ? DotType.webChromeFamily : 'Roboto',
    fontSize: size,
    height: line / size,
    fontWeight: weight,
    color: color,
  );

  /// The page title beside ←: 22/28 regular.
  static TextStyle title(DotColors c) =>
      _roboto(22, 28, FontWeight.w400, c.ink);

  /// A row's title: 16/24.
  static TextStyle row(DotColors c) => _roboto(16, 24, FontWeight.w400, c.ink);

  /// A row's second line (its value or detail) and page text: 14/20, ink 2.
  static TextStyle second(DotColors c) =>
      _roboto(14, 20, FontWeight.w400, c.ink2);

  /// A group's caption: 14/20 medium in the accent.
  static TextStyle caption(DotColors c) =>
      _roboto(14, 20, FontWeight.w500, c.accent);
}
