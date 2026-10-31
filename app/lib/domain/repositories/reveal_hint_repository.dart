import 'package:dottoday/domain/entities/reveal_hint.dart';

/// Read/write access to minimal mode's reveal hints (docs/14 §6),
/// owner-scoped. Writes are for the write path only (M2.3).
abstract interface class RevealHintRepository {
  /// Every hint record of [userId] (at most one per [HintId]).
  Stream<List<RevealHint>> watchAll(String userId);

  /// The record [id] owned by [userId], or null.
  Future<RevealHint?> findById(String userId, String id);

  /// Inserts or replaces each record by id.
  Future<void> upsertAll(Iterable<RevealHint> hints);
}
