import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:flutter/material.dart';

/// One chip of the [WeekSummaryStrip]: a glyph and its words.
typedef WeekChip = ({DotGlyph glyph, String text});

/// "Busiest · Thu · 7 h 30", "Lightest · Sat · 2 h 30", "Free · 68 h 45
/// unplanned", "Done · 13 of 29" (docs/10 §3 `WeekSummaryStrip`): read-only
/// outlined chips that wrap on a narrow window.
class WeekSummaryStrip extends StatelessWidget {
  const WeekSummaryStrip({required this.chips, super.key});

  final List<WeekChip> chips;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    return Wrap(
      spacing: DotSpace.s,
      runSpacing: DotSpace.s,
      children: [
        for (final c in chips)
          DecoratedBox(
            decoration: ShapeDecoration(
              color: t.colors.raised,
              shape: StadiumBorder(side: BorderSide(color: t.colors.outline)),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: DotSpace.m,
                vertical: DotSpace.s,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                spacing: DotSpace.s,
                children: [
                  DotIcon(c.glyph, color: t.colors.text, size: DotSize.rowIcon),
                  Text(c.text, style: t.styles.body),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
