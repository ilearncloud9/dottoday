import 'dart:ui' show DisplayFeatureState, DisplayFeatureType;

import 'package:dottoday/core/theme/dot_metrics.dart';
import 'package:flutter/widgets.dart';

/// The window's layout rules (Concept E rules §12.2; ED-167, ED-168):
/// width classes at 600 / 840, the short-height rule H1, and when a 420
/// side panel (the task editor, a proposal) docks instead of floating.
/// Space decides, never the device or platform.
abstract final class AppLayout {
  /// H1: below this usable height the compact layout is used and nothing
  /// docks (ED-168).
  static const double shortHeight = 480;

  /// A side panel floats below this window width, whatever else fits
  /// (ED-167).
  static const double dockFrom = 1160;

  /// What Today keeps beside a docked panel (ED-168 M): 480, or 600 when
  /// text is above [largeText].
  static const double todayMin = 480;
  static const double todayMinLarge = 600;

  /// Text larger than 130 % asks for the wider Today minimum.
  static const double largeText = 1.3;

  /// The class this window lays out in: [WidthClass] by width, except a
  /// window under [shortHeight] of usable height (after safe areas, not
  /// counting the keyboard), which keeps the compact layout (H1). Opening
  /// the keyboard never changes it.
  ///
  /// ```dart
  /// AppLayout.classOf(context); // 874 × 402 landscape phone: compact
  /// ```
  static WidthClass classOf(BuildContext context, {double? width}) {
    if (isShort(context)) return WidthClass.compact;
    return WidthClass.of(width ?? MediaQuery.sizeOf(context).width);
  }

  /// Whether the window is under [shortHeight] of usable height (H1): a
  /// phone in landscape, a foldable half open, a short browser window.
  static bool isShort(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final padding = MediaQuery.paddingOf(context);
    if (size.height - padding.top - padding.bottom < shortHeight) return true;
    // A foldable half open on a table: each half is a short window, so
    // the phone layout (ED-168, ED-334).
    return MediaQuery.displayFeaturesOf(context).any(
      (f) =>
          f.state == DisplayFeatureState.postureHalfOpened &&
          f.bounds.width > f.bounds.height,
    );
  }

  /// A hinge with a gap running down the window (ED-099, ED-334): no pane
  /// or text may cross it, so the content keeps to one side. A flat fold
  /// with no gap is ordinary screen.
  static bool hasHinge(BuildContext context) =>
      MediaQuery.displayFeaturesOf(context).any(
        (f) =>
            f.type == DisplayFeatureType.hinge &&
            f.bounds.width > 0 &&
            f.bounds.height > f.bounds.width,
      );

  /// Whether a [DotSize.sidePanel] panel docks beside content [available]
  /// wide (the panel's own slot included): the window is at least
  /// [dockFrom] and the content keeps its minimum at this text size (M).
  /// Otherwise it floats over the content (ED-167, ED-168).
  ///
  /// ```dart
  /// AppLayout.docks(context, available: 1080); // 1160 window: docks
  /// ```
  static bool docks(BuildContext context, {required double available}) {
    if (classOf(context) != WidthClass.expanded) return false;
    if (MediaQuery.sizeOf(context).width < dockFrom) return false;
    final scale = MediaQuery.textScalerOf(context).scale(1);
    final min = scale > largeText ? todayMinLarge : todayMin;
    return available - DotSize.sidePanel - DotSpace.hairline >= min;
  }
}
