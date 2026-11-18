import 'dart:math' as math;

import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:flutter/material.dart';

/// The hour-label gutter (E-FullA-v2: 44), wider as text grows so "10 AM"
/// stays whole at 200 %.
double hourGutter(BuildContext context) => math.max(
  DotSize.gridGutter,
  MediaQuery.textScalerOf(context).scale(DotSize.gridGutter),
);

/// One whole hour inside a thread row: how far down the row it falls
/// (0 at the row's top, 1 at its bottom) and its label ("9 AM").
typedef ThreadHourMark = ({double at, String label});

/// The time a thread row stands for on the hour scale: its [minutes]
/// (the row is at least that tall) and the whole hours inside it.
typedef ThreadHourSpan = ({int minutes, List<ThreadHourMark> marks});

/// The Day view's thread on hours (E-FullA-v2 web Day, M19.2 part 2): a
/// row per entry as tall as its time at [pxPerMinute] (never shorter than
/// its content), the hour labels in a gutter and the hour lines across.
/// [spans] lines up with the thread's entries; a null span (a cap, now,
/// a knot) keeps the row's own height and carries no hour.
@immutable
final class ThreadHours {
  const ThreadHours({required this.spans, required this.pxPerMinute});

  final List<ThreadHourSpan?> spans;
  final double pxPerMinute;
}

/// [child] (a thread row) after the hour gutter, at least [span]'s time
/// tall, its hours' labels in the gutter and lines behind it.
class ThreadHourRow extends StatelessWidget {
  const ThreadHourRow({
    required this.span,
    required this.pxPerMinute,
    required this.child,
    super.key,
  });

  final ThreadHourSpan? span;
  final double pxPerMinute;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final s = span;
    final gutter = hourGutter(context);
    Widget row = Padding(
      padding: EdgeInsetsDirectional.only(start: gutter),
      child: child,
    );
    if (s == null) return row;
    row = ConstrainedBox(
      constraints: BoxConstraints(minHeight: s.minutes * pxPerMinute),
      child: row,
    );
    if (s.marks.isEmpty) return row;
    return CustomPaint(
      painter: _Hours(
        marks: s.marks,
        style: t.styles.gridHour,
        line: t.colors.gridLine,
        scaler: MediaQuery.textScalerOf(context),
        direction: Directionality.of(context),
        gutter: gutter,
      ),
      child: row,
    );
  }
}

/// The hour lines across a row and their labels, right-aligned in the
/// gutter and centred on their line.
final class _Hours extends CustomPainter {
  const _Hours({
    required this.marks,
    required this.style,
    required this.line,
    required this.scaler,
    required this.direction,
    required this.gutter,
  });

  final double gutter;
  final List<ThreadHourMark> marks;
  final TextStyle style;
  final Color line;
  final TextScaler scaler;
  final TextDirection direction;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = line;
    const end = DotSpace.xs + DotSpace.xxs;
    final rtl = direction == TextDirection.rtl;
    for (final m in marks) {
      final y = m.at * size.height;
      canvas.drawRect(
        Rect.fromLTWH(
          rtl ? 0 : gutter,
          y,
          size.width - gutter,
          DotSpace.hairline,
        ),
        paint,
      );
      final text = TextPainter(
        text: TextSpan(text: m.label, style: style),
        textDirection: direction,
        textScaler: scaler,
        maxLines: 1,
      )..layout(maxWidth: gutter - end);
      final x = rtl ? size.width - gutter + end : gutter - end - text.width;
      text
        ..paint(canvas, Offset(x, y - text.height / 2))
        ..dispose();
    }
  }

  @override
  bool shouldRepaint(_Hours old) =>
      old.marks != marks ||
      old.style != style ||
      old.line != line ||
      old.scaler != scaler ||
      old.direction != direction ||
      old.gutter != gutter;
}
