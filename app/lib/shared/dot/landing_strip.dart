import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:flutter/material.dart';

/// Minimal Add's mini horizon (E-PhonesMinimal frames 3 and 6, ED-217):
/// the waking day from [fromUtc] to [toUtc], dotted; the day's other
/// tasks as faint rings ([others], CR-133); and where the new task lands
/// as a 22 px ring in its colour with [label] ("6 PM") under it. A
/// picture only: the "Lands at" line above it says the same in words.
class LandingStrip extends StatelessWidget {
  const LandingStrip({
    required this.fromUtc,
    required this.toUtc,
    required this.others,
    required this.landingUtc,
    required this.color,
    required this.label,
    super.key,
  });

  final DateTime fromUtc;
  final DateTime toUtc;
  final List<({DateTime startUtc, TaskColor color})> others;
  final DateTime landingUtc;
  final TaskColor color;
  final String label;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    return ExcludeSemantics(
      child: SizedBox(
        height: DotSize.landingStrip,
        child: LayoutBuilder(
          builder: (context, box) {
            final x = _x(landingUtc, box.maxWidth);
            return Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned.fill(
                  child: CustomPaint(
                    painter: _StripPainter(
                      xs: [
                        for (final o in others) _x(o.startUtc, box.maxWidth),
                      ],
                      colors: [for (final o in others) t.tasks[o.color].ring],
                      landingX: x,
                      landing: t.tasks[color].ring,
                      line: t.colors.threadAhead,
                      ground: t.colors.raised,
                    ),
                  ),
                ),
                Positioned(
                  top: DotSize.landingMarker + DotSpace.xxs,
                  left: (x - DotSize.landingStrip).clamp(0, box.maxWidth),
                  width: DotSize.landingStrip * 2,
                  child: Text(
                    label,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    style: t.styles.threadMeta.copyWith(
                      color: t.colors.text,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  double _x(DateTime at, double width) {
    const r = DotSize.landingMarker / 2;
    final span = toUtc.difference(fromUtc).inSeconds;
    if (span <= 0) return r;
    final p = (at.difference(fromUtc).inSeconds / span).clamp(0.0, 1.0);
    return r + p * (width - 2 * r);
  }
}

class _StripPainter extends CustomPainter {
  const _StripPainter({
    required this.xs,
    required this.colors,
    required this.landingX,
    required this.landing,
    required this.line,
    required this.ground,
  });

  final List<double> xs;
  final List<Color> colors;
  final double landingX;
  final Color landing;
  final Color line;
  final Color ground;

  @override
  void paint(Canvas canvas, Size size) {
    const y = DotSize.landingMarker / 2;
    final dot = Paint()..color = line;
    const gap = DotSize.horizonLine * 2;
    for (var x = 0.0; x < size.width; x += gap) {
      canvas.drawCircle(Offset(x, y), DotSize.horizonLine / 2, dot);
    }
    const r = DotSize.horizonDot / 2;
    final ring = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = DotSize.horizonRing;
    for (final (i, x) in xs.indexed) {
      canvas
        ..drawCircle(Offset(x, y), r, Paint()..color = ground)
        ..drawCircle(
          Offset(x, y),
          r,
          ring..color = colors[i].withValues(alpha: TaskAlpha.landingOthers),
        );
    }
    const big = DotSize.landingMarker / 2;
    canvas
      ..drawCircle(Offset(landingX, y), big, Paint()..color = ground)
      ..drawCircle(
        Offset(landingX, y),
        big - DotSize.landingRing / 2,
        Paint()
          ..color = landing
          ..style = PaintingStyle.stroke
          ..strokeWidth = DotSize.landingRing,
      );
  }

  @override
  bool shouldRepaint(_StripPainter old) =>
      old.landingX != landingX ||
      old.xs.length != xs.length ||
      old.landing != landing ||
      old.line != line;
}
