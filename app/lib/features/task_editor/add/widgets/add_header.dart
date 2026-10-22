import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/features/task_editor/add/state/add_flow.dart';
import 'package:flutter/material.dart';

/// Top of the Add sheet (`A-ios-add-what`, `A-ios-add-when`): "‹ Back" on
/// step 2, the step dots, and close.
class AddHeader extends StatelessWidget {
  const AddHeader({required this.step, required this.onBack, super.key});

  final AddStep step;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final l10n = context.l10n;
    // One back glyph on every platform: §4 doesn't list it as an idiom
    // (the renders differ; the doc wins).
    const back = DotGlyphs.chevronLeft;
    return SizedBox(
      height: DotTouch.android,
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (step == AddStep.when)
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: TextButton.icon(
                onPressed: onBack,
                icon: DotIcon(back, color: t.colors.accentInk),
                label: Text(
                  l10n.addBack,
                  style: t.styles.body.copyWith(color: t.colors.accentInk),
                ),
              ),
            ),
          _StepDots(current: step.index, total: AddStep.values.length),
          Align(
            alignment: AlignmentDirectional.centerEnd,
            child: IconButton(
              onPressed: () => Navigator.of(context).maybePop(),
              tooltip: l10n.sheetClose,
              icon: DotIcon(DotGlyphs.close, color: t.colors.text),
            ),
          ),
        ],
      ),
    );
  }
}

/// The page dots: the current step is a short accent bar.
class _StepDots extends StatelessWidget {
  const _StepDots({required this.current, required this.total});

  final int current;
  final int total;

  @override
  Widget build(BuildContext context) {
    final c = DotTheme.of(context).colors;
    return Semantics(
      label: context.l10n.addStepOf(current + 1, total),
      excludeSemantics: true,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: DotSpace.xs + DotSpace.xxs,
        children: [
          for (var i = 0; i < total; i++)
            AnimatedContainer(
              duration: DotTheme.of(context).motion.base,
              curve: DotTheme.of(context).motion.curve,
              width: i == current ? DotSpace.l + DotSpace.xxs : DotSpace.s,
              height: DotSpace.s,
              decoration: BoxDecoration(
                color: i == current ? c.accent : c.hairline,
                borderRadius: BorderRadius.circular(DotRadii.pill),
              ),
            ),
        ],
      ),
    );
  }
}
