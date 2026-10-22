import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:flutter/material.dart';

/// "Add 5 tasks?" under a field that received a pasted list (03 §3.3,
/// R-07): one tap adds them all; "Keep as one" joins the lines instead.
class PasteConfirm extends StatelessWidget {
  const PasteConfirm({
    required this.count,
    required this.onAdd,
    required this.onKeepOne,
    super.key,
  });

  final int count;
  final VoidCallback onAdd;
  final VoidCallback onKeepOne;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final l10n = context.l10n;
    return Semantics(
      liveRegion: true,
      child: Container(
        padding: const EdgeInsetsDirectional.fromSTEB(
          DotSpace.l,
          DotSpace.s,
          DotSpace.s,
          DotSpace.s,
        ),
        decoration: BoxDecoration(
          color: t.colors.accentTint,
          borderRadius: BorderRadius.circular(DotRadii.card),
        ),
        child: Wrap(
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: DotSpace.s,
          children: [
            Text(l10n.pasteAsk(count), style: t.styles.body),
            Wrap(
              spacing: DotSpace.xs,
              children: [
                // Ink, not the accent: the accent fails 4.5:1 on its tint.
                TextButton(
                  onPressed: onKeepOne,
                  style: TextButton.styleFrom(
                    foregroundColor: t.colors.accentInk,
                  ),
                  child: Text(l10n.pasteKeep),
                ),
                FilledButton(
                  onPressed: onAdd,
                  child: Text(l10n.pasteAdd(count)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
