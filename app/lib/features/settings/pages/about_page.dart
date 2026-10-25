import 'dart:async';

import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/router/app_routes.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/data/system/system_providers.dart';
import 'package:dottoday/features/settings/pages/page_frame.dart';
import 'package:dottoday/shared/settings/settings_group.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Settings › About Dottoday (docs/09 M3f.7): version, What's new (the
/// changelog page, M8.2) and the open-source licences.
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
              onTap: () => unawaited(
                context.push(AppRoutes.settingsPage(SettingsPage.changelog)),
              ),
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
}
