import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/data/layout/layout_providers.dart';
import 'package:dottoday/domain/time/day_dot_geometry.dart';
import 'package:dottoday/features/onboarding/steps/layout_sketch.dart';
import 'package:dottoday/shared/dot/day_dot.dart';
import 'package:dottoday/shared/layout/layout_switch.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Onboarding step 0 (docs/14 §4; the owner's render, 2026-10-31): the
/// day dot, one question, two radio cards — *Just the next dot*
/// (preselected: Get started chose it) and *The full planner*, each with a
/// sketch of its thread — then Continue and where you are in this layout's
/// flow. A tap applies at once; either is one tap to undo in Settings.
class LayoutStep extends ConsumerWidget {
  const LayoutStep({required this.onNext, required this.steps, super.key});

  final VoidCallback onNext;

  /// The steps after the welcome in the chosen layout's flow (step 0 is
  /// the first), for the dots under Continue.
  final int steps;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = DotTheme.of(context);
    final l10n = context.l10n;
    final minimal = ref.watch(layoutPolicyProvider.select((p) => p.isMinimal));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              DotSpace.page,
              DotSpace.xxl,
              DotSpace.page,
              DotSpace.l,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: DotSpace.l,
              children: [
                const ExcludeSemantics(
                  child: DayDot(
                    geometry: DayDotGeometry.filled(_dayShare),
                    size: DotSize.dayDot,
                  ),
                ),
                Semantics(
                  header: true,
                  child: Text(
                    l10n.onboardingLayoutTitle,
                    style: t.styles.pageTitle,
                  ),
                ),
                Text(
                  l10n.onboardingLayoutBody,
                  style: t.styles.body.copyWith(color: t.colors.muted),
                ),
                const SizedBox(height: DotSpace.xs),
                _LayoutCard(
                  title: l10n.onboardingLayoutMinimalTitle,
                  body: l10n.onboardingLayoutMinimalBody,
                  sketch: LayoutSketch.minimal,
                  selected: minimal,
                  onTap: () => setLayout(context, minimal: true),
                ),
                _LayoutCard(
                  title: l10n.onboardingLayoutFullTitle,
                  body: l10n.onboardingLayoutFullBody,
                  sketch: LayoutSketch.full,
                  selected: !minimal,
                  onTap: () => setLayout(context, minimal: false),
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(
            DotSpace.page,
            DotSpace.s,
            DotSpace.page,
            DotSpace.l,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: DotSpace.l,
            children: [
              FilledButton(
                onPressed: onNext,
                child: Text(l10n.onboardingContinue),
              ),
              Center(child: _StepDots(total: steps)),
            ],
          ),
        ),
      ],
    );
  }

  /// The day dot as drawn in the render: a morning, partly filled.
  static const _dayShare = 0.4;
}

class _LayoutCard extends StatelessWidget {
  const _LayoutCard({
    required this.title,
    required this.body,
    required this.sketch,
    required this.selected,
    required this.onTap,
  });

  final String title;
  final String body;
  final LayoutSketch sketch;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final c = t.colors;
    return Semantics(
      button: true,
      selected: selected,
      checked: selected,
      inMutuallyExclusiveGroup: true,
      label: title,
      hint: body,
      excludeSemantics: true,
      onTap: onTap,
      child: Material(
        color: c.raised,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DotRadii.cardLarge),
          side: BorderSide(
            color: selected ? c.accent : c.outline,
            width: selected ? DotSpace.hairline * 2 : DotSpace.hairline,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(DotSpace.l + DotSpace.xxs),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: DotSpace.l,
              children: [
                _RadioDot(selected: selected),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: DotSpace.xs,
                    children: [
                      Text(title, style: t.styles.cardTitle),
                      Text(body, style: t.styles.body.copyWith(color: c.muted)),
                      const SizedBox(height: DotSpace.s),
                      LayoutSketchView(sketch: sketch),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// The card's radio: an outline, or the accent ring with its dot.
class _RadioDot extends StatelessWidget {
  const _RadioDot({required this.selected});

  final bool selected;

  @override
  Widget build(BuildContext context) {
    final c = DotTheme.of(context).colors;
    return Container(
      width: DotSize.doneCircle,
      height: DotSize.doneCircle,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: selected ? c.accent : c.muted,
          width: DotSize.smallDotOutline,
        ),
      ),
      child: selected
          ? Container(
              width: DotSpace.m + DotSpace.xxs,
              height: DotSpace.m + DotSpace.xxs,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: c.accent,
              ),
            )
          : null,
    );
  }
}

/// Where you are: the current step a short accent bar, the rest dots (as
/// Add's header).
class _StepDots extends StatelessWidget {
  const _StepDots({required this.total});

  final int total;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    return Semantics(
      label: context.l10n.onboardingStepOf(1, total),
      excludeSemantics: true,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: DotSpace.xs + DotSpace.xxs,
        children: [
          for (var i = 0; i < total; i++)
            Container(
              width: i == 0 ? DotSpace.l + DotSpace.xxs : DotSpace.s,
              height: DotSpace.s,
              decoration: BoxDecoration(
                color: i == 0 ? t.colors.accent : t.colors.hairline,
                borderRadius: BorderRadius.circular(DotRadii.pill),
              ),
            ),
        ],
      ),
    );
  }
}
