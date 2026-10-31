import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/router/app_routes.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/data/profile/profile_providers.dart';
import 'package:dottoday/features/settings/pages/page_frame.dart';
import 'package:dottoday/features/settings/settings_screen.dart';
import 'package:dottoday/shared/settings/settings_group.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Minimal Settings › Everything else… (docs/14 §4): the full Settings
/// tree, and Search, which has no tab in minimal (§3; owner, 2026-10-30).
class EverythingPage extends ConsumerWidget {
  const EverythingPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = DotTheme.of(context);
    final l10n = context.l10n;
    final profile = ref.watch(currentProfileProvider).value;
    return SettingsPageFrame(
      title: l10n.settingsEverythingElse,
      children: [
        SettingsGroup(
          caption: '',
          children: [
            SettingsRow(
              glyph: DotGlyphs.search,
              tint: t.colors.accentInk,
              title: l10n.navSearch,
              onTap: () => context.go(AppRoutes.search),
            ),
          ],
        ),
        if (profile != null)
          ...settingsGroups(context, profile, profile.settings),
      ],
    );
  }
}
