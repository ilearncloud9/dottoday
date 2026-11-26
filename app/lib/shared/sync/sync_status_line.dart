import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/shortcuts/app_shortcuts.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/domain/sync/sync_status.dart';
import 'package:flutter/material.dart';

/// The sync state at the foot of the Mac and web sidebar (R-08; E-G4-7
/// B5, B6; E-R2-8 on expanded tablets; M20.10 part 4a, ED-481): its icon
/// and words, never colour alone; "Saved in this browser · 2 changes
/// waiting to sync" on the web while offline. Nothing while there is no
/// account. A tap opens Sync as a popover pointing at the line.
class SyncStatusLine extends StatelessWidget {
  const SyncStatusLine({
    required this.status,
    required this.now,
    this.browser = false,
    super.key,
  });

  final SyncStatus status;

  /// The web: offline reads "Saved in this browser" (B6).
  final bool browser;

  /// For "4 min ago".
  final DateTime now;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final l10n = context.l10n;
    final text = syncLineText(l10n, status, now, browser: browser);
    if (text == null) return const SizedBox.shrink();
    return Semantics(
      button: true,
      label: l10n.syncTitle,
      value: text,
      excludeSemantics: true,
      child: InkWell(
        borderRadius: BorderRadius.circular(DotRadii.field),
        onTap: () => _open(context),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: DotTouch.pointer),
          child: Row(
            spacing: DotSpace.s,
            children: [
              DotIcon(
                syncLineGlyph(status),
                color: t.colors.muted,
                size: DotSize.rowIcon,
              ),
              Flexible(child: Text(text, style: t.styles.rowMeta)),
            ],
          ),
        ),
      ),
    );
  }

  void _open(BuildContext context) {
    final box = context.findRenderObject() as RenderBox?;
    final anchor = box == null
        ? null
        : box.localToGlobal(Offset.zero) & box.size;
    Actions.maybeInvoke(context, ShowSyncIntent(anchor: anchor));
  }
}

/// The line's icon (E-G4-7 B legend).
DotGlyph syncLineGlyph(SyncStatus status) {
  if (status.conflicts.isNotEmpty) return DotGlyphs.warning;
  return switch (status.state) {
    SyncState.synced || SyncState.localOnly => DotGlyphs.check,
    SyncState.syncing => DotGlyphs.sync,
    SyncState.offline => DotGlyphs.cloudOff,
    SyncState.error => DotGlyphs.warning,
    SyncState.sessionEnded => DotGlyphs.lock,
  };
}

/// How long ago [at] was, for "synced …": just now, minutes, hours.
String syncAgo(AppLocalizations l10n, DateTime? at, DateTime now) {
  final minutes = at == null ? 0 : now.difference(at).inMinutes;
  if (minutes < 1) return l10n.syncAgoJustNow;
  if (minutes < 60) return l10n.syncAgoMinutes(minutes);
  return l10n.syncAgoHours(minutes ~/ 60);
}

/// The line for [status]; null without an account. In a [browser],
/// offline reads "Saved in this browser", with what is waiting (B6).
String? syncLineText(
  AppLocalizations l10n,
  SyncStatus status,
  DateTime now, {
  bool browser = false,
}) {
  if (status.conflicts.isNotEmpty) {
    return l10n.bannerConflicts(status.conflicts.length);
  }
  return switch (status.state) {
    SyncState.localOnly => null,
    SyncState.synced => l10n.syncLineSynced(
      syncAgo(l10n, status.lastSyncedUtc, now),
    ),
    SyncState.syncing => l10n.syncLineSyncing,
    SyncState.offline when browser =>
      status.pending == 0
          ? l10n.syncLineBrowser
          : l10n.syncSummary(
              l10n.syncLineBrowser,
              l10n.syncPending(status.pending),
            ),
    SyncState.offline => l10n.syncLineOffline,
    // "Couldn't sync" (E-G4-7 B legend); "Sync paused" is the fast
    // clock's, in the sheet (ED-482).
    SyncState.error => l10n.syncLineError,
    SyncState.sessionEnded => l10n.syncLineSessionEnded,
  };
}
