import 'dart:async';

import 'package:dottoday/core/failures/app_failure.dart';
import 'package:dottoday/core/failures/failure_messages.dart';
import 'package:dottoday/core/failures/result.dart';
import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/data/trash/trash_providers.dart';
import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:dottoday/domain/scheduling/schedule_result.dart';
import 'package:dottoday/domain/undo/undo_service.dart';
import 'package:dottoday/features/inbox/state/inbox_actions.dart';
import 'package:dottoday/features/inbox/widgets/pick_time_sheet.dart';
import 'package:dottoday/features/inbox/widgets/schedule_sheet.dart';
import 'package:dottoday/shared/feedback/undo_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// What the Inbox's buttons and swipes do, each confirmed with Undo
/// (docs/02 F3, R-11). Built per frame from the screen's context.
final class InboxCommands {
  InboxCommands(
    this._context, {
    required this.today,
    required this.timeText,
    required this.rangeText,
  }) : _container = ProviderScope.containerOf(_context),
       _messenger = ScaffoldMessenger.of(_context),
       _l10n = _context.l10n;

  final BuildContext _context;
  final ProviderContainer _container;
  final ScaffoldMessengerState _messenger;
  final AppLocalizations _l10n;
  final DateTime today;
  final String Function(DateTime utc) timeText;
  final String Function(Slot slot) rangeText;

  UndoService get _undo => _container.read(undoServiceProvider);

  void _report<T>(
    Result<T, AppFailure> result,
    String message,
    UndoToken? Function(T value) tokenOf,
  ) {
    switch (result) {
      case Ok(:final value):
        final token = tokenOf(value);
        final undo = _undo;
        token == null
            ? _messenger.showSnackBar(SnackBar(content: Text(message)))
            : showUndoSnackbarOn(
                _messenger,
                _l10n,
                message: message,
                onUndo: () => unawaited(undo.undo(token)),
              );
      case Err(:final failure):
        _messenger.showSnackBar(
          SnackBar(content: Text(failureMessage(_l10n, failure))),
        );
    }
  }

  Future<bool> add(String text) async {
    final result = await addFromText(
      _container,
      text,
      languageCode: Localizations.localeOf(_context).languageCode,
      untitled: _l10n.inboxUntitled,
    );
    final rows = result is Ok<Added, AppFailure> ? result.value.rows : null;
    final first = rows?.firstOrNull;
    final timed = first?.occurrence?.startUtc;
    final title = first?.occurrence?.title ?? first?.series?.title ?? '';
    final message = rows != null && rows.length == 1 && timed != null
        ? _l10n.snackAddedTimed(title, timeText(timed))
        : _l10n.snackAddedInbox(rows?.length ?? 0, title);
    _report(result, message, (v) => v.token);
    return result is Ok;
  }

  Future<void> schedule(Occurrence item) async {
    final choice = await showScheduleSheet(
      _context,
      item: item,
      today: today,
      rangeText: rangeText,
    );
    final picked = switch (choice) {
      SlotPicked(:final choice) => choice,
      PickTime() when _context.mounted => await showPickTimeSheet(
        _context,
        item: item,
        today: today,
        rangeText: rangeText,
      ),
      _ => null,
    };
    if (picked != null) await place(item, picked);
  }

  /// Puts [item] in [choice]'s slot; the snackbar repeats its label
  /// ("Today, 11:30 – 12:30").
  Future<void> place(Occurrence item, SlotChoice choice) async {
    final result = await scheduleItem(_container, item, choice.slot.startUtc);
    _report(result, _l10n.snackScheduled(item.title, choice.label), (t) => t);
  }

  Future<void> trash(Occurrence item) async => _report(
    await trashItem(_container, item),
    _l10n.snackTrashed(item.title),
    (t) => t,
  );
}
