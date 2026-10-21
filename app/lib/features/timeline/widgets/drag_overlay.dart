import 'dart:math' as math;

import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/app_theme.dart';
import 'package:dottoday/features/timeline/layout/drag_math.dart';
import 'package:dottoday/features/timeline/layout/timeline_geometry.dart';
import 'package:dottoday/features/timeline/state/timeline_interaction.dart';
import 'package:dottoday/features/timeline/widgets/block_tile.dart';
import 'package:dottoday/features/timeline/widgets/drag_coordinator.dart';
import 'package:dottoday/features/timeline/widgets/time_labels.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Elevation of the lifted ghost.
const double _lift = 8;

/// The lifted ghost with its floating snapped time label while dragging,
/// and resize handles on the selected block otherwise (docs/03 §3.2).
/// Lives at the top of the day canvas, in the same coordinates.
class DragOverlay extends ConsumerWidget {
  const DragOverlay({
    required this.geometry,
    required this.gutter,
    required this.width,
    required this.use24h,
    super.key,
  });

  final TimelineGeometry geometry;
  final double gutter;
  final double width;
  final bool use24h;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(timelineInteractionProvider);
    final drag = state.drag;
    if (drag != null) return _ghost(context, drag);
    final selected = geometry.layout.placements
        .where((p) => p.block.id == state.selectedId)
        .firstOrNull;
    if (selected == null) return const SizedBox.shrink();
    return _Handles(
      top: selected.top,
      bottom: selected.bottom - AppTimeline.blockGap,
      left: gutter + (width - gutter) * selected.column / selected.columns,
      width: (width - gutter) / selected.columns - AppTimeline.blockGap,
      onStart: (global, mode) =>
          DragScope.maybeOf(context)?.start(selected, global, mode),
    );
  }

  Widget _ghost(BuildContext context, DragSession drag) {
    final t = AppTheme.of(context);
    final scale = geometry.scale;
    final s = drag.proposed;
    final top = scale.yOf(s.start.toDouble());
    final minHeight =
        AppTimeline.minBlockHeight * MediaQuery.textScalerOf(context).scale(1);
    final height = math.max(
      scale.yOf((s.start + s.duration).toDouble()) - top,
      minHeight,
    );
    final block = drag.block.copyWith(
      startUtc: geometry.day.startUtc.add(Duration(minutes: s.start)),
      durationMin: s.duration,
    );
    final range = context.l10n.blockTimeRange(
      timeOfUtc(
        context,
        geometry.day.location,
        block.startUtc!,
        use24h: use24h,
      ),
      timeOfUtc(context, geometry.day.location, block.endUtc!, use24h: use24h),
    );
    return Stack(
      clipBehavior: Clip.none,
      children: [
        PositionedDirectional(
          top: top,
          start: gutter,
          width: width - gutter - AppTimeline.blockGap,
          height: height - AppTimeline.blockGap,
          child: IgnorePointer(
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppRadii.block),
                boxShadow: [
                  BoxShadow(
                    color: t.colors.onSurface.withValues(alpha: 0.22),
                    blurRadius: _lift * 2,
                    offset: const Offset(0, _lift / 2),
                  ),
                ],
              ),
              child: BlockTile(
                block: block,
                location: geometry.day.location,
                use24h: use24h,
              ),
            ),
          ),
        ),
        _TimeLabel(top: top, left: gutter, text: range),
      ],
    );
  }
}

/// Live snapped time in a floating pill above the ghost (below it near the
/// top of the day so it never leaves the canvas).
class _TimeLabel extends StatelessWidget {
  const _TimeLabel({required this.top, required this.left, required this.text});

  final double top;

  /// Start offset (the gutter width).
  final double left;
  final String text;

  @override
  Widget build(BuildContext context) {
    final t = AppTheme.of(context);
    final height = MediaQuery.textScalerOf(context).scale(AppSpacing.xl + 4);
    final above = top - height - AppSpacing.xs;
    return PositionedDirectional(
      top: above >= 0 ? above : top + AppSpacing.xs,
      start: left + AppSpacing.s,
      child: IgnorePointer(
        child: Semantics(
          liveRegion: true,
          label: text,
          excludeSemantics: true,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: t.colors.accent,
              borderRadius: BorderRadius.circular(height / 2),
            ),
            child: Padding(
              padding: const EdgeInsetsDirectional.symmetric(
                horizontal: AppSpacing.m,
                vertical: AppSpacing.xs,
              ),
              child: Text(
                text,
                style: t.typography.mono.copyWith(color: t.colors.onAccent),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Grips at the top and bottom of the selected block; dragging one resizes
/// at once (no long-press: the handle is already an explicit target).
class _Handles extends StatelessWidget {
  const _Handles({
    required this.top,
    required this.bottom,
    required this.left,
    required this.width,
    required this.onStart,
  });

  final double top;
  final double bottom;
  final double left;
  final double width;
  final bool? Function(Offset global, DragMode mode) onStart;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    const size = kMinInteractiveDimension;
    final x = left + width / 2 - size / 2;
    final t = AppTheme.of(context);
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Selection ring, same token as the focus ring (03 §4: accent, 2 px).
        PositionedDirectional(
          top: top,
          start: left,
          width: width,
          height: bottom - top,
          child: IgnorePointer(
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppRadii.block),
                border: Border.all(color: t.colors.accent, width: 2),
              ),
            ),
          ),
        ),
        PositionedDirectional(
          top: top - size / 2,
          start: x,
          child: _Handle(
            label: l10n.resizeHandleStart,
            onStart: (g) => onStart(g, DragMode.resizeStart),
          ),
        ),
        PositionedDirectional(
          top: bottom - size / 2,
          start: x,
          child: _Handle(
            label: l10n.resizeHandleEnd,
            onStart: (g) => onStart(g, DragMode.resizeEnd),
          ),
        ),
      ],
    );
  }
}

class _Handle extends StatelessWidget {
  const _Handle({required this.label, required this.onStart});

  final String label;
  final void Function(Offset global) onStart;

  @override
  Widget build(BuildContext context) {
    final t = AppTheme.of(context);
    final drag = DragScope.maybeOf(context);
    return Semantics(
      label: label,
      child: MouseRegion(
        cursor: SystemMouseCursors.resizeRow,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          dragStartBehavior: DragStartBehavior.down,
          onVerticalDragStart: (d) => onStart(d.globalPosition),
          onVerticalDragUpdate: (d) => drag?.update(d.globalPosition),
          onVerticalDragEnd: (_) => drag?.end(),
          onVerticalDragCancel: drag?.cancel,
          child: SizedBox.square(
            dimension: kMinInteractiveDimension,
            child: Center(
              child: Container(
                width: AppSpacing.xl,
                height: AppSpacing.s,
                decoration: BoxDecoration(
                  color: t.colors.accent,
                  borderRadius: BorderRadius.circular(AppSpacing.xs),
                  border: Border.all(color: t.colors.surfaceRaised),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
