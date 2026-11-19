import 'package:dottoday/data/scheduling/day_room_providers.dart';
import 'package:dottoday/domain/quick_add/quick_add_parser.dart';
import 'package:dottoday/features/task_editor/add/add_save.dart';
import 'package:dottoday/features/task_editor/add/state/add_flow.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Create task and the popover's Add (and Return on the title): the typed
/// time, else the first free slot (docs/10 §6), unless "@inbox" was
/// typed; a pasted list goes to [submitMany]. On success Add closes; on
/// failure it stays or reopens as it was (ED-152 rule 1, M8.5b).
Future<void> submitAdd(
  BuildContext context,
  WidgetRef ref,
  AddRequest request,
) async {
  final state = ref.read(addFlowProvider(request)).value;
  if (state == null) return;
  if (QuickAddParser.lines(state.text).length > 1) {
    return submitMany(context, ref, request);
  }
  var draft = currentDraft(ref, request, state);
  if (draft.startMinute == null && !draft.inbox) {
    final room = await ref.read(dayRoomProvider(draft.day).future);
    draft = draft.withStartUtc(
      firstFreeStart(room, draft),
      snap: room.snapMinutes,
    );
  }
  if (!context.mounted) return;
  await saveFromSheet(context, request, draft);
}

/// Every line of a pasted list (R-07), after "Add 3 tasks?".
Future<void> submitMany(
  BuildContext context,
  WidgetRef ref,
  AddRequest request,
) {
  final text = ref.read(addFlowProvider(request)).value?.text ?? '';
  return addManyFromSheet(context, request, text);
}

/// Add to Inbox instead: no time, whatever was typed.
Future<void> submitInbox(
  BuildContext context,
  WidgetRef ref,
  AddRequest request,
) async {
  final state = ref.read(addFlowProvider(request)).value;
  if (state == null) return;
  await saveFromSheet(
    context,
    request,
    currentDraft(ref, request, state),
    toInbox: true,
  );
}

/// Try again: the save that failed, with the draft as it is now.
Future<void> retryAdd(
  BuildContext context,
  WidgetRef ref,
  AddRequest request,
  AddRetry retry,
) => switch (retry) {
  AddRetry.inbox => submitInbox(context, ref, request),
  AddRetry.many => submitMany(context, ref, request),
  AddRetry.save || AddRetry.another => submitAdd(context, ref, request),
};
