import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/shared/dot/thread_axis.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

/// Lays out one thread row: [dot] on the axis over the [piece] painted
/// down it, [child] beside it and an optional [trailing] control, all
/// centred on the row (E rules §5.2), which is at least [minHeight] tall.
/// Geometry is directional, so the thread runs down the start edge in RTL.
class ThreadRowFrame extends StatelessWidget {
  const ThreadRowFrame({
    required this.piece,
    required this.child,
    this.dot,
    this.trailing,
    this.minHeight = 0,
    this.card = false,
    super.key,
  });

  final AxisPiece piece;
  final Widget child;
  final Widget? dot;
  final Widget? trailing;
  final double minHeight;

  /// The now card (E rules §5.3): the row sits on a card that reaches
  /// [DotSpace.nowCard] past each side and covers the thread.
  final bool card;

  @override
  Widget build(BuildContext context) {
    final c = DotTheme.of(context).colors;
    return CustomPaint(
      painter: _AxisAtStart(
        ThreadAxisPainter(
          piece: piece,
          hairline: c.threadAhead,
          accent: c.accent,
          card: c.card,
          ghostSide: Directionality.of(context) == TextDirection.rtl ? 1 : -1,
        ),
        rtl: Directionality.of(context) == TextDirection.rtl,
        card: card ? (fill: c.card, edge: c.hairline) : null,
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(minHeight: minHeight),
        child: Row(
          children: [
            SizedBox(
              width: threadAxisWidth,
              child: switch (dot) {
                final d? => Center(child: _Overhang(child: d)),
                null => null,
              },
            ),
            const SizedBox(width: threadTextGap),
            Expanded(child: child),
            ?trailing,
          ],
        ),
      ),
    );
  }
}

/// Paints [axis] in the [threadAxisWidth] column at the row's start edge.
/// With [card], the now card over it: radius 24, a 1 px inset hairline.
final class _AxisAtStart extends CustomPainter {
  const _AxisAtStart(this.axis, {required this.rtl, this.card});

  final ThreadAxisPainter axis;
  final bool rtl;
  final ({Color fill, Color edge})? card;

  @override
  void paint(Canvas canvas, Size size) {
    canvas
      ..save()
      ..translate(rtl ? size.width - threadAxisWidth : 0, 0);
    axis.paint(canvas, Size(threadAxisWidth, size.height));
    canvas.restore();
    final card = this.card;
    if (card == null) return;
    final box = RRect.fromRectAndRadius(
      Rect.fromLTRB(
        -DotSpace.nowCard,
        0,
        size.width + DotSpace.nowCard,
        size.height,
      ),
      const Radius.circular(DotRadii.cardLarge),
    );
    canvas
      ..drawRRect(box, Paint()..color = card.fill)
      ..drawRRect(
        box.deflate(DotSpace.hairline / 2),
        Paint()
          ..color = card.edge
          ..style = PaintingStyle.stroke
          ..strokeWidth = DotSpace.hairline,
      );
  }

  @override
  bool shouldRepaint(_AxisAtStart old) =>
      old.rtl != rtl || old.card != card || axis.shouldRepaint(old.axis);
}

/// Lays its child out at any width and takes no more than it is given,
/// so the child overhangs both sides evenly: a phone's 52 dot over the 48
/// column (owner, ED-419).
class _Overhang extends SingleChildRenderObjectWidget {
  const _Overhang({required super.child});

  @override
  RenderObject createRenderObject(BuildContext context) => _RenderOverhang();
}

class _RenderOverhang extends RenderShiftedBox {
  _RenderOverhang() : super(null);

  @override
  void performLayout() {
    final child = this.child!;
    child.layout(
      constraints.copyWith(minWidth: 0, maxWidth: double.infinity),
      parentUsesSize: true,
    );
    size = constraints.constrain(child.size);
    (child.parentData! as BoxParentData).offset = Offset(
      (size.width - child.size.width) / 2,
      (size.height - child.size.height) / 2,
    );
  }
}
