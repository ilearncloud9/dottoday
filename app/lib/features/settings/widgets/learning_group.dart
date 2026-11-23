import 'dart:math' as math;

import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/data/scheduling/learning_providers.dart';
import 'package:dottoday/domain/entities/settings.dart';
import 'package:dottoday/domain/scheduling/learning_thresholds.dart';
import 'package:dottoday/features/settings/widgets/energy_row.dart';
import 'package:dottoday/shared/settings/settings_group.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// LEARNING (docs/13 §4.1, E-R2-23 §4): what Dottoday is learning, said
/// from day one, how far along each feature is ("6/10", "Ready for 12
/// tasks"), and the privacy line. The reality thread
/// and energy count to one threshold; lengths reveal per task and step, so
/// they count what is ready instead.
class LearningGroup extends ConsumerWidget {
  const LearningGroup({required this.settings, super.key});

  final Settings settings;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = DotTheme.of(context);
    final l10n = context.l10n;
    final th = ref.watch(learningThresholdsProvider);
    final p = ref.watch(learningProgressProvider).value;
    return SettingsGroup(
      caption: l10n.settingsLearning,
      footer: l10n.settingsLearningPrivacy,
      children: [
        _reality(context, t, th, p),
        SettingsRow(
          glyph: DotGlyphs.clock,
          tint: t.colors.accentInk,
          title: l10n.settingsLearningDurations,
          subtitle:
              _ready(p?.tasksReady, l10n.settingsLearningTasksReady) ??
              l10n.settingsLearningDurationsPending(th.taskMinSamples),
        ),
        SettingsRow(
          glyph: DotGlyphs.stepLines,
          tint: t.tasks[TaskColor.violet].ink,
          title: l10n.settingsLearningSteps,
          subtitle:
              _ready(p?.stepsReady, l10n.settingsLearningStepsReady) ??
              l10n.settingsLearningStepsPending(th.stepMinSamples),
        ),
        EnergyRow(settings: settings),
      ],
    );
  }

  Widget _reality(
    BuildContext context,
    DotTheme t,
    LearningThresholds th,
    LearningProgress? p,
  ) {
    final l10n = context.l10n;
    final total = th.realityMinRuns;
    if (p?.realityRevealed ?? false) {
      return SettingsRow(
        glyph: DotGlyphs.review,
        tint: t.colors.accentInk,
        title: l10n.settingsLearningReality,
        subtitle: l10n.settingsLearningRealityReady,
      );
    }
    final done = math.min(p?.realityRuns ?? 0, total);
    // "6/10" at the row's end (E-R2-23 §4), read as a sentence.
    return SettingsRow(
      glyph: DotGlyphs.review,
      tint: t.colors.accentInk,
      title: l10n.settingsLearningReality,
      subtitle: l10n.settingsLearningRealityPending(total),
      trailing: Semantics(
        label: l10n.settingsLearningProgressLabel(done, total),
        excludeSemantics: true,
        child: Text(
          l10n.settingsLearningProgress(done, total),
          style: t.styles.body.copyWith(color: t.colors.muted),
        ),
      ),
    );
  }

  /// "Ready for 3 tasks" once any is ready; null until then, so the row
  /// keeps saying how it learns.
  static String? _ready(int? count, String Function(int) text) =>
      count == null || count == 0 ? null : text(count);
}
