/// 4-pt spacing grid from docs/03-ux-spec.md §1.
abstract final class AppSpacing {
  static const double xs = 4;
  static const double s = 8;
  static const double m = 12;
  static const double l = 16;
  static const double xl = 24;
  static const double xxl = 32;

  /// Minimum interactive size (44 pt iOS; Android's 48 dp is enforced by
  /// Material's own tap-target sizing).
  static const double minTouchTarget = 44;

  /// Hairline stroke width, drawn in `AppColors.outline`.
  static const double hairline = 1;
}

/// Corner radii from docs/03-ux-spec.md §1.
abstract final class AppRadii {
  static const double block = 10;
  static const double card = 14;
  static const double sheet = 20;
}
