import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/domain/entities/subtask.dart';
import 'package:dottoday/domain/focus/focus_state.dart';
import 'package:dottoday/domain/scheduling/learning.dart';
import 'package:dottoday/shared/duration/duration_chips.dart';
import 'package:dottoday/shared/learning/learned_line.dart';
import 'package:flutter/material.dart';

/// "STEP 2 OF 3 · Draft timeline · 14:20 left" with its bar
/// (`B-ios-focus`); "Every step done" once all are ticked.
class FocusStepCard extends StatelessWidget {
  const FocusStepCard({
    required this.state,
    this.taskTitle = '',
    this.onResetLearning,
    super.key,
  });

  final FocusState state;

  /// The task's title, for the reset's message.
  final String taskTitle;

  /// Clears what this task taught, on this device (docs/13 §6).
  final LearnedReset? onResetLearning;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final l10n = context.l10n;
    final step = state.step;
    final left = state.stepLeft;
    final meta = t.styles.cardTitle.copyWith(color: t.colors.secondary);
    final usual = switch (state.stepLearned) {
      Learned(usualMinutes: final usual?, :final samples) => LearnedLine(
        text: l10n.learnUsually(formatDurationShort(l10n, usual)),
        explanation: LearnedExplanation.perTitle(
          l10n,
          samples: samples,
          title: taskTitle,
          reset: onResetLearning,
        ),
        style: meta,
      ),
      _ => null,
    };
    // E-R2-9: "STEP 3 OF 4", the step, then "8:00 left · usually 20 min".
    return DecoratedBox(
      decoration: BoxDecoration(
        color: t.colors.card,
        border: Border.all(color: t.colors.hairline),
        borderRadius: const BorderRadius.all(
          Radius.circular(DotRadii.cardLarge),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(DotSpace.l),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: DotSpace.xxs,
          children: [
            if (step != null)
              Text(
                l10n
                    .focusStep(state.stepIndex! + 1, state.steps.length)
                    .toUpperCase(),
                style: t.styles.caption,
              ),
            Text(
              step?.title ?? l10n.focusAllSteps,
              style: t.styles.promptTitle,
            ),
            if (left != null || usual != null)
              Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: DotSpace.s,
                children: [
                  if (left != null)
                    Text(
                      l10n.liveActivityLeft(countdown(left)),
                      style: meta.copyWith(color: t.colors.accentText),
                    ),
                  if (left != null && usual != null)
                    ExcludeSemantics(
                      child: Text('·', style: meta), // l10n-ignore: separator
                    ),
                  ?usual,
                ],
              ),
          ],
        ),
      ),
    );
  }
}

/// The steps as a small thread: ticked (filled, struck), current (accent
/// ring, accent title), to come (outlined).
class FocusStepThread extends StatelessWidget {
  const FocusStepThread({required this.state, super.key});

  final FocusState state;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: DotSpace.s,
      children: [
        for (final (i, s) in state.steps.indexed)
          Row(
            spacing: DotSpace.m,
            children: [
              _StepMark(step: s, current: i == state.stepIndex),
              Expanded(
                child: Text(
                  s.title,
                  style:
                      (i == state.stepIndex && !s.done
                              ? t.styles.cardTitle
                              : t.styles.body)
                          .copyWith(
                            color: s.done
                                ? t.colors.secondary
                                : i == state.stepIndex
                                ? t.colors.accentText
                                : null,
                            decoration: s.done
                                ? TextDecoration.lineThrough
                                : null,
                          ),
                ),
              ),
            ],
          ),
      ],
    );
  }
}

class _StepMark extends StatelessWidget {
  const _StepMark({required this.step, required this.current});

  final Subtask step;
  final bool current;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final c = t.colors;
    return ExcludeSemantics(
      child: Container(
        width: DotSize.pickerDot,
        height: DotSize.pickerDot,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: step.done ? c.accent : null,
          border: Border.all(
            color: step.done || current ? c.accent : c.secondary,
            width: DotSize.smallDotOutline,
          ),
        ),
        child: step.done
            ? Center(
                child: DotIcon(
                  DotGlyphs.check,
                  color: c.onAccent,
                  size: DotSize.weekDot + DotSpace.xs,
                ),
              )
            : null,
      ),
    );
  }
}

/// A pill toggle with an icon (`B-ios-focus`: "Chime every 15 min",
/// "Deep work · Focus on"); the accent tint when on. [onChanged] null
/// shows [detail] without a switch (the web's Deep work).
class FocusToggle extends StatelessWidget {
  const FocusToggle({
    required this.glyph,
    required this.label,
    required this.value,
    required this.onChanged,
    this.detail,
    super.key,
  });

  final DotGlyph glyph;
  final String label;
  final String? detail;
  final bool value;
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final on = value && onChanged != null;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: on ? t.colors.tonal : null,
        border: Border.all(color: on ? t.colors.accent : t.colors.hairline),
        borderRadius: const BorderRadius.all(
          Radius.circular(DotRadii.cardLarge),
        ),
      ),
      child: Padding(
        padding: const EdgeInsetsDirectional.symmetric(
          horizontal: DotSpace.m,
          vertical: DotSpace.xs,
        ),
        child: MergeSemantics(
          child: Row(
            spacing: DotSpace.xs,
            children: [
              DotIcon(
                glyph,
                color: on ? t.colors.accentText : t.colors.secondary,
                size: DotSize.rowIcon,
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: t.styles.body.copyWith(
                        color: on ? t.colors.accentText : null,
                      ),
                    ),
                    if (detail case final d?)
                      Text(
                        d,
                        style: t.styles.rowMeta.copyWith(
                          color: t.colors.secondary,
                        ),
                      ),
                  ],
                ),
              ),
              if (onChanged != null)
                Switch.adaptive(value: value, onChanged: onChanged),
            ],
          ),
        ),
      ),
    );
  }
}
