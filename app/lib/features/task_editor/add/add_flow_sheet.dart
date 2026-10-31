import 'dart:async';

import 'package:dottoday/core/editing/pending_brain_dump.dart';
import 'package:dottoday/core/editing/pending_routine_drop.dart';
import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/data/layout/layout_providers.dart';
import 'package:dottoday/data/profile/profile_providers.dart';
import 'package:dottoday/data/routines/routine_providers.dart';
import 'package:dottoday/data/scheduling/day_room_providers.dart';
import 'package:dottoday/domain/layout/feature_id.dart';
import 'package:dottoday/domain/quick_add/add_draft.dart';
import 'package:dottoday/domain/scheduling/inbox_plan.dart';
import 'package:dottoday/domain/validation/field_rules.dart';
import 'package:dottoday/features/task_editor/add/add_save.dart';
import 'package:dottoday/features/task_editor/add/add_when_host.dart';
import 'package:dottoday/features/task_editor/add/state/add_flow.dart';
import 'package:dottoday/features/task_editor/add/widgets/add_header.dart';
import 'package:dottoday/features/task_editor/add/widgets/add_routine_chips.dart';
import 'package:dottoday/features/task_editor/add/widgets/add_what_step.dart';
import 'package:dottoday/features/task_editor/breakdown/breakdown_flow.dart';
import 'package:dottoday/shared/duration/duration_chips.dart';
import 'package:dottoday/shared/feedback/save_failure.dart';
import 'package:dottoday/shared/sheets/app_sheet.dart';
import 'package:dottoday/shared/time/time_labels.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timezone/timezone.dart' as tz;

/// Opens Add (docs/10 §3 `AddFlow`) from the add button or ⌘N: a sheet on
/// phones, a popover from medium width (the Mac/web editor panel is
/// M3e.5). [text] prefills the title, [startUtc] the time and [day] the
/// day; [resume] reopens a sheet whose save failed, as it was (M8.5b).
Future<void> showAddFlow(
  BuildContext context, {
  String text = '',
  DateTime? startUtc,
  DateTime? day,
  AddFlowState? resume,
}) {
  final request = AddRequest(
    languageCode: Localizations.localeOf(context).languageCode,
    text: text,
    startUtc: startUtc,
    day: day,
    resume: resume,
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
        AddHeader(
          step: state.step,
          onBack: () => notifier.goTo(AddStep.what),
          // Minimal Add is one step (docs/14 §4); More is the old step 2.
          dots: !watchSimplified(ref, FeatureId.addTask),
        ),
        if (state.saveFailure case final failed?)
          SaveFailureBanner(
            failure: failed.failure,
            onRetry: () => _retry(context, ref, state, failed.retry),
          ),
        Expanded(
          child: switch (state.step) {
            AddStep.what => _What(request: request, state: state),
            AddStep.when => AddWhenHost(request: request, state: state),
          },
        ),
      ],
    );
  }

  /// Try again: the same save, with the draft as it is now.
  void _retry(
    BuildContext context,
    WidgetRef ref,
    AddFlowState state,
    AddRetry retry,
  ) {
    final draft = currentDraft(ref, request, state);
    unawaited(switch (retry) {
      AddRetry.save => saveFromSheet(context, request, draft),
      AddRetry.inbox => saveFromSheet(context, request, draft, toInbox: true),
      AddRetry.another => addAnother(context, request, draft),
      AddRetry.many => addManyFromSheet(context, request, state.text),
    });
  }
}

class _What extends ConsumerWidget {
  const _What({required this.request, required this.state});

  final AddRequest request;
  final AddFlowState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(addFlowProvider(request).notifier);
    final profile = ref.watch(currentProfileProvider).value;
    final settings = profile?.settings;
    // Warm and alive for Continue's first-free-slot lookup.
    final room = ref.watch(dayRoomProvider(state.draft.day)).value;
    final minimal = watchSimplified(ref, FeatureId.addTask);
    void save({bool toInbox = false}) => unawaited(
      saveFromSheet(
        context,
        request,
        currentDraft(ref, request, state),
        toInbox: toInbox,
      ),
    );
    final draft = currentDraft(ref, request, state);
    final start =
        draft.startUtc ?? (room == null ? null : _firstFree(room, draft));
    return AddWhatStep(
      minimal: minimal,
      whenLabel: start == null || profile == null
          ? null
          : context.l10n.addWhenChip(
              timeOfUtc(
                context,
                tz.getLocation(profile.tzId),
                start,
                use24h: use24hFor(context, settings?.use24h),
              ),
            ),
      lengthLabel: formatDurationShort(context.l10n, draft.length),
      onMore: () => unawaited(_continue(ref)),
      state: state,
      habits: ref.watch(habitsProvider).value ?? const [],
      routines: AddRoutineChips(
        routines: ref.watch(routinesProvider).value ?? const [],
        typed: state.draft.title,
        onPick: (r) {
          // The shell's host proposes it (routines are their own feature);
          // Add closes so the proposal opens over the day.
          ref
              .read(pendingRoutineDropProvider.notifier)
              .request(
                RoutineDropRequest(
                  routine: r,
                  date: state.draft.day,
                  today: state.draft.today,
                ),
              );
          unawaited(Navigator.of(context).maybePop());
        },
      ),
      use24h: use24hFor(context, settings?.use24h),
      onType: notifier.type,
      onPickHabit: notifier.pickHabit,
      onColor: (c) => notifier.edit((d) => d.withColor(c.key)),
      onIcon: (i) => notifier.edit((d) => d.withIcon(i.key)),
      // Minimal: Enter puts the dot on the thread, in the next free slot
      // when no time was typed (docs/14 §4).
      onSubmit: minimal ? () => unawaited(_saveOnThread(context, ref)) : save,
      onAnother: () => unawaited(
        addAnother(context, request, currentDraft(ref, request, state)),
      ),
      onAddMany: () => minimal
          ? _toBrainDump(context, ref)
          : unawaited(
              addManyFromSheet(
                context,
                request,
                ref.read(addFlowProvider(request)).value?.text ?? state.text,
              ),
            ),
      onContinue: () => unawaited(_continue(ref)),
      onInbox: () => save(toInbox: true),
      onBreakDown: state.draft.title.isEmpty
          ? null
          : () => unawaited(_breakDown(context, ref)),
    );
  }

  /// Break it down (M10.4): accepted steps join the draft, and its length
  /// grows to their sum; both are written with the task on Save.
  Future<void> _breakDown(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(addFlowProvider(request).notifier);
    final draft = currentDraft(ref, request, state);
    return breakDown(
      context,
      BreakdownTarget(
        title: draft.title,
        durationMin: draft.length,
        colorKey: draft.color,
        iconKey: draft.icon,
        onDraftAccepted: (steps) => notifier.edit((d) {
          final next = d.withSteps(steps);
          final total = next.stepsTotal;
          return total == null
              ? next
              : next.withDuration(total.clamp(minDurationMin, maxDurationMin));
        }),
      ),
    );
  }

  /// To When; with no time yet, start in the first free slot of the day
  /// (docs/10 §6 "Add never asks for what it can infer").
  Future<void> _continue(WidgetRef ref) async {
    final notifier = ref.read(addFlowProvider(request).notifier);
    final draft = currentDraft(ref, request, state);
    if (draft.startMinute == null) {
      final room = await ref.read(dayRoomProvider(draft.day).future);
      final from = _firstFree(room, draft);
      notifier.edit((d) => d.withStartUtc(from, snap: room.snapMinutes));
    }
    notifier.goTo(AddStep.when);
  }

  /// Minimal Add's save: the typed time, else the first free slot, on the
  /// thread (never the Inbox: that is what Later is for).
  Future<void> _saveOnThread(BuildContext context, WidgetRef ref) async {
    var draft = currentDraft(ref, request, state);
    if (draft.startMinute == null) {
      final room = await ref.read(dayRoomProvider(draft.day).future);
      draft = draft.withStartUtc(
        _firstFree(room, draft),
        snap: room.snapMinutes,
      );
    }
    if (!context.mounted) return;
    await saveFromSheet(context, request, draft);
  }

  /// Several lines in minimal Add: Brain dump plans them, and nothing is
  /// written before Accept (docs/14 §3 B4, CLAUDE.md §11).
  void _toBrainDump(BuildContext context, WidgetRef ref) {
    final text = ref.read(addFlowProvider(request)).value?.text ?? state.text;
    ref.read(pendingBrainDumpProvider.notifier).request(text);
    unawaited(Navigator.of(context).maybePop());
  }

  /// The first free slot that fits [draft]; with no room left, now on
  /// today, Wake Up on a later day.
  static DateTime _firstFree(DayRoom room, AddDraft draft) =>
      room.slotsFor(draft.length).firstOrNull?.startUtc ??
      (room.fromUtc.isAfter(room.startUtc) ? room.fromUtc : room.startUtc);
}
