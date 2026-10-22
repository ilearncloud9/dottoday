import 'dart:async';

import 'package:dottoday/core/failures/app_failure.dart';
import 'package:dottoday/core/failures/failure_messages.dart';
import 'package:dottoday/core/failures/result.dart';
import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/data/profile/profile_providers.dart';
import 'package:dottoday/data/quick_add/quick_add_actions.dart';
import 'package:dottoday/data/trash/trash_providers.dart';
import 'package:dottoday/domain/quick_add/add_draft.dart';
import 'package:dottoday/domain/undo/undo_service.dart';
import 'package:dottoday/features/task_editor/add/state/add_actions.dart';
import 'package:dottoday/shared/feedback/undo_snackbar.dart';
import 'package:dottoday/shared/time/time_labels.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:timezone/timezone.dart' as tz;

/// Writes [draft] (docs/02 F2 "Saving is optimistic": with [close] the
/// sheet goes first), then confirms with Undo (R-11). Returns whether it
/// was written.
Future<bool> saveFromSheet(
  BuildContext context,
  AddDraft draft, {
  bool toInbox = false,
  bool close = true,
}) async {
  final container = ProviderScope.containerOf(context);
  final messenger = ScaffoldMessenger.of(context);
  final l10n = context.l10n;
  final use24h = use24hFor(
    context,
    container.read(currentProfileProvider).value?.settings.use24h,
  );
  final when = draft.startUtc == null || toInbox
      ? null
      : _whenText(context, draft, use24h: use24h);
  if (close) Navigator.of(context).pop();
  final result = await saveDraft(
    container,
    draft,
    untitled: l10n.inboxUntitled,
    toInbox: toInbox,
  );
  _confirm(container, messenger, l10n, result, when: when);
  return result is Ok;
}

/// Adds every line of a pasted list (R-07) — timed lines on their day,
/// the rest in the Inbox, one Undo — then closes the sheet.
Future<void> addManyFromSheet(
  BuildContext context,
  String text, {
  required String languageCode,
}) async {
  final container = ProviderScope.containerOf(context);
  final messenger = ScaffoldMessenger.of(context);
  final l10n = context.l10n;
  Navigator.of(context).pop();
  final result = await addFromText(
    container,
    text,
    languageCode: languageCode,
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
      messenger.showSnackBar(
        SnackBar(content: Text(failureMessage(l10n, failure))),
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

/// "Pay rent added for 5:00 PM" with Undo, or the failure.
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
      _announce(container, messenger, l10n, message, value.token);
    case Err(:final failure):
      messenger.showSnackBar(
        SnackBar(content: Text(failureMessage(l10n, failure))),
      );
  }
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
