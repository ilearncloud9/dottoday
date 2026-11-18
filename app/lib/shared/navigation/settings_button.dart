import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/router/app_routes.dart';
import 'package:dottoday/core/router/settings_return.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/data/profile/profile_providers.dart';
import 'package:dottoday/shared/settings/profile_avatar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// "Settings and account" (ED-238): the phones' way into Settings, the
/// profile's circle in the top row, now that Settings is not a tab. It
/// remembers the address it was pressed on, so Settings' Back returns
/// there. 44 pt / 48 dp.
class SettingsButton extends ConsumerWidget {
  const SettingsButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final name =
        ref.watch(currentProfileProvider).value?.displayName?.trim() ?? '';
    final size = DotIdiom.of(context) == DotIdiom.cupertino
        ? DotTouch.min
        : DotTouch.android;
    return Semantics(
      button: true,
      label: l10n.settingsAndAccount,
      excludeSemantics: true,
      child: Tooltip(
        message: l10n.settingsAndAccount,
        child: InkResponse(
          radius: size / 2,
          onTap: () {
            final router = GoRouter.of(context);
            ref
                .read(settingsReturnProvider.notifier)
                .from(
                  router.routerDelegate.currentConfiguration.uri.toString(),
                );
            router.go(AppRoutes.settings);
          },
          child: SizedBox.square(
            dimension: size,
            child: Center(child: ProfileAvatar(name: name)),
          ),
        ),
      ),
    );
  }
}
