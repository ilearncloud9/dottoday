import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/shared/duration/duration_chips.dart';
import 'package:flutter/material.dart';

/// The task being broken down, above the card (`B-ios-break-it-down`):
/// its outlined dot, title, and "Today · 4:00 PM · was 1 h 30 → now 1 h 40".
class BreakdownLead extends StatelessWidget {
  const BreakdownLead({
    required this.title,
    required this.color,
    required this.icon,
    required this.beforeMin,
    required this.afterMin,
    this.when,
    super.key,
  });

  final String title;
  final TaskColor color;
  final TaskIcon icon;

  /// "Today · 4:00 PM"; null for a task with no time yet.
  final String? when;
  final int beforeMin;
  final int afterMin;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final l10n = context.l10n;
    final swatch = t.tasks[color];
    final length = afterMin == beforeMin
        ? formatDurationShort(l10n, beforeMin)
        : l10n.breakdownWasNow(
            formatDurationShort(l10n, beforeMin),
            formatDurationShort(l10n, afterMin),
          );
    return MergeSemantics(
      child: Row(
        spacing: DotSpace.m,
        children: [
          Container(
            width: DotSize.addDot,
            height: DotSize.addDot,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: swatch.color,
                width: DotSize.dotOutline,
              ),
            ),
            child: Center(
              child: icon.glyph == null
                  ? null
                  : DotIcon(icon.glyph!, color: swatch.color),
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: DotSpace.xxs,
              children: [
                Text(title, style: t.styles.topBarTitle),
                Text(
                  [?when, length].join(' · '), // l10n-ignore: a separator
                  style: t.styles.rowMeta.copyWith(color: t.colors.muted),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// "Total 1 h 40 · the dot grows to fit", the dot before and after, and
/// the Smallest step note (`B-ios-break-it-down`).
class BreakdownTotal extends StatelessWidget {
  const BreakdownTotal({
    required this.totalMin,
    required this.beforeMin,
    required this.color,
    super.key,
  });

  final int totalMin;
  final int beforeMin;
  final TaskColor color;

  /// Ring sizes for the before → after picture, by length (bounded).
  static const double _small = DotSize.macRowDot;
  static const double _large = DotSize.rowDot;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final l10n = context.l10n;
    final swatch = t.tasks[color];
    final grows = totalMin > beforeMin;
    Widget ring(double size, double alpha) => Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: swatch.color.withValues(alpha: alpha),
          width: DotSize.dotOutline,
        ),
      ),
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: DotSpace.s,
      children: [
        Row(
          spacing: DotSpace.s,
          children: [
            Expanded(
              child: Text(
                l10n.breakdownTotal(formatDurationShort(l10n, totalMin)),
                style: t.styles.body,
              ),
            ),
            ExcludeSemantics(
              child: Row(
                spacing: DotSpace.xs,
                children: [
                  ring(grows ? _small : _large, TaskAlpha.faded),
                  DotIcon(
                    DotGlyphs.arrowRight,
                    color: t.colors.muted,
                    size: DotSize.rowIcon,
                  ),
                  ring(grows ? _large : _small, 1),
                ],
              ),
            ),
          ],
        ),
        Text(
          l10n.breakdownSmallest,
          style: t.styles.rowMeta.copyWith(color: t.colors.muted),
        ),
      ],
    );
  }
}
