import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/app_theme.dart';
import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:dottoday/features/timeline/widgets/time_labels.dart';
import 'package:flutter/material.dart';
import 'package:timezone/timezone.dart' as tz;

/// One block on the timeline: colour fill, icon, title and time range
/// (docs/03 §3.1 "Block anatomy"; states and badges arrive in M3.3).
///
/// Short blocks use a single row (title · time) so text never clips; taller
/// ones stack the time under a title of up to two lines.
class BlockTile extends StatelessWidget {
  const BlockTile({
    required this.block,
    required this.location,
    required this.use24h,
    super.key,
  });

  final Occurrence block;
  final tz.Location location;
  final bool use24h;

  @override
  Widget build(BuildContext context) {
    final t = AppTheme.of(context);
    final color = BlockColor.fromKey(block.colorKey);
    final strong = t.blocks[color].strong;
    final start = timeOfUtc(context, location, block.startUtc!, use24h: use24h);
    final end = timeOfUtc(context, location, block.endUtc!, use24h: use24h);
    final l10n = context.l10n;
    return Semantics(
      container: true,
      label: l10n.blockSemantics(block.title, start, end),
      excludeSemantics: true,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: t.blocks.fill(color, t.colors.surface),
          borderRadius: BorderRadius.circular(AppRadii.block),
        ),
        child: LayoutBuilder(
          builder: (context, c) => Padding(
            padding: const EdgeInsetsDirectional.symmetric(
              horizontal: AppSpacing.s,
              vertical: AppSpacing.xs,
            ),
            child: _content(
              t,
              strong,
              Icon(
                BlockIcon.fromKey(block.iconKey).icon,
                size: MediaQuery.textScalerOf(context).scale(AppSpacing.l),
                color: strong,
              ),
              l10n.blockTimeRange(start, end),
              titleLines: _titleLines(context, t, c.maxHeight),
              roomForTime: c.maxWidth >= _rowTimeWidth(context),
            ),
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

  /// Narrower single-row tiles show the title only (the time is still in
  /// the semantics label), so the title is never squeezed out by the time.
  double _rowTimeWidth(BuildContext context) =>
      MediaQuery.textScalerOf(context).scale(AppSpacing.xxl * 5);

  Widget _content(
    AppTheme t,
    Color strong,
    Widget icon,
    String range, {
    required int titleLines,
    required bool roomForTime,
  }) {
    final tall = titleLines > 0;
    final title = Text(
      block.title,
      maxLines: tall ? titleLines : 1,
      overflow: TextOverflow.ellipsis,
      style: t.typography.body.copyWith(color: strong),
    );
    final time = Text(
      range,
      maxLines: 1,
      style: t.typography.mono.copyWith(color: strong),
    );
    if (!tall) {
      return Row(
        children: [
          icon,
          const SizedBox(width: AppSpacing.xs),
          Expanded(child: title),
          if (roomForTime) ...[const SizedBox(width: AppSpacing.s), time],
        ],
      );
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsetsDirectional.only(top: AppSpacing.xs),
          child: icon,
        ),
        const SizedBox(width: AppSpacing.xs),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [title, time],
          ),
        ),
      ],
    );
  }
}
