import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:flutter/material.dart';

/// "Next free slot today: 11:30 – 12:30 · fits Go for a run" + Place
/// (docs/10 §3 `NextFreeSlot`, `A-ios-inbox`): a dashed card with a bit
/// of dotted thread, the slot, and one button.
class NextFreeSlot extends StatelessWidget {
  const NextFreeSlot({
    required this.text,
    required this.placeLabel,
    required this.onPlace,
    super.key,
  });

  final String text;
  final String placeLabel;
  final VoidCallback onPlace;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final c = t.colors;
    return CustomPaint(
      painter: _DashedCard(color: c.outline),
      child: Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(
          DotSpace.xl,
          DotSpace.m,
          DotSpace.m,
          DotSpace.m,
        ),
        child: Row(
          spacing: DotSpace.m,
          children: [
            ExcludeSemantics(
              child: CustomPaint(
                size: const Size(DotSpace.hairline * 2, DotSpace.xl),
                painter: DottedLinePainter(color: c.outline),
              ),
            ),
            Expanded(
              child: Text(
                text,
                style: t.styles.rowMeta.copyWith(color: c.text),
              ),
            ),
            FilledButton(onPressed: onPlace, child: Text(placeLabel)),
          ],
        ),
      ),
    );
  }
}

/// A short vertical run of dots: free time on the thread.
final class DottedLinePainter extends CustomPainter {
  const DottedLinePainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    const step = DotSpace.xs;
    for (var y = 0.0; y <= size.height; y += step) {
      canvas.drawCircle(Offset(size.width / 2, y), size.width / 2, paint);
    }
  }

  @override
  bool shouldRepaint(DottedLinePainter old) => old.color != color;
}

/// A dashed rounded-rectangle outline.
final class _DashedCard extends CustomPainter {
  const _DashedCard({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final rrect = RRect.fromRectAndRadius(
      (Offset.zero & size).deflate(DotSpace.hairline),
      const Radius.circular(DotRadii.card),
    );
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = DotSpace.hairline * 1.5
      ..color = color;
    for (final metric in (Path()..addRRect(rrect)).computeMetrics()) {
      const dash = DotSpace.xs + DotSpace.xxs;
      for (var d = 0.0; d < metric.length; d += dash * 2) {
        canvas.drawPath(metric.extractPath(d, d + dash), paint);
      }
    }
  }

  @override
  bool shouldRepaint(_DashedCard old) => old.color != color;
}
