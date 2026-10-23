import 'dart:async';

import 'package:dottoday/core/failures/failure_messages.dart';
import 'package:dottoday/core/failures/result.dart';
import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/data/profile/zone_move_actions.dart';
import 'package:dottoday/data/trash/trash_providers.dart';
import 'package:dottoday/domain/time/time_zones.dart';
import 'package:dottoday/domain/time/zone_move.dart';
import 'package:dottoday/shared/feedback/banner_strip.dart';
import 'package:dottoday/shared/feedback/undo_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// "You're now in Berlin — keep times or shift?" (docs/07 travelling,
/// docs/09 M5.9) above every screen until the person picks; both are one
/// undoable write. Keep times is first: it is the default (07).
class ZoneBanner extends ConsumerWidget {
  const ZoneBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final zone = ref.watch(zoneMoveOfferProvider);
    if (zone == null) return const SizedBox.shrink();
    final l10n = context.l10n;
    final city = zoneCity(zone);
    void pick(ZoneMoveChoice choice) =>
        unawaited(_move(context, ref, zone, city, choice));
    return BannerStrip(
      glyph: DotGlyphs.globe,
      text: l10n.zoneBannerText(city),
      actions: [
        (l10n.zoneKeep, () => pick(ZoneMoveChoice.keepTimes)),
        (l10n.zoneShift, () => pick(ZoneMoveChoice.shift)),
      ],
    );
  }

  Future<void> _move(
    BuildContext context,
    WidgetRef ref,
    String zone,
    String city,
    ZoneMoveChoice choice,
  ) async {
    final l10n = context.l10n;
    final messenger = ScaffoldMessenger.of(context);
    final undo = ref.read(undoServiceProvider);
    final result = await moveToZone(
      ProviderScope.containerOf(context),
      newZone: zone,
      choice: choice,
    );
    switch (result) {
      case Ok(value: final token):
        showUndoSnackbarOn(
          messenger,
          l10n,
          message: choice == ZoneMoveChoice.keepTimes
              ? l10n.zoneKeptSnack(city)
              : l10n.zoneShiftedSnack(city),
          onUndo: () => undo.undo(token),
        );
      case Err(:final failure):
        messenger.showSnackBar(
          SnackBar(content: Text(failureMessage(l10n, failure))),
        );
    }
  }
}
