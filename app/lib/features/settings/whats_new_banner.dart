import 'dart:async';

import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/router/app_routes.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/data/release/whats_new_seen.dart';
import 'package:dottoday/shared/feedback/banner_strip.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// "Dottoday 0.2.0 is here · See what's new" once after an update that
/// brought notes (PRD F11 "In-app What's new after updates", R-19). A
/// strip, not a dialog: it never stands between the person and their day.
/// See what's new opens the changelog; Not now hides it until the next
/// update. Nothing on a fresh install.
class WhatsNewBanner extends ConsumerWidget {
  const WhatsNewBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unseen = ref.watch(unseenReleasesNowProvider);
    if (unseen.isEmpty) return const SizedBox.shrink();
    final l10n = context.l10n;
    final newest = unseen.first.version;
    void seen() =>
        unawaited(ref.read(whatsNewSeenProvider.notifier).markSeen(newest));
    return BannerStrip(
      glyph: DotGlyphs.bolt,
      text: l10n.whatsNewBanner(newest),
      actions: [
        (
          l10n.whatsNewOpen,
          () {
            seen();
            context.go(AppRoutes.settingsPage(SettingsPage.changelog));
          },
        ),
        (l10n.promptNotNow, seen),
      ],
    );
  }
}
