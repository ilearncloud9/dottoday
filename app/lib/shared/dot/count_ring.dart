import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/shared/dot/thread.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// A dotted ring holding a count (docs/10 §1 "the Inbox is a dotted ring
/// holding loose dots"): the Inbox and Search headers.
class CountRing extends StatelessWidget {
  const CountRing({required this.count, required this.label, super.key});

  final int count;

  /// Read out instead of the number ("5 unscheduled tasks").
  final String label;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    return Semantics(
      container: true,
      label: label,
      excludeSemantics: true,
      child: CustomPaint(
        painter: DashedPillPainter(color: t.colors.outline),
        child: SizedBox.square(
          dimension: DotSize.liveDot + DotSpace.m,
          child: Center(
            child: Text(
              NumberFormat.decimalPattern(
                Localizations.localeOf(context).toLanguageTag(),
              ).format(count),
              style: t.styles.cardTitle,
            ),
          ),
        ),
      ),
    );
  }
}
