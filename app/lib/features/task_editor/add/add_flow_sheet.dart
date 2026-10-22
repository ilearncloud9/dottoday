import 'dart:async';

import 'package:dottoday/data/profile/profile_providers.dart';
import 'package:dottoday/data/scheduling/day_room_providers.dart';
import 'package:dottoday/features/task_editor/add/add_save.dart';
import 'package:dottoday/features/task_editor/add/add_when_host.dart';
import 'package:dottoday/features/task_editor/add/state/add_flow.dart';
import 'package:dottoday/features/task_editor/add/widgets/add_header.dart';
import 'package:dottoday/features/task_editor/add/widgets/add_what_step.dart';
import 'package:dottoday/shared/sheets/app_sheet.dart';
import 'package:dottoday/shared/time/time_labels.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Opens Add (docs/10 §3 `AddFlow`) from the add button or ⌘N: a sheet on
/// phones, a popover from medium width (the Mac/web editor panel is
/// M3e.5). [text] prefills the title, [startUtc] the time and [day] the
/// day.
Future<void> showAddFlow(
  BuildContext context, {
  String text = '',
  DateTime? startUtc,
  DateTime? day,
}) {
  final request = AddRequest(
    languageCode: Localizations.localeOf(context).languageCode,
    text: text,
    startUtc: startUtc,
    day: day,
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
            AddStep.when => AddWhenHost(request: request, state: state),
          },
        ),
      ],
    );
  }
}

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
      saveFromSheet(
        context,
        currentDraft(ref, request, state),
        toInbox: toInbox,
      ),
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
      onAnother: () => unawaited(_another(context, ref)),
      onAddMany: () => unawaited(
        addManyFromSheet(
          context,
          ref.read(addFlowProvider(request)).value?.text ?? state.text,
          languageCode: request.languageCode,
        ),
      ),
      onContinue: () => unawaited(_continue(ref)),
      onInbox: () => save(toInbox: true),
    );
  }

  /// Shift+Enter: add this one, keep the sheet, start the next where it
  /// ends.
  Future<void> _another(BuildContext context, WidgetRef ref) async {
    final draft = currentDraft(ref, request, state);
    final saved = await saveFromSheet(context, draft, close: false);
    if (saved) ref.read(addFlowProvider(request).notifier).another(draft);
  }

  /// To When; with no time yet, start in the first free slot of the day
  /// (docs/10 §6 "Add never asks for what it can infer").
  Future<void> _continue(WidgetRef ref) async {
    final notifier = ref.read(addFlowProvider(request).notifier);
    final draft = currentDraft(ref, request, state);
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
