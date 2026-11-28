import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/features/task_editor/add/state/add_flow.dart';
import 'package:flutter/material.dart';

/// Top of Minimal's Add sheet (docs/14 §4): "‹ Back" on the When step,
/// and close. Minimal Add is one step, so it shows no step dots.
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
                icon: DotIcon(back, color: t.colors.accentText),
                label: Text(
                  l10n.addBack,
                  style: t.styles.body.copyWith(color: t.colors.accentText),
                ),
              ),
            ),
          Align(
            alignment: AlignmentDirectional.centerEnd,
            child: IconButton(
              onPressed: () => Navigator.of(context).maybePop(),
              tooltip: l10n.sheetClose,
              icon: DotIcon(DotGlyphs.close, color: t.colors.ink),
            ),
          ),
        ],
      ),
    );
  }
}
