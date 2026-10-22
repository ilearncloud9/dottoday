import 'dart:async';

import 'package:dottoday/core/failures/app_failure.dart';
import 'package:dottoday/core/failures/failure_messages.dart';
import 'package:dottoday/core/failures/result.dart';
import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/data/profile/profile_providers.dart';
import 'package:dottoday/data/trash/trash_providers.dart';
import 'package:dottoday/domain/quick_add/add_draft.dart';
import 'package:dottoday/features/task_editor/add/state/add_actions.dart';
import 'package:dottoday/features/task_editor/add/state/add_flow.dart';
import 'package:dottoday/features/task_editor/add/widgets/add_header.dart';
import 'package:dottoday/features/task_editor/add/widgets/add_what_step.dart';
import 'package:dottoday/shared/feedback/undo_snackbar.dart';
import 'package:dottoday/shared/sheets/app_sheet.dart';
import 'package:dottoday/shared/time/time_labels.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
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
    final flow = ref.watch(addFlowProvider(request));
    final habits = ref.watch(habitsProvider).value ?? const [];
    final settings = ref.watch(currentProfileProvider).value?.settings;
    final use24h = use24hFor(context, settings?.use24h);
    final notifier = ref.read(addFlowProvider(request).notifier);
    final state = flow.value;
    if (state == null) return const SizedBox.shrink();
    // Reads the draft at call time: Enter can arrive before the frame that
    // rebuilt these callbacks with the last keystroke.
    void save({bool toInbox = false}) => unawaited(
      _save(
        context,
        ref.read(addFlowProvider(request)).value?.draft ?? state.draft,
        toInbox: toInbox,
      ),
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AddHeader(step: state.step, onBack: () => notifier.goTo(AddStep.what)),
        Expanded(
          child: AddWhatStep(
            state: state,
            habits: habits,
            use24h: use24h,
            onType: notifier.type,
            onPickHabit: notifier.pickHabit,
            onColor: (c) => notifier.edit((d) => d.withColor(c.key)),
            onIcon: (i) => notifier.edit((d) => d.withIcon(i.key)),
            onSubmit: save,
            // The When step lands in M3c.2; until then Continue adds.
            onContinue: save,
            onInbox: () => save(toInbox: true),
          ),
        ),
      ],
    );
  }
}

/// Closes the sheet at once and writes [draft] (docs/02 F2 "Saving is
/// optimistic"), then confirms with Undo (R-11).
Future<void> _save(
  BuildContext context,
  AddDraft draft, {
  required bool toInbox,
}) async {
  final container = ProviderScope.containerOf(context);
  final messenger = ScaffoldMessenger.of(context);
  final l10n = context.l10n;
  final locale = Localizations.localeOf(context).toLanguageTag();
  final use24h = use24hFor(
    context,
    container.read(currentProfileProvider).value?.settings.use24h,
  );
  final when = draft.startUtc == null
      ? null
      : _whenText(context, draft, locale: locale, use24h: use24h);
  Navigator.of(context).pop();
  final result = await saveDraft(
    container,
    draft,
    untitled: l10n.inboxUntitled,
    toInbox: toInbox,
  );
  _confirm(container, messenger, l10n, result, when: when);
}

/// "Pay rent added for 5:00 PM" with Undo, or the failure (R-11).
void _confirm(
  ProviderContainer container,
  ScaffoldMessengerState messenger,
  AppLocalizations l10n,
  Result<AddedTask, AppFailure> result, {
  required String? when,
}) {
  switch (result) {
    case Ok(:final value):
      final o = value.rows.occurrence;
      final title = o?.title ?? value.rows.series?.title ?? '';
      final message = (o?.isInbox ?? false) || when == null
          ? l10n.snackAddedInbox(1, title)
          : l10n.snackAddedTimed(title, when);
      final token = value.token;
      if (token == null) {
        messenger.showSnackBar(SnackBar(content: Text(message)));
        return;
      }
      final undo = container.read(undoServiceProvider);
      showUndoSnackbarOn(
        messenger,
        l10n,
        message: message,
        onUndo: () => unawaited(undo.undo(token)),
      );
    case Err(:final failure):
      messenger.showSnackBar(
        SnackBar(content: Text(failureMessage(l10n, failure))),
      );
  }
}

/// "5:00 PM" today, else "Thu, Oct 23, 5:00 PM".
String _whenText(
  BuildContext context,
  AddDraft draft, {
  required String locale,
  required bool use24h,
}) {
  final time = timeOfUtc(
    context,
    tz.getLocation(draft.tzId),
    draft.startUtc!,
    use24h: use24h,
  );
  if (draft.day == draft.today) return time;
  final day = DateFormat.MMMEd(locale).format(draft.day);
  return context.l10n.addWhenOnDay(day, time);
}
