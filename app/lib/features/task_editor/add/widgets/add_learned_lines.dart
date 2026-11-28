import 'package:dottoday/core/clock/clock_provider.dart';
import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/data/layout/layout_providers.dart';
import 'package:dottoday/data/profile/profile_providers.dart';
import 'package:dottoday/data/scheduling/day_room_providers.dart';
import 'package:dottoday/data/scheduling/learning_meta.dart';
import 'package:dottoday/data/scheduling/learning_providers.dart';
import 'package:dottoday/domain/entities/settings.dart';
import 'package:dottoday/domain/layout/feature_id.dart';
import 'package:dottoday/domain/layout/layout_policy.dart';
import 'package:dottoday/domain/scheduling/energy_window.dart';
import 'package:dottoday/domain/scheduling/learning_thresholds.dart';
import 'package:dottoday/domain/time/clock_time.dart';
import 'package:dottoday/features/task_editor/add/state/add_flow.dart';
import 'package:dottoday/features/task_editor/add/widgets/add_energy_hint.dart';
import 'package:dottoday/shared/duration/duration_chips.dart';
import 'package:dottoday/shared/learning/learned_line.dart';
import 'package:dottoday/shared/time/time_labels.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timezone/timezone.dart' as tz;

/// [energy]'s window when Add should suggest it for [title] (11 C4,
/// M11.5): suggestions on, enough runs, and a task of that kind.
EnergyWindow? energyFor(
  ({EnergyWindow? window, int completions})? energy,
  Settings? settings,
  String title,
  LearningThresholds thresholds,
) {
  final w = energy?.window;
  if (w == null || settings == null || title.isEmpty) return null;
  final on = energySuggestionsOn(
    settings,
    completions: energy!.completions,
    thresholds: thresholds,
  );
  return on && w.knows(title) ? w : null;
}

/// What Add learned, under the time (owner, M19.3 part 3b): "usually
/// 1 h 20" (docs/13 §6), "usually starts ~15 min after plan" (11 C3), and
/// the high-energy window with Try (11 C4). Each line only when it
/// applies; nothing at all for a new title. Create task and the popover
/// show it; Minimal's When step keeps its own lines, with C4 off.
class AddLearnedLines extends ConsumerWidget {
  const AddLearnedLines({required this.request, super.key});

  final AddRequest request;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(addFlowProvider(request)).value;
    final profile = ref.watch(currentProfileProvider).value;
    if (state == null || profile == null) return const SizedBox.shrink();
    final draft = currentDraft(ref, request, state);
    final thresholds = ref.watch(learningThresholdsProvider);
    final l10n = context.l10n;
    LearnedExplanation why(int samples) => LearnedExplanation.perTitle(
      l10n,
      samples: samples,
      title: draft.title,
      // docs/13 §6: clears what this title taught, on this device.
      reset: () => ref
          .read(learningMetaProvider.notifier)
          .resetUndoable(draft.title, ref.read(clockProvider).nowUtc()),
    );
    final learned = draft.learned;
    final offset = learned.startOffsetMinutes;
    final lines = [
      if (learned.usualMinutes case final usual?)
        _line(
          context,
          l10n.learnUsually(formatDurationShort(l10n, usual)),
          why(learned.samples),
        ),
      if (offset != null && offset.abs() >= thresholds.tendencyFromMinutes)
        _line(
          context,
          offset > 0
              ? l10n.learnStartsAfter(offset)
              : l10n.learnStartsBefore(-offset),
          why(learned.offsetSamples),
        ),
      ?_energy(context, ref, draft.title),
    ];
    if (lines.isEmpty) return const SizedBox.shrink();
    // Its own gap, so an empty one takes no room in its parent.
    return Padding(
      padding: const EdgeInsets.only(top: DotSpace.s),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: DotSpace.xs,
        children: lines,
      ),
    );
  }

  Widget _line(BuildContext context, String text, LearnedExplanation why) {
    final t = DotTheme.of(context);
    return LearnedLine(
      text: text,
      explanation: why,
      style: t.styles.rowMeta.copyWith(color: t.colors.secondary),
    );
  }

  /// The energy window and Try, at the typed time or the first free slot.
  Widget? _energy(BuildContext context, WidgetRef ref, String title) {
    final profile = ref.watch(currentProfileProvider).value!;
    // C4's own switch: Off in Minimal (docs/14 §3); never written.
    final off =
        watchFeature(ref, FeatureId.energySuggestions) == FeatureVisibility.off;
    final w = energyFor(
      ref.watch(energyWindowProvider).value,
      off
          ? profile.settings.copyWith(energySuggestions: false)
          : profile.settings,
      title,
      ref.watch(learningThresholdsProvider),
    );
    if (w == null) return null;
    final state = ref.watch(addFlowProvider(request)).value!;
    final draft = currentDraft(ref, request, state);
    final room = ref.watch(dayRoomProvider(draft.day)).value;
    final start =
        draft.startUtc ?? (room == null ? null : firstFreeStart(room, draft));
    if (start == null) return null;
    final zone = tz.getLocation(profile.tzId);
    return AddEnergyHint(
      window: w,
      text: DayTimeText(
        context,
        zone,
        draft.day,
        use24h: use24hFor(context, profile.settings.use24h),
      ),
      startMinute: ClockTime.ofUtc(zone, start).minutesOfDay,
      onStart: (m) => ref
          .read(addFlowProvider(request).notifier)
          .edit((d) => d.withStartMinute(m)),
    );
  }
}
