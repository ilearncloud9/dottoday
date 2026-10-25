import 'dart:async';

import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/data/calendar/write_back_providers.dart';
import 'package:dottoday/domain/calendar/write_back_merge.dart';
import 'package:dottoday/shared/feedback/banner_strip.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// A strip above every screen when edits of imported events didn't reach
/// their calendar (docs/02 F5 "failures surface as a non-blocking banner
/// with retry", docs/09 M7.3): events changed on both sides first, with
/// Keep mine / Use calendar's, then the ones to try again. Nothing is
/// lost meanwhile: the edit stays here either way (R-08).
class WriteBackBanner extends ConsumerWidget {
  const WriteBackBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final state = ref.watch(writeBackControllerProvider);
    final controller = ref.read(writeBackControllerProvider.notifier);
    if (state.clashes > 0) {
      return BannerStrip(
        glyph: DotGlyphs.calendar,
        text: l10n.bannerWriteBackClash(state.clashes),
        actions: [
          (
            l10n.syncKeepMine,
            () => unawaited(controller.resolve(WriteBackPrefer.mine)),
          ),
          (
            l10n.bannerUseCalendars,
            () => unawaited(controller.resolve(WriteBackPrefer.calendar)),
          ),
        ],
      );
    }
    if (state.failed > 0) {
      return BannerStrip(
        glyph: DotGlyphs.calendar,
        text: l10n.bannerWriteBackPending(state.failed),
        actions: [(l10n.stateRetry, () => unawaited(controller.retry()))],
      );
    }
    return const SizedBox.shrink();
  }
}
