import 'dart:async';

import 'package:dottoday/core/failures/failure_messages.dart';
import 'package:dottoday/core/failures/result.dart';
import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/data/profile/profile_providers.dart';
import 'package:dottoday/data/quick_add/quick_add_actions.dart';
import 'package:dottoday/data/trash/trash_providers.dart';
import 'package:dottoday/domain/quick_add/add_draft.dart';
import 'package:dottoday/domain/undo/undo_service.dart';
import 'package:dottoday/features/task_editor/add/add_flow_sheet.dart';
import 'package:dottoday/features/task_editor/add/state/add_actions.dart';
import 'package:dottoday/features/task_editor/add/state/add_flow.dart';
import 'package:dottoday/shared/feedback/undo_snackbar.dart';
import 'package:dottoday/shared/time/time_labels.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:timezone/timezone.dart' as tz;

/// Writes [draft] (docs/02 F2.10 "Saving is optimistic": with [close] the
/// sheet goes first), then confirms with Undo (R-11). A failed write
/// keeps what was typed (M8.5b, R-08): a closed sheet reopens as it was,
/// an open one shows the failure, both with Try again. Returns whether
/// it was written.
Future<bool> saveFromSheet(
  BuildContext context,
  AddRequest request,
  AddDraft draft, {
  bool toInbox = false,
  bool close = true,
}) async {
  final container = ProviderScope.containerOf(context);
  final messenger = ScaffoldMessenger.of(context);
  final navigator = Navigator.of(context);
  final l10n = context.l10n;
  final use24h = use24hFor(
    context,
    container.read(currentProfileProvider).value?.settings.use24h,
  );
  final when = draft.startUtc == null || toInbox
      ? null
      : _whenText(context, draft, use24h: use24h);
  final shown = container.read(addFlowProvider(request)).value;
  if (close) navigator.pop();
  final result = await saveDraft(
    container,
    draft,
    untitled: l10n.inboxUntitled,
    toInbox: toInbox,
  );
  switch (result) {
    case Ok(:final value):
      _confirm(container, messenger, l10n, value, when: when);
      return true;
    case Err(:final failure):
      final retry = switch ((close, toInbox)) {
        (false, _) => AddRetry.another,
        (true, true) => AddRetry.inbox,
        (true, false) => AddRetry.save,
      };
      _Kept(
        container,
        messenger,
        navigator,
        l10n,
        request,
      ).show(shown?.copyWith(draft: draft), (failure: failure, retry: retry));
      return false;
  }
}

/// Shift+Enter: adds [draft], keeps the sheet and starts the next where
/// it ends (R-07 "Add another keeps the sheet open").
Future<void> addAnother(
  BuildContext context,
  AddRequest request,
  AddDraft draft,
) async {
  final container = ProviderScope.containerOf(context);
  final notifier = container.read(addFlowProvider(request).notifier);
  final saved = await saveFromSheet(context, request, draft, close: false);
  if (saved) notifier.another(draft);
}

/// Adds every line of a pasted list (R-07) — timed lines on their day,
/// the rest in the Inbox, one Undo — then closes the sheet; it reopens
/// with the list if the write fails (M8.5b).
Future<void> addManyFromSheet(
  BuildContext context,
  AddRequest request,
  String text,
) async {
  final container = ProviderScope.containerOf(context);
  final messenger = ScaffoldMessenger.of(context);
  final navigator = Navigator.of(context);
  final l10n = context.l10n;
  final shown = container.read(addFlowProvider(request)).value;
  navigator.pop();
  final result = await addFromText(
    container,
    text,
    languageCode: request.languageCode,
    untitled: l10n.inboxUntitled,
  );
  switch (result) {
    case Ok(:final value):
      final first = value.rows.firstOrNull;
      final title = first?.occurrence?.title ?? first?.series?.title ?? '';
      _announce(
        container,
        messenger,
        l10n,
        l10n.snackAddedInbox(value.rows.length, title),
        value.token,
      );
    case Err(:final failure):
      _Kept(
        container,
        messenger,
        navigator,
        l10n,
        request,
      ).show(shown, (failure: failure, retry: AddRetry.many));
  }
}

/// Where a failed save's draft goes: back on the open sheet, or a
/// reopened one; a snackbar only when there is no sheet to hold it.
final class _Kept {
  const _Kept(
    this.container,
    this.messenger,
    this.navigator,
    this.l10n,
    this.request,
  );

  final ProviderContainer container;
  final ScaffoldMessengerState messenger;
  final NavigatorState navigator;
  final AppLocalizations l10n;
  final AddRequest request;

  void show(AddFlowState? shown, AddSaveFailure failure) {
    if (failure.retry == AddRetry.another) {
      container.read(addFlowProvider(request).notifier).failed(failure);
      return;
    }
    if (shown == null || !navigator.mounted) {
      messenger.showSnackBar(
        SnackBar(content: Text(failureMessage(l10n, failure.failure))),
      );
      return;
    }
    unawaited(
      showAddFlow(navigator.context, resume: shown.withFailure(failure)),
    );
  }
}

/// [message], with Undo when there is a [token] (a new series has none yet).
void _announce(
  ProviderContainer container,
  ScaffoldMessengerState messenger,
  AppLocalizations l10n,
  String message,
  UndoToken? token,
) {
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
}

/// "Pay rent added for 5:00 PM" with Undo.
void _confirm(
  ProviderContainer container,
  ScaffoldMessengerState messenger,
  AppLocalizations l10n,
  AddedTask added, {
  required String? when,
}) {
  final o = added.rows.occurrence;
  final title = o?.title ?? added.rows.series?.title ?? '';
  final message = (o?.isInbox ?? false) || when == null
      ? l10n.snackAddedInbox(1, title)
      : l10n.snackAddedTimed(title, when);
  _announce(container, messenger, l10n, message, added.token);
}

/// "5:00 PM" today, else "Thu, Oct 23, 5:00 PM".
String _whenText(BuildContext context, AddDraft draft, {required bool use24h}) {
  final time = timeOfUtc(
    context,
    tz.getLocation(draft.tzId),
    draft.startUtc!,
    use24h: use24h,
  );
  if (draft.day == draft.today) return time;
  final locale = Localizations.localeOf(context).toLanguageTag();
  final day = DateFormat.MMMEd(locale).format(draft.day);
  return context.l10n.addWhenOnDay(day, time);
}
