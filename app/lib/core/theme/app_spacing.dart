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

  /// Extra bottom inset for content under a floating action button: 56 dp
  /// FAB + its 16 dp margin + 16 dp breathing room, so the end of a scrolled
  /// list is never hidden behind it (M0.13).
  static const double fabClearance = 56 + l + l;
}

/// Layout breakpoints (Material 3 window size classes, docs/03 §2).
abstract final class AppBreakpoints {
  /// From this width up, navigation is a rail instead of a bottom bar.
  static const double navigationRail = 600;
}

/// Corner radii from docs/03-ux-spec.md §1.
abstract final class AppRadii {
  static const double block = 10;
  static const double card = 14;
  static const double sheet = 20;
}
