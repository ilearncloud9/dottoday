import 'dart:async';

import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/data/system/system_providers.dart';
import 'package:dottoday/features/settings/pages/page_frame.dart';
import 'package:dottoday/shared/settings/settings_group.dart';
import 'package:dottoday/shared/sheets/app_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Settings › About Dottoday (docs/09 M3f.7): version, What's new and the
/// open-source licences.
class AboutPage extends ConsumerWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = DotTheme.of(context);
    final l10n = context.l10n;
    final version = ref.watch(appVersionProvider).value;
    return SettingsPageFrame(
      title: l10n.settingsAboutApp,
      children: [
        SettingsGroup(
          caption: l10n.settingsAbout,
          children: [
            SettingsRow(
              glyph: DotGlyphs.today,
              tint: t.colors.accentInk,
              title: l10n.settingsVersion,
              value: version,
            ),
            SettingsRow(
              glyph: DotGlyphs.bolt,
              tint: t.tasks[TaskColor.amber].ink,
              title: l10n.settingsWhatsNew,
              onTap: () => unawaited(_whatsNew(context)),
            ),
            SettingsRow(
              glyph: DotGlyphs.info,
              tint: t.colors.muted,
              title: l10n.aboutLicences,
              onTap: () => showLicensePage(
                context: context,
                applicationVersion: version,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _whatsNew(BuildContext context) => showAppSheet<void>(
    context: context,
    title: context.l10n.settingsWhatsNew,
    builder: (_) => Text(
      context.l10n.settingsWhatsNewBody,
      style: DotTheme.of(context).styles.body,
    ),
  );
}
