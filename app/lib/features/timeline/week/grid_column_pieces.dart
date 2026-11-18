import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/shared/dot/thread.dart';
import 'package:flutter/material.dart';

/// Lane [lane] of [lanes] across the column, inside its 4 px insets, 6
/// apart.
class GridLane extends StatelessWidget {
  const GridLane({
    super.key,
    required this.lane,
    required this.lanes,
    required this.child,
  });

  final int lane;
  final int lanes;
  final Widget child;

  static const _gap = DotSpace.xs + DotSpace.xxs;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, box) {
      final inner = box.maxWidth - DotSize.gridInset * 2;
      final width = (inner - _gap * (lanes - 1)) / lanes;
      return Padding(
        padding: EdgeInsetsDirectional.only(
          start: DotSize.gridInset + lane * (width + _gap),
        ),
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

/// Where a dragged task would land (E-FullA-v2 Week): its time's box,
/// dashed in the accent over a light tint, with [label] ("Wed · 11:30 –
/// 12:00") inside.
List<Widget> gridDropPreview(
  BuildContext context, {
  required double top,
  required double height,
  required String label,
}) {
  final t = DotTheme.of(context);
  final c = t.colors;
  return [
    Positioned(
      left: DotSize.gridInset,
      right: DotSize.gridInset,
      top: top,
      height: height < DotSize.gridPill ? DotSize.gridPill : height,
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
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: DotSpace.s + DotSpace.hairline,
                vertical: DotSpace.xxs + DotSpace.hairline,
              ),
              child: Text(
                label,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: t.styles.gridPill.copyWith(color: c.accentText),
              ),
            ),
          ),
        ),
      ),
    ),
  ];
}
