import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/data/scheduling/learning_providers.dart';
import 'package:dottoday/domain/entities/settings.dart';
import 'package:dottoday/domain/scheduling/energy_window.dart';
import 'package:dottoday/domain/scheduling/learning_thresholds.dart';
import 'package:dottoday/features/settings/widgets/settings_change.dart';
import 'package:dottoday/shared/settings/settings_group.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Settings › Planning › Energy suggestions (11 C4, docs/09 M11.5): off
/// and locked until [LearningThresholds.energyMinCompletions] high-energy tasks were finished
/// with real times ("· 7 so far"); then on unless the user turned it off.
class EnergyRow extends ConsumerWidget {
  const EnergyRow({required this.settings, super.key});

  final Settings settings;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = DotTheme.of(context);
    final l10n = context.l10n;
    final thresholds = ref.watch(learningThresholdsProvider);
    final done = ref.watch(energyWindowProvider).value?.completions ?? 0;
    final ready = done >= thresholds.energyMinCompletions;
    return SettingsRow(
      glyph: DotGlyphs.bolt,
      tint: t.tasks[TaskColor.amber].ink,
      title: l10n.settingsEnergy,
      subtitle: ready
          ? l10n.settingsEnergyDetail
          : l10n.settingsEnergyLocked(done),
      toggle: energySuggestionsOn(
        settings,
        completions: done,
        thresholds: thresholds,
      ),
      onToggle: ready
          ? (v) =>
                changeSettings(context, (s) => s.copyWith(energySuggestions: v))
          : null,
    );
  }
}
