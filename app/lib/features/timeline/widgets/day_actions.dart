import 'dart:async';

import 'package:dottoday/core/clock/clock_provider.dart';
import 'package:dottoday/core/editing/editing_task.dart';
import 'package:dottoday/core/editing/focus_task.dart';
import 'package:dottoday/core/failures/app_failure.dart';
import 'package:dottoday/core/failures/failure_messages.dart';
import 'package:dottoday/core/failures/result.dart';
import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/shortcuts/app_shortcuts.dart';
import 'package:dottoday/data/trash/trash_providers.dart';
import 'package:dottoday/domain/entities/enums.dart';
import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:dottoday/domain/undo/undo_service.dart';
import 'package:dottoday/features/timeline/state/block_actions.dart';
import 'package:dottoday/features/timeline/widgets/task_sheet.dart';
import 'package:dottoday/shared/dot/thread.dart';
import 'package:dottoday/shared/feedback/undo_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Thread callbacks for a day's [blocks]: done toggles (light haptic, §2.4),
/// +15 min and Shift the rest, each confirmed with an Undo snackbar.
ThreadActions dayThreadActions(
  BuildContext context,
  WidgetRef ref, {
  required List<Occurrence> blocks,
  required String Function(DateTime utc) timeText,
  ThreadDrag? drag,
  Set<String> selectedIds = const {},
  ValueChanged<String>? onSelect,
}) {
  final messenger = ScaffoldMessenger.of(context);
  final l10n = context.l10n;
  final undo = ref.read(undoServiceProvider);
  Occurrence find(String id) => blocks.firstWhere((o) => o.id == id);

  void report<T>(
    Result<T, AppFailure> result,
    String Function(T value) message,
    UndoToken Function(T value) tokenOf,
  ) => reportUndoable(
    messenger,
    l10n,
    undo,
    result,
    message: message,
    tokenOf: tokenOf,
  );

  return ThreadActions(
    drag: drag,
    selectedIds: selectedIds,
    onSelect: onSelect,
    onOpen: (id) =>
        openTask(context, id, otherwise: () => showTaskSheet(context, id)),
    onFocus: (id) => openFocus(context, id),
    // "N h free · add here" opens Add at the gap, or now if the gap has
    // begun (R-17).
    onAddHere: (gap) {
      final now = ref.read(clockProvider).nowUtc();
      final from = gap.startUtc;
      Actions.maybeInvoke(
        context,
        AddTaskIntent(
          startUtc: from == null || from.isBefore(now) ? now : from,
        ),
      );
    },
    onToggleDone: (id) async {
      final o = find(id);
      final wasDone = o.status == OccurrenceStatus.done;
      unawaited(HapticFeedback.lightImpact());
      report(
        await toggleDone(ref, o),
        (_) => wasDone ? l10n.snackNotDone(o.title) : l10n.snackDone(o.title),
        (token) => token,
      );
    },
    onExtend: (id) async {
      final o = find(id);
      final end = o.endUtc!.add(const Duration(minutes: 15));
      report(
        await extendTask(ref, o),
        (_) => l10n.snackExtended(o.title, timeText(end)),
        (token) => token,
      );
    },
    onShiftRest: (id) async {
      final live = find(id);
      final overrun = overrunOf(live, blocks);
      if (overrun <= 0) return;
      report(
        await shiftRest(ref, day: blocks, live: live, overrunMinutes: overrun),
        (v) {
          final (_, r) = v;
          final pin = r.blockedById;
          return pin == null
              ? l10n.snackShifted(r.movedIds.length)
              : l10n.snackShiftedPartial(r.movedIds.length, find(pin).title);
        },
        (v) => v.$1,
      );
    },
  );
}

/// Shows an Undo snackbar for a write that worked, or the failure's
/// message. Takes the messenger and undo service up front, so it works
/// after the widget that started the write has gone.
void reportUndoable<T>(
  ScaffoldMessengerState messenger,
  AppLocalizations l10n,
  UndoService undo,
  Result<T, AppFailure> result, {
  required String Function(T value) message,
  required UndoToken Function(T value) tokenOf,
}) {
  switch (result) {
    case Ok(:final value):
      showUndoSnackbarOn(
        messenger,
        l10n,
        message: message(value),
        onUndo: () => unawaited(undo.undo(tokenOf(value))),
      );
    case Err(:final failure):
      messenger.showSnackBar(
        SnackBar(content: Text(failureMessage(l10n, failure))),
      );
  }
}
