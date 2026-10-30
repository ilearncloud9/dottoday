import 'dart:async';

import 'package:dottoday/core/clock/clock_provider.dart';
import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/router/app_routes.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/data/profile/profile_providers.dart';
import 'package:dottoday/data/profile/settings_actions.dart';
import 'package:dottoday/data/sync/sync_providers.dart';
import 'package:dottoday/domain/entities/settings.dart';
import 'package:dottoday/domain/sync/sync_status.dart';
import 'package:dottoday/features/layout/feature_id.dart';
import 'package:dottoday/features/layout/layout_providers.dart';
import 'package:dottoday/features/settings/minimal_settings.dart';
import 'package:dottoday/features/settings/widgets/data_about_groups.dart';
import 'package:dottoday/features/settings/widgets/day_shape_group.dart';
import 'package:dottoday/features/settings/widgets/learning_group.dart';
import 'package:dottoday/features/settings/widgets/look_group.dart';
import 'package:dottoday/features/settings/widgets/planning_group.dart';
import 'package:dottoday/features/settings/widgets/reminders_group.dart';
import 'package:dottoday/shared/settings/settings_group.dart';
import 'package:dottoday/shared/states/screen_states.dart';
import 'package:dottoday/shared/sync/sync_status_line.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Settings P1 (docs/10 §5.2, `A-ios-settings`, `A-android-settings`):
/// DAY SHAPE, PLANNING, REMINDERS, LOOK, DATA, ABOUT, plus PRD F8's
/// snapping, shift default, alerts default, language, trash, feedback and
/// changelog. Every change applies at once (03 §3.7). Layout is the first
/// row in both layouts; minimal shows [MinimalSettings] (docs/14 §4).
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  static const _key = ValueKey('route:settings');

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(currentProfileProvider);
    final profile = profileAsync.value;
    if (profile == null) {
      return StateScaffold(
        key: _key,
        inputs: [profileAsync],
        onRetry: () => ref.invalidate(currentProfileProvider),
      );
    }
    final s = profile.settings;
    return Scaffold(
      key: _key,
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: DotSize.readableColumn),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(
                DotSpace.page,
                DotSpace.l,
                DotSpace.page,
                DotSpace.fabClearance,
              ),
              children: [
                _Header(
                  profile: profile,
                  sync:
                      ref.watch(syncStatusProvider).value ??
                      SyncStatus.localOnly,
                  now: ref.watch(clockProvider).nowUtc(),
                ),
                const SizedBox(height: DotSpace.xl),
                if (watchSimplified(ref, FeatureId.notifications))
                  MinimalSettings(settings: s)
                else ...[
                  const SettingsGroup(caption: '', children: [LayoutRow()]),
                  for (final group in settingsGroups(context, profile, s)) ...[
                    const SizedBox(height: DotSpace.xl),
                    group,
                  ],
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// The full Settings tree's groups: the Settings tab in full, and minimal's
/// Everything else… page.
List<Widget> settingsGroups(
  BuildContext context,
  Profile profile,
  Settings s,
) => [
  DayShapeGroup(settings: s),
  PlanningGroup(settings: s),
  LearningGroup(settings: s),
  RemindersGroup(settings: s),
  LookGroup(
    settings: s,
    locale: profile.locale,
    onLocale: (code) => unawaited(
      updateProfile(
        ProviderScope.containerOf(context),
        (p) => p.copyWith(locale: code),
      ),
    ),
  ),
  const DataGroup(),
  const AboutGroup(),
];

/// "Settings", "Kody · on this device" — or "Kody · synced just now" when
/// signed in (`A-ios-settings`, M6.3) — and the initial in a circle. The
/// name and avatar open Settings › Account (M3f.7).
class _Header extends StatelessWidget {
  const _Header({required this.profile, required this.sync, required this.now});

  final Profile profile;
  final SyncStatus sync;
  final DateTime now;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final l10n = context.l10n;
    final name = profile.displayName?.trim();
    final hasName = name != null && name.isNotEmpty;
    return InkWell(
      borderRadius: BorderRadius.circular(DotRadii.card),
      onTap: () =>
          unawaited(context.push(AppRoutes.settingsPage(SettingsPage.account))),
      child: _row(t, l10n, name ?? '', hasName: hasName),
    );
  }

  String _subtitle(
    AppLocalizations l10n,
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

  Widget _row(
    DotTheme t,
    AppLocalizations l10n,
    String name, {
    required bool hasName,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Semantics(
                header: true,
                child: Text(l10n.navSettings, style: t.styles.pageTitle),
              ),
              Text(
                _subtitle(l10n, name, hasName: hasName),
                style: t.styles.body.copyWith(color: t.colors.muted),
              ),
            ],
          ),
        ),
        Semantics(
          button: true,
          label: hasName
              ? l10n.settingsAvatarLabel(name)
              : l10n.settingsAccount,
          hint: l10n.settingsAccount,
          excludeSemantics: true,
          child: CircleAvatar(
            radius: DotSize.dayDot / 2,
            backgroundColor: t.colors.accentTint,
            child: hasName
                ? Text(
                    name.characters.first.toUpperCase(),
                    style: t.styles.cardTitle.copyWith(
                      color: t.colors.accentInk,
                    ),
                  )
                : DotIcon(DotGlyphs.person, color: t.colors.accentInk),
          ),
        ),
      ],
    );
  }
}
