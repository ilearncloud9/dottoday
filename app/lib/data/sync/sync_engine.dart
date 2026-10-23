import 'dart:convert';

import 'package:dottoday/core/clock/clock.dart';
import 'package:dottoday/core/ids/id_generator.dart';
import 'package:dottoday/data/db/app_database.dart';
import 'package:dottoday/data/sync/outbox.dart';
import 'package:dottoday/data/sync/row_merge.dart';
import 'package:dottoday/data/sync/server_columns.dart';
import 'package:dottoday/data/sync/shared_hlc.dart';
import 'package:dottoday/data/sync/sync_gateway.dart';
import 'package:dottoday/data/sync/synced_rows.dart';
import 'package:dottoday/domain/sync/hlc.dart';
import 'package:drift/drift.dart';

/// What one run did (for the status and tests).
typedef SyncRun = ({int pulled, int pushed, int conflicts});

/// Offline-first sync (docs/04 §4, ADR-0002, R-08): pull what changed on
/// the server since the last cursor, merge it field by field into the
/// local rows (conflicts recorded, never lost), then push the outbox.
///
/// Pull before push, so a same-field edit from another device is seen as
/// a conflict instead of being overwritten by the push's last-writer-wins.
/// Pulled rows are written without new outbox rows. A server or network
/// error stops the run and leaves local data and the outbox as they are.
final class SyncEngine {
  SyncEngine({
    required AppDatabase db,
    required SyncGateway gateway,
    required SharedHlc hlc,
    required Clock clock,
    IdGenerator ids = const UuidV7Generator(),
    int pageSize = 500,
  }) : _db = db,
       _gateway = gateway,
       _hlc = hlc,
       _clock = clock,
       _ids = ids,
       _pageSize = pageSize,
       _outbox = Outbox(db),
       _rows = SyncedRows(db);

  final AppDatabase _db;
  final SyncGateway _gateway;
  final SharedHlc _hlc;
  final Clock _clock;
  final IdGenerator _ids;
  final int _pageSize;
  final Outbox _outbox;
  final SyncedRows _rows;

  /// The outbox, for the pending count.
  Outbox get outbox => _outbox;

  /// One full round for [userId] (the signed-in account, already adopted).
  /// [onProgress] hears (done, total) while an account's first sync brings
  /// its rows down ("Bringing your tasks… 120 of 300", M6.4).
  /// Throws [SyncGatewayException] when the server can't be reached or
  /// refuses; what was done before stays done.
  Future<SyncRun> run(
    String userId, {
    void Function(int done, int total)? onProgress,
  }) async {
    final first = !await _hasCursor('profiles');
    if (first) await _yieldDefaultProfile(userId);
    var total = 0;
    if (first && onProgress != null) {
      for (final entity in syncedEntities) {
        total += await _gateway.count(entity, _epoch);
      }
      onProgress(0, total);
    }
    var pulled = 0;
    var conflicts = 0;
    for (final entity in syncedEntities) {
      final (rows, found) = await _pull(
        userId,
        entity,
        progress: first && onProgress != null
            ? (n) => onProgress((pulled + n).clamp(0, total), total)
            : null,
      );
      pulled += rows;
      conflicts += found;
    }
    var pushed = 0;
    for (final batch in await _outbox.batches(size: _pageSize)) {
      if (batch.changes.isNotEmpty) await _gateway.push(batch.changes);
      await _outbox.acknowledge(batch);
      pushed += batch.changes.length;
    }
    return (pulled: pulled, pushed: pushed, conflicts: conflicts);
  }

  /// Pages through [entity] from its cursor; returns (rows, conflicts).
  /// The first pull of an entity for an account lets local writes win
  /// (docs/09 M6.4: what was made here before signing in stays).
  Future<(int, int)> _pull(
    String userId,
    String entity, {
    void Function(int pulledSoFar)? progress,
  }) async {
    final localWins = !await _hasCursor(entity);
    var since = await _cursor(entity);
    var rows = 0;
    var conflicts = 0;
    while (true) {
      final page = await _gateway.pull(entity, since, limit: _pageSize);
      if (page.isEmpty) break;
      final ids = [for (final r in page) r['id']! as String];
      final pending = await _outbox.pendingFor(entity, ids);
      final versions = await _gateway.fieldVersions(entity, ids);
      final seen = await _seen(entity, ids);
      await _hlc.receive([for (final v in versions.values) ...v.values]);
      final last = DateTime.parse(page.last['updated_at']! as String).toUtc();
      await _db.transaction(() async {
        for (final r in page) {
          final id = r['id']! as String;
          conflicts += await _apply(
            userId,
            entity,
            toLocalRow(r),
            pending[id] ?? const {},
            versions[id] ?? const {},
            seen[id] ?? const {},
            localWins: localWins,
          );
          await _remember(entity, id, versions[id] ?? const {});
        }
        await _saveCursor(entity, last);
      });
      rows += page.length;
      progress?.call(rows);
      // A full page whose rows all share the cursor's instant can't move
      // it; stop rather than read the same page again.
      if (page.length < _pageSize || !last.isAfter(since)) break;
      since = last;
    }
    // Visited, even if the server had nothing: the next pull of it is no
    // longer this account's first.
    if (localWins && rows == 0) await _saveCursor(entity, since);
    return (rows, conflicts);
  }

  Future<int> _apply(
    String userId,
    String entity,
    Map<String, Object?> remote,
    Map<String, PendingField> pending,
    Map<String, String> versions,
    Map<String, String> seen, {
    required bool localWins,
  }) async {
    final id = remote['id']! as String;
    final local = await _rows.find(entity, userId, id);
    final merged = mergeRemote(
      entity: entity,
      local: local,
      remote: remote,
      pending: pending,
      versions: versions,
      seen: seen,
      localWins: localWins,
    );
    await _rows.put(entity, merged.row);
    if (merged.settled.isNotEmpty) {
      await _outbox.drop(entity, id, merged.settled);
    }
    if (merged.restamp.isNotEmpty) {
      final clock = await _hlc.clock();
      final newest = [
        for (final f in merged.restamp) ?Hlc.tryParse(versions[f] ?? ''),
      ].reduce((a, b) => a > b ? a : b);
      final hlc = clock.outrank(newest).toString();
      await _outbox.restamp(entity, id, merged.restamp, hlc);
      await _hlc.save();
    }
    final now = _clock.nowUtc().millisecondsSinceEpoch;
    for (final c in merged.conflicts) {
      await _db
          .into(_db.conflicts)
          .insert(
            ConflictsCompanion.insert(
              id: _ids.newId(),
              userId: userId,
              entity: entity,
              entityId: id,
              field: c.field,
              mine: Value(jsonEncode(c.mine)),
              theirs: Value(jsonEncode(c.theirs)),
              createdAt: now,
            ),
          );
    }
    await _rows.markDirty(
      entity,
      id,
      dirty: pending.length > merged.settled.length,
    );
    return merged.conflicts.length;
  }

  /// A returning account on a new device (docs/09 M6.4): the profile this
  /// device made on first launch holds defaults, not choices. Where another
  /// device already wrote the account's profile, those initial values give
  /// way (they share the clock of the profile's `created_at`); anything
  /// changed here since still wins.
  Future<void> _yieldDefaultProfile(String userId) async {
    final server = (await _gateway.fieldVersions('profiles', [userId]))[userId];
    if (server == null || server.isEmpty) return;
    final pending = (await _outbox.pendingFor('profiles', [userId]))[userId];
    final creation = pending?['created_at']?.hlc;
    if (pending == null || creation == null) return;
    await _outbox.drop('profiles', userId, [
      for (final MapEntry(key: field, value: p) in pending.entries)
        if (p.hlc == creation && server.containsKey(field)) field,
    ]);
  }

  Future<bool> _hasCursor(String entity) async =>
      await (_db.select(
        _db.syncCursors,
      )..where((c) => c.entity.equals(entity))).getSingleOrNull() !=
      null;

  static final _epoch = DateTime.fromMillisecondsSinceEpoch(0, isUtc: true);

  /// The server versions this device last pulled for [ids].
  Future<Map<String, Map<String, String>>> _seen(
    String entity,
    List<String> ids,
  ) async {
    final rows = await (_db.select(
      _db.fieldSeen,
    )..where((f) => f.entity.equals(entity) & f.entityId.isIn(ids))).get();
    final out = <String, Map<String, String>>{};
    for (final r in rows) {
      (out[r.entityId] ??= {})[r.field] = r.hlc;
    }
    return out;
  }

  Future<void> _remember(
    String entity,
    String id,
    Map<String, String> versions,
  ) async {
    for (final MapEntry(key: field, value: hlc) in versions.entries) {
      await _db
          .into(_db.fieldSeen)
          .insertOnConflictUpdate(
            FieldSeenCompanion.insert(
              entity: entity,
              entityId: id,
              field: field,
              hlc: hlc,
            ),
          );
    }
  }

  Future<DateTime> _cursor(String entity) async {
    final row = await (_db.select(
      _db.syncCursors,
    )..where((c) => c.entity.equals(entity))).getSingleOrNull();
    return DateTime.fromMillisecondsSinceEpoch(row?.sinceUtc ?? 0, isUtc: true);
  }

  Future<void> _saveCursor(String entity, DateTime last) => _db
      .into(_db.syncCursors)
      .insertOnConflictUpdate(
        SyncCursorsCompanion.insert(
          entity: entity,
          sinceUtc: last.millisecondsSinceEpoch,
        ),
      );
}
