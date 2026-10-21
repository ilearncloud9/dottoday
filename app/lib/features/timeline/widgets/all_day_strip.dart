import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:flutter/material.dart';

/// All-day items above the timeline (docs/03 §3.1 "optional all-day
/// strip"); hidden when there are none.
class AllDayStrip extends StatelessWidget {
  const AllDayStrip({required this.items, super.key});

  final List<Occurrence> items;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    // Capped so a day full of all-day items never pushes the timeline
    // off screen; the strip scrolls on its own beyond that.
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height / 3,
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(
            DotSpace.l,
            DotSpace.s,
            DotSpace.l,
            DotSpace.s,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Semantics(
                header: true,
                child: Text(
                  context.l10n.timelineAllDay,
                  style: t.styles.rowMeta.copyWith(color: t.colors.muted),
                ),
              ),
              const SizedBox(height: DotSpace.xs),
              Wrap(
                spacing: DotSpace.s,
                runSpacing: DotSpace.s,
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
    final t = DotTheme.of(context);
    final color = TaskColor.fromKey(item.colorKey);
    final strong = t.tasks[color].ink;
    return Container(
      constraints: const BoxConstraints(minHeight: DotTouch.min),
      padding: const EdgeInsetsDirectional.symmetric(horizontal: DotSpace.m),
      decoration: BoxDecoration(
        color: t.tasks[color].tint,
        borderRadius: BorderRadius.circular(DotRadii.card),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            BlockIcon.fromKey(item.iconKey).icon,
            size: DotSpace.l,
            color: strong,
          ),
          const SizedBox(width: DotSpace.xs),
          Text(item.title, style: t.styles.body.copyWith(color: strong)),
        ],
      ),
    );
  }
}
