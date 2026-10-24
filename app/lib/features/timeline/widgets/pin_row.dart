import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/shared/settings/settings_group.dart';
import 'package:flutter/material.dart';

/// "Pinned" with its switch, in the task sheet and the editor (docs/02
/// F1.5, F2.9, R-17): a pinned task stays put when others shift, run late
/// or are dragged past it. The whole row toggles; the switch is the same
/// idiom as Settings (`DotSwitch`, docs/10 §4).
class PinRow extends StatelessWidget {
  const PinRow({
    required this.pinned,
    required this.onChanged,
    this.contentPadding,
    this.minHeight = DotTouch.android,
    super.key,
  });

  final bool pinned;
  final ValueChanged<bool> onChanged;

  /// The editor's rows sit flush; the sheet's card keeps ListTile's inset.
  final EdgeInsetsGeometry? contentPadding;
  final double minHeight;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final l10n = context.l10n;
    return MergeSemantics(
      child: ListTile(
        onTap: () => onChanged(!pinned),
        contentPadding: contentPadding,
        minTileHeight: minHeight,
        leading: DotIcon(DotGlyphs.lock, color: t.colors.muted),
        title: Text(l10n.pinTitle, style: t.styles.body),
        subtitle: Text(l10n.pinDetail, style: t.styles.rowMeta),
        trailing: DotSwitch(value: pinned, onChanged: onChanged),
      ),
    );
  }
}
