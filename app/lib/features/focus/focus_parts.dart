import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/domain/entities/subtask.dart';
import 'package:dottoday/domain/focus/focus_state.dart';
import 'package:dottoday/shared/duration/duration_chips.dart';
import 'package:flutter/material.dart';

/// "STEP 2 OF 3 · Draft timeline · 14:20 left" with its bar
/// (`B-ios-focus`); "Every step done" once all are ticked.
class FocusStepCard extends StatelessWidget {
  const FocusStepCard({required this.state, super.key});

  final FocusState state;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final l10n = context.l10n;
    final step = state.step;
    final left = state.stepLeft;
    final done = state.steps.where((s) => s.done).length;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: t.colors.raised,
        border: Border.all(color: t.colors.outline),
        borderRadius: const BorderRadius.all(
          Radius.circular(DotRadii.cardLarge),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(DotSpace.l),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: DotSpace.m,
          children: [
            MergeSemantics(
              child: Row(
                spacing: DotSpace.m,
                children: [
                  ExcludeSemantics(
                    child: SizedBox.square(
                      dimension: DotSize.pickerDot,
                      child: CircularProgressIndicator(
                        value: state.steps.isEmpty
                            ? 1
                            : done / state.steps.length,
                        strokeWidth: DotSize.liveRing,
                        color: t.colors.accent,
                        backgroundColor: t.colors.hairline,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (step != null)
                          Text(
                            l10n
                                .focusStep(
                                  state.stepIndex! + 1,
                                  state.steps.length,
                                )
                                .toUpperCase(),
                            style: t.styles.caption,
                          ),
                        Text(
                          step?.title ?? l10n.focusAllSteps,
                          style: t.styles.rowTitle,
                        ),
                      ],
                    ),
                  ),
                  if (left != null)
                    Text(
                      l10n.liveActivityLeft(countdown(left)),
                      style: t.styles.rowTitle.copyWith(
                        color: t.colors.accentInk,
                      ),
                    ),
                ],
              ),
            ),
            if (state.stepProgress case final p?)
              ClipRRect(
                borderRadius: const BorderRadius.all(
                  Radius.circular(DotRadii.pill),
                ),
                child: LinearProgressIndicator(
                  value: p,
                  minHeight: DotSize.segment,
                  color: t.colors.accent,
                  backgroundColor: t.colors.hairline,
                ),
              ),
            // The timer runs on the step's usual length (docs/13 §5).
            if (state.stepLearned?.usualMinutes case final usual?)
              Text(
                l10n.learnUsually(formatDurationShort(l10n, usual)),
                style: t.styles.rowMeta.copyWith(color: t.colors.muted),
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
                  style: t.styles.body.copyWith(
                    color: s.done
                        ? t.colors.muted
                        : i == state.stepIndex
                        ? t.colors.accentInk
                        : null,
                    decoration: s.done ? TextDecoration.lineThrough : null,
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
            color: step.done || current ? c.accent : c.muted,
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
        color: on ? t.colors.accentTint : null,
        border: Border.all(color: on ? t.colors.accent : t.colors.outline),
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
                color: on ? t.colors.accentInk : t.colors.muted,
                size: DotSize.rowIcon,
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: t.styles.body.copyWith(
                        color: on ? t.colors.accentInk : null,
                      ),
                    ),
                    if (detail case final d?)
                      Text(
                        d,
                        style: t.styles.rowMeta.copyWith(color: t.colors.muted),
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
