import 'package:dottoday/core/l10n/generated/app_localizations.dart';
import 'package:dottoday/core/logging/logger.dart';
import 'package:dottoday/data/notifications/notification_platform.dart';
import 'package:dottoday/data/notifications/push/server_push_mirror.dart';
import 'package:dottoday/data/notifications/push/supabase_push_store.dart';
import 'package:dottoday/data/notifications/web/browser_push_any.dart';
import 'package:dottoday/domain/notifications/notification_permission.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// The tab's reminders, also sent by the server while signed in, so they
/// arrive with the tab closed (docs/07 Web, M5.3b, wired in M6.1).
///
/// Without a client or VAPID key the tab works alone. The target is looked
/// up on every sync: none while signed out or before notifications are
/// allowed (it never asks for them itself), and the subscription is
/// registered once per user and endpoint.
NotificationPlatform withServerPush(
  NotificationPlatform tab, {
  required SupabaseClient? client,
  required String? vapidPublicKey,
  required NotificationPermission permission,
  required AppLocalizations l10n,
  required Logger logger,
}) {
  if (client == null || vapidPublicKey == null) return tab;
  final store = SupabasePushStore(client);
  String? registeredFor;
  PushTarget? registered;
  Future<PushTarget?> target() async {
    final user = client.auth.currentUser;
    if (user == null) return null;
    if (await permission.status() != PermissionState.granted) return null;
    final sub = await browserPushSubscription(vapidPublicKey);
    if (sub == null) return null;
    final key = '${user.id} ${sub.endpoint}';
    if (registeredFor != key) {
      registered = PushTarget(
        subscriptionId: await store.subscribe(sub.endpoint),
        p256dh: sub.p256dh,
        auth: sub.auth,
      );
      registeredFor = key;
    }
    return registered;
  }

  return ServerPushMirror(
    inner: tab,
    target: target,
    store: store,
    encrypt: encryptForPush,
    doneLabel: l10n.notifActionDone,
    plusLabel: l10n.liveExtend,
    logger: logger,
  );
}
