import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:flutter/material.dart';

/// "Just Gather documents · 10 min?" and Start (11 B2, docs/09 M10.6): a
/// quiet line in the accent, never a warning colour (11 §D no shame).
class SmallestStepLine extends StatelessWidget {
  const SmallestStepLine({required this.text, this.onStart, super.key});

  final String text;
  final VoidCallback? onStart;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    return Wrap(
      spacing: DotSpace.s,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Text(text, style: t.styles.rowMeta.copyWith(color: t.colors.accentInk)),
        if (onStart != null)
          FilledButton.tonal(
            onPressed: onStart,
            style: FilledButton.styleFrom(shape: dotChipShape(context)),
            child: Text(context.l10n.smallestStepStart),
          ),
      ],
    );
  }
}
