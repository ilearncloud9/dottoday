import 'dart:convert';

import 'package:dottoday/core/clock/clock.dart';
import 'package:dottoday/core/ids/id_generator.dart';
import 'package:dottoday/data/db/app_database.dart';
import 'package:dottoday/data/db/owner_meta.dart';
import 'package:dottoday/data/sync/outbox.dart';
import 'package:dottoday/data/sync/row_merge.dart';
import 'package:dottoday/data/sync/server_columns.dart';
import 'package:dottoday/data/sync/shared_hlc.dart';
import 'package:dottoday/data/sync/sync_gateway.dart';
import 'package:dottoday/data/sync/synced_rows.dart';
import 'package:dottoday/domain/sync/clock_skew.dart';
import 'package:drift/drift.dart';

/// What one run did (for the status and tests).
/// What a round did. [skew] is set when the device clock is more than
/// 5 min off; when it is fast, [pushed] is 0 and the outbox waits (M6.5.7).
typedef SyncRun = ({int pulled, int pushed, int conflicts, ClockSkew? skew});

/// Offline-first sync (docs/04 §4, ADR-0002, R-08): pull what changed on
/// the server since the last cursor, merge it field by field into the
/// local rows (conflicts recorded, never lost), then push the outbox.
///
/// Pull before push, so a same-field edit from another device is seen as
/// a conflict instead of being overwritten by the push's last-writer-wins.
/// Pulled rows are written without new outbox rows. A server or network
/// error stops the run and leaves local data and the outbox as they are.
/// A run is one owner's (CR-160): it pushes only that account's outbox
/// entries and keeps its own pull cursors; other owners' rows on the
/// device are never read for it.
final class SyncEngine {
  SyncEngine({
    required AppDatabase db,
    required SyncGateway gateway,
    required SharedHlc hlc,
    required Clock clock,
    IdGenerator ids = const UuidV7Generator(),
    int pageSize = 500,
    Duration? Function()? clockOffset,
  }) : _db = db,
       _gateway = gateway,
       _hlc = hlc,
       _clock = clock,
       _ids = ids,
       _pageSize = pageSize,
       _clockOffset = clockOffset,
       _outbox = Outbox(db),
       _rows = SyncedRows(db);

  final AppDatabase _db;
  final SyncGateway _gateway;
  final SharedHlc _hlc;
  final Clock _clock;
  final IdGenerator _ids;
  final int _pageSize;

  /// Device minus server time, when known (`ServerClock`).
  final Duration? Function()? _clockOffset;
  final Outbox _outbox;
  final SyncedRows _rows;

  /// The outbox, for the pending count.
  Outbox get outbox => _outbox;

  /// One full round for [userId] (the signed-in account, already made the
  /// active owner by `signInOwner`).
  /// [onProgress] hears (done, total) while an account's first sync brings
  /// its rows down ("Bringing your tasks… 120 of 300", M6.4).
  /// Throws [SyncGatewayException] when the server can't be reached or
  /// refuses; what was done before stays done.
  Future<SyncRun> run(
    String userId, {
    void Function(int done, int total)? onProgress,
  }) async {
    final first = !await _hasCursor(userId, 'profiles');
    if (first) await _settleProfile(userId);
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
    final skew = ClockSkew.of(_clockOffset?.call());
    // A fast clock's versions are more than 5 min in the future, which
    // sync_push refuses (ADR-0002): keep them until the clock is right
    // instead of failing the round (rejected: "Sync paused").
    if (skew?.fast ?? false) {
      return (pulled: pulled, pushed: 0, conflicts: conflicts, skew: skew);
    }
    var pushed = 0;
    for (final batch in await _outbox.batches(userId, size: _pageSize)) {
      if (batch.changes.isNotEmpty) await _gateway.push(batch.changes);
      await _outbox.acknowledge(batch);
      pushed += batch.changes.length;
    }
    return (pulled: pulled, pushed: pushed, conflicts: conflicts, skew: skew);
  }

  /// Pages through [entity] from [userId]'s cursor; returns (rows,
  /// conflicts).
  Future<(int, int)> _pull(
    String userId,
    String entity, {
    void Function(int pulledSoFar)? progress,
  }) async {
    final first = !await _hasCursor(userId, entity);
    var after = await _cursor(userId, entity);
    var rows = 0;
    var conflicts = 0;
    while (true) {
      final page = await _gateway.pull(entity, after, limit: _pageSize);
      if (page.isEmpty) break;
      final ids = [for (final r in page) r['id']! as String];
      final pending = await _outbox.pendingFor(userId, entity, ids);
      final versions = await _gateway.fieldVersions(entity, ids);
      final seen = await _seen(entity, ids);
      await _hlc.receive([for (final v in versions.values) ...v.values]);
      final last = (
        updatedAt: page.last['updated_at']! as String,
        id: page.last['id']! as String,
      );
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
          );
          await _remember(entity, id, versions[id] ?? const {});
        }
        await _saveCursor(userId, entity, last);
      });
      rows += page.length;
      progress?.call(rows);
      if (page.length < _pageSize) break;
      after = last;
    }
    // Visited, even if the server had nothing: the next pull of it is no
    // longer this account's first.
    if (first && rows == 0) await _saveCursor(userId, entity, after);
    return (rows, conflicts);
  }

  Future<int> _apply(
    String userId,
    String entity,
    Map<String, Object?> remote,
    Map<String, PendingField> pending,
    Map<String, String> versions,
    Map<String, String> seen,
  ) async {
    final id = remote['id']! as String;
    final local = await _rows.find(entity, userId, id);
    final merged = mergeRemote(
      entity: entity,
      local: local,
      remote: remote,
      pending: pending,
      versions: versions,
      seen: seen,
    );
    await _rows.put(entity, merged.row);
    if (merged.settled.isNotEmpty) {
      await _outbox.drop(entity, id, merged.settled);
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

  /// An account's first sync on this device (docs/09 M6.4, CR-160
  /// criterion 7): when the account already has settings on the server,
  /// they stay. The profile pending here (a fresh device's defaults, or the
  /// current guest's settings) is not pushed over them; the guest's stay
  /// kept for an explicit choice (B1). A new account (no settings yet) takes
  /// this device's profile, so there is nothing to choose. One transaction;
  /// a run that fails later finds the outbox already settled.
  Future<void> _settleProfile(String userId) async {
    final server = (await _gateway.fieldVersions('profiles', [userId]))[userId];
    final hasSettings = server != null && server.isNotEmpty;
    await _db.transaction(() async {
      if (!hasSettings) {
        await (_db.delete(
          _db.localMeta,
        )..where((m) => m.key.equals(guestSettingsKey(userId)))).go();
        return;
      }
      await (_db.delete(_db.changeLog)..where(
            (c) =>
                c.ownerId.equals(userId) &
                c.entity.equals('profiles') &
                c.entityId.equals(userId),
          ))
          .go();
    });
  }

  Future<bool> _hasCursor(String owner, String entity) async =>
      await (_db.select(_db.syncCursors)
            ..where((c) => c.ownerId.equals(owner) & c.entity.equals(entity)))
          .getSingleOrNull() !=
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

  /// Where [entity]'s next pull starts: after the last row pulled, or
  /// from its instant on for a cursor saved before v17.
  Future<PullCursor> _cursor(String owner, String entity) async {
    final row =
        await (_db.select(_db.syncCursors)
              ..where((c) => c.ownerId.equals(owner) & c.entity.equals(entity)))
            .getSingleOrNull();
    if (row?.sinceAt case final at?) return (updatedAt: at, id: row!.sinceId);
    final since = DateTime.fromMillisecondsSinceEpoch(
      row?.sinceUtc ?? 0,
      isUtc: true,
    );
    return (updatedAt: since.toIso8601String(), id: null);
  }

  Future<void> _saveCursor(String owner, String entity, PullCursor last) => _db
      .into(_db.syncCursors)
      .insertOnConflictUpdate(
        SyncCursorsCompanion.insert(
          ownerId: owner,
          entity: entity,
          sinceUtc: DateTime.parse(last.updatedAt).millisecondsSinceEpoch,
          sinceAt: Value(last.updatedAt),
          sinceId: Value(last.id),
        ),
      );
}
