import 'dart:convert';

import 'package:dottoday/data/db/app_database.dart';
import 'package:dottoday/data/sync/server_columns.dart';
import 'package:dottoday/data/sync/sync_gateway.dart';
import 'package:drift/drift.dart';

/// One field waiting to go up: its JSON value and the HLC it was written
/// with (a `change_log` row, docs/04 §4).
typedef PendingField = ({int seq, Object? value, String hlc});

/// A push batch and the outbox rows it settles once acknowledged.
typedef OutboxBatch = ({List<PushChange> changes, List<int> seqs});

/// The local outbox (`change_log`): what this device wrote and the server
/// hasn't acknowledged yet (docs/04 §4). Rows leave only when the server
/// took them or a pull resolved their field; never on an error (R-08).
final class Outbox {
  Outbox(this._db);

  final AppDatabase _db;

  /// How many rows wait (the pill's "N changes waiting").
  Stream<int> watchCount() {
    final count = _db.changeLog.seq.count();
    return (_db.selectOnly(
      _db.changeLog,
    )..addColumns([count])).map((r) => r.read(count) ?? 0).watchSingle();
  }

  /// The newest pending value per field of each of [ids] of [entity].
  Future<Map<String, Map<String, PendingField>>> pendingFor(
    String entity,
    Iterable<String> ids,
  ) async {
    final list = ids.toList();
    if (list.isEmpty) return const {};
    final rows =
        await (_db.select(_db.changeLog)
              ..where((c) => c.entity.equals(entity) & c.entityId.isIn(list))
              ..orderBy([(c) => OrderingTerm.asc(c.seq)]))
            .get();
    final out = <String, Map<String, PendingField>>{};
    for (final r in rows) {
      (out[r.entityId] ??= {})[r.field] = (
        seq: r.seq,
        value: jsonDecode(r.value),
        hlc: r.hlc,
      );
    }
    return out;
  }

  /// Forgets the pending writes of [fields] of row [id]: a pull resolved
  /// them in the server's favour.
  Future<void> drop(String entity, String id, Iterable<String> fields) =>
      (_db.delete(_db.changeLog)..where(
            (c) =>
                c.entity.equals(entity) &
                c.entityId.equals(id) &
                c.field.isIn(fields.toList()),
          ))
          .go();

  /// Everything waiting, as push batches of at most [size] changes: one
  /// change per entity version, parents before children (series before
  /// their occurrences, occurrences before subtasks), oldest first.
  Future<List<OutboxBatch>> batches({int size = 500}) async {
    final rows = await (_db.select(
      _db.changeLog,
    )..orderBy([(c) => OrderingTerm.asc(c.seq)])).get();
    final groups = <(String, String, String), List<ChangeLogRow>>{};
    for (final r in rows) {
      (groups[(r.entity, r.entityId, r.hlc)] ??= []).add(r);
    }
    final keys = groups.keys.toList()
      ..sort((a, b) {
        final byEntity = syncedEntities
            .indexOf(a.$1)
            .compareTo(syncedEntities.indexOf(b.$1));
        return byEntity != 0
            ? byEntity
            : groups[a]!.first.seq.compareTo(groups[b]!.first.seq);
      });
    final out = <OutboxBatch>[];
    var changes = <PushChange>[];
    var seqs = <int>[];
    for (final key in keys) {
      final group = groups[key]!;
      seqs.addAll(group.map((r) => r.seq));
      final allowed = pushableColumns[key.$1] ?? const <String>{};
      final fields = <String, Object?>{
        for (final r in group)
          if (allowed.contains(r.field))
            r.field: toServerValue(r.field, jsonDecode(r.value)),
      };
      // Only device-only fields changed: nothing to send, settled anyway.
      if (fields.isNotEmpty) {
        changes.add(
          PushChange(entity: key.$1, id: key.$2, hlc: key.$3, fields: fields),
        );
      }
      if (changes.length == size) {
        out.add((changes: changes, seqs: seqs));
        changes = [];
        seqs = [];
      }
    }
    if (seqs.isNotEmpty) out.add((changes: changes, seqs: seqs));
    return out;
  }

  /// The server took [batch]: its rows leave the outbox, and rows with
  /// nothing left to send are no longer dirty.
  Future<void> acknowledge(OutboxBatch batch) => _db.transaction(() async {
    await (_db.delete(
      _db.changeLog,
    )..where((c) => c.seq.isIn(batch.seqs))).go();
    for (final entity in syncedEntities) {
      await _db.customUpdate(
        'UPDATE $entity SET dirty = 0 WHERE dirty = 1 AND NOT EXISTS '
        '(SELECT 1 FROM change_log c WHERE c.entity = ? '
        'AND c.entity_id = $entity.id)',
        variables: [Variable<String>(entity)],
        updates: {_db.allTables.firstWhere((t) => t.actualTableName == entity)},
      );
    }
  });
}
