import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/app_theme.dart';
import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:flutter/material.dart';

/// All-day items above the timeline (docs/03 §3.1 "optional all-day
/// strip"); hidden when there are none.
class AllDayStrip extends StatelessWidget {
  const AllDayStrip({required this.items, super.key});

  final List<Occurrence> items;

  @override
  Widget build(BuildContext context) {
    final t = AppTheme.of(context);
    // Capped so a day full of all-day items never pushes the timeline
    // off screen; the strip scrolls on its own beyond that.
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height / 3,
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(
            AppSpacing.l,
            AppSpacing.s,
            AppSpacing.l,
            AppSpacing.s,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Semantics(
                header: true,
                child: Text(
                  context.l10n.timelineAllDay,
                  style: t.typography.label.copyWith(
                    color: t.colors.onSurfaceMuted,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Wrap(
                spacing: AppSpacing.s,
                runSpacing: AppSpacing.s,
                children: [for (final o in items) _AllDayChip(item: o)],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AllDayChip extends StatelessWidget {
  const _AllDayChip({required this.item});

  final Occurrence item;

  @override
  Widget build(BuildContext context) {
    final t = AppTheme.of(context);
    final color = BlockColor.fromKey(item.colorKey);
    final strong = t.blocks[color].strong;
    return Container(
      constraints: const BoxConstraints(minHeight: AppSpacing.minTouchTarget),
      padding: const EdgeInsetsDirectional.symmetric(horizontal: AppSpacing.m),
      decoration: BoxDecoration(
        color: t.blocks.fill(color, t.colors.surface),
        borderRadius: BorderRadius.circular(AppRadii.block),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            BlockIcon.fromKey(item.iconKey).icon,
            size: AppSpacing.l,
            color: strong,
          ),
          const SizedBox(width: AppSpacing.xs),
          Text(item.title, style: t.typography.body.copyWith(color: strong)),
        ],
      ),
    );
  }
}
