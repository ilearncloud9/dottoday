import 'dart:async';

import 'package:dottoday/data/sync/sync_gateway.dart';

/// An in-memory Supabase for sync tests (docs/09 M6.2), faithful to
/// `sync_push` (migration 0002): per-field last-writer-wins on HLC string
/// order, a placeholder row for a new id, `field_versions`, and a
/// server-assigned `updated_at` that only moves forward. Like Postgres'
/// `now()`, one call's rows share one instant (migration 0001's trigger
/// runs inside `sync_push`'s transaction), so a big push makes many rows
/// with the same `updated_at`. Several devices can share one server
/// ([forDevice]).
final class FakeSyncServer {
  FakeSyncServer(this.userId);

  final String userId;
  final rows = <String, Map<String, Map<String, Object?>>>{};
  final versions = <(String, String, String), String>{};
  final _nudges = StreamController<void>.broadcast();
  var _tick = DateTime.utc(2026, 10, 23);

  /// Total `sync_push` calls (every device).
  var pushes = 0;

  /// What the next call throws, if anything.
  SyncTrouble? failNext;

  SyncGateway forDevice() => _DeviceGateway(this);

  /// Rows of [entity] as the server holds them.
  Map<String, Map<String, Object?>> table(String entity) => rows[entity] ??= {};

  String _nextUpdatedAt() {
    _tick = _tick.add(const Duration(milliseconds: 1));
    return _tick.toIso8601String();
  }

  void _maybeFail() {
    final f = failNext;
    if (f == null) return;
    failNext = null;
    throw SyncGatewayException(f, StateError('fake ${f.name}'));
  }

  void _push(List<PushChange> changes) {
    _maybeFail();
    pushes++;
    final now = _nextUpdatedAt();
    for (final c in changes) {
      // A new id: a placeholder, created_at by the server (column default).
      final row = table(c.entity).putIfAbsent(
        c.id,
        () => {'id': c.id, 'user_id': userId, 'created_at': now},
      );
      var applied = false;
      for (final MapEntry(key: field, value: value) in c.fields.entries) {
        if (const {
          'id',
          'user_id',
          'created_at',
          'updated_at',
        }.contains(field)) {
          continue;
        }
        final key = (c.entity, c.id, field);
        final existing = versions[key];
        if (existing != null && existing.compareTo(c.hlc) >= 0) continue;
        row[field] = value;
        versions[key] = c.hlc;
        applied = true;
      }
      if (applied || !row.containsKey('updated_at')) row['updated_at'] = now;
    }
    _nudges.add(null);
  }
}

final class _DeviceGateway implements SyncGateway {
  _DeviceGateway(this._server);

  final FakeSyncServer _server;

  @override
  Future<void> push(List<PushChange> changes) async => _server._push(changes);

  @override
  Future<List<Map<String, Object?>>> pull(
    String entity,
    PullCursor after, {
    required int limit,
  }) async {
    _server._maybeFail();
    final found =
        _server.table(entity).values.where((r) => _after(r, after)).toList()
          ..sort((a, b) {
            final t = (a['updated_at']! as String).compareTo(
              b['updated_at']! as String,
            );
            return t != 0
                ? t
                : (a['id']! as String).compareTo(b['id']! as String);
          });
    return [
      for (final r in found.take(limit)) {...r},
    ];
  }

  /// PostgREST's `updated_at > t OR (updated_at = t AND id > id)`, or
  /// `updated_at >= t` without an id.
  static bool _after(Map<String, Object?> row, PullCursor after) {
    final t = (row['updated_at']! as String).compareTo(after.updatedAt);
    return switch (after.id) {
      null => t >= 0,
      final id => t > 0 || (t == 0 && (row['id']! as String).compareTo(id) > 0),
    };
  }

  @override
  Future<int> count(String entity, DateTime sinceUtc) async => (await pull(
    entity,
    (updatedAt: sinceUtc.toUtc().toIso8601String(), id: null),
    limit: 1 << 30,
  )).length;

  @override
  Future<Map<String, Map<String, String>>> fieldVersions(
    String entity,
    List<String> ids,
  ) async {
    _server._maybeFail();
    final out = <String, Map<String, String>>{};
    for (final MapEntry(:key, :value) in _server.versions.entries) {
      if (key.$1 == entity && ids.contains(key.$2)) {
        (out[key.$2] ??= {})[key.$3] = value;
      }
    }
    return out;
  }

  @override
  Stream<void> changes() => _server._nudges.stream;
}
