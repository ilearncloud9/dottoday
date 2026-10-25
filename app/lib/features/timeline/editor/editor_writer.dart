import 'dart:async';

import 'package:dottoday/core/failures/app_failure.dart';
import 'package:dottoday/core/failures/result.dart';
import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/logging/logger.dart';
import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:dottoday/domain/undo/undo_service.dart';
import 'package:dottoday/domain/writes/write_batch.dart';
import 'package:dottoday/shared/feedback/save_failure.dart';
import 'package:flutter/material.dart';

/// The editor's write path: one undoable row write, never silent when it
/// fails (M8.5b, R-08). Read up front: the last flush runs in dispose,
/// where ref and context are off limits.
final class EditorWriter {
  EditorWriter({required this.undo, required this.logger});

  final UndoService undo;
  final Logger logger;
  ScaffoldMessengerState? _messenger;
  AppLocalizations? _l10n;

  /// Keeps what a failure after close needs; call from
  /// didChangeDependencies.
  void attach(BuildContext context) {
    _messenger = ScaffoldMessenger.maybeOf(context);
    _l10n = context.l10n;
  }

  /// Writes [draft] (an empty title keeps [keepTitle]); the failure, or
  /// null when it landed. A failure once [closed] is offered again from
  /// a snackbar.
  Future<AppFailure?> write(
    Occurrence draft, {
    required String keepTitle,
    required DateTime nowUtc,
    required bool Function() closed,
  }) async {
    final title = draft.title.trim();
    final row = draft.copyWith(
      title: title.isEmpty ? keepTitle : title,
      updatedAt: nowUtc,
    );
    final failure = await _write(row);
    if (failure != null && closed()) _offerRetry(row, failure);
    return failure;
  }

  Future<AppFailure?> _write(Occurrence row) async {
    final written = await undo.applyUndoable(
      WriteBatch(userId: row.userId, occurrences: [row]),
    );
    switch (written) {
      case Ok():
        return null;
      case Err(:final failure):
        logger.warn(
          'editor.autosave_failed', // l10n-ignore: a log event
          fields: {'id': LogId(row.id)}, // l10n-ignore: a log field
          error: failure,
        );
        return failure;
    }
  }

  /// The sheet is gone: a snackbar holds [row] with Try again until it is
  /// written.
  void _offerRetry(Occurrence row, AppFailure failure) {
    final messenger = _messenger;
    final l10n = _l10n;
    if (messenger == null || l10n == null || !messenger.mounted) return;
    void retry() => unawaited(
      _write(row).then((again) {
        if (again == null) return;
        showSaveFailureSnack(messenger, l10n, again, onRetry: retry);
      }),
    );
    showSaveFailureSnack(messenger, l10n, failure, onRetry: retry);
  }
}

/// The editor's debounced autosave (03 §3.4 "nothing lost on dismiss"):
/// [touch] after each change, [flush] to write now. A failed write stays
/// [dirty], so the next flush tries again.
final class DraftAutosave {
  DraftAutosave(this._write);

  /// How long typing pauses before a save. Behaviour, not motion, so it is
  /// not a DotMotion token.
  static const debounce = Duration(milliseconds: 600); // style-ignore: save

  final Future<AppFailure?> Function() _write;
  Timer? _timer;

  /// Whether a change waits to be written.
  bool dirty = false;

  /// A change happened: [onDue] runs once typing pauses for [debounce].
  void touch(VoidCallback onDue) {
    dirty = true;
    _timer?.cancel();
    _timer = Timer(debounce, onDue);
  }

  /// Writes now if [dirty]; the failure, or null when all is written.
  Future<AppFailure?> flush() async {
    _timer?.cancel();
    if (!dirty) return null;
    dirty = false;
    final failure = await _write();
    if (failure != null) dirty = true;
    return failure;
  }
}
