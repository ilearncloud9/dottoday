import 'package:flutter/material.dart' show kMinInteractiveDimension;

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

/// Timeline geometry (docs/03 §3.1). Densities are at 100 % text and are
/// multiplied by the text scale (up to 2×) so blocks grow with Dynamic Type.
abstract final class AppTimeline {
  /// Core hours: 108 px per hour, so a 30-minute block (54 px) clears the
  /// 48 dp + gap minimum and back-to-back half hours stay in one column.
  static const double pxPerMinute = 1.8;

  /// Collapsed outside-hours zones: 24 px per hour.
  static const double collapsedPxPerMinute = 0.4;

  /// Width of the hour-label gutter at 100 % text.
  static const double gutterWidth = 56;

  /// Gap between side-by-side blocks and at the trailing edge.
  static const double blockGap = 2;

  /// Now-line stroke and its leading dot.
  static const double nowLineWidth = 2;
  static const double nowDot = 8;

  /// Smallest drawn block: the 48 dp tap target (Android floor, also
  /// ≥ 44 pt iOS) for its complete toggle, plus the gap below it.
  static const double minBlockHeight = kMinInteractiveDimension + blockGap;

  /// Visible-window granularity for the lazy canvas: blocks are rebuilt only
  /// when scrolling crosses a bucket, not on every frame (R-15).
  static const double lazyBucket = 512;
}
