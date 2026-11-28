import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/shortcuts/app_shortcuts.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/domain/sync/sync_status.dart';
import 'package:dottoday/shared/sync/sync_status_line.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Sync in Today's top row (E-Phones; rules §4 "Sync status"; E-G4-7 B,
/// M20.10 part 4a, ED-481): the glyph, the crossed cloud while offline
/// (B2), a ring while syncing (A3), a teal dot while synced; at the top
/// the changes waiting to sync or "!" when sync failed (B3), and below
/// the changes that need you (E-Phones). Its label says the state in
/// words, never the colour alone (R-08, rules §12.4); a tap opens the
/// Sync sheet. A 48 target.
class SyncButton extends StatelessWidget {
  const SyncButton({required this.status, required this.now, super.key});

  final SyncStatus status;

  /// For "Synced · 4 min ago".
  final DateTime now;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final c = t.colors;
    final l10n = context.l10n;
    final material = DotIdiom.of(context) != DotIdiom.cupertino;
    final glyph = material ? DotSize.headerGlyphAndroid : DotSize.headerGlyph;
    final conflicts = status.conflicts.length;
    final synced = status.state == SyncState.synced && status.conflicts.isEmpty;
    final offline = status.state == SyncState.offline;
    // The top badge (E-G4-7 B legend): "!" when sync failed, else the
    // changes still waiting for the server.
    final String? top = switch (status.state) {
      SyncState.error ||
      SyncState.sessionEnded => '!', // l10n-ignore: a symbol, not words
      SyncState.localOnly => null,
      _ when status.pending > 0 => NumberFormat.decimalPattern(
        Localizations.localeOf(context).toLanguageTag(),
      ).format(status.pending),
      _ => null,
    };
    return Semantics(
      button: true,
      label: l10n.syncTitle,
      value: syncLineText(l10n, status, now) ?? l10n.syncLocalOnly,
      excludeSemantics: true,
      onTap: () => _open(context),
      child: InkResponse(
        onTap: () => _open(context),
        radius: DotTouch.android / 2,
        child: SizedBox.square(
          // 48 on every platform: the device sweep's floor (docs/08 §3).
          dimension: DotTouch.android,
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              if (status.state == SyncState.syncing)
                // A thin arc on a faint track round the glyph, still, not a
                // spinner: calm, and nothing to stop for Reduce Motion
                // (E-G4-7 A2, A3).
                SizedBox.square(
                  dimension: glyph + 2 * DotSpace.xs,
                  child: CircularProgressIndicator(
                    value: _syncingArc,
                    strokeWidth: DotSize.syncDotRing,
                    color: c.accent,
                    backgroundColor: c.hairline,
                  ),
                ),
              DotIcon(
                offline ? DotGlyphs.cloudOff : DotGlyphs.sync,
                color: material ? c.ink2 : c.secondary,
                size: glyph,
              ),
              if (top != null)
                PositionedDirectional(
                  bottom: DotTouch.android / 2 + DotSpace.xs,
                  start: DotTouch.android / 2 + DotSpace.xs,
                  child: _Badge(text: top),
                ),
              if (synced)
                PositionedDirectional(
                  top: DotTouch.android / 2,
                  start: DotTouch.android / 2,
                  child: _Dot(color: c.accent, ring: c.ground),
                ),
              if (conflicts > 0)
                // Down and out from the glyph's corner, as E-Phones draws it.
                PositionedDirectional(
                  top: DotTouch.android / 2 + DotSpace.nowCard,
                  start: DotTouch.android / 2 + DotSpace.nowCard,
                  child: _Badge(
                    text: NumberFormat.decimalPattern(
                      Localizations.localeOf(context).toLanguageTag(),
                    ).format(conflicts),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  /// How much of the ring the still arc covers (E-G4-7 A2, A3).
  static const _syncingArc = 0.3;

  void _open(BuildContext context) =>
      Actions.maybeInvoke(context, const ShowSyncIntent());
}

class _Dot extends StatelessWidget {
  const _Dot({required this.color, required this.ring});

  final Color color;
  final Color ring;

  @override
  Widget build(BuildContext context) => Container(
    width: DotSize.syncDot + 2 * DotSize.syncDotRing,
    height: DotSize.syncDot + 2 * DotSize.syncDotRing,
    decoration: BoxDecoration(
      color: color,
      shape: BoxShape.circle,
      border: Border.all(color: ring, width: DotSize.syncDotRing),
    ),
  );
}

class _Badge extends StatelessWidget {
  const _Badge({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    return Container(
      constraints: const BoxConstraints(
        minWidth: DotSize.badge,
        minHeight: DotSize.badge,
      ),
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: DotSpace.xxs),
      decoration: BoxDecoration(
        color: t.colors.ink,
        borderRadius: BorderRadius.circular(DotSize.badge / 2),
      ),
      child: Text(text, style: t.styles.badge.copyWith(color: t.colors.ground)),
    );
  }
}
