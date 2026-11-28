import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/domain/proposals/proposal.dart';
import 'package:dottoday/shared/dot/overlap_knot.dart';
import 'package:flutter/material.dart';

/// What changes, tinted by kind (`B-ios-rebalance`, E-R2-35): moves in
/// the accent, length in amber, leaving the day in violet, untouched and to the Inbox in
/// the quiet grey, in the tag's shape (E-Phones-2). Colour is
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
        t.tasks[TaskColor.violet].tint,
        t.tasks[TaskColor.violet].ink,
      ),
      ProposalChange.untouched ||
      ProposalChange.overlaps ||
      // The quiet grey tag of E-Phones-2 ("no room · to the Inbox").
      ProposalChange.toInbox => (t.colors.control, t.colors.ink2),
      _ => (t.colors.tonal, t.colors.accentText),
    };
    // The tag's shape (DotTag, E-Phones-2): 20 tall, fully round, 700 12.
    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: DotSize.tag),
      child: DecoratedBox(
        decoration: ShapeDecoration(color: fill, shape: const StadiumBorder()),
        child: Padding(
          padding: const EdgeInsetsDirectional.symmetric(
            horizontal: DotSpace.s,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            spacing: DotSpace.xs,
            children: [
              if (change == ProposalChange.overlaps)
                OverlapKnot(
                  first: t.tasks[color].color,
                  second: t.colors.secondary,
                ),
              Flexible(
                child: Text(text, style: t.styles.tag.copyWith(color: ink)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
