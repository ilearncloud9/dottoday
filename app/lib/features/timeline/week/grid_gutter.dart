import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/features/timeline/week/week_pieces.dart';
import 'package:flutter/material.dart';

/// "7 AM", "8 AM" … beside the hour lines, right-aligned in the gutter.
class GridHourLabels extends StatelessWidget {
  const GridHourLabels({super.key, required this.labels});

  final List<String> labels;

  @override
  Widget build(BuildContext context) {
    final style = DotTheme.of(context).styles.gridHour;
    final half = style.fontSize! * style.height! / 2;
    return Stack(
      children: [
        for (final (i, label) in labels.indexed)
          Positioned(
            top:
                (WeekScale.leadMinutes + i * Duration.minutesPerHour) *
                    WeekScale.pxPerMinute -
                half,
            left: 0,
            right: DotSpace.xs + DotSpace.xxs,
            child: ExcludeSemantics(
              child: Text(label, style: style, textAlign: TextAlign.end),
            ),
          ),
      ],
    );
  }
}

/// Now's time in the gutter (E-FullA-v2: "10:42" on a card pill with an
/// accent edge).
class GridNowBead extends StatelessWidget {
  const GridNowBead({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final c = t.colors;
    return Semantics(
      label: context.l10n.timelineNow(text),
      excludeSemantics: true,
      child: DecoratedBox(
        decoration: ShapeDecoration(
          color: c.card,
          shape: StadiumBorder(side: BorderSide(color: c.nowBeadEdge)),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: DotSpace.xs),
          child: Text(
            text,
            style: t.styles.nowBead.copyWith(color: c.accentText),
          ),
        ),
      ),
    );
  }
}
