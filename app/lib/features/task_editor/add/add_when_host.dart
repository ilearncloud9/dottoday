import 'dart:async';

import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/data/profile/profile_providers.dart';
import 'package:dottoday/data/profile/settings_actions.dart';
import 'package:dottoday/data/schedule/planned_colors.dart';
import 'package:dottoday/data/scheduling/day_room_providers.dart';
import 'package:dottoday/data/scheduling/learning_providers.dart';
import 'package:dottoday/domain/entities/settings.dart';
import 'package:dottoday/domain/quick_add/add_draft.dart';
import 'package:dottoday/domain/scheduling/energy_window.dart';
import 'package:dottoday/domain/scheduling/inbox_plan.dart';
import 'package:dottoday/domain/scheduling/learning_thresholds.dart';
import 'package:dottoday/domain/time/clock_time.dart';
import 'package:dottoday/domain/time/duration_presets.dart';
import 'package:dottoday/features/task_editor/add/add_save.dart';
import 'package:dottoday/features/task_editor/add/state/add_flow.dart';
import 'package:dottoday/features/task_editor/add/widgets/add_when_step.dart';
import 'package:dottoday/features/task_editor/add/widgets/time_menu.dart';
import 'package:dottoday/features/task_editor/add/widgets/type_time_sheet.dart';
import 'package:dottoday/shared/dot/round_more_button.dart';
import 'package:dottoday/shared/duration/duration_preview.dart';
import 'package:dottoday/shared/duration/duration_sheet.dart';
import 'package:dottoday/shared/pickers/day_pickers.dart';
import 'package:dottoday/shared/pickers/zone_picker.dart';
import 'package:dottoday/shared/time/time_labels.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timezone/timezone.dart' as tz;

/// The energy window to suggest for the draft (11 C4, M11.5): only when
/// suggestions are on and the title is one of the user's high-energy
/// tasks.
EnergyWindow? _energyFor(
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

/// Step 2 wired to the flow: the day's room, presets, the TIME and
/// DURATION ⋯, Add / Add another.
class AddWhenHost extends ConsumerWidget {
  const AddWhenHost({required this.request, required this.state, super.key});

  final AddRequest request;
  final AddFlowState state;

  EnergyWindow? _energy(WidgetRef ref) => _energyFor(
    ref.watch(energyWindowProvider).value,
    ref.watch(currentProfileProvider).value?.settings,
    state.draft.title,
    ref.watch(learningThresholdsProvider),
  );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(addFlowProvider(request).notifier);
    final settings = ref.watch(currentProfileProvider).value?.settings;
    final room = ref.watch(dayRoomProvider(state.draft.day)).value;
    if (room == null || state.draft.startUtc == null) {
      return const SizedBox.shrink();
    }
    return AddWhenStep(
      energy: _energy(ref),
      thresholds: ref.watch(learningThresholdsProvider),
      state: state,
      room: room,
      presets: settings?.durationPresets ?? defaultDurationPresets,
      use24h: use24hFor(context, settings?.use24h),
      snapMinutes: settings?.snapMinutes ?? 5,
      onStart: (m) => notifier.edit((d) => d.withStartMinute(m)),
      onDuration: (m) => notifier.edit((d) => d.withDuration(m)),
      onAdd: () => unawaited(
        saveFromSheet(context, request, currentDraft(ref, request, state)),
      ),
      onAnother: () => unawaited(
        addAnother(context, request, currentDraft(ref, request, state)),
      ),
      onEditDay: () => unawaited(_changeDay(context, ref)),
      timeMenu: TimeMenu(
        dayText: relativeDayName(context, state.draft.day, state.draft.today),
        zoneText: zoneCity(state.draft.tzId),
        allDay: state.draft.allDay,
        onChangeDay: () => unawaited(_changeDay(context, ref)),
        onPickWeek: () => unawaited(_pickWeek(context, ref)),
        onAllDay: () => notifier.edit((d) => d.withAllDay(value: !d.allDay)),
        onInbox: () => unawaited(
          saveFromSheet(
            context,
            request,
            currentDraft(ref, request, state),
            toInbox: true,
          ),
        ),
        onZone: () => unawaited(_zone(context, ref)),
        onTypeTime: () => unawaited(_typeTime(context, ref)),
      ),
      durationMenu: RoundMoreButton(
        tooltip: context.l10n.addMoreDuration,
        onTap: () => unawaited(_duration(context, ref, room)),
      ),
    );
  }

  /// The Duration sheet (A3) for the draft; presets save as they change.
  Future<void> _duration(
    BuildContext context,
    WidgetRef ref,
    DayRoom room,
  ) async {
    final container = ProviderScope.containerOf(context);
    final draft = currentDraft(ref, request, state);
    final settings = ref.read(currentProfileProvider).value?.settings;
    final text = DayTimeText(
      context,
      tz.getLocation(draft.tzId),
      draft.day,
      use24h: use24hFor(context, settings?.use24h),
    );
    final minutes = await showDurationSheet(
      context,
      initial: draft.length,
      color: TaskColor.fromKey(draft.color),
      icon: TaskIcon.fromKey(draft.icon),
      presets: settings?.durationPresets ?? defaultDurationPresets,
      onPresets: (p) => unawaited(
        updateSettings(container, (s) => s.copyWith(durationPresets: p)),
      ),
      preview: (m) => durationPreview(context, room, draft.startUtc!, m, text),
    );
    if (minutes == null) return;
    ref
        .read(addFlowProvider(request).notifier)
        .edit((d) => d.withDuration(minutes));
  }

  Future<void> _changeDay(BuildContext context, WidgetRef ref) async {
    final draft = currentDraft(ref, request, state);
    final day = await showMonthDayPicker(
      context,
      plannedFor: (m) => plannedColors(ProviderScope.containerOf(context), m),
      initial: draft.day,
      today: draft.today,
      firstDayOfWeek: _weekStart(ref),
    );
    if (day != null) _edit(ref, (d) => d.withDay(day));
  }

  Future<void> _pickWeek(BuildContext context, WidgetRef ref) async {
    final draft = currentDraft(ref, request, state);
    final day = await showWeekDayPicker(
      context,
      initial: draft.day,
      today: draft.today,
      firstDayOfWeek: _weekStart(ref),
    );
    if (day != null) _edit(ref, (d) => d.withDay(day));
  }

  Future<void> _zone(BuildContext context, WidgetRef ref) async {
    final draft = currentDraft(ref, request, state);
    final id = await showZonePicker(context, current: draft.tzId);
    if (id != null) _edit(ref, (d) => d.withZone(id));
  }

  /// "Type a time" (R-20): the shared `TimeInput`; it yields a time of
  /// day only, so the task's day never moves.
  Future<void> _typeTime(BuildContext context, WidgetRef ref) async {
    final draft = currentDraft(ref, request, state);
    final settings = ref.read(currentProfileProvider).value?.settings;
    final time = await showTypeTimeSheet(
      context,
      initial: ClockTime.fromMinutes(draft.startMinute ?? 0),
      use24h: settings?.use24h,
    );
    if (time != null) _edit(ref, (d) => d.withStartMinute(time.minutesOfDay));
  }

  int _weekStart(WidgetRef ref) =>
      ref.read(currentProfileProvider).value?.settings.firstDayOfWeek ?? 1;

  void _edit(WidgetRef ref, AddDraft Function(AddDraft) change) =>
      ref.read(addFlowProvider(request).notifier).edit(change);
}
