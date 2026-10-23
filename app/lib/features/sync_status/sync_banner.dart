import 'dart:async';

import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/data/sync/sync_providers.dart';
import 'package:dottoday/domain/sync/sync_status.dart';
import 'package:dottoday/features/sync_status/sync_sheet.dart';
import 'package:dottoday/shared/feedback/banner_strip.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// A strip above every screen (docs/10 §5.4 "offline (banner, everything
/// still editable)", R-08): conflicts that need the user — with Review —
/// or being offline. Nothing for local-only use or when all is well.
class SyncBanner extends ConsumerWidget {
  const SyncBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final status = ref.watch(syncStatusProvider).value;
    if (status == null) return const SizedBox.shrink();
    if (status.conflicts.isNotEmpty) {
      return BannerStrip(
        glyph: DotGlyphs.warning,
        text: l10n.bannerConflicts(status.conflicts.length),
        actions: [(l10n.bannerReview, () => unawaited(showSyncSheet(context)))],
      );
    }
    if (status.state == SyncState.offline) {
      return BannerStrip(glyph: DotGlyphs.dottedLine, text: l10n.bannerOffline);
    }
    return const SizedBox.shrink();
  }
}
