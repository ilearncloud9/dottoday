import 'dart:async';

import 'package:dottoday/core/clock/clock_provider.dart';
import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/data/focus/focus_providers.dart';
import 'package:dottoday/data/intents/intent_providers.dart';
import 'package:dottoday/data/trash/trash_providers.dart';
import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:dottoday/domain/entities/subtask.dart';
import 'package:dottoday/domain/intents/dot_action.dart';
import 'package:dottoday/domain/scheduling/task_progress.dart' as progress;
import 'package:dottoday/domain/validation/field_rules.dart';
import 'package:dottoday/domain/writes/write_batch.dart';
import 'package:dottoday/shared/feedback/save_failure.dart';
import 'package:dottoday/shared/feedback/undo_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Focus's writes (docs/09 M10.5), each one batch through the write path.
final class FocusActions {
  const FocusActions(this.ref);

  final WidgetRef ref;

  /// Opening Focus is a start (B1): `actualStart` once, never inferred.
  Future<void> opened(String id) =>
      ref.read(dotIntentsProvider).run(StartFocus(id));

  /// Done, with Undo; Deep work's Do Not Disturb goes off with it.
  Future<void> done(BuildContext context, Occurrence task) async {
    final messenger = ScaffoldMessenger.of(context);
    final l10n = context.l10n;
    final now = ref.read(clockProvider).nowUtc();
    unawaited(ref.read(deepWorkGatewayProvider).turnOff());
    await _undoable(
      messenger,
      l10n,
      [progress.markDone(task, now)],
      const [],
      l10n.focusDoneMessage(task.title),
    );
  }

  /// +15 min on the planned length, with Undo.
  Future<void> extend(BuildContext context, Occurrence task) {
    final messenger = ScaffoldMessenger.of(context);
    final l10n = context.l10n;
    final now = ref.read(clockProvider).nowUtc();
    final longer = (task.durationMin + 15).clamp(
      minDurationMin,
      maxDurationMin,
    );
    return _undoable(
      messenger,
      l10n,
      [task.copyWith(durationMin: longer, updatedAt: now)],
      const [],
      l10n.focusExtendedMessage(task.title),
    );
  }

  /// Next step: ticks [step]; the next one's timer starts now.
  Future<void> nextStep(BuildContext context, Subtask step) {
    final messenger = ScaffoldMessenger.of(context);
    final l10n = context.l10n;
    final now = ref.read(clockProvider).nowUtc();
    return _write(messenger, l10n, [], [
      step.copyWith(done: true, updatedAt: now),
    ], null);
  }

  Future<void> _undoable(
    ScaffoldMessengerState messenger,
    AppLocalizations l10n,
    List<Occurrence> occurrences,
    List<Subtask> subtasks,
    String message,
  ) => _write(messenger, l10n, occurrences, subtasks, message);

  /// One undoable batch; [message] offers Undo. A failure is said, with
  /// Try again (R-08: never silent).
  Future<void> _write(
    ScaffoldMessengerState messenger,
    AppLocalizations l10n,
    List<Occurrence> occurrences,
    List<Subtask> subtasks,
    String? message,
  ) async {
    final undo = ref.read(undoServiceProvider);
    final userId = occurrences.firstOrNull?.userId ?? subtasks.first.userId;
    final written = await undo.applyUndoable(
      WriteBatch(userId: userId, occurrences: occurrences, subtasks: subtasks),
    );
    written.when(
      ok: (token) {
        if (message == null) return;
        showUndoSnackbarOn(
          messenger,
          l10n,
          message: message,
          onUndo: () => unawaited(undo.undo(token)),
        );
      },
      err: (f) => showSaveFailureSnack(
        messenger,
        l10n,
        f,
        onRetry: () =>
            unawaited(_write(messenger, l10n, occurrences, subtasks, message)),
      ),
    );
  }
}
