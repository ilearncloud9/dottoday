import 'package:flutter/painting.dart';

/// Primitive colours, named by what they look like, not by role. Light
/// values are Concept E's (docs/redesign/E_DESIGN_RULES.md §4.1, M18.1);
/// dark values are still Concept A's until M18.2.
///
/// The only file with raw hex values besides the generated task palette.
/// Widgets never read these: they read roles from `DotTheme.of(context)`.
abstract final class DotPrimitives {
  /// E `ground`: the app background.
  static const ground = Color(0xFFFBF7F1);

  /// E `surface`: cards, sheets, popovers.
  static const cream = Color(0xFFFFFDF9);
  static const white = Color(0xFFFFFFFF);

  /// E `ink`: primary text (15.07:1 on [ground]).
  static const ink = Color(0xFF241F2B);

  /// E `secondary`: times, summaries, labels (5.45:1 on [ground]).
  static const grey6A = Color(0xFF6A6273);

  /// E `hairline`: rgba(36,31,43,.08), row and card edges.
  static const hairline = Color(0x14241F2B);

  /// E `threadAhead`: the dotted thread and free-time dots.
  static const lilacBE = Color(0xFFBEB6C7);

  static const night12 = Color(0xFF121214);
  static const night1C = Color(0xFF1C1C20);
  static const snow = Color(0xFFF2F2F0);
  static const grey9A = Color(0xFF9A9AA0);
  static const night2C = Color(0xFF2C2C32);
  static const night3A = Color(0xFF3A3A40);

  static const navy = Color(0xFF0B1020);
  static const green2F = Color(0xFF2FA37A);

  /// Floating-element shadow, E ink at 10 %.
  static const shadow = Color(0x1A241F2B);
}
