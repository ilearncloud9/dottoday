import 'dart:async';

import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/data/profile/profile_providers.dart';
import 'package:dottoday/data/profile/settings_actions.dart';
import 'package:dottoday/data/scheduling/day_room_providers.dart';
import 'package:dottoday/domain/quick_add/add_draft.dart';
import 'package:dottoday/domain/scheduling/inbox_plan.dart';
import 'package:dottoday/domain/time/duration_presets.dart';
import 'package:dottoday/features/task_editor/add/add_save.dart';
import 'package:dottoday/features/task_editor/add/state/add_flow.dart';
import 'package:dottoday/features/task_editor/add/widgets/add_header.dart';
import 'package:dottoday/features/task_editor/add/widgets/add_what_step.dart';
import 'package:dottoday/features/task_editor/add/widgets/add_when_step.dart';
import 'package:dottoday/shared/dot/round_more_button.dart';
import 'package:dottoday/shared/duration/duration_preview.dart';
import 'package:dottoday/shared/duration/duration_sheet.dart';
import 'package:dottoday/shared/sheets/app_sheet.dart';
import 'package:dottoday/shared/time/time_labels.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timezone/timezone.dart' as tz;

/// Opens Add (docs/10 §3 `AddFlow`) from the add button or ⌘N: a sheet on
/// phones, a popover from medium width (the Mac/web editor panel is
/// M3e.5). [text] prefills the title.
Future<void> showAddFlow(BuildContext context, {String text = ''}) {
  final request = AddRequest(
    languageCode: Localizations.localeOf(context).languageCode,
    text: text,
  );
  return showAppSheet<void>(
    context: context,
    fullHeight: true,
    builder: (_) => AddFlowSheet(request: request),
  );
}

/// The Add sheet's content: header and the current step.
class AddFlowSheet extends ConsumerWidget {
  const AddFlowSheet({required this.request, super.key});

  final AddRequest request;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(addFlowProvider(request)).value;
    if (state == null) return const SizedBox.shrink();
    final notifier = ref.read(addFlowProvider(request).notifier);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AddHeader(step: state.step, onBack: () => notifier.goTo(AddStep.what)),
        Expanded(
          child: switch (state.step) {
            AddStep.what => _What(request: request, state: state),
            AddStep.when => _When(request: request, state: state),
          },
        ),
      ],
    );
  }
}

/// The draft as it is now: Enter can arrive before the frame that rebuilt
/// the callbacks with the last keystroke.
AddDraft _current(WidgetRef ref, AddRequest request, AddFlowState shown) =>
    ref.read(addFlowProvider(request)).value?.draft ?? shown.draft;

class _What extends ConsumerWidget {
  const _What({required this.request, required this.state});

  final AddRequest request;
  final AddFlowState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(addFlowProvider(request).notifier);
    final settings = ref.watch(currentProfileProvider).value?.settings;
    // Warm and alive for Continue's first-free-slot lookup.
    ref.watch(dayRoomProvider(state.draft.day));
    void save({bool toInbox = false}) => unawaited(
      saveFromSheet(context, _current(ref, request, state), toInbox: toInbox),
    );
    return AddWhatStep(
      state: state,
      habits: ref.watch(habitsProvider).value ?? const [],
      use24h: use24hFor(context, settings?.use24h),
      onType: notifier.type,
      onPickHabit: notifier.pickHabit,
      onColor: (c) => notifier.edit((d) => d.withColor(c.key)),
      onIcon: (i) => notifier.edit((d) => d.withIcon(i.key)),
      onSubmit: save,
      onContinue: () => unawaited(_continue(ref)),
      onInbox: () => save(toInbox: true),
    );
  }

  /// To When; with no time yet, start in the first free slot of the day
  /// (docs/10 §6 "Add never asks for what it can infer").
  Future<void> _continue(WidgetRef ref) async {
    final notifier = ref.read(addFlowProvider(request).notifier);
    final draft = _current(ref, request, state);
    if (draft.startMinute == null) {
      final room = await ref.read(dayRoomProvider(draft.day).future);
      final slot = room.slotsFor(draft.length).firstOrNull;
      // No room left: now on today, Wake Up on a later day.
      final from =
          slot?.startUtc ??
          (room.fromUtc.isAfter(room.startUtc) ? room.fromUtc : room.startUtc);
      notifier.edit((d) => d.withStartUtc(from, snap: room.snapMinutes));
    }
    notifier.goTo(AddStep.when);
  }
}

class _When extends ConsumerWidget {
  const _When({required this.request, required this.state});

  final AddRequest request;
  final AddFlowState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(addFlowProvider(request).notifier);
    final settings = ref.watch(currentProfileProvider).value?.settings;
    final room = ref.watch(dayRoomProvider(state.draft.day)).value;
    if (room == null || state.draft.startUtc == null) {
      return const SizedBox.shrink();
    }
    return AddWhenStep(
      state: state,
      room: room,
      presets: settings?.durationPresets ?? defaultDurationPresets,
      use24h: use24hFor(context, settings?.use24h),
      snapMinutes: settings?.snapMinutes ?? 5,
      onStart: (m) => notifier.edit((d) => d.withStartMinute(m)),
      onDuration: (m) => notifier.edit((d) => d.withDuration(m)),
      onAdd: () =>
          unawaited(saveFromSheet(context, _current(ref, request, state))),
      onAnother: () => unawaited(_another(context, ref)),
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
    final draft = _current(ref, request, state);
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

  Future<void> _another(BuildContext context, WidgetRef ref) async {
    final notifier = ref.read(addFlowProvider(request).notifier);
    final draft = _current(ref, request, state);
    final saved = await saveFromSheet(context, draft, close: false);
    if (saved) notifier.another(draft);
  }
}
