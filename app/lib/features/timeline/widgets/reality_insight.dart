import 'package:dottoday/core/clock/clock_provider.dart';
import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/data/scheduling/learning_meta.dart';
import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:dottoday/features/timeline/state/reality_thread.dart';
import 'package:dottoday/shared/duration/duration_chips.dart';
import 'package:dottoday/shared/learning/learned_line.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// "● Deep work usually takes you 2 h 20 · Add will suggest it   OK"
/// under the Reality thread (`B-ios-reality-thread`, 11 C3, docs/09
/// M11.3). OK puts it away for this task, this session; a tap on the
/// sentence explains it (docs/13 §6).
class RealityInsightStrip extends ConsumerWidget {
  const RealityInsightStrip({
    required this.task,
    required this.usualMinutes,
    required this.samples,
    super.key,
  });

  final Occurrence task;
  final int usualMinutes;

  /// Runs [usualMinutes] was taken from, for the explanation (docs/13 §6).
  final int samples;

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
                child: LearnedLine(
                  text: l10n.learnInsight(
                    task.title,
                    formatDurationShort(l10n, usualMinutes),
                  ),
                  explanation: LearnedExplanation.perTitle(
                    l10n,
                    samples: samples,
                    title: task.title,
                    reset: () => ref
                        .read(learningMetaProvider.notifier)
                        .resetUndoable(
                          task.title,
                          ref.read(clockProvider).nowUtc(),
                        ),
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
