import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/shared/dot/task_row.dart';
import 'package:dottoday/shared/dot/thread_axis.dart';
import 'package:dottoday/shared/dot/thread_models.dart';
import 'package:dottoday/shared/duration/duration_chips.dart';
import 'package:flutter/material.dart';

/// Between two overlapping tasks (ADR-0015): the knot, one strand per
/// task crossing once, beside "Run and Sleep share 15 min" with "share 15
/// min" in the later task's ink. The dots above and below stay as they
/// are. Never a warning colour (11 §D no shame).
class OverlapRow extends StatelessWidget {
  const OverlapRow({required this.overlap, super.key});

  final ThreadOverlap overlap;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final l10n = context.l10n;
    final word = l10n.threadOverlapShareTime(
      formatDurationShort(l10n, overlap.minutes),
    );
    final line = l10n.threadOverlapShare(
      overlap.aboveTitle,
      overlap.belowTitle,
      word,
    );
    final at = line.indexOf(word);
    final style = t.styles.threadMeta;
    final accent = style.copyWith(
      color: t.tasks[overlap.below].ink,
      fontWeight: FontWeight.w700,
    );
    return ThreadRowFrame(
      piece: OverlapPiece(
        above: t.tasks[overlap.above].color,
        below: t.tasks[overlap.below].color,
      ),
      // Grows with large text rather than clipping it (§7.4).
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: DotSize.overlapRow),
        child: Align(
          alignment: AlignmentDirectional.centerStart,
          child: Text.rich(
            at < 0
                ? TextSpan(text: line)
                : TextSpan(
                    children: [
                      TextSpan(text: line.substring(0, at)),
                      TextSpan(text: word, style: accent),
                      TextSpan(text: line.substring(at + word.length)),
                    ],
                  ),
            style: style,
          ),
        ),
      ),
    );
  }
}
