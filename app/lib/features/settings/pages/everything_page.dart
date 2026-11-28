import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/router/app_routes.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/features/settings/pages/group_pages.dart';
import 'package:dottoday/features/settings/pages/page_frame.dart';
import 'package:dottoday/features/settings/panes/settings_pane_scope.dart';
import 'package:dottoday/features/settings/settings_screen.dart';
import 'package:dottoday/shared/settings/settings_group.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Minimal Settings › Everything else… (docs/14 §4): the full Settings
/// root (M20.7 part 1, E-PhonesMinimal), then Search, which has no tab in
/// minimal (§3; owner, 2026-10-30).
class EverythingPage extends ConsumerWidget {
  const EverythingPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // In two panes the root is in the list pane (owner, part 5a); the
    // detail shows Your day.
    if (SettingsPaneScope.paneAt(context) == SettingsPane.detail) {
      return const SettingsGroupPage(page: SettingsPage.yourDay);
    }
    final t = DotTheme.of(context);
    final l10n = context.l10n;
    return SettingsPageFrame(
      // The same root as Full (E-PhonesMinimal, ED-084), then Search,
      // which has no tab in minimal (docs/14 §3).
      title: l10n.navSettings,
      page: SettingsPage.everything,
      children: [
        const SettingsRoot(),
        SettingsGroup(
          caption: '',
          children: [
            SettingsRow(
              glyph: DotGlyphs.search,
              tint: t.colors.accentText,
              title: l10n.navSearch,
              onTap: () => context.go(AppRoutes.search),
            ),
          ],
        ),
      ],
    );
  }
}
