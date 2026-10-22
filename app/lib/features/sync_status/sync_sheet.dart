import 'dart:async';

import 'package:dottoday/core/clock/clock_provider.dart';
import 'package:dottoday/core/failures/failure_messages.dart';
import 'package:dottoday/core/failures/result.dart';
import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/router/app_routes.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/data/profile/profile_providers.dart';
import 'package:dottoday/data/sync/sync_providers.dart';
import 'package:dottoday/domain/sync/sync_status.dart';
import 'package:dottoday/features/sync_status/conflict_card.dart';
import 'package:dottoday/shared/sheets/app_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:timezone/timezone.dart' as tz;

/// The Sync sheet (docs/09 M3f.8, R-08): where sync stands, when it last
/// ran, what is waiting, Sync now, and each conflict with "Keep mine /
/// Keep theirs". With no account, it says so and offers Sign in.
Future<void> showSyncSheet(BuildContext context) => showAppSheet<void>(
  context: context,
  title: context.l10n.syncTitle,
  builder: (_) => const _SyncBody(),
);

class _SyncBody extends ConsumerWidget {
  const _SyncBody();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = DotTheme.of(context);
    final l10n = context.l10n;
    final status = ref.watch(syncStatusProvider).value ?? SyncStatus.localOnly;
    if (status.state == SyncState.localOnly) return const _LocalOnly();
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: DotSpace.s,
      children: [
        Text(_stateLine(l10n, status.state), style: t.styles.body),
        Text(
          l10n.syncSummary(
            _lastSynced(context, ref, status.lastSyncedUtc),
            l10n.syncPending(status.pending),
          ),
          style: t.styles.rowMeta,
        ),
        _syncNowButton(context, ref, status.state),
        if (status.conflicts.isNotEmpty) ...[
          const SizedBox(height: DotSpace.s),
          Text(l10n.syncConflicts.toUpperCase(), style: t.styles.caption),
          Text(l10n.syncConflictHint, style: t.styles.rowMeta),
          for (final c in status.conflicts) ConflictCard(conflict: c),
        ],
      ],
    );
  }

  Widget _syncNowButton(BuildContext context, WidgetRef ref, SyncState state) =>
      Align(
        alignment: AlignmentDirectional.centerStart,
        child: OutlinedButton(
          onPressed: state == SyncState.syncing
              ? null
              : () => unawaited(_syncNow(context, ref)),
          child: Text(context.l10n.syncNow),
        ),
      );

  static String _stateLine(AppLocalizations l10n, SyncState state) =>
      switch (state) {
        SyncState.synced || SyncState.localOnly => l10n.syncStateSynced,
        SyncState.syncing => l10n.syncStateSyncing,
        SyncState.offline => l10n.syncStateOffline,
        SyncState.error => l10n.syncStateError,
      };

  /// "Last synced just now / 4 min ago / Tue, Oct 20, 9:41 PM".
  static String _lastSynced(BuildContext context, WidgetRef ref, DateTime? at) {
    final l10n = context.l10n;
    if (at == null) return l10n.syncNever;
    final now = ref.watch(clockProvider).nowUtc();
    final minutes = now.difference(at).inMinutes;
    if (minutes < 1) return l10n.syncJustNow;
    if (minutes < 60) return l10n.syncMinutesAgo(minutes);
    final locale = Localizations.localeOf(context).toLanguageTag();
    final tzId = ref.watch(currentProfileProvider).value?.tzId;
    final local = tzId == null
        ? at
        : tz.TZDateTime.from(at, tz.getLocation(tzId));
    return l10n.syncAt(DateFormat.MMMEd(locale).add_jm().format(local));
  }

  Future<void> _syncNow(BuildContext context, WidgetRef ref) async {
    final messenger = ScaffoldMessenger.of(context);
    final l10n = context.l10n;
    if (await ref.read(syncServiceProvider).syncNow() case Err(
      :final failure,
    )) {
      messenger.showSnackBar(
        SnackBar(content: Text(failureMessage(l10n, failure))),
      );
    }
  }
}

/// No account: what that means, and Sign in….
class _LocalOnly extends StatelessWidget {
  const _LocalOnly();

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final l10n = context.l10n;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: DotSpace.m,
      children: [
        Text(l10n.syncLocalOnlyBody, style: t.styles.body),
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: FilledButton(
            onPressed: () {
              final router = GoRouter.of(context);
              Navigator.of(context).pop();
              unawaited(
                router.push(AppRoutes.settingsPage(SettingsPage.account)),
              );
            },
            child: Text(l10n.syncSignIn),
          ),
        ),
      ],
    );
  }
}
