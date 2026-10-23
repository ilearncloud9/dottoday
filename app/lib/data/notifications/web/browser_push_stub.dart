// Non-web builds have no browser push (docs/09 M5.3b).
import 'dart:typed_data';

typedef BrowserPushSubscription = ({
  String endpoint,
  String p256dh,
  String auth,
});

Future<BrowserPushSubscription?> browserPushSubscription(
  String vapidPublicKey,
) async => null;

Future<Uint8List> encryptForPush(
  Uint8List plaintext,
  String p256dh,
  String auth,
) => throw UnsupportedError('web push exists only on the web');
