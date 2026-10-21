import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:flutter/material.dart';

/// The block's icon circle (docs/03 §3.1). Doubles as the complete toggle
/// ("Complete: tap icon circle", 03 §3.2): its hit area is the full
/// 48 dp target even though the drawn circle is smaller.
class IconCircle extends StatelessWidget {
  const IconCircle({
    required this.icon,
    required this.color,
    required this.done,
    required this.label,
    this.onPressed,
    super.key,
  });

  final IconData icon;

  /// The block's strong colour.
  final Color color;
  final bool done;

  /// Screen-reader name of the toggle ("Mark Gym done").
  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final scaler = MediaQuery.textScalerOf(context);
    final diameter = scaler.scale(DotSpace.xl + DotSpace.xs);
    final target = scaler.scale(kMinInteractiveDimension);
    final circle = Container(
      width: diameter,
      height: diameter,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: done ? t.colors.success : color.withValues(alpha: 0.16),
      ),
      child: Icon(
        done ? Icons.check : icon,
        size: diameter * 0.6,
        color: done ? t.colors.raised : color,
      ),
    );
    final box = SizedBox(
      width: target,
      height: target,
      child: Center(child: circle),
    );
    if (onPressed == null) return ExcludeSemantics(child: box);
    return Semantics(
      // Its own node, so the block's label stays separate from the toggle.
      container: true,
      button: true,
      checked: done,
      label: label,
      excludeSemantics: true,
      onTap: onPressed,
      child: InkResponse(onTap: onPressed, radius: target / 2, child: box),
    );
  }
}
