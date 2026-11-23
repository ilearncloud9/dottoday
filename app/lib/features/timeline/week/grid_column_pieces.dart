import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/features/timeline/week/grid_scale.dart';
import 'package:dottoday/features/timeline/week/week_pieces.dart';
import 'package:dottoday/shared/dot/thread.dart';
import 'package:flutter/material.dart';

/// Lane [lane] of [lanes] across the column, inside its 4 px insets, 6
/// apart. [stacked] (touch, E-R2-2): the first keeps the whole column and
/// each later lane sits over it one ring further in, to the same edge.
class GridLane extends StatelessWidget {
  const GridLane({
    super.key,
    required this.lane,
    required this.lanes,
    required this.child,
    this.stacked = false,
  });

  final int lane;
  final int lanes;
  final bool stacked;
  final Widget child;

  static const _gap = DotSpace.xs + DotSpace.xxs;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, box) {
      final inner = box.maxWidth - DotSize.gridInset * 2;
      final width = stacked
          ? inner - lane * DotSize.gridTouchRing
          : (inner - _gap * (lanes - 1)) / lanes;
      final start = stacked
          ? lane * DotSize.gridTouchRing
          : lane * (width + _gap);
      return Padding(
        padding: EdgeInsetsDirectional.only(start: DotSize.gridInset + start),
        child: Align(
          alignment: AlignmentDirectional.topStart,
          child: SizedBox(width: width, child: child),
        ),
      );
    },
  );
}

/// A column's hour lines from [firstLine] down every hour, its left
/// divider, and today's [tint].
final class GridLines extends CustomPainter {
  const GridLines({
    required this.line,
    required this.divider,
    required this.tint,
    required this.firstLine,
  });

  final Color line;
  final Color divider;
  final Color? tint;
  final double firstLine;

  @override
  void paint(Canvas canvas, Size size) {
    if (tint case final t?) {
      canvas.drawRect(Offset.zero & size, Paint()..color = t);
    }
    final paint = Paint()..color = line;
    for (var y = firstLine; y < size.height; y += DotSize.gridHour) {
      canvas.drawRect(
        Rect.fromLTWH(0, y, size.width, DotSpace.hairline),
        paint,
      );
    }
    canvas.drawRect(
      Rect.fromLTWH(0, 0, DotSpace.hairline, size.height),
      Paint()..color = divider,
    );
  }

  @override
  bool shouldRepaint(GridLines old) =>
      old.line != line ||
      old.divider != divider ||
      old.tint != tint ||
      old.firstLine != firstLine;
}

/// Now's dot on today's thread (E-FullA-v2 Week): 14 across in the
/// accent, a 2 px card-coloured edge.
class GridNowDot extends StatelessWidget {
  const GridNowDot({super.key});

  @override
  Widget build(BuildContext context) {
    final c = DotTheme.of(context).colors;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: c.accent,
        shape: BoxShape.circle,
        border: Border.all(color: c.card, width: DotSpace.xxs),
      ),
    );
  }
}

/// Where a dragged task would land (E-FullA-v2 Week, E-R2-25 §2): its
/// time's box, dashed in the accent over a light tint, with [label] ("Wed
/// · 11:30 – 12:00") on a filled pill just above it, so the lifted card
/// over the box never hides it.
List<Widget> gridDropPreview(
  BuildContext context, {
  required double top,
  required double height,
  required String label,
}) {
  final t = DotTheme.of(context);
  final c = t.colors;
  final scale = GridScale.of(context);
  return [
    Positioned(
      left: DotSize.gridInset,
      right: DotSize.gridInset,
      top: top,
      height: height < scale.minCard ? scale.minCard : height,
      child: IgnorePointer(
        child: CustomPaint(
          foregroundPainter: DashedPillPainter(
            color: c.accent,
            radius: DotRadii.block,
          ),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: c.gridDrop,
              borderRadius: BorderRadius.circular(DotRadii.block),
            ),
          ),
        ),
      ),
    ),
    // Above the box: moved up by its own height.
    Positioned(
      left: DotSize.gridInset,
      top: top - DotSpace.xxs,
      child: IgnorePointer(
        child: FractionalTranslation(
          translation: const Offset(0, -1),
          child: DecoratedBox(
            decoration: ShapeDecoration(
              color: c.accent,
              shape: const StadiumBorder(),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: DotSpace.s,
                vertical: DotSpace.xxs,
              ),
              child: Text(
                label,
                maxLines: 1,
                softWrap: false,
                style: scale.pill(t.styles).copyWith(color: c.onAccent),
              ),
            ),
          ),
        ),
      ),
    ),
  ];
}

/// Today's stretch of the now line at [y] and the dot on the column's
/// thread.
List<Widget> gridNowMark(DotColors c, GridScale scale, double y) => [
  gridLine(c.nowLineToday, y, DotSpace.hairline * 1.5),
  Positioned(
    left: scale.threadX + (DotSize.gridThread - DotSize.gridNowDot) / 2,
    top: y - DotSize.gridNowDot / 2,
    width: DotSize.gridNowDot,
    height: DotSize.gridNowDot,
    child: const GridNowDot(),
  ),
];

/// Under a day column's blocks: the hour lines (today tinted), a click
/// target on free grid ([onEmpty]) and the [thread].
List<Widget> gridColumnBackground(
  BuildContext context, {
  required GridScale scale,
  required bool today,
  required VoidCallback? onEmpty,
  required CustomPainter thread,
}) {
  final c = DotTheme.of(context).colors;
  return [
    Positioned.fill(
      child: CustomPaint(
        painter: GridLines(
          line: c.gridLine,
          divider: c.gridDivider,
          tint: today ? c.gridToday : null,
          firstLine: GridScale.leadMinutes * scale.pxPerMinute,
        ),
      ),
    ),
    // Over the painted lines (a painter takes every hit), under the
    // blocks: a click on free grid.
    if (onEmpty != null)
      Positioned.fill(
        child: ExcludeSemantics(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onEmpty,
          ),
        ),
      ),
    Positioned(
      left: scale.threadX,
      top: 0,
      bottom: 0,
      width: DotSize.gridThread,
      child: CustomPaint(painter: thread),
    ),
  ];
}
