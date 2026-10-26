import 'dart:async';

import 'package:dottoday/core/clock/clock_provider.dart';
import 'package:dottoday/core/failures/failure_messages.dart';
import 'package:dottoday/core/failures/result.dart';
import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/data/profile/settings_actions.dart';
import 'package:dottoday/domain/entities/settings.dart';
import 'package:dottoday/domain/scheduling/low_energy.dart';
import 'package:dottoday/shared/settings/settings_group.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Settings › Planning › Low-energy mode (11 D2, docs/09 M12.2): the same
/// switch as Today's ⋯; on until the next Wake Up.
class LowEnergyRow extends ConsumerWidget {
  const LowEnergyRow({required this.settings, super.key});

  final Settings settings;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = DotTheme.of(context);
    final l10n = context.l10n;
    final now = ref.watch(clockProvider).nowUtc();
    return SettingsRow(
      glyph: DotGlyphs.moon,
      tint: t.tasks[TaskColor.violet].ink,
      title: l10n.lowEnergyMode,
      subtitle: l10n.settingsLowEnergyDetail,
      toggle: lowEnergyOn(settings, now),
      onToggle: (on) {
        final messenger = ScaffoldMessenger.of(context);
        unawaited(
          setLowEnergy(ProviderScope.containerOf(context), on: on).then((r) {
            if (r case Err(:final failure)) {
              messenger.showSnackBar(
                SnackBar(content: Text(failureMessage(l10n, failure))),
              );
            }
          }),
        );
      },
    );
  }
}
