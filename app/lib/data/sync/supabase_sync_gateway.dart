import 'dart:async';

import 'package:dottoday/data/sync/realtime_nudges.dart';
import 'package:dottoday/data/sync/server_columns.dart';
import 'package:dottoday/data/sync/sync_gateway.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// [SyncGateway] on Supabase (migrations 0001/0002): `sync_push` for
/// writes, PostgREST for pulls and field versions, Realtime for nudges.
/// RLS keeps every call to the signed-in user's rows (06 §3).
final class SupabaseSyncGateway implements SyncGateway {
  SupabaseSyncGateway(this._client);

  final SupabaseClient _client;

  @override
  Future<void> push(List<PushChange> changes) => _guard(
    () => _client.rpc<void>(
      'sync_push',
      params: {
        'changes': [for (final c in changes) c.toJson()],
      },
    ),
  );

  @override
  Future<List<Map<String, Object?>>> pull(
    String entity,
    PullCursor after, {
    required int limit,
  }) => _guard(() async {
    final from = _client.from(entity).select();
    // Quoted: a timestamp holds PostgREST's reserved `.` and `:`.
    final at = '"${after.updatedAt}"';
    final rows = await switch (after.id) {
      null => from.gte('updated_at', after.updatedAt),
      final id => from.or('updated_at.gt.$at,and(updated_at.eq.$at,id.gt.$id)'),
    }.order('updated_at').order('id').limit(limit);
    return [for (final r in rows) Map<String, Object?>.from(r)];
  });

  @override
  Future<int> count(String entity, DateTime sinceUtc) => _guard(
    () => _client
        .from(entity)
        .count()
        .gte('updated_at', sinceUtc.toUtc().toIso8601String()),
  );

  @override
  Future<Map<String, Map<String, String>>> fieldVersions(
    String entity,
    List<String> ids,
  ) => _guard(() async {
    final out = <String, Map<String, String>>{};
    // 100 ids per request keeps the query string well under URL limits.
    for (var i = 0; i < ids.length; i += 100) {
      final rows = await _client
          .from('field_versions')
          .select('entity_id, field, hlc')
          .eq('entity', entity)
          .inFilter(
            'entity_id',
            ids.sublist(i, (i + 100).clamp(0, ids.length)),
          );
      for (final r in rows) {
        (out[r['entity_id'] as String] ??= {})[r['field'] as String] =
            r['hlc'] as String;
      }
    }
    return out;
  });

  @override
  Future<({int revision, bool frozen})> accountRevision() => _guard(() async {
    final rows = await _client.rpc<List<dynamic>>('account_revision');
    final row = rows.single as Map<String, dynamic>;
    return (
      revision: (row['revision'] as num).toInt(),
      frozen: row['frozen'] == true,
    );
  });

  @override
  Future<Set<String>> ownIds(String entity, List<String> ids) =>
      _guard(() async {
        final out = <String>{};
        for (var i = 0; i < ids.length; i += 100) {
          final rows = await _client
              .from(entity)
              .select('id')
              .inFilter('id', ids.sublist(i, (i + 100).clamp(0, ids.length)));
          out.addAll(rows.map((r) => r['id'] as String));
        }
        return out;
      });

  @override
  Stream<void> changes() => RealtimeNudges(_openFeed).stream();

  /// One `dottoday-sync` channel on every synced table.
  Future<void> Function() _openFeed({
    required void Function() onChange,
    required void Function(FeedStatus) onStatus,
  }) {
    final channel = _client.channel('dottoday-sync');
    for (final table in syncedEntities) {
      channel.onPostgresChanges(
        event: PostgresChangeEvent.all,
        schema: 'public',
        table: table,
        callback: (_) => onChange(),
      );
    }
    // Joining is reported before the server's change feed is live; its
    // own "ok" says when changes made from then on will be announced.
    channel.onSystemEvents((payload) {
      if (payload is Map &&
          payload['extension'] == 'postgres_changes' &&
          payload['status'] == 'ok') {
        onStatus(FeedStatus.live);
      }
    });
    channel.subscribe(
      (status, _) => onStatus(switch (status) {
        RealtimeSubscribeStatus.subscribed => FeedStatus.subscribed,
        RealtimeSubscribeStatus.channelError => FeedStatus.error,
        RealtimeSubscribeStatus.timedOut => FeedStatus.timedOut,
        RealtimeSubscribeStatus.closed => FeedStatus.closed,
      }),
    );
    return () async => _client.removeChannel(channel);
  }

  /// The row a 0014 "not accessible" refusal names, if this is one.
  static ({String entity, String id})? _foreign(PostgrestException e) {
    if (e.code != '42501') return null;
    final m = _notAccessible.firstMatch(e.message);
    return m == null ? null : (entity: m[2]!, id: m[1]!);
  }

  static final _notAccessible = RegExp(
    r'sync_push: row ([0-9a-f-]{36}) of ([a-z_]+) not accessible',
  );

  /// Network trouble is "offline"; anything the server refused is "server".
  static Future<T> _guard<T>(Future<T> Function() run) async {
    try {
      return await run();
    } on PostgrestException catch (e) {
      throw SyncGatewayException(SyncTrouble.server, e, foreign: _foreign(e));
    } on AuthException catch (e) {
      throw SyncGatewayException(SyncTrouble.server, e);
    } on Exception catch (e) {
      // SocketException, ClientException, TimeoutException …
      throw SyncGatewayException(SyncTrouble.offline, e);
    }
  }
}
