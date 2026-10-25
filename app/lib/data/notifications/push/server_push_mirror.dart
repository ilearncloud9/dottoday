import 'dart:convert';
import 'dart:typed_data';

import 'package:dottoday/core/logging/logger.dart';
import 'package:dottoday/data/notifications/notification_platform.dart';
import 'package:dottoday/data/notifications/push/push_store.dart';
import 'package:dottoday/domain/notifications/notification_payload.dart';

/// Where this browser's pushes go: its server subscription and the keys
/// the browser gave for encrypting to it.
final class PushTarget {
  const PushTarget({
    required this.subscriptionId,
    required this.p256dh,
    required this.auth,
  });

  final String subscriptionId;
  final String p256dh;
  final String auth;
}

/// Encrypts a push body to a subscription (RFC 8291; web/push_crypto.js).
typedef PushEncrypt =
    Future<Uint8List> Function(Uint8List plaintext, String p256dh, String auth);

/// Copies every reminder the tab schedules to the server, encrypted, so
/// it still arrives when the tab is closed (docs/07 Web, docs/09 M5.3b).
///
/// Wraps the in-tab [NotificationPlatform]: the tab keeps its timers (and
/// in-app banner), the server sends the same notification id as the push
/// tag, so a browser shows one notification even when both fire (R-10).
/// No target (signed out, push refused, no VAPID key) means tab only.
/// Server errors are logged and never break the tab's reminders.
final class ServerPushMirror implements NotificationPlatform {
  ServerPushMirror({
    required NotificationPlatform inner,
    required Future<PushTarget?> Function() target,
    required PushStore store,
    required PushEncrypt encrypt,
    required String doneLabel,
    required String plusLabel,
    String? startLabel,
    required Logger logger,
  }) : _inner = inner,
       _target = target,
       _store = store,
       _encrypt = encrypt,
       _doneLabel = doneLabel,
       _plusLabel = plusLabel,
       _startLabel = startLabel,
       _logger = logger;

  final NotificationPlatform _inner;
  final Future<PushTarget?> Function() _target;
  final PushStore _store;
  final PushEncrypt _encrypt;
  final String _doneLabel;
  final String _plusLabel;

  /// Smallest step's Start (M10.6).
  final String? _startLabel;
  final Logger _logger;

  @override
  Future<void> initialize(void Function(NotificationTap) onTap) async {
    await _inner.initialize(onTap);
    // The tab starts with no timers and re-plans everything; the server's
    // copies are replaced the same way, so nothing stale lingers.
    await _guard((t) => _store.clearPending(t.subscriptionId));
  }

  @override
  Future<NotificationTap?> launchTap() => _inner.launchTap();

  @override
  Future<List<(int, String?)>> pending() => _inner.pending();

  @override
  Future<void> cancel(int id) async {
    await _inner.cancel(id);
    await _guard((t) => _store.remove(t.subscriptionId, [id]));
  }

  @override
  Future<void> schedule(OsNotification n) async {
    await _inner.schedule(n);
    await _guard((t) async {
      final body = await _encrypt(_pushJson(n), t.p256dh, t.auth);
      await _store.put(t.subscriptionId, [
        PushRow(
          notificationId: n.id,
          fireAtUtc: n.fireAtUtc,
          plan: n.payload,
          ciphertext: body,
        ),
      ]);
    });
  }

  /// What web/sw.js shows on `push` (title, body, tag = id, actions).
  Uint8List _pushJson(OsNotification n) => utf8.encode(
    jsonEncode({
      'id': n.id,
      'title': n.title,
      'body': n.body,
      'payload': n.payload,
      'silent': n.silent,
      'actions': [
        if (n.withActions) ...[
          {'action': NotificationAction.done.name, 'title': _doneLabel},
          {'action': NotificationAction.plus15.name, 'title': _plusLabel},
        ],
        if (n.startAction && _startLabel != null)
          {'action': NotificationAction.start.name, 'title': _startLabel},
      ],
    }),
  );

  Future<void> _guard(Future<void> Function(PushTarget t) work) async {
    try {
      final t = await _target();
      if (t != null) await work(t);
    } on Object catch (e, st) {
      _logger.warn('push.mirror_failed', error: e, stackTrace: st);
    }
  }
}
