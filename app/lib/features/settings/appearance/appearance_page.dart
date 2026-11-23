import 'dart:async';

import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/router/app_routes.dart';
import 'package:dottoday/data/profile/profile_providers.dart';
import 'package:dottoday/data/profile/settings_actions.dart';
import 'package:dottoday/features/settings/appearance/app_colour.dart';
import 'package:dottoday/features/settings/appearance/appearance_preview.dart';
import 'package:dottoday/features/settings/appearance/layout_row.dart';
import 'package:dottoday/features/settings/appearance/theme_thumbnails.dart';
import 'package:dottoday/features/settings/pages/page_frame.dart';
import 'package:dottoday/features/settings/settings_places.dart';
import 'package:dottoday/features/settings/widgets/format_group.dart';
import 'package:dottoday/shared/settings/settings_group.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Settings › Appearance (E-G3-9b, ED-161; M20.7 part 3): the live preview
/// pinned under the title, then Layout, Theme, App colour and Format.
/// Every change applies at once and shows in the preview.
class AppearancePage extends ConsumerWidget {
  const AppearancePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final profile = ref.watch(currentProfileProvider).value;
    return SettingsPageFrame(
      title: settingsPlace(l10n, SettingsPage.appearance).title,
      page: SettingsPage.appearance,
      pinned: const AppearancePreview(),
      children: [
        if (profile != null) ...[
          SettingsGroup(caption: l10n.layoutRow, children: const [LayoutRow()]),
          ThemeGroup(settings: profile.settings),
          AppColourGroup(profile: profile),
          FormatGroup(
            settings: profile.settings,
            locale: profile.locale,
            onLocale: (code) => unawaited(
              updateProfile(
                ProviderScope.containerOf(context),
                (p) => p.copyWith(locale: code),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
