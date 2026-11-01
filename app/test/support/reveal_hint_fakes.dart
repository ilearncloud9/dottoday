import 'dart:async';

import 'package:dottoday/data/reveal/hint_providers.dart';
import 'package:dottoday/domain/entities/reveal_hint.dart';
import 'package:dottoday/domain/repositories/reveal_hint_repository.dart';
import 'package:dottoday/domain/reveal/hint_scheduler.dart';

import 'timeline_fakes.dart';

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

/// Wake Up's discovery hints (docs/15 §11), each shown as often as it ever
/// will be: the harness default, so a phone with Wake Up off doesn't put
/// the promise on every Today. Discovery tests pass their own records.
List<RevealHint> spentDiscovery() => [
  for (final h in HintId.values.skip(6))
    RevealHint(
      id: revealHintRowId(testUserId, h),
      userId: testUserId,
      hintId: h,
      shownCount: hintMaxShowsOf(h),
      createdAt: DateTime.utc(2026),
      updatedAt: DateTime.utc(2026),
    ),
];
