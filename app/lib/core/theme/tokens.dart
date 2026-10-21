import 'package:flutter/painting.dart';

/// Primitive colours of Concept A (docs/10-ui-concept-a.md §2.1), named by
/// what they look like, not by role.
///
/// The only file with raw hex values besides the generated task palette.
/// Widgets never read these: they read roles from `DotTheme.of(context)`.
abstract final class DotPrimitives {
  static const paper = Color(0xFFFAFAF8);
  static const white = Color(0xFFFFFFFF);
  static const ink = Color(0xFF1A1A1C);
  static const grey6B = Color(0xFF6B6B70);
  static const stoneE2 = Color(0xFFE2E2DE);
  static const stoneC9 = Color(0xFFC9C9C4);

  static const night12 = Color(0xFF121214);
  static const night1C = Color(0xFF1C1C20);
  static const snow = Color(0xFFF2F2F0);
  static const grey9A = Color(0xFF9A9AA0);
  static const night2C = Color(0xFF2C2C32);
  static const night3A = Color(0xFF3A3A40);

  static const navy = Color(0xFF0B1020);
  static const green2F = Color(0xFF2FA37A);

  /// Floating-element shadow `0 8px 24px rgba(26,26,28,.10)` (§2.3).
  static const shadow = Color(0x1A1A1A1C);
}
