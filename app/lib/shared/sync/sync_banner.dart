import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/layout/app_layout.dart';
import 'package:dottoday/core/shortcuts/app_shortcuts.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/data/sync/sync_providers.dart';
import 'package:dottoday/domain/sync/sync_status.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Offline, or changes that need you (R-08; E-G4-7 B2, B3; M20.10 part
/// 4a, ED-481): a rounded strip with the crossed cloud and "Offline ·
/// everything still works here", or the warning and "1 change needs you"
/// with Review. On Today it sits under the week strip (B2); on the other
/// screens at their top. Phones and medium windows only: expanded windows
/// carry the state in the sidebar line, always in view (E-R2-8).
class SyncBanner extends ConsumerWidget {
  const SyncBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final status = ref.watch(syncStatusProvider).value;
    if (status == null || AppLayout.classOf(context) == WidthClass.expanded) {
      return const SizedBox.shrink();
    }
    if (status.conflicts.isNotEmpty) {
      return _Strip(
        glyph: DotGlyphs.warning,
        text: l10n.bannerConflicts(status.conflicts.length),
        action: (
          l10n.bannerReview,
          // The sheet is the sync feature's; the app root opens it.
          () => Actions.maybeInvoke(context, const ShowSyncIntent()),
        ),
      );
    }
    if (status.state == SyncState.offline) {
      return _Strip(glyph: DotGlyphs.cloudOff, text: l10n.bannerOffline);
    }
    return const SizedBox.shrink();
  }
}

/// The strip as E-G4-7 B2 draws it: the page's sunk fill, rounded, inset
/// from the sides, the glyph and one line in ink, an optional text action.
class _Strip extends StatelessWidget {
  const _Strip({required this.glyph, required this.text, this.action});

  final DotGlyph glyph;
  final String text;
  final (String, VoidCallback)? action;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final action = this.action;
    return Semantics(
      container: true,
      liveRegion: true,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: DotSpace.page,
          vertical: DotSpace.xs,
        ),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: t.colors.sunk,
            borderRadius: BorderRadius.circular(DotRadii.notice),
          ),
          child: Padding(
            padding: EdgeInsetsDirectional.fromSTEB(
              DotSpace.m,
              DotSpace.s,
              action == null ? DotSpace.m : DotSpace.xs,
              DotSpace.s,
            ),
            child: Row(
              spacing: DotSpace.s,
              children: [
                DotIcon(glyph, color: t.colors.text, size: DotSize.rowIcon),
                Expanded(
                  child: Text(
                    text,
                    style: t.styles.rowMeta.copyWith(color: t.colors.text),
                  ),
                ),
                if (action != null)
                  TextButton(onPressed: action.$2, child: Text(action.$1)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
