import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:flutter/material.dart';

/// The locked dot on a broken thread (E-R2-21 §6, ED-319; M20.10 part 3,
/// ED-479): a lock in an accent ring, a dashed thread either side, over
/// the recovery screen's title. Decorative: the title says it.
class LockedDot extends StatelessWidget {
  const LockedDot({super.key});

  @override
  Widget build(BuildContext context) {
    final c = DotTheme.of(context).colors;
    return ExcludeSemantics(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _Thread(color: c.secondary),
          Container(
            width: DotSize.stateIcon,
            height: DotSize.stateIcon,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: c.accentText,
                width: DotSize.miniRingStroke,
              ),
            ),
            child: Center(
              child: DotIcon(
                DotGlyphs.lock,
                color: c.accentText,
                size: DotSize.stateGlyph,
              ),
            ),
          ),
          _Thread(color: c.secondary),
        ],
      ),
    );
  }
}

/// One side of the broken thread: a short dashed line.
class _Thread extends StatelessWidget {
  const _Thread({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) => CustomPaint(
    size: const Size(DotSize.stateIcon, DotSize.miniRingStroke),
    painter: _DashPainter(color),
  );
}

class _DashPainter extends CustomPainter {
  const _DashPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = size.height;
    final y = size.height / 2;
    for (
      var x = DotSpace.xs;
      x < size.width - DotSpace.xs;
      x += 2 * DotSpace.xs
    ) {
      canvas.drawLine(Offset(x, y), Offset(x + DotSpace.xs, y), paint);
    }
  }

  @override
  bool shouldRepaint(_DashPainter old) => old.color != color;
}
