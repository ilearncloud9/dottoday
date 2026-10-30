import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:flutter/material.dart';

/// The round done circle at a row's end (`Main`, ADR-0015): a ring in the
/// task's [color] that fills with a white tick once [done]; tapping it again
/// undoes it. The row keeps its place either way.
class DoneCircle extends StatelessWidget {
  const DoneCircle({
    required this.color,
    required this.done,
    required this.title,
    this.onTap,
    super.key,
  });

  final TaskColor color;
  final bool done;

  /// The task's title, for the screen reader ("Boom, checked").
  final String title;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final swatch = t.tasks[color];
    final l10n = context.l10n;
    const size = DotSize.doneCircle;
    return Semantics(
      button: true,
      checked: done,
      label: title,
      onTapHint: done ? l10n.dotMarkNotDoneHint : l10n.dotMarkDoneHint,
      onTap: onTap,
      excludeSemantics: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: SizedBox.square(
          dimension: DotTouch.android,
          child: Center(
            child: AnimatedContainer(
              duration: t.motion.base,
              curve: t.motion.curve,
              width: size,
              height: size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: done ? swatch.color : null,
                border: Border.all(
                  color: swatch.color,
                  width: DotSize.dotOutline,
                ),
              ),
              child: done
                  ? Center(
                      child: DotIcon(
                        DotGlyphs.check,
                        color: swatch.check,
                        size: size * DotSize.rowIcon / DotSize.rowDot,
                        bold: true,
                      ),
                    )
                  : null,
            ),
          ),
        ),
      ),
    );
  }
}
