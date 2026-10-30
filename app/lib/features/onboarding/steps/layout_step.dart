import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/data/layout/layout_providers.dart';
import 'package:dottoday/features/onboarding/steps/step_frame.dart';
import 'package:dottoday/shared/layout/layout_switch.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Onboarding step 0 (docs/14 §4): one question, two cards — *Just the
/// next dot* (preselected: Get started already chose it) and *The full
/// planner*. A tap applies at once; either is one tap to undo later.
class LayoutStep extends ConsumerWidget {
  const LayoutStep({required this.onNext, super.key});

  final VoidCallback onNext;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final minimal = ref.watch(layoutPolicyProvider.select((p) => p.isMinimal));
    return StepFrame(
      title: l10n.onboardingLayoutTitle,
      body: l10n.onboardingLayoutBody,
      primary: l10n.onboardingContinue,
      onPrimary: onNext,
      children: [
        _LayoutCard(
          title: l10n.onboardingLayoutMinimalTitle,
          body: l10n.onboardingLayoutMinimalBody,
          selected: minimal,
          onTap: () => setLayout(context, minimal: true),
        ),
        _LayoutCard(
          title: l10n.onboardingLayoutFullTitle,
          body: l10n.onboardingLayoutFullBody,
          selected: !minimal,
          onTap: () => setLayout(context, minimal: false),
        ),
      ],
    );
  }
}

class _LayoutCard extends StatelessWidget {
  const _LayoutCard({
    required this.title,
    required this.body,
    required this.selected,
    required this.onTap,
  });

  final String title;
  final String body;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final c = t.colors;
    return Padding(
      padding: const EdgeInsets.only(bottom: DotSpace.m),
      child: Semantics(
        button: true,
        selected: selected,
        inMutuallyExclusiveGroup: true,
        label: title,
        hint: body,
        excludeSemantics: true,
        child: Material(
          color: selected ? Color.alphaBlend(c.accentTint, c.raised) : c.raised,
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
              padding: const EdgeInsets.all(DotSpace.l),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: DotSpace.xs,
                children: [
                  Text(title, style: t.styles.cardTitle),
                  Text(body, style: t.styles.body.copyWith(color: c.muted)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
