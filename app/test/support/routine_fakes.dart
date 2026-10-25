import 'dart:async';

import 'package:dottoday/domain/entities/routine.dart';
import 'package:dottoday/domain/repositories/routine_repository.dart';

/// In-memory routines (docs/09 M11.4) for widget tests on fakes.
final class FakeRoutineRepository implements RoutineRepository {
  FakeRoutineRepository([Iterable<Routine> rows = const []]) : rows = [...rows];

  final List<Routine> rows;
  final _changes = StreamController<void>.broadcast();

  List<Routine> get _live => [
    for (final r in rows)
      if (r.deletedAt == null) r,
  ]..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));

  @override
  Stream<List<Routine>> watchActive(String userId) async* {
    yield _live;
    yield* _changes.stream.map((_) => _live);
  }

  @override
  Future<Routine?> findById(String userId, String id) async =>
      rows.where((r) => r.id == id).firstOrNull;

  @override
  Future<void> upsertAll(Iterable<Routine> routines) async {
    for (final r in routines) {
      rows
        ..removeWhere((x) => x.id == r.id)
        ..add(r);
    }
    _changes.add(null);
  }
}
