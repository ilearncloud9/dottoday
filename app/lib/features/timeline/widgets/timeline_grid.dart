import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/app_theme.dart';
import 'package:flutter/material.dart';

/// Static background: outside-hours zones and hour hairlines. Pure value
/// inputs, so it repaints only when the layout changes.
class TimelineGridPainter extends CustomPainter {
  const TimelineGridPainter({
    required this.hourYs,
    required this.zones,
    required this.gutterWidth,
    required this.textDirection,
    required this.lineColor,
    required this.zoneColor,
  });

  final List<double> hourYs;

  /// Pixel ranges of the collapsed/expanded outside-hours zones.
  final List<(double, double)> zones;
  final double gutterWidth;

  /// The gutter is on the start side, so it flips in RTL.
  final TextDirection textDirection;
  final Color lineColor;
  final Color zoneColor;

  @override
  void paint(Canvas canvas, Size size) {
    final zone = Paint()..color = zoneColor;
    for (final (top, bottom) in zones) {
      canvas.drawRect(Rect.fromLTRB(0, top, size.width, bottom), zone);
    }
    final line = Paint()
      ..color = lineColor
      ..strokeWidth = AppSpacing.hairline;
    final rtl = textDirection == TextDirection.rtl;
    final x0 = rtl ? 0.0 : gutterWidth;
    final x1 = rtl ? size.width - gutterWidth : size.width;
    for (final y in hourYs) {
      canvas.drawLine(Offset(x0, y), Offset(x1, y), line);
    }
  }

  @override
  bool shouldRepaint(TimelineGridPainter old) =>
      old.gutterWidth != gutterWidth ||
      old.textDirection != textDirection ||
      old.lineColor != lineColor ||
      old.zoneColor != zoneColor ||
      !_sameList(old.hourYs, hourYs) ||
      !_sameList(old.zones, zones);

  static bool _sameList<T>(List<T> a, List<T> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}

/// Header button of an outside-hours zone: "Before 07:00" / "After 22:00",
/// toggling between collapsed and full density (docs/02 F1, R-17).
class ZoneToggle extends StatelessWidget {
  const ZoneToggle({
    required this.label,
    required this.expanded,
    required this.onPressed,
    super.key,
  });

  final String label;
  final bool expanded;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final t = AppTheme.of(context);
    return Semantics(
      expanded: expanded,
      child: TextButton.icon(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          foregroundColor: t.colors.onSurfaceMuted,
          minimumSize: const Size(0, AppSpacing.minTouchTarget),
          textStyle: t.typography.label,
        ),
        icon: Icon(expanded ? Icons.unfold_less : Icons.unfold_more),
        label: Text(label),
      ),
    );
  }
}

/// "+n" marker for blocks beyond the 3-column limit.
class OverflowChip extends StatelessWidget {
  const OverflowChip({required this.count, required this.onPressed, super.key});

  final int count;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final t = AppTheme.of(context);
    return Semantics(
      label: l10n.timelineMoreBlocksLabel(count),
      button: true,
      excludeSemantics: true,
      onTap: onPressed,
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          backgroundColor: t.colors.surfaceRaised,
          foregroundColor: t.colors.onSurface,
          minimumSize: const Size.square(AppSpacing.minTouchTarget),
          textStyle: t.typography.label,
        ),
        child: Text(l10n.timelineMoreBlocks(count)),
      ),
    );
  }
}
