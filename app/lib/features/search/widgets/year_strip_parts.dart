import 'dart:math' as math;

import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart' show NumberFormat;

/// One month of the year strip, option B (E-R2-34, ED-348): a dot that
/// fills like a task's, as far round as the share of its days planned,
/// with that count inside. The month in progress is dashed; the open one
/// has a second ring, the keyboard's a focus ring.
class YearMonthRing extends StatelessWidget {
  const YearMonthRing({
    required this.planned,
    required this.days,
    required this.inProgress,
    required this.open,
    required this.focused,
    super.key,
  });

  /// Days with something planned, and the month's length.
  final int planned;
  final int days;
  final bool inProgress;
  final bool open;
  final bool focused;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final c = t.colors;
    return CustomPaint(
      painter: _RingPainter(
        share: days == 0 ? 0 : planned / days,
        inProgress: inProgress,
        accent: c.accent,
        track: Color.alphaBlend(c.tonal, c.card),
        outer: focused ? c.focus : (open ? c.accent : null),
      ),
      child: SizedBox.square(
        dimension: DotSize.yearMonthDot,
        child: Center(
          child: Text(
            NumberFormat.decimalPattern(
              Localizations.localeOf(context).toLanguageTag(),
            ).format(planned),
            style: t.styles.rowTitle,
            textScaler: TextScaler.noScaling,
          ),
        ),
      ),
    );
  }
}

final class _RingPainter extends CustomPainter {
  const _RingPainter({
    required this.share,
    required this.inProgress,
    required this.accent,
    required this.track,
    required this.outer,
  });

  final double share;
  final bool inProgress;
  final Color accent;
  final Color track;

  /// The open month's ring or the focus ring, outside the dot.
  final Color? outer;

  static const _stroke = DotSize.yearMonthStroke;

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final r = size.shortestSide / 2 - _stroke;
    final line = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = _stroke
      ..strokeCap = StrokeCap.round;
    if (inProgress) {
      _dashed(
        canvas,
        c,
        r,
        Paint.from(line)
          ..color = accent
          ..strokeCap = StrokeCap.butt
          ..strokeWidth = _stroke / 2,
      );
    } else {
      canvas.drawCircle(c, r, line..color = track);
    }
    if (share > 0) {
      canvas.drawArc(
        Rect.fromCircle(center: c, radius: r),
        -math.pi / 2,
        2 * math.pi * share.clamp(0, 1),
        false,
        line..color = accent,
      );
    }
    if (outer case final o?) {
      canvas.drawCircle(
        c,
        r + _stroke + DotSpace.xxs,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = DotSpace.hairline * 1.5
          ..color = o,
      );
    }
  }

  /// The month in progress: its track in dashes.
  void _dashed(Canvas canvas, Offset c, double r, Paint paint) {
    const dashes = 12;
    const sweep = math.pi / dashes;
    for (var i = 0; i < dashes; i++) {
      canvas.drawArc(
        Rect.fromCircle(center: c, radius: r),
        -math.pi / 2 + i * 2 * sweep,
        sweep,
        false,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.share != share ||
      old.inProgress != inProgress ||
      old.accent != accent ||
      old.track != track ||
      old.outer != outer;
}

/// A day of the open month (E-R2-34 option B): filled when all of it was
/// done, a ring when it was planned, a faint ring when nothing was.
class YearDayDot extends StatelessWidget {
  const YearDayDot({required this.share, super.key});

  /// The day's done share; null when nothing was planned.
  final double? share;

  @override
  Widget build(BuildContext context) {
    final c = DotTheme.of(context).colors;
    final s = share;
    return Container(
      width: DotSize.yearDayDot,
      height: DotSize.yearDayDot,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: s == 1 ? c.accent : null,
        border: s == 1
            ? null
            : Border.all(
                color: s == null ? c.threadAhead : c.accent,
                width: DotSize.smallDotOutline,
              ),
      ),
    );
  }
}
