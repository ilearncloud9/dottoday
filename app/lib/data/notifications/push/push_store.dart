import 'dart:typed_data';

/// One reminder for the server to push (docs/09 M5.3b): when, the ID-only
/// plan (for diffing), and the body encrypted in the browser (06 §1).
final class PushRow {
  const PushRow({
    required this.notificationId,
    required this.fireAtUtc,
    required this.plan,
    required this.ciphertext,
  });

  final int notificationId;
  final DateTime fireAtUtc;
  final String plan;
  final Uint8List ciphertext;
}

/// The server side of web push (`push_subscriptions` / `scheduled_pushes`,
/// migration 0003). A port: Supabase in the app, a fake in tests.
abstract interface class PushStore {
  /// Registers this browser's push [endpoint]; returns its subscription id.
  Future<String> subscribe(String endpoint);

  /// Inserts or replaces [rows] for [subscriptionId].
  Future<void> put(String subscriptionId, List<PushRow> rows);

  /// Removes the not-yet-sent reminders [notificationIds].
  Future<void> remove(String subscriptionId, List<int> notificationIds);

  /// Removes every not-yet-sent reminder of [subscriptionId] (a fresh tab
  /// re-plans them all).
  Future<void> clearPending(String subscriptionId);
}
