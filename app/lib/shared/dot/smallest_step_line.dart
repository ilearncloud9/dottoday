import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:flutter/material.dart';

/// "Just Gather documents · 10 min?" and Start (11 B2, docs/09 M10.6,
/// E-R2-23 §2): a quiet line in accent ink, never a warning colour (11 §D
/// no shame), and a small tinted Start: under the line on iPhone, at its
/// end on Android, wrapping when it doesn't fit.
class SmallestStepLine extends StatelessWidget {
  const SmallestStepLine({required this.text, this.onStart, super.key});

  final String text;
  final VoidCallback? onStart;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final line = Text(
      text,
      style: t.styles.chip.copyWith(color: t.colors.accentInk),
    );
    final onStart = this.onStart;
    if (onStart == null) return line;
    final start = FilledButton(
      onPressed: onStart,
      style: FilledButton.styleFrom(
        backgroundColor: t.colors.accentTint,
        foregroundColor: t.colors.accentInk,
        shape: const StadiumBorder(),
        // Small to look at, the platform's floor to tap.
        minimumSize: const Size(0, DotSize.smallChipHeight),
        tapTargetSize: MaterialTapTargetSize.padded,
        padding: const EdgeInsetsDirectional.symmetric(horizontal: DotSpace.l),
        textStyle: t.styles.chip,
      ),
      child: Text(context.l10n.smallestStepStart),
    );
    if (DotIdiom.of(context) == DotIdiom.cupertino) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: DotSpace.xs,
        children: [line, start],
      );
    }
    return Wrap(
      spacing: DotSpace.s,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [line, start],
    );
  }
}
