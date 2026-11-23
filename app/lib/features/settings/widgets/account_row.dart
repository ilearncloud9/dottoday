import 'dart:async';

import 'package:dottoday/core/clock/clock_provider.dart';
import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/router/app_routes.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/data/profile/profile_providers.dart';
import 'package:dottoday/data/sync/sync_providers.dart';
import 'package:dottoday/domain/sync/sync_status.dart';
import 'package:dottoday/shared/settings/profile_avatar.dart';
import 'package:dottoday/shared/sync/sync_status_line.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// "Your account" at the top of Settings (M20.7 part 1, E-Phones): the
/// initial in a circle, then "Kody · synced just now" — or "Kody · on this
/// device" (M6.3). Opens Settings › Account (M3f.7). A grouped card on
/// iPhone, a filled card on Material.
class AccountCard extends ConsumerWidget {
  const AccountCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(currentProfileProvider).value;
    if (profile == null) return const SizedBox.shrink();
    final sync = ref.watch(syncStatusProvider).value ?? SyncStatus.localOnly;
    final now = ref.watch(clockProvider).nowUtc();
    final t = DotTheme.of(context);
    final l10n = context.l10n;
    final name = profile.displayName?.trim() ?? '';
    final hasName = name.isNotEmpty;
    final cupertino = DotIdiom.of(context) == DotIdiom.cupertino;
    return Material(
      color: cupertino ? t.colors.raised : t.colors.chip,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(DotRadii.cardLarge),
        side: cupertino ? BorderSide(color: t.colors.outline) : BorderSide.none,
      ),
      clipBehavior: Clip.antiAlias,
      child: _row(
        context,
        t,
        l10n,
        name,
        hasName: hasName,
        subtitle: _subtitle(l10n, sync, now, name, hasName: hasName),
      ),
    );
  }

  Widget _row(
    BuildContext context,
    DotTheme t,
    AppLocalizations l10n,
    String name, {
    required bool hasName,
    required String subtitle,
  }) {
    return Semantics(
      button: true,
      label: hasName ? l10n.settingsAvatarLabel(name) : l10n.settingsAccount,
      child: InkWell(
        onTap: () => unawaited(
          context.push(AppRoutes.settingsPage(SettingsPage.account)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(DotSpace.l),
          child: Row(
            spacing: DotSpace.m,
            children: [
              ExcludeSemantics(child: ProfileAvatar(name: name)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l10n.settingsYourAccount, style: t.styles.rowTitle),
                    Text(subtitle, style: t.styles.rowMeta),
                  ],
                ),
              ),
              DotIcon(
                DotGlyphs.chevronRight,
                color: t.colors.muted,
                size: DotSize.rowIcon,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _subtitle(
    AppLocalizations l10n,
    SyncStatus sync,
    DateTime now,
    String name, {
    required bool hasName,
  }) {
    if (sync.state == SyncState.synced && sync.conflicts.isEmpty) {
      final ago = syncAgo(l10n, sync.lastSyncedUtc, now);
      return hasName
          ? l10n.settingsSynced(name, ago)
          : l10n.settingsSyncedNoName(ago);
    }
    final line = syncLineText(l10n, sync, now);
    if (line == null) {
      return hasName
          ? l10n.settingsLocalOnly(name)
          : l10n.settingsLocalOnlyNoName;
    }
    return hasName ? l10n.settingsNameAndStatus(name, line) : line;
  }
}
