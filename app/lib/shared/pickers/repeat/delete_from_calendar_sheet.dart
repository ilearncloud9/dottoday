import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/shared/sheets/app_sheet.dart';
import 'package:flutter/material.dart';

/// "Also delete it from {calendar}?" after Delete › All on a repeating
/// calendar event (docs/02 F5.7): Only in Dottoday (false, first) or
/// Delete from {calendar} too (true). Null = closed.
Future<bool?> showDeleteFromCalendarSheet(
  BuildContext context,
  String calendar,
) => showAppSheet<bool>(
  context: context,
  title: context.l10n.seriesDeleteCalendarTitle(calendar),
  builder: (sheet) {
    final t = DotTheme.of(sheet);
    final l10n = sheet.l10n;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ListTile(
          contentPadding: EdgeInsets.zero,
          minTileHeight: DotTouch.android,
          title: Text(l10n.seriesDeleteOnlyHere, style: t.styles.body),
          onTap: () => Navigator.of(sheet).pop(false),
        ),
        ListTile(
          contentPadding: EdgeInsets.zero,
          minTileHeight: DotTouch.android,
          title: Text(
            l10n.seriesDeleteFromCalendar(calendar),
            style: t.styles.body,
          ),
          subtitle: Text(
            l10n.seriesDeleteFromCalendarDetail,
            style: t.styles.rowMeta,
          ),
          onTap: () => Navigator.of(sheet).pop(true),
        ),
      ],
    );
  },
);
