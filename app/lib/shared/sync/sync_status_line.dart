import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/domain/sync/sync_status.dart';
import 'package:flutter/material.dart';

/// "Synced · just now" with its dot (`A-mac-week-alt3-board`, the foot of
/// the Inbox sidebar; docs/09 M6.3, R-08). Nothing while there is no
/// account. The text says the state; the dot only repeats it.
class SyncStatusLine extends StatelessWidget {
  const SyncStatusLine({required this.status, required this.now, super.key});

  final SyncStatus status;

  /// For "4 min ago".
  final DateTime now;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final text = syncLineText(context.l10n, status, now);
    if (text == null) return const SizedBox.shrink();
    final color = switch (status.state) {
      SyncState.synced when status.conflicts.isEmpty => t.colors.success,
      SyncState.syncing => t.colors.accent,
      _ => t.colors.muted,
    };
    return Row(
      spacing: DotSpace.s,
      children: [
        Container(
          width: DotSize.weekDot,
          height: DotSize.weekDot,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        Flexible(child: Text(text, style: t.styles.rowMeta)),
      ],
    );
  }
}

/// How long ago [at] was, for "synced …": just now, minutes, hours.
String syncAgo(AppLocalizations l10n, DateTime? at, DateTime now) {
  final minutes = at == null ? 0 : now.difference(at).inMinutes;
  if (minutes < 1) return l10n.syncAgoJustNow;
  if (minutes < 60) return l10n.syncAgoMinutes(minutes);
  return l10n.syncAgoHours(minutes ~/ 60);
}

/// The line for [status]; null without an account.
String? syncLineText(AppLocalizations l10n, SyncStatus status, DateTime now) {
  if (status.conflicts.isNotEmpty) {
    return l10n.bannerConflicts(status.conflicts.length);
  }
  return switch (status.state) {
    SyncState.localOnly => null,
    SyncState.synced => l10n.syncLineSynced(
      syncAgo(l10n, status.lastSyncedUtc, now),
    ),
    SyncState.syncing => l10n.syncLineSyncing,
    SyncState.offline => l10n.syncLineOffline,
    SyncState.error => l10n.syncLinePaused,
  };
}
