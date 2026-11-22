import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:flutter/widgets.dart';

/// A task as a hollow ring in its colour: small in a routine's mini
/// thread and low-energy's Later pile (E-R2-22), large in Pick today's
/// one thing (E-R2-34), where the pick wears a [halo]. Drawn only: the
/// row or card around it carries the label.
class MiniRing extends StatelessWidget {
  const MiniRing({
    required this.color,
    this.size = DotSize.miniRing,
    this.stroke = DotSize.miniRingStroke,
    this.halo = false,
    super.key,
  });

  final TaskColor color;

  /// [DotSize.miniRing], or [DotSize.pickRing] in the one-thing pick.
  final double size;

  /// [DotSize.miniRingStroke], or [DotSize.pickRingStroke].
  final double stroke;

  /// A second ring [DotSize.pickHalo] outside, drawn past the ring's own
  /// box so rows keep one alignment with and without it.
  final bool halo;

  @override
  Widget build(BuildContext context) {
    final ink = DotTheme.of(context).tasks[color].color;
    final ring = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: ink, width: stroke),
      ),
    );
    if (!halo) return ExcludeSemantics(child: ring);
    const out = DotSize.pickHalo + DotSize.pickHaloStroke;
    return ExcludeSemantics(
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          ring,
          Positioned(
            left: -out,
            top: -out,
            right: -out,
            bottom: -out,
            child: DecoratedBox(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: ink, width: DotSize.pickHaloStroke),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
