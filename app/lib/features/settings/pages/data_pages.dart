import 'dart:async';

import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/data/backup/backup_providers.dart';
import 'package:dottoday/data/profile/profile_providers.dart';
import 'package:dottoday/domain/backup/backup_service.dart';
import 'package:dottoday/domain/export/export_files.dart';
import 'package:dottoday/features/settings/pages/export_flows.dart';
import 'package:dottoday/features/settings/pages/page_frame.dart';
import 'package:dottoday/shared/settings/settings_group.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Settings › Export (docs/09 M8.1, R-11): the three file exports, free on
/// every platform, Import a backup, and the backups kept on this device.
class ExportPage extends StatelessWidget {
  const ExportPage({super.key});

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final l10n = context.l10n;
    SettingsRow format(
      DotGlyph glyph,
      TaskColor color,
      String title,
      String detail,
      ExportFormat f,
    ) => SettingsRow(
      glyph: glyph,
      tint: t.tasks[color].ink,
      title: title,
      subtitle: detail,
      onTap: () => unawaited(exportAs(context, f)),
    );
    return SettingsPageFrame(
      title: l10n.settingsExport,
      children: [
        PageText(l10n.exportIntro),
        SettingsGroup(
          caption: l10n.exportFormats,
          children: [
            format(
              DotGlyphs.share,
              TaskColor.mint,
              l10n.exportJson,
              l10n.exportJsonDetail,
              ExportFormat.json,
            ),
            format(
              DotGlyphs.week,
              TaskColor.sky,
              l10n.exportCsv,
              l10n.exportCsvDetail,
              ExportFormat.csv,
            ),
            format(
              DotGlyphs.calendar,
              TaskColor.violet,
              l10n.exportIcs,
              l10n.exportIcsDetail,
              ExportFormat.ics,
            ),
          ],
        ),
        PageText(l10n.exportPlain),
        SettingsGroup(
          caption: l10n.exportRestore,
          children: [
            SettingsRow(
              glyph: DotGlyphs.undo,
              tint: t.colors.accentInk,
              title: l10n.exportImport,
              subtitle: l10n.exportImportDetail,
              onTap: () => unawaited(importBackup(context)),
            ),
          ],
        ),
        const _LocalBackups(),
        PageText(l10n.exportBackupsNote),
      ],
    );
  }
}

/// ON THIS DEVICE: each local backup, newest first; a tap goes back to it.
class _LocalBackups extends ConsumerWidget {
  const _LocalBackups();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = DotTheme.of(context);
    final l10n = context.l10n;
    final locale = Localizations.localeOf(context).toLanguageTag();
    // Until the profile loads; the zone id is never shown.
    final tzId =
        ref.watch(currentProfileProvider).value?.tzId ??
        'UTC'; // l10n-ignore: zone id
    final list = ref.watch(backupListProvider).value ?? const <BackupInfo>[];
    return SettingsGroup(
      caption: l10n.exportBackups,
      children: [
        if (list.isEmpty)
          SettingsRow(
            glyph: DotGlyphs.clock,
            tint: t.colors.muted,
            title: l10n.exportBackupsNone,
          ),
        for (final b in list)
          SettingsRow(
            glyph: DotGlyphs.clock,
            tint: t.colors.muted,
            title: backupLabel(b.createdAtUtc, tzId, locale),
            subtitle: _reason(l10n, b.reason),
            onTap: () => unawaited(restoreBackup(context, b)),
          ),
      ],
    );
  }

  static String _reason(AppLocalizations l10n, BackupReason reason) =>
      switch (reason) {
        BackupReason.daily => l10n.exportBackupDaily,
        BackupReason.preImport => l10n.exportBackupPreImport,
        BackupReason.preRestore => l10n.exportBackupPreRestore,
      };
}
