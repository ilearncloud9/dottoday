import 'package:dottoday/core/theme/app_theme.dart';
import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:dottoday/features/timeline/layout/timeline_geometry.dart';
import 'package:dottoday/features/timeline/widgets/block_gestures.dart';
import 'package:dottoday/features/timeline/widgets/drag_overlay.dart';
import 'package:dottoday/features/timeline/widgets/now_line.dart';
import 'package:dottoday/features/timeline/widgets/time_labels.dart';
import 'package:dottoday/features/timeline/widgets/timeline_block.dart';
import 'package:dottoday/features/timeline/widgets/timeline_grid.dart';
import 'package:flutter/material.dart';

/// Callbacks and labels the canvas needs from its screen.
final class DayCanvasActions {
  const DayCanvasActions({
    required this.beforeLabel,
    required this.afterLabel,
    required this.expanded,
    required this.onToggleBefore,
    required this.onToggleAfter,
    required this.onShowHidden,
    required this.onTapEmpty,
  });

  final String beforeLabel;
  final String afterLabel;
  final ({bool before, bool after}) expanded;
  final VoidCallback onToggleBefore;
  final VoidCallback onToggleAfter;
  final ValueChanged<List<Occurrence>> onShowHidden;
  final VoidCallback onTapEmpty;
}

/// The full-height day, building only the blocks inside `[from, to)`
/// (the lazy window, R-15). One coordinate space for everything, so later
/// gestures (M3.4) map pointer y to time with one `minuteAt` call.
class DayCanvas extends StatelessWidget {
  const DayCanvas({
    required this.geometry,
    required this.width,
    required this.gutter,
    required this.use24h,
    required this.showNow,
    required this.from,
    required this.to,
    required this.actions,
    this.canvasKey,
    super.key,
  });

  /// Lets the drag coordinator map global pointer positions to canvas y.
  final GlobalKey? canvasKey;

  final TimelineGeometry geometry;
  final double width;
  final double gutter;
  final bool use24h;
  final bool showNow;
  final double from;
  final double to;
  final DayCanvasActions actions;

  @override
  Widget build(BuildContext context) {
    final t = AppTheme.of(context);
    final g = geometry;
    // A tap anywhere that no block, toggle or handle claims clears the
    // selection (and its resize handles).
    return GestureDetector(
      key: canvasKey,
      behavior: HitTestBehavior.opaque,
      onTap: actions.onTapEmpty,
      child: SizedBox(
        height: g.height,
        width: width,
        child: Stack(
          children: [
            if (showNow) PastTint(day: g.day, scale: g.scale),
            Positioned.fill(
              child: RepaintBoundary(
                child: CustomPaint(
                  painter: TimelineGridPainter(
                    hourYs: [for (final h in g.hours) h.y],
                    zones: g.zones,
                    gutterWidth: gutter,
                    textDirection: Directionality.of(context),
                    lineColor: t.colors.outline,
                    zoneColor: t.colors.surfaceSunken,
                  ),
                ),
              ),
            ),
            ..._hourLabels(context, t),
            ..._zoneToggles(),
            ..._blocks(),
            ..._overflow(),
            if (showNow)
              NowLine(day: g.day, scale: g.scale, left: gutter, use24h: use24h),
            Positioned.fill(
              child: DragOverlay(
                geometry: g,
                gutter: gutter,
                width: width,
                use24h: use24h,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Iterable<Widget> _hourLabels(BuildContext context, AppTheme t) sync* {
    final style = t.typography.mono.copyWith(color: t.colors.onSurfaceMuted);
    final lineHeight = MediaQuery.textScalerOf(
      context,
    ).scale(style.fontSize! * style.height!);
    var lastY = double.negativeInfinity;
    for (final h in geometry.hours) {
      // Collapsed zones pack hours tighter than a label: skip any label
      // that would collide with the previous one.
      if (h.y - lastY < lineHeight) continue;
      lastY = h.y;
      if (h.y + lineHeight < from || h.y - lineHeight > to) continue;
      yield PositionedDirectional(
        top: h.y,
        start: 0,
        width: gutter - AppSpacing.xs,
        child: ExcludeSemantics(
          child: Text(
            hourLabel(context, h.mark.label, use24h: use24h),
            textAlign: TextAlign.end,
            maxLines: 1,
            style: style,
          ),
        ),
      );
    }
  }

  Iterable<Widget> _zoneToggles() sync* {
    final g = geometry;
    if (g.hasBeforeZone) {
      yield PositionedDirectional(
        top: 0,
        start: gutter,
        child: ZoneToggle(
          label: actions.beforeLabel,
          expanded: actions.expanded.before,
          onPressed: actions.onToggleBefore,
        ),
      );
    }
    if (g.hasAfterZone) {
      yield PositionedDirectional(
        top: g.scale.yOf(g.coreTo),
        start: gutter,
        child: ZoneToggle(
          label: actions.afterLabel,
          expanded: actions.expanded.after,
          onPressed: actions.onToggleAfter,
        ),
      );
    }
  }

  double get _lane => width - gutter - AppTimeline.blockGap;

  Iterable<Widget> _blocks() sync* {
    for (final p in geometry.layout.visibleIn(from, to)) {
      final colWidth = _lane / p.columns;
      yield PositionedDirectional(
        key: ValueKey(p.block.id),
        top: p.top,
        height: p.height - AppTimeline.blockGap,
        start: gutter + p.column * colWidth,
        width: colWidth - AppTimeline.blockGap,
        child: RepaintBoundary(
          child: BlockGestures(
            placement: p,
            child: TimelineBlock(
              placement: p,
              date: geometry.day.date,
              location: geometry.day.location,
              use24h: use24h,
            ),
          ),
        ),
      );
    }
  }

  Iterable<Widget> _overflow() sync* {
    for (final m in geometry.layout.overflow) {
      if (m.top > to || m.top + AppSpacing.minTouchTarget < from) continue;
      yield PositionedDirectional(
        top: m.top,
        end: AppTimeline.blockGap,
        child: OverflowChip(
          count: m.hidden.length,
          onPressed: () => actions.onShowHidden(m.hidden),
        ),
      );
    }
  }
}
