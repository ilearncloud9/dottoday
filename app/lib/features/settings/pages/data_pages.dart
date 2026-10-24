import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/features/settings/pages/page_frame.dart';
import 'package:dottoday/shared/settings/settings_group.dart';
import 'package:flutter/material.dart';

/// Settings › Export (docs/09 M3f.7; the files land in M8.1, R-11): the
/// formats to come, free, and today's way out (Copy day as text).
class ExportPage extends StatelessWidget {
  const ExportPage({super.key});

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final l10n = context.l10n;
    SettingsRow format(DotGlyph glyph, String title, String detail) =>
        SettingsRow(
          glyph: glyph,
          tint: t.colors.muted,
          title: title,
          subtitle: detail,
        );
    return SettingsPageFrame(
      title: l10n.settingsExport,
      children: [
        PageText(l10n.exportIntro),
        SettingsGroup(
          caption: l10n.exportFormats,
          children: [
            format(DotGlyphs.share, l10n.exportJson, l10n.exportJsonDetail),
            format(DotGlyphs.week, l10n.exportCsv, l10n.exportCsvDetail),
            format(DotGlyphs.calendar, l10n.exportIcs, l10n.exportIcsDetail),
          ],
        ),
        PageText(l10n.exportComingSoon),
      ],
    );
  }
}
