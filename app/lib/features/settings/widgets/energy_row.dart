import 'dart:math' as math;

import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/data/scheduling/learning_providers.dart';
import 'package:dottoday/domain/entities/settings.dart';
import 'package:dottoday/features/settings/widgets/learning_status.dart';
import 'package:dottoday/features/settings/widgets/settings_change.dart';
import 'package:dottoday/shared/settings/settings_group.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Settings › Learning › Energy suggestions (11 C4, docs/13 §3): off and
/// locked with its progress until [LearningThresholds.energyMinCompletions]
/// high-energy tasks were finished with real times; then available but
/// still off ("ready — based on 20 completed tasks") until the user turns
/// it on.
class EnergyRow extends ConsumerWidget {
  const EnergyRow({required this.settings, super.key});

  final Settings settings;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = DotTheme.of(context);
    final l10n = context.l10n;
    final total = ref.watch(learningThresholdsProvider).energyMinCompletions;
    final done = ref.watch(energyWindowProvider).value?.completions ?? 0;
    final ready = done >= total;
    final on = ready && settings.energySuggestions == true;
    final shown = math.min(done, total);
    return SettingsRow(
      glyph: DotGlyphs.bolt,
      tint: t.tasks[TaskColor.amber].ink,
      title: l10n.settingsEnergy,
      subtitle: switch ((ready, on)) {
        (false, _) => l10n.settingsEnergyLocked(total, done),
        (true, false) => l10n.settingsEnergyReady(done),
        (true, true) => l10n.settingsEnergyDetail,
      },
      below: ready
          ? null
          : LearningStatus(
              text: l10n.settingsLearningProgress(shown, total),
              done: shown,
              of: total,
              label: l10n.settingsLearningProgressLabel(shown, total),
            ),
      toggle: on,
      onToggle: ready
          ? (v) =>
                changeSettings(context, (s) => s.copyWith(energySuggestions: v))
          : null,
    );
  }
}
