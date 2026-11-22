import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:flutter/widgets.dart';

/// A task as a small hollow ring in its colour (E-R2-22): a routine's
/// mini thread and steps, low-energy's Later pile and its rows. Drawn
/// only: the row or card around it carries the label.
class MiniRing extends StatelessWidget {
  const MiniRing({
    required this.color,
    this.size = DotSize.miniRing,
    super.key,
  });

  final TaskColor color;

  /// [DotSize.miniRing]; the stroke stays [DotSize.miniRingStroke].
  final double size;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    return ExcludeSemantics(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: t.tasks[color].color,
            width: DotSize.miniRingStroke,
          ),
        ),
      ),
    );
  }
}
