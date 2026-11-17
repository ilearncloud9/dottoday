import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/shared/dot/task_row.dart';
import 'package:dottoday/shared/dot/thread_axis.dart';
import 'package:dottoday/shared/dot/thread_models.dart';
import 'package:dottoday/shared/duration/duration_chips.dart';
import 'package:flutter/material.dart';

/// Between two overlapping tasks (ADR-0015, E rules §5.4): the 26 px
/// knot, one strand per task, beside "Overlap · 10:30–11:00" in the
/// secondary colour (E-Phones Today). A screen reader hears both tasks:
/// "Run and Sleep share 15 min". Never a warning colour (11 §D no shame).
class OverlapRow extends StatelessWidget {
  const OverlapRow({required this.overlap, super.key});

  final ThreadOverlap overlap;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final l10n = context.l10n;
    final spoken = l10n.threadOverlapShare(
      overlap.aboveTitle,
      overlap.belowTitle,
      l10n.threadOverlapShareTime(formatDurationShort(l10n, overlap.minutes)),
    );
    return ThreadRowFrame(
      minHeight: DotSize.overlapRow,
      piece: OverlapPiece(
        above: t.tasks[overlap.above].color,
        below: t.tasks[overlap.below].color,
      ),
      child: Semantics(
        label: spoken,
        excludeSemantics: true,
        child: Align(
          alignment: AlignmentDirectional.centerStart,
          child: Text(
            l10n.threadOverlapRange(overlap.range),
            style: t.styles.threadMeta,
          ),
        ),
      ),
    );
  }
}
