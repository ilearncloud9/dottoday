import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/shared/dot/capacity_ring.dart';
import 'package:flutter/material.dart';

/// A Settings › Learning row's progress, under its text (docs/13 §4.1):
/// the ring and "7/10" while counting to a threshold, or just the text
/// ("Ready for 3 tasks"). Below rather than beside the title, so at the
/// largest text size the words keep the row's whole width.
class LearningStatus extends StatelessWidget {
  const LearningStatus({
    required this.text,
    this.done,
    this.of,
    this.label,
    super.key,
  });

  /// "7/10" or "Ready for 3 tasks".
  final String text;

  /// With [of] and [label]: a ring filled [done] of [of].
  final int? done;
  final int? of;

  /// The screen-reader reading of the ring and [text] together.
  final String? label;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final style = t.styles.rowMeta.copyWith(color: t.colors.accentInk);
    final (d, o, l) = (done, of, label);
    if (d == null || o == null || l == null) {
      return Padding(
        padding: const EdgeInsetsDirectional.only(top: DotSpace.xs),
        child: Text(text, style: style),
      );
    }
    return Padding(
      padding: const EdgeInsetsDirectional.only(top: DotSpace.s),
      child: Semantics(
        label: l,
        excludeSemantics: true,
        child: Row(
          spacing: DotSpace.s,
          children: [
            CapacityRing.count(done: d, of: o, label: l),
            Flexible(child: Text(text, style: style)),
          ],
        ),
      ),
    );
  }
}
