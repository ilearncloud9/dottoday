import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/app_theme.dart';
import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:dottoday/features/timeline/layout/block_facts.dart';
import 'package:dottoday/features/timeline/widgets/block_badges.dart';
import 'package:dottoday/features/timeline/widgets/block_label.dart';
import 'package:dottoday/features/timeline/widgets/icon_circle.dart';
import 'package:dottoday/features/timeline/widgets/time_labels.dart';
import 'package:flutter/material.dart';
import 'package:timezone/timezone.dart' as tz;

/// Width of the overdue bar on the block's start edge (docs/03 §3.1).
const double _overdueBar = 3;

/// One block on the timeline (docs/03 §3.1 "Block anatomy"): colour fill,
/// icon circle (tap to complete), title, time range and badges. Done
/// blocks desaturate with a struck-through title; overdue ones get a thin
/// warning bar and nothing louder.
///
/// Short blocks use a single row so text never clips; taller ones stack
/// the time and badges under up to two title lines.
class BlockTile extends StatelessWidget {
  const BlockTile({
    required this.block,
    required this.location,
    required this.use24h,
    this.facts,
    this.onToggleDone,
    super.key,
  });

  final Occurrence block;
  final tz.Location location;
  final bool use24h;

  /// State and badges; null shows the block plain (e.g. in lists).
  final BlockFacts? facts;

  /// Tapping the icon circle; null makes the circle decorative.
  final VoidCallback? onToggleDone;

  @override
  Widget build(BuildContext context) {
    final t = AppTheme.of(context);
    final f = facts ?? BlockFacts.of(block, nowUtc: null);
    final color = BlockColor.fromKey(block.colorKey);
    final fill = t.blocks.fill(color, t.colors.surface);
    final ink = f.done ? t.colors.onSurfaceMuted : t.blocks[color].strong;
    final start = timeOfUtc(context, location, block.startUtc!, use24h: use24h);
    final end = timeOfUtc(context, location, block.endUtc!, use24h: use24h);
    final l10n = context.l10n;
    return Semantics(
      container: true,
      label: blockLabel(
        l10n,
        title: block.title,
        start: start,
        end: end,
        facts: f,
      ),
      child: DecoratedBox(
        decoration: BoxDecoration(
          // "Fill desaturates": blend most of the way to the sunken grey.
          color: f.done ? Color.lerp(fill, t.colors.surfaceSunken, 0.75) : fill,
          borderRadius: BorderRadius.circular(AppRadii.block),
          border: f.overdue
              ? BorderDirectional(
                  start: BorderSide(
                    color: t.colors.warning,
                    width: _overdueBar,
                  ),
                )
              : null,
        ),
        child: LayoutBuilder(
          builder: (context, c) => _BlockContent(
            title: block.title,
            range: l10n.blockTimeRange(start, end),
            facts: f,
            ink: ink,
            circle: IconCircle(
              icon: BlockIcon.fromKey(block.iconKey).icon,
              color: t.blocks[color].strong,
              done: f.done,
              label: f.done
                  ? l10n.blockMarkNotDone(block.title)
                  : l10n.blockMarkDone(block.title),
              onPressed: onToggleDone,
            ),
            titleLines: _titleLines(context, t, c.maxHeight),
            badgeLine: _hasBadgeLine(context, t, c.maxHeight),
            wide: c.maxWidth >= _rowTimeWidth(context),
            bounded: c.hasBoundedHeight,
          ),
        ),
      ),
    );
  }

  /// Title lines that fit above the time line in [height], 0–2; 0 means
  /// a single row (title · time). Measured at the current text scale so
  /// nothing overflows at 200 % (03 §4).
  int _titleLines(BuildContext context, AppTheme t, double height) {
    if (height.isInfinite) return 2; // unconstrained, e.g. in a list
    final scaler = MediaQuery.textScalerOf(context);
    double line(TextStyle s) => scaler.scale(s.fontSize!) * s.height!;
    final room = height - AppSpacing.s - line(t.typography.mono);
    return (room / line(t.typography.body)).floor().clamp(0, 2);
  }

  /// Whether, below two title lines and the time, there is room for a
  /// separate badge line (else badges share the time's line).
  bool _hasBadgeLine(BuildContext context, AppTheme t, double height) {
    if (height.isInfinite) return true;
    final scaler = MediaQuery.textScalerOf(context);
    double line(TextStyle s) => scaler.scale(s.fontSize!) * s.height!;
    final needed =
        AppSpacing.s +
        line(t.typography.body) * 2 +
        line(t.typography.mono) * 2;
    return height >= needed;
  }

  /// Narrower single-row tiles show the title only (the time is still in
  /// the semantics label), so the title is never squeezed out by the time.
  double _rowTimeWidth(BuildContext context) =>
      MediaQuery.textScalerOf(context).scale(AppSpacing.xxl * 5);
}

class _BlockContent extends StatelessWidget {
  const _BlockContent({
    required this.title,
    required this.range,
    required this.facts,
    required this.ink,
    required this.circle,
    required this.titleLines,
    required this.badgeLine,
    required this.wide,
    required this.bounded,
  });

  final String title;
  final String range;
  final BlockFacts facts;
  final Color ink;
  final Widget circle;
  final int titleLines;

  /// Badges get their own wrapping line under the time.
  final bool badgeLine;
  final bool wide;

  /// Whether the tile has a fixed height (on the timeline) rather than
  /// sizing to its content (in a list).
  final bool bounded;

  @override
  Widget build(BuildContext context) {
    final t = AppTheme.of(context);
    final tall = titleLines > 0;
    final titleText = ExcludeSemantics(
      child: Text(
        title,
        maxLines: tall ? titleLines : 1,
        overflow: TextOverflow.ellipsis,
        style: t.typography.body.copyWith(
          color: ink,
          decoration: facts.done ? TextDecoration.lineThrough : null,
          decorationColor: ink,
        ),
      ),
    );
    final time = ExcludeSemantics(
      child: Text(
        range,
        maxLines: 1,
        softWrap: false,
        // Narrow overlap columns can't fit the range; fade it at the edge.
        overflow: TextOverflow.fade,
        style: t.typography.mono.copyWith(color: ink),
      ),
    );
    final badges = hasBadges(facts)
        ? BlockBadges(facts: facts, color: ink)
        : null;
    return Row(
      crossAxisAlignment: tall
          ? CrossAxisAlignment.start
          : CrossAxisAlignment.center,
      children: [
        circle,
        Expanded(
          child: Padding(
            padding: const EdgeInsetsDirectional.only(
              end: AppSpacing.s,
              top: AppSpacing.xs,
              bottom: AppSpacing.xs,
            ),
            child: tall
                ? _tall(titleText, time, badges)
                : _row(titleText, time, badges),
          ),
        ),
      ],
    );
  }

  /// Title lines were sized to leave one line for time + badges; the clip
  /// is a guard for rounding at odd text scales, never a layout tool.
  Widget _tall(Widget title, Widget time, Widget? badges) {
    final column = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        title,
        // With a spare line, badges get their own; otherwise they share the
        // time's line and are cut at the edge (the label still names them).
        if (badgeLine) ...[
          time,
          ?badges,
        ] else
          Row(
            children: [
              Flexible(child: time),
              if (badges != null) ...[
                const SizedBox(width: AppSpacing.s),
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    physics: const NeverScrollableScrollPhysics(),
                    child: badges,
                  ),
                ),
              ],
            ],
          ),
      ],
    );
    if (!bounded) return column;
    return ClipRect(
      child: OverflowBox(
        alignment: AlignmentDirectional.topStart,
        maxHeight: double.infinity,
        child: column,
      ),
    );
  }

  Widget _row(Widget title, Widget time, Widget? badges) => Row(
    children: [
      Expanded(child: title),
      if (wide) ...[const SizedBox(width: AppSpacing.s), time],
      if (wide && badges != null) ...[
        const SizedBox(width: AppSpacing.s),
        badges,
      ],
    ],
  );
}
