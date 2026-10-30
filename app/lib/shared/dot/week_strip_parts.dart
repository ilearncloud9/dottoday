import 'dart:math' as math;

import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/shared/dot/week_strip.dart';
import 'package:flutter/material.dart';

/// The 8 px completion dot (docs/10 §3 `WeekStrip`, `MonthGrid`).
class CompletionDot extends StatelessWidget {
  const CompletionDot({
    required this.completion,
    this.size = DotSize.weekDot,
    super.key,
  });

  final Completion completion;
  final double size;

  @override
  Widget build(BuildContext context) {
    final c = DotTheme.of(context).colors;
    return CustomPaint(
      size: Size.square(size + DotSpace.xxs),
      painter: _CompletionPainter(
        share: completion.share,
        accent: c.accent,
        track: Color.alphaBlend(c.accentTint, c.raised),
        hairline: c.hairline,
      ),
    );
  }
}

final class _CompletionPainter extends CustomPainter {
  const _CompletionPainter({
    required this.share,
    required this.accent,
    required this.track,
    required this.hairline,
  });

  final double? share;
  final Color accent;
  final Color track;
  final Color hairline;

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final r = DotSize.weekDot / 2;
    final s = share;
    if (s == null) {
      final ring = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = DotSpace.hairline * 1.5
        ..color = hairline;
      canvas.drawCircle(c, r, ring);
      return;
    }
    final rect = Rect.fromCircle(center: c, radius: r);
    canvas.drawCircle(c, r, Paint()..color = s >= 1 ? accent : track);
    if (s > 0 && s < 1) {
      canvas.drawArc(
        rect,
        -math.pi / 2,
        2 * math.pi * s,
        true,
        Paint()..color = accent,
      );
    }
  }

  @override
  bool shouldRepaint(_CompletionPainter old) =>
      old.share != share ||
      old.accent != accent ||
      old.track != track ||
      old.hairline != hairline;
}

/// The grab handle under the strip that pulls the month open (§2.4).
class PullHandle extends StatelessWidget {
  const PullHandle({required this.open, this.onPull, super.key});

  final bool open;
  final VoidCallback? onPull;

  @override
  Widget build(BuildContext context) {
    final c = DotTheme.of(context).colors;
    final l10n = context.l10n;
    return Semantics(
      button: true,
      expanded: open,
      label: open ? l10n.weekStripHideMonth : l10n.weekStripShowMonth,
      excludeSemantics: true,
      onTap: onPull,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onPull,
        onVerticalDragEnd: onPull == null ? null : (_) => onPull!(),
        child: SizedBox(
          // A full 48 dp target although the bar is 5 px (§7.4 wins over
          // the render's tighter gap).
          width: DotTouch.android * 2,
          height: DotTouch.android,
          child: Center(
            child: Container(
              width: DotSize.rowDot,
              height: DotSize.weekDot / 2 + 1,
              decoration: BoxDecoration(
                color: c.outline,
                borderRadius: BorderRadius.circular(DotRadii.pill),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
