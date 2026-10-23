import 'package:dottoday/data/notifications/push/push_store.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// [PushStore] on Supabase (migration 0003, RLS: own rows only). Used once
/// signed in (M6.1); every call runs as the user, never the service role.
final class SupabasePushStore implements PushStore {
  SupabasePushStore(this._client);

  final SupabaseClient _client;

  @override
  Future<String> subscribe(String endpoint) async {
    final row = await _client
        .from('push_subscriptions')
        .upsert({'endpoint': endpoint}, onConflict: 'user_id,endpoint')
        .select('id')
        .single();
    return row['id'] as String;
  }

  @override
  Future<void> put(String subscriptionId, List<PushRow> rows) async {
    if (rows.isEmpty) return;
    await _client.from('scheduled_pushes').upsert([
      for (final r in rows)
        {
          'subscription_id': subscriptionId,
          'notification_id': r.notificationId,
          'fire_at': r.fireAtUtc.toUtc().toIso8601String(),
          'plan': r.plan,
          // PostgREST takes bytea as \x + hex.
          'ciphertext': '\\x${_hex(r.ciphertext)}',
          'sent_at': null,
        },
    ], onConflict: 'subscription_id,notification_id');
  }

  @override
  Future<void> remove(String subscriptionId, List<int> notificationIds) =>
      _client
          .from('scheduled_pushes')
          .delete()
          .eq('subscription_id', subscriptionId)
          .inFilter('notification_id', notificationIds)
          .isFilter('sent_at', null);

  @override
  Future<void> clearPending(String subscriptionId) => _client
      .from('scheduled_pushes')
      .delete()
      .eq('subscription_id', subscriptionId)
      .isFilter('sent_at', null);

  static String _hex(List<int> bytes) =>
      bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
}
