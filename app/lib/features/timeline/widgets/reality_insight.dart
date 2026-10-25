import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:dottoday/features/timeline/state/reality_thread.dart';
import 'package:dottoday/shared/duration/duration_chips.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// "● Deep work usually takes you 2 h 20 · Add will suggest it   OK"
/// under the Reality thread (`B-ios-reality-thread`, 11 C3, docs/09
/// M11.3). OK puts it away for this task, this session.
class RealityInsightStrip extends ConsumerWidget {
  const RealityInsightStrip({
    required this.task,
    required this.usualMinutes,
    super.key,
  });

  final Occurrence task;
  final int usualMinutes;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = DotTheme.of(context);
    final l10n = context.l10n;
    return Padding(
      padding: const EdgeInsets.only(top: DotSpace.s),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: t.colors.raised,
          borderRadius: BorderRadius.circular(DotRadii.card),
          border: Border.all(color: t.colors.outline),
        ),
        child: Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(
            DotSpace.l,
            DotSpace.xs,
            DotSpace.xs,
            DotSpace.xs,
          ),
          child: Row(
            spacing: DotSpace.m,
            children: [
              ExcludeSemantics(
                child: SizedBox.square(
                  dimension: DotSize.weekDot * 1.5,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: t.colors.accent,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  l10n.learnInsight(
                    task.title,
                    formatDurationShort(l10n, usualMinutes),
                  ),
                  style: t.styles.body,
                ),
              ),
              TextButton(
                onPressed: () => ref
                    .read(dismissedInsightsProvider.notifier)
                    .dismiss(task.id),
                child: Text(l10n.learnInsightOk),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
