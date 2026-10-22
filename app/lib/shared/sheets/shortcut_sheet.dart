import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/shared/sheets/app_sheet.dart';
import 'package:flutter/material.dart';

/// A group of the shortcut sheet: its caption and (keys, what they do).
typedef ShortcutGroup = ({
  String caption,
  List<({String keys, String action})> rows,
});

/// The ⌘/ sheet (docs/10 §5.3 "Mac/web keyboard shortcut sheet", M3e.6):
/// every binding by where it works. A popover from the medium width up.
Future<void> showShortcutSheet(
  BuildContext context,
  List<ShortcutGroup> groups,
) => showAppSheet<void>(
  context: context,
  title: context.l10n.shortcutsTitle,
  builder: (sheet) {
    final t = DotTheme.of(sheet);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: DotSpace.l,
      children: [
        for (final g in groups)
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: DotSpace.xs,
            children: [
              Semantics(
                header: true,
                child: Text(g.caption.toUpperCase(), style: t.styles.caption),
              ),
              for (final r in g.rows)
                MergeSemantics(
                  child: Row(
                    spacing: DotSpace.m,
                    children: [
                      Expanded(child: Text(r.action, style: t.styles.body)),
                      _Keys(keys: r.keys),
                    ],
                  ),
                ),
            ],
          ),
      ],
    );
  },
);

class _Keys extends StatelessWidget {
  const _Keys({required this.keys});

  final String keys;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: t.colors.surface,
        border: Border.all(color: t.colors.outline),
        borderRadius: BorderRadius.circular(DotRadii.chipAndroid),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: DotSpace.s,
          vertical: DotSpace.xxs,
        ),
        child: Text(
          keys,
          style: t.styles.rowMeta.copyWith(color: t.colors.text),
        ),
      ),
    );
  }
}
