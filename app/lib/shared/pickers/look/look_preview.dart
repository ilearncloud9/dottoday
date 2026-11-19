import 'dart:math' as math;

import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:flutter/material.dart';

/// All colours' preview (ED-156, ED-157): the task as ahead, in progress
/// and done in [colour], and whether its ring had to be deepened to stay
/// visible (3:1).
class LookPreview extends StatelessWidget {
  const LookPreview({required this.colour, required this.icon, super.key});

  final TaskColor colour;
  final TaskIcon icon;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final l10n = context.l10n;
    final s = t.tasks[colour];
    final glyph = icon.glyph ?? DotGlyphs.check;
    final adjusted = s.ring != s.color;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: DotSpace.m,
        vertical: DotSpace.s + DotSpace.xxs,
      ),
      decoration: BoxDecoration(
        color: t.colors.ground,
        borderRadius: const BorderRadius.all(Radius.circular(DotSpace.l)),
        border: Border.all(color: t.colors.hairline, width: DotSpace.hairline),
      ),
      child: Row(
        spacing: DotSpace.m,
        children: [
          Semantics(
            label: l10n.lookAhead,
            child: _dot(
              t,
              DotLook.previewDot,
              BoxDecoration(
                shape: BoxShape.circle,
                color: t.colors.raised,
                border: Border.all(color: s.ring, width: DotLook.previewRing),
              ),
              DotIcon(glyph, color: s.ring, size: DotLook.previewGlyph),
            ),
          ),
          Semantics(
            label: l10n.lookInProgress,
            child: SizedBox.square(
              dimension: DotLook.previewArc,
              child: CustomPaint(
                painter: _ArcPainter(
                  ring: s.ring,
                  track: s.color.withValues(alpha: TaskAlpha.track),
                ),
                child: Center(
                  child: DotIcon(
                    glyph,
                    color: s.ring,
                    size: DotLook.previewGlyph,
                  ),
                ),
              ),
            ),
          ),
          Semantics(
            label: l10n.lookDone,
            child: _dot(
              t,
              DotLook.previewDot,
              BoxDecoration(shape: BoxShape.circle, color: s.color),
              DotIcon(DotGlyphs.check, color: s.check, active: true),
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final line in [
                  l10n.lookPreviewStates,
                  if (adjusted)
                    l10n.lookRingAdjusted(hexOf(s.ring))
                  else
                    l10n.lookRingSame,
                ])
                  Text(
                    line,
                    style: t.styles.inspectorLabel.copyWith(
                      color: t.colors.text,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _dot(DotTheme t, double size, BoxDecoration d, Widget child) =>
      Container(
        width: size,
        height: size,
        alignment: Alignment.center,
        decoration: d,
        child: child,
      );
}

/// The in-progress ring: the arc in the ring shade (ED-157), the rest in
/// a faint track.
class _ArcPainter extends CustomPainter {
  const _ArcPainter({required this.ring, required this.track});

  final Color ring;
  final Color track;

  /// How far along the preview's task is, as drawn (65 %).
  static const _progress = 0.65;

  @override
  void paint(Canvas canvas, Size size) {
    const w = DotLook.previewRing;
    final rect = (Offset.zero & size).deflate(w / 2);
    final p = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = w;
    canvas
      ..drawArc(rect, 0, math.pi * 2, false, p..color = track)
      ..drawArc(
        rect,
        -math.pi / 2,
        math.pi * 2 * _progress,
        false,
        p
          ..color = ring
          ..strokeCap = StrokeCap.round,
      );
  }

  @override
  bool shouldRepaint(_ArcPainter old) => old.ring != ring || old.track != track;
}
