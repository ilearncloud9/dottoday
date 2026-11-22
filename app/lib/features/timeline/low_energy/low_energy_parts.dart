import 'dart:math' as math;

import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:flutter/material.dart';

/// A raised low-energy card (E-R2-22): the one dot, or "Nothing else
/// today. Rest well."
class LowEnergyCard extends StatelessWidget {
  const LowEnergyCard({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final c = DotTheme.of(context).colors;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: c.raised,
        borderRadius: BorderRadius.circular(DotRadii.cardLarge),
        border: Border.all(color: c.outline, width: DotSpace.hairline),
      ),
      child: Padding(padding: const EdgeInsets.all(DotSpace.l), child: child),
    );
  }
}

/// The one dot to look at (E-R2-22): its ring (filling while it runs),
/// title, "until 11:00 AM · 18 min left" or "at 2:00 PM", and Done and
/// Not today side by side.
class NextDotCard extends StatelessWidget {
  const NextDotCard({
    required this.task,
    required this.progress,
    required this.when,
    required this.onDone,
    required this.onNotToday,
    super.key,
  });

  final Occurrence task;

  /// Share of its planned time gone; 0 before it starts.
  final double progress;
  final String when;
  final VoidCallback onDone;
  final VoidCallback onNotToday;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final l10n = context.l10n;
    final tone = t.tasks[TaskColor.fromKey(task.colorKey)];
    const size = WidgetStatePropertyAll(Size(0, DotTouch.min + DotSpace.xs));
    return LowEnergyCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: DotSpace.s,
        children: [
          Center(
            child: _Ring(
              progress: progress,
              color: tone.color,
              track: tone.tint,
            ),
          ),
          const SizedBox(height: DotSpace.xxs),
          Text(
            task.title,
            textAlign: TextAlign.center,
            style: t.styles.promptTitle,
          ),
          Text(
            when,
            textAlign: TextAlign.center,
            style: t.styles.rowMeta.copyWith(color: t.colors.muted),
          ),
          const SizedBox(height: DotSpace.xs),
          Wrap(
            spacing: DotSpace.s,
            runSpacing: DotSpace.s,
            alignment: WrapAlignment.center,
            children: [
              ConstrainedBox(
                constraints: const BoxConstraints(minWidth: _buttonMin),
                child: FilledButton.icon(
                  onPressed: onDone,
                  style: ButtonStyle(
                    backgroundColor: WidgetStatePropertyAll(tone.color),
                    foregroundColor: WidgetStatePropertyAll(tone.check),
                    textStyle: WidgetStatePropertyAll(t.styles.button),
                    minimumSize: size,
                  ),
                  icon: DotIcon(
                    DotGlyphs.check,
                    color: tone.check,
                    size: DotSize.rowIcon,
                  ),
                  label: Text(l10n.liveDone),
                ),
              ),
              ConstrainedBox(
                constraints: const BoxConstraints(minWidth: _buttonMin),
                child: OutlinedButton(
                  onPressed: onNotToday,
                  style: ButtonStyle(
                    textStyle: WidgetStatePropertyAll(t.styles.button),
                    minimumSize: size,
                  ),
                  child: Text(l10n.lowEnergyNotToday),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Each button's least width: two side by side on a phone, wrapping at
  /// large text.
  static const _buttonMin = DotSize.lowEnergyRing + DotSpace.xxl;
}

/// The ring around the one dot: the track, the share gone in the task's
/// colour from the top, and the dot inside.
class _Ring extends StatelessWidget {
  const _Ring({
    required this.progress,
    required this.color,
    required this.track,
  });

  final double progress;
  final Color color;
  final Color track;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    return ExcludeSemantics(
      child: TweenAnimationBuilder<double>(
        tween: Tween(end: progress.clamp(0, 1)),
        duration: t.motion.slow,
        curve: t.motion.curve,
        builder: (context, sweep, _) => CustomPaint(
          size: const Size.square(DotSize.lowEnergyRing),
          painter: _RingPainter(sweep: sweep, color: color, track: track),
        ),
      ),
    );
  }
}

final class _RingPainter extends CustomPainter {
  const _RingPainter({
    required this.sweep,
    required this.color,
    required this.track,
  });

  final double sweep;
  final Color color;
  final Color track;

  @override
  void paint(Canvas canvas, Size size) {
    const stroke = DotSize.lowEnergyRingStroke;
    final center = size.center(Offset.zero);
    final radius = size.shortestSide / 2 - stroke / 2;
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;
    canvas
      ..drawCircle(center, radius, paint..color = track)
      ..drawCircle(center, DotSize.lowEnergyDot / 2, Paint()..color = color);
    if (sweep <= 0) return;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      2 * math.pi * sweep,
      false,
      paint..color = color,
    );
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.sweep != sweep || old.color != color || old.track != track;
}

/// "🌿 Low-energy · on" beside the title (E-R2-22): a tinted pill; one tap
/// turns the mode off (the Day menu and Settings › Planning have the same
/// switch, ED-093).
class LowEnergyChip extends StatelessWidget {
  const LowEnergyChip({required this.onTurnOff, super.key});

  final VoidCallback onTurnOff;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final c = t.colors;
    final l10n = context.l10n;
    return Semantics(
      button: true,
      toggled: true,
      label: l10n.lowEnergyMode,
      hint: l10n.lowEnergyTurnOff,
      excludeSemantics: true,
      child: InkWell(
        onTap: onTurnOff,
        borderRadius: BorderRadius.circular(DotRadii.pill),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: DotTouch.min),
          child: Center(
            widthFactor: 1,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: c.accentTint,
                borderRadius: BorderRadius.circular(DotRadii.pill),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: DotSpace.s + DotSpace.xxs,
                  vertical: DotSpace.xs,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  spacing: DotSpace.xs,
                  children: [
                    DotIcon(
                      TaskIcon.leaf.glyph!,
                      color: c.accentInk,
                      size: DotSize.miniRing + DotSpace.xxs,
                    ),
                    Text(
                      l10n.lowEnergyOn,
                      style: t.styles.rowMeta.copyWith(
                        color: c.accentInk,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
