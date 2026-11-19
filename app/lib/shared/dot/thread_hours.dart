import 'dart:math' as math;

import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/shared/dot/thread_axis.dart';
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
  const ThreadHours({
    required this.spans,
    required this.pxPerMinute,
    this.nowIn,
  });

  final List<ThreadHourSpan?> spans;
  final double pxPerMinute;

  /// Now inside the live task's row instead of a row of its own (the
  /// E-FullA-v2 web Day board): that row's index, how far down it now is,
  /// the now row's index (drawn as nothing) and its time ("10:42").
  final ({int row, double at, int nowRow, String time})? nowIn;
}

/// Now drawn across a row: the line over the card, the dot on the
/// thread and the time in the gutter.
typedef ThreadHourNow = ({double at, String time});

/// [child] (a thread row) after the hour gutter, at least [span]'s time
/// tall, its hours' labels in the gutter and lines behind it.
class ThreadHourRow extends StatelessWidget {
  const ThreadHourRow({
    required this.span,
    required this.pxPerMinute,
    required this.child,
    this.now,
    super.key,
  });

  /// Now inside this row (the live task's), when the thread draws it there.
  final ThreadHourNow? now;

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
    if (now case final n?) {
      row = Semantics(
        label: context.l10n.timelineNow(n.time),
        child: CustomPaint(
          foregroundPainter: _Now(
            at: n.at,
            time: n.time,
            gutter: gutter,
            line: t.colors.nowLineToday,
            dot: t.colors.accent,
            edge: t.colors.card,
            beadEdge: t.colors.nowBeadEdge,
            style: t.styles.nowBead.copyWith(color: t.colors.accentText),
            scaler: MediaQuery.textScalerOf(context),
          ),
          child: row,
        ),
      );
    }
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

/// Now across the live task's row: the line, the 14 dot on the thread and
/// the time in the gutter (E-FullA-v2 web Day: "10:42").
final class _Now extends CustomPainter {
  const _Now({
    required this.at,
    required this.time,
    required this.gutter,
    required this.line,
    required this.dot,
    required this.edge,
    required this.beadEdge,
    required this.style,
    required this.scaler,
  });

  final Color beadEdge;
  final double at;
  final String time;
  final double gutter;
  final Color line;
  final Color dot;
  final Color edge;
  final TextStyle style;
  final TextScaler scaler;

  @override
  void paint(Canvas canvas, Size size) {
    final y = at * size.height;
    canvas.drawRect(
      Rect.fromLTWH(gutter, y, size.width - gutter, DotSpace.hairline * 1.5),
      Paint()..color = line,
    );
    final centre = Offset(gutter + threadAxisWidth / 2, y);
    canvas
      ..drawCircle(centre, DotSize.gridNowDot / 2, Paint()..color = edge)
      ..drawCircle(
        centre,
        DotSize.gridNowDot / 2 - DotSpace.xxs,
        Paint()..color = dot,
      );
    final text = TextPainter(
      text: TextSpan(text: time, style: style),
      textDirection: TextDirection.ltr,
      textScaler: scaler,
      maxLines: 1,
    )..layout();
    const pad = DotSpace.xs;
    final box = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        gutter - text.width - pad * 3,
        y - text.height / 2,
        text.width + pad * 2,
        text.height,
      ),
      Radius.circular(text.height / 2),
    );
    canvas.drawRRect(box, Paint()..color = edge);
    canvas.drawRRect(
      box,
      Paint()
        ..style = PaintingStyle.stroke
        ..color = beadEdge,
    );
    text
      ..paint(canvas, Offset(box.left + pad, box.top))
      ..dispose();
  }

  @override
  bool shouldRepaint(_Now old) =>
      old.at != at ||
      old.time != time ||
      old.gutter != gutter ||
      old.line != line ||
      old.dot != dot ||
      old.style != style ||
      old.scaler != scaler;
}
