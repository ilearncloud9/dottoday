import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:flutter/material.dart';

/// What the sync pill shows (docs/02 F7 "synced / syncing / offline /
/// error"), plus [localOnly] for the no-account case.
enum SyncPillState { localOnly, synced, syncing, offline, error }

/// Small status pill in the Today header (docs/03 §3.1, R-08). Each state has
/// its own icon and text, so colour is never the only signal. Static until
/// the sync engine drives it (M6.3).
class SyncPill extends StatelessWidget {
  const SyncPill({
    required this.state,
    this.onTap,
    this.iconOnly = false,
    super.key,
  });

  final SyncPillState state;

  /// Hide the visible text (kept as the semantics label) where space is
  /// short, e.g. a phone header at large text sizes.
  final bool iconOnly;

  /// Opens sync details; null renders a non-interactive pill.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final (icon, label, color) = _look(context.l10n, t.colors);
    final pill = Container(
      constraints: const BoxConstraints(minHeight: DotTouch.min),
      padding: const EdgeInsetsDirectional.symmetric(horizontal: DotSpace.m),
      alignment: AlignmentDirectional.center,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: DotSpace.l, color: color),
          if (!iconOnly) ...[
            const SizedBox(width: DotSpace.xs),
            // Text stays muted: warning amber is below 4.5:1 on surface.
            Text(
              label,
              style: t.styles.rowMeta.copyWith(color: t.colors.muted),
            ),
          ],
        ],
      ),
    );
    return Semantics(
      container: true,
      button: onTap != null,
      label: label,
      // The InkWell's own tap action is excluded with its subtree, so expose
      // it here for screen readers.
      onTap: onTap,
      excludeSemantics: true,
      child: onTap == null
          ? pill
          : InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(DotTouch.min),
              child: pill,
            ),
    );
  }

  (IconData, String, Color) _look(AppLocalizations l10n, DotColors c) =>
      switch (state) {
        SyncPillState.localOnly => (
          Icons.phone_iphone,
          l10n.syncLocalOnly,
          c.muted,
        ),
        SyncPillState.synced => (
          Icons.cloud_done_outlined,
          l10n.syncSynced,
          c.muted,
        ),
        SyncPillState.syncing => (Icons.sync, l10n.syncSyncing, c.accent),
        SyncPillState.offline => (
          Icons.cloud_off_outlined,
          l10n.syncOffline,
          c.muted,
        ),
        SyncPillState.error => (Icons.error_outline, l10n.syncError, c.muted),
      };
}
