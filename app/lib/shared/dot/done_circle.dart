import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:flutter/material.dart';

/// The round done circle at a row's end (ADR-0015, E rules §4.4): a 2.5 px
/// ring, grey ahead and in the task's [color] for the [live] task, that
/// fills with the task's colour and a white tick once [done]; tapping it
/// again undoes it. The row keeps its place either way.
class DoneCircle extends StatelessWidget {
  const DoneCircle({
    required this.color,
    required this.done,
    required this.title,
    this.live = false,
    this.onTap,
    super.key,
  });

  final TaskColor color;
  final bool done;

  /// The task under way: its ring is in the task's colour.
  final bool live;

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
                border: done
                    ? null
                    : Border.all(
                        color: live ? swatch.color : t.colors.ring,
                        width: DotSize.doneRing,
                      ),
              ),
              child: done
                  ? Center(
                      child: DotIcon(
                        DotGlyphs.check,
                        color: swatch.check,
                        // A 15 check in the 28 circle (E rules §6).
                        size: size * 15 / 28,
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
