import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/shared/dot/task_row.dart';
import 'package:dottoday/shared/dot/thread_axis.dart';
import 'package:dottoday/shared/dot/thread_models.dart';
import 'package:flutter/material.dart';

/// Between two overlapping tasks (ADR-0015): their dots meet as capsules,
/// the lower one's top cut by a notch, beside "Tasks are overlapping" with
/// the last word in the lower task's colour. Never a warning colour (11 §D
/// no shame): the task's own hue, as its ink.
class OverlapRow extends StatelessWidget {
  const OverlapRow({required this.overlap, super.key});

  final ThreadOverlap overlap;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final l10n = context.l10n;
    final word = l10n.threadOverlappingWord;
    final line = l10n.threadOverlapping(word);
    final at = line.indexOf(word);
    final style = t.styles.threadMeta;
    final accent = style.copyWith(
      color: t.tasks[overlap.below].ink,
      fontWeight: FontWeight.w700,
    );
    return ThreadRowFrame(
      piece: OverlapPiece(
        above: t.tasks[overlap.above].tint,
        below: t.tasks[overlap.below].tint,
        notch: t.colors.raised,
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
