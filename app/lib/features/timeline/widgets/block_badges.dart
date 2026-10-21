import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/app_theme.dart';
import 'package:dottoday/features/timeline/layout/block_facts.dart';
import 'package:flutter/material.dart';

/// Badge row: subtask ring + "2/3", recurring, pinned, calendar, alerts.
/// Decorative for screen readers — the block label says the same words.
class BlockBadges extends StatelessWidget {
  const BlockBadges({required this.facts, required this.color, super.key});

  final BlockFacts facts;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final t = AppTheme.of(context);
    final size = MediaQuery.textScalerOf(context).scale(AppSpacing.m + 2);
    final style = t.typography.mono.copyWith(color: color);
    Widget icon(IconData data) => Icon(data, size: size, color: color);
    return ExcludeSemantics(
      child: Wrap(
        spacing: AppSpacing.xs,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          if (facts.hasSubtasks) ...[
            SizedBox.square(
              dimension: size,
              child: CircularProgressIndicator(
                value: facts.subtasksDone / facts.subtasksTotal,
                strokeWidth: AppSpacing.xs / 2,
                color: color,
                backgroundColor: color.withValues(alpha: 0.25),
              ),
            ),
            Text(
              context.l10n.blockSubtasksShort(
                facts.subtasksDone,
                facts.subtasksTotal,
              ),
              style: style,
            ),
          ],
          if (facts.recurring) icon(Icons.repeat),
          if (facts.pinned) icon(Icons.lock_outline),
          if (facts.calendar) icon(Icons.event_outlined),
          if (facts.alertCount > 0) ...[
            icon(Icons.notifications_none),
            if (facts.alertCount > 1)
              Text(facts.alertCount.toString(), style: style),
          ],
        ],
      ),
    );
  }
}

/// Whether [facts] has any badge to draw.
bool hasBadges(BlockFacts facts) =>
    facts.hasSubtasks ||
    facts.recurring ||
    facts.pinned ||
    facts.calendar ||
    facts.alertCount > 0;
