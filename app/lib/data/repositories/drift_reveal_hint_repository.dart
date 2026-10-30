import 'package:dottoday/data/daos/reveal_hints_dao.dart';
import 'package:dottoday/data/db/app_database.dart';
import 'package:dottoday/data/mappers/entity_mappers.dart';
import 'package:dottoday/domain/entities/reveal_hint.dart';
import 'package:dottoday/domain/repositories/reveal_hint_repository.dart';

/// [RevealHintRepository] over the local Drift database.
final class DriftRevealHintRepository implements RevealHintRepository {
  DriftRevealHintRepository(AppDatabase db) : _dao = RevealHintsDao(db);

  final RevealHintsDao _dao;

  @override
  Stream<List<RevealHint>> watchAll(String userId) =>
      _dao.watchAll(userId).map((rows) => rows.map(revealHintFromRow).toList());

  @override
  Future<RevealHint?> findById(String userId, String id) async {
    final row = await _dao.findById(userId, id);
    return row == null ? null : revealHintFromRow(row);
  }

  @override
  Future<void> upsertAll(Iterable<RevealHint> hints) => _dao.upsertAll(
    hints.map((h) => revealHintCodec.encode<RevealHintRow>(h.toJson())),
  );
}
