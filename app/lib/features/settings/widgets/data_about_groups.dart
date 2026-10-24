import 'dart:async';

import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/router/app_routes.dart';
import 'package:dottoday/core/shortcuts/app_shortcuts.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/data/sync/sync_providers.dart';
import 'package:dottoday/data/system/system_providers.dart';
import 'package:dottoday/domain/sync/sync_status.dart';
import 'package:dottoday/features/settings/widgets/feedback_sheet.dart';
import 'package:dottoday/features/settings/widgets/trash_sheet.dart';
import 'package:dottoday/shared/settings/settings_group.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Opens a Settings sub-page inside the Settings tab (M3f.7).
void _open(BuildContext context, SettingsPage page) =>
    unawaited(context.push(AppRoutes.settingsPage(page)));

/// DATA: Sync (the sheet, M3f.8), Calendars, Export (pages, M3f.7) and
/// Trash (R-11).
class DataGroup extends ConsumerWidget {
  const DataGroup({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = DotTheme.of(context);
    final l10n = context.l10n;
    final sync = ref.watch(syncStatusProvider).value ?? SyncStatus.localOnly;
    return SettingsGroup(
      caption: l10n.settingsData,
      children: [
        SettingsRow(
          glyph: DotGlyphs.repeat,
          tint: t.colors.accentInk,
          title: l10n.settingsSync,
          value: _syncValue(l10n, sync),
          // The sheet belongs to the sync feature; the app root opens it.
          onTap: () => Actions.maybeInvoke(context, const ShowSyncIntent()),
        ),
        SettingsRow(
          glyph: DotGlyphs.calendar,
          tint: t.tasks[TaskColor.sky].ink,
          title: l10n.settingsCalendars,
          subtitle: l10n.settingsCalendarsDetail,
          onTap: () => _open(context, SettingsPage.calendars),
        ),
        SettingsRow(
          glyph: DotGlyphs.share,
          tint: t.tasks[TaskColor.mint].ink,
          title: l10n.settingsExport,
          subtitle: l10n.settingsExportDetail,
          onTap: () => _open(context, SettingsPage.export),
        ),
        SettingsRow(
          glyph: DotGlyphs.trash,
          tint: t.colors.muted,
          title: l10n.settingsTrash,
          subtitle: l10n.settingsTrashDetail,
          onTap: () => unawaited(showTrashSheet(context)),
        ),
      ],
    );
  }
}

/// The Sync row's value: conflicts first, else the state.
String _syncValue(AppLocalizations l10n, SyncStatus s) {
  if (s.conflicts.isNotEmpty) return l10n.bannerConflicts(s.conflicts.length);
  return switch (s.state) {
    SyncState.localOnly => l10n.syncLocalOnly,
    SyncState.synced => l10n.syncSynced,
    SyncState.syncing => l10n.syncSyncing,
    SyncState.offline => l10n.syncOffline,
    SyncState.error => l10n.syncError,
  };
}

/// ABOUT: Help, Privacy, About Dottoday (version, What's new, licences;
/// pages, M3f.7) and Send feedback (PRD F11, R-19).
class AboutGroup extends ConsumerWidget {
  const AboutGroup({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = DotTheme.of(context);
    final l10n = context.l10n;
    final version = ref.watch(appVersionProvider).value;
    return SettingsGroup(
      caption: l10n.settingsAbout,
      children: [
        SettingsRow(
          glyph: DotGlyphs.help,
          tint: t.colors.accentInk,
          title: l10n.settingsHelp,
          onTap: () => _open(context, SettingsPage.help),
        ),
        SettingsRow(
          glyph: DotGlyphs.lock,
          tint: t.tasks[TaskColor.teal].ink,
          title: l10n.settingsPrivacy,
          onTap: () => _open(context, SettingsPage.privacy),
        ),
        SettingsRow(
          glyph: DotGlyphs.today,
          tint: t.tasks[TaskColor.amber].ink,
          title: l10n.settingsAboutApp,
          value: version,
          onTap: () => _open(context, SettingsPage.about),
        ),
        SettingsRow(
          glyph: DotGlyphs.edit,
          tint: t.tasks[TaskColor.mint].ink,
          title: l10n.settingsFeedback,
          onTap: () => unawaited(showFeedbackSheet(context)),
        ),
      ],
    );
  }
}
