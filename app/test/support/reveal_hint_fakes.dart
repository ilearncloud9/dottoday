import 'dart:async';

import 'package:dottoday/domain/entities/reveal_hint.dart';
import 'package:dottoday/domain/repositories/reveal_hint_repository.dart';

/// In-memory minimal-mode hint records (docs/14 §6).
final class FakeRevealHintRepository implements RevealHintRepository {
  FakeRevealHintRepository([Iterable<RevealHint> rows = const []])
    : rows = [...rows];

  final List<RevealHint> rows;
  final _changes = StreamController<void>.broadcast();

  @override
  Stream<List<RevealHint>> watchAll(String userId) async* {
    yield [...rows];
    yield* _changes.stream.map((_) => [...rows]);
  }

  @override
  Future<RevealHint?> findById(String userId, String id) async =>
      rows.where((r) => r.id == id).firstOrNull;

  @override
  Future<void> upsertAll(Iterable<RevealHint> hints) async {
    for (final h in hints) {
      rows
        ..removeWhere((x) => x.id == h.id)
        ..add(h);
    }
    _changes.add(null);
  }
}
