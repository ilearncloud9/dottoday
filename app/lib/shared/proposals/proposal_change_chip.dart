import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/domain/proposals/proposal.dart';
import 'package:dottoday/shared/dot/overlap_knot.dart';
import 'package:flutter/material.dart';

/// What changes, tinted by kind (`B-ios-rebalance`): moves in the accent,
/// length in amber, leaving the day in rose, untouched in grey. Colour is
/// never the only signal: the text says it. An overlap leads with the knot
/// (ADR-0015): this task's strand, and a muted one for the other.
class ProposalChangeChip extends StatelessWidget {
  const ProposalChangeChip({
    super.key,
    required this.text,
    required this.change,
    required this.color,
  });

  final String text;
  final ProposalChange change;
  final TaskColor color;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final (fill, ink) = switch (change) {
      ProposalChange.resized => (
        t.tasks[TaskColor.amber].tint,
        t.tasks[TaskColor.amber].ink,
      ),
      ProposalChange.movedToDay => (
        t.tasks[TaskColor.rose].tint,
        t.tasks[TaskColor.rose].ink,
      ),
      ProposalChange.untouched ||
      ProposalChange.overlaps ||
      ProposalChange.toInbox => (t.colors.hairline, t.colors.muted),
      _ => (t.colors.accentTint, t.colors.accentInk),
    };
    return DecoratedBox(
      decoration: BoxDecoration(
        color: fill,
        borderRadius: const BorderRadius.all(Radius.circular(DotRadii.pill)),
      ),
      child: Padding(
        padding: const EdgeInsetsDirectional.symmetric(
          horizontal: DotSpace.m,
          vertical: DotSpace.xxs,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          spacing: DotSpace.xs,
          children: [
            if (change == ProposalChange.overlaps)
              OverlapKnot(first: t.tasks[color].color, second: t.colors.muted),
            Flexible(
              child: Text(text, style: t.styles.rowMeta.copyWith(color: ink)),
            ),
          ],
        ),
      ),
    );
  }
}
