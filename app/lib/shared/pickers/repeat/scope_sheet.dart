import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/domain/recurrence/series_edit.dart';
import 'package:dottoday/shared/sheets/app_sheet.dart';
import 'package:flutter/material.dart';

/// "Change which?" / "Delete which?" for a repeating task (docs/09 M3f.1,
/// R-01): This one · This and following · All (past ones stay). [scopes]
/// limits the rows (a repeat rule has no "this one"). Null = cancelled.
Future<EditScope?> showScopeSheet(
  BuildContext context, {
  required bool delete,
  List<EditScope> scopes = EditScope.values,
}) => showAppSheet<EditScope>(
  context: context,
  title: delete ? context.l10n.scopeTitleDelete : context.l10n.scopeTitleEdit,
  builder: (sheet) {
    final t = DotTheme.of(sheet);
    final l10n = sheet.l10n;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final s in scopes)
          ListTile(
            contentPadding: EdgeInsets.zero,
            minTileHeight: DotTouch.android,
            title: Text(switch (s) {
              EditScope.thisOne => l10n.scopeThis,
              EditScope.following => l10n.scopeFollowing,
              EditScope.all => l10n.scopeAll,
            }, style: t.styles.body),
            subtitle: s == EditScope.all
                ? Text(l10n.scopeAllDetail, style: t.styles.rowMeta)
                : null,
            onTap: () => Navigator.of(sheet).pop(s),
          ),
      ],
    );
  },
);
