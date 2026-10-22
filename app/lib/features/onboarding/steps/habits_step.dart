import 'dart:async';

import 'package:dottoday/core/clock/clock_provider.dart';
import 'package:dottoday/core/failures/failure_messages.dart';
import 'package:dottoday/core/failures/result.dart';
import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/data/onboarding/onboarding_actions.dart';
import 'package:dottoday/data/profile/profile_providers.dart';
import 'package:dottoday/domain/entities/enums.dart';
import 'package:dottoday/domain/onboarding/starter_habits.dart';
import 'package:dottoday/domain/time/day_shape.dart';
import 'package:dottoday/features/onboarding/steps/step_frame.dart';
import 'package:dottoday/shared/dot/task_dot.dart';
import 'package:dottoday/shared/duration/duration_chips.dart';
import 'package:dottoday/shared/time/time_labels.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timezone/timezone.dart' as tz;

/// The starter habit's title in the user's language.
String starterTitle(AppLocalizations l10n, StarterHabit h) => switch (h) {
  StarterHabit.morningRun => l10n.starterMorningRun,
  StarterHabit.deepWork => l10n.starterDeepWork,
  StarterHabit.lunch => l10n.starterLunch,
  StarterHabit.walk => l10n.starterWalk,
  StarterHabit.gym => l10n.starterGym,
  StarterHabit.read => l10n.starterRead,
  StarterHabit.planTomorrow => l10n.starterPlanTomorrow,
};

/// O3 Habits (docs/10 §5.1, docs/09 M4.3; skippable): pick up to five
/// starters, each shown at its time tomorrow; "Add 3 to tomorrow" puts
/// them on tomorrow's thread (one write).
class HabitsStep extends ConsumerStatefulWidget {
  const HabitsStep({required this.onNext, super.key});

  final VoidCallback onNext;

  @override
  ConsumerState<HabitsStep> createState() => _HabitsStepState();
}

/// A leaf: only the picked set.
class _HabitsStepState extends ConsumerState<HabitsStep> {
  final _picked = <StarterHabit>{};

  Future<void> _add() async {
    final l10n = context.l10n;
    final messenger = ScaffoldMessenger.of(context);
    final result = await plantStarters(
      ProviderScope.containerOf(context, listen: false),
      {..._picked},
      (h) => starterTitle(l10n, h),
    );
    if (result case Err(:final failure)) {
      // Stay on the step: nothing was added.
      messenger.showSnackBar(
        SnackBar(content: Text(failureMessage(l10n, failure))),
      );
      return;
    }
    widget.onNext();
  }

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final l10n = context.l10n;
    final full = _picked.length >= maxStarters;
    final count = _picked.length;
    return StepFrame(
      title: l10n.onboardingHabitsTitle,
      body: l10n.onboardingHabitsBody,
      primary: count == 0
          ? l10n.onboardingContinue
          : l10n.onboardingHabitsAdd(count),
      onPrimary: count == 0 ? widget.onNext : () => unawaited(_add()),
      children: [
        for (final h in StarterHabit.values)
          _Row(
            habit: h,
            meta: _meta(context, h),
            picked: _picked.contains(h),
            onChanged: full && !_picked.contains(h)
                ? null
                : (on) =>
                      setState(() => on ? _picked.add(h) : _picked.remove(h)),
          ),
        if (full) Text(l10n.onboardingHabitsMax, style: t.styles.rowMeta),
      ],
    );
  }

  /// "7:30 AM · 30 min": where it would land tomorrow.
  String _meta(BuildContext context, StarterHabit h) {
    final l10n = context.l10n;
    final length = formatDurationShort(l10n, h.durationMin);
    final profile = ref.watch(currentProfileProvider).value;
    if (profile == null) return length;
    final zone = tz.getLocation(profile.tzId);
    final local = tz.TZDateTime.from(ref.watch(clockProvider).nowUtc(), zone);
    final tomorrow = DateTime(local.year, local.month, local.day + 1);
    final shape = DayShape.on(
      zone,
      tomorrow,
      profile.settings.boundaryFor(Weekday.values[tomorrow.weekday - 1]),
    );
    final time = timeOfUtc(
      context,
      zone,
      h.startOn(shape, zone),
      use24h: use24hFor(context, profile.settings.use24h),
    );
    return l10n.onboardingHabitMeta(time, length);
  }
}

class _Row extends StatelessWidget {
  const _Row({
    required this.habit,
    required this.meta,
    required this.picked,
    required this.onChanged,
  });

  final StarterHabit habit;
  final String meta;
  final bool picked;
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final title = starterTitle(context.l10n, habit);
    return CheckboxListTile(
      value: picked,
      onChanged: onChanged == null ? null : (v) => onChanged!(v ?? false),
      contentPadding: EdgeInsets.zero,
      secondary: TaskDot(
        color: TaskColor.fromKey(habit.colorKey),
        icon: TaskIcon.fromKey(habit.iconKey),
        state: DotState.upcoming,
        label: title,
      ),
      title: Text(title, style: t.styles.rowTitle),
      subtitle: Text(meta, style: t.styles.rowMeta),
    );
  }
}
