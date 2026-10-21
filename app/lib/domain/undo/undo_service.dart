import 'package:dottoday/core/failures/app_failure.dart';
import 'package:dottoday/core/failures/result.dart';
import 'package:dottoday/domain/writes/write_batch.dart';

/// Handle for reverting one write within [UndoService.window] (R-11, 03
/// `UndoSnackbar`). Opaque to the UI except for its expiry.
final class UndoToken {
  const UndoToken({required this.id, required this.expiresAtUtc});

  final String id;
  final DateTime expiresAtUtc;

  @override
  bool operator ==(Object other) => other is UndoToken && other.id == id;

  @override
  int get hashCode => id.hashCode;
}

/// Undoable writes for timeline actions (move, resize, complete, delete,
/// duplicate). Tokens live in memory: they end with the snackbar, and Trash
/// covers anything older.
abstract interface class UndoService {
  /// How long a token can be redeemed.
  static const window = Duration(seconds: 30);

  /// Writes [batch] through the write path and returns a token that puts
  /// every touched row back. Only occurrences and subtasks are undoable;
  /// series edits get their own scopes in M4.4.
  Future<Result<UndoToken, AppFailure>> applyUndoable(WriteBatch batch);

  /// Reverts [token]'s write: changed rows get their previous version,
  /// created rows go to Trash. Fails with [UndoExpiredFailure] after
  /// [window] or if already used.
  Future<Result<void, AppFailure>> undo(UndoToken token);
}
