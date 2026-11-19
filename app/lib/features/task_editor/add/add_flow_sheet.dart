import 'dart:async';

import 'package:dottoday/core/editing/add_anchor.dart';
import 'package:dottoday/core/editing/pending_brain_dump.dart';
import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/layout/app_layout.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/data/layout/layout_providers.dart';
import 'package:dottoday/data/profile/profile_providers.dart';
import 'package:dottoday/data/scheduling/day_room_providers.dart';
import 'package:dottoday/domain/layout/feature_id.dart';
import 'package:dottoday/domain/layout/layout_policy.dart';
import 'package:dottoday/features/task_editor/add/add_save.dart';
import 'package:dottoday/features/task_editor/add/add_when_host.dart';
import 'package:dottoday/features/task_editor/add/create/create_task_sheet.dart';
import 'package:dottoday/features/task_editor/add/popover/add_popover.dart';
import 'package:dottoday/features/task_editor/add/state/add_flow.dart';
import 'package:dottoday/features/task_editor/add/widgets/add_header.dart';
import 'package:dottoday/features/task_editor/add/widgets/add_what_step.dart';
import 'package:dottoday/shared/duration/duration_chips.dart';
import 'package:dottoday/shared/feedback/save_failure.dart';
import 'package:dottoday/shared/sheets/anchored_popover.dart';
import 'package:dottoday/shared/sheets/app_sheet.dart';
import 'package:dottoday/shared/time/time_labels.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timezone/timezone.dart' as tz;

/// Opens Add (docs/10 §3 `AddFlow`) from the add button or ⌘N: Create
/// task on phones (ED-140), the popover under the toolbar's + from medium
/// width (E-R2-36, ED-342), and Minimal's own Add sheet at every width
/// (ED-152, M19.6). [text] prefills the title, [startUtc] the time and
/// [day] the day; [resume] reopens Add whose save failed, as it was
/// (M8.5b).
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
  final minimal =
      ProviderScope.containerOf(
        context,
        listen: false,
      ).read(layoutPolicyProvider).visibility(FeatureId.addTask) ==
      FeatureVisibility.simplified;
  // AppLayout: a short landscape phone stays compact too (H1).
  final phone = AppLayout.classOf(context) == WidthClass.compact;
  if (!phone && !minimal) {
    return showAnchoredPopover<void>(
      context: context,
      anchor: AddAnchor.current(),
      width: DotSize.addPopover,
      builder: (_) => AddPopover(request: request),
    );
  }
  return showAppSheet<void>(
    context: context,
    fullHeight: true,
    builder: (_) => minimal
        ? AddFlowSheet(request: request)
        : CreateTaskSheet(request: request),
  );
}

/// Minimal's Add sheet (docs/14 §4, ED-152): the title and two chips,
/// Add and More (the When step).
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
    // Warm and alive for the first-free-slot lookup.
    final room = ref.watch(dayRoomProvider(state.draft.day)).value;
    final draft = currentDraft(ref, request, state);
    final start =
        draft.startUtc ?? (room == null ? null : firstFreeStart(room, draft));
    return AddWhatStep(
      state: state,
      whenLabel: start == null || profile == null
          ? null
          : context.l10n.addWhenChip(
              timeOfUtc(
                context,
                tz.getLocation(profile.tzId),
                start,
                use24h: use24hFor(context, profile.settings.use24h),
              ),
            ),
      lengthLabel: formatDurationShort(context.l10n, draft.length),
      onMore: () => unawaited(_more(ref)),
      onType: notifier.type,
      onRemoveToken: notifier.keepAsText,
      // Enter puts the dot on the thread, in the next free slot when no
      // time was typed (docs/14 §4).
      onSubmit: () => unawaited(_saveOnThread(context, ref)),
      onAnother: () => unawaited(
        addAnother(context, request, currentDraft(ref, request, state)),
      ),
      onAddMany: () => _toBrainDump(context, ref),
    );
  }

  /// To When; with no time yet, start in the first free slot of the day
  /// (docs/10 §6 "Add never asks for what it can infer").
  Future<void> _more(WidgetRef ref) async {
    final notifier = ref.read(addFlowProvider(request).notifier);
    final draft = currentDraft(ref, request, state);
    if (draft.startMinute == null) {
      final room = await ref.read(dayRoomProvider(draft.day).future);
      final from = firstFreeStart(room, draft);
      notifier.edit((d) => d.withStartUtc(from, snap: room.snapMinutes));
    }
    notifier.goTo(AddStep.when);
  }

  /// The save: the typed time, else the first free slot, on the thread
  /// (never the Inbox: that is what Later is for).
  Future<void> _saveOnThread(BuildContext context, WidgetRef ref) async {
    var draft = currentDraft(ref, request, state);
    if (draft.startMinute == null) {
      final room = await ref.read(dayRoomProvider(draft.day).future);
      draft = draft.withStartUtc(
        firstFreeStart(room, draft),
        snap: room.snapMinutes,
      );
    }
    if (!context.mounted) return;
    await saveFromSheet(context, request, draft);
  }

  /// Several lines: Brain dump plans them, and nothing is written before
  /// Accept (docs/14 §3 B4, CLAUDE.md §11).
  void _toBrainDump(BuildContext context, WidgetRef ref) {
    final text = ref.read(addFlowProvider(request)).value?.text ?? state.text;
    ref.read(pendingBrainDumpProvider.notifier).request(text);
    unawaited(Navigator.of(context).maybePop());
  }
}
