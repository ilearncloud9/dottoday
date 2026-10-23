// Browser web-push bindings (docs/09 M5.3b): the push subscription and
// RFC 8291 encryption from web/push_crypto.js. Hand-written js_interop.
import 'dart:js_interop';
import 'dart:typed_data';

@JS('navigator.serviceWorker')
external _Container? get _serviceWorker;

extension type _Container._(JSObject _) implements JSObject {
  external JSPromise<_Registration> get ready;
}

extension type _Registration._(JSObject _) implements JSObject {
  external _PushManager get pushManager;
}

extension type _PushManager._(JSObject _) implements JSObject {
  external JSPromise<_Subscription?> getSubscription();
  external JSPromise<_Subscription> subscribe(JSObject options);
}

extension type _Subscription._(JSObject _) implements JSObject {
  external String get endpoint;
  external JSArrayBuffer? getKey(String name);
}

@JS('dottodayPushCrypto')
external _PushCrypto? get _pushCrypto;

extension type _PushCrypto._(JSObject _) implements JSObject {
  external JSPromise<JSUint8Array> encrypt(
    JSUint8Array plaintext,
    String p256dh,
    String auth,
  );
  external String bytesToB64u(JSUint8Array bytes);
  external JSUint8Array b64uToBytes(String s);
}

/// This browser's push subscription: where to send, and the keys to
/// encrypt to (base64url).
typedef BrowserPushSubscription = ({
  String endpoint,
  String p256dh,
  String auth,
});

/// The current subscription, created with [vapidPublicKey] if needed; null
/// where push isn't available or permission isn't granted.
Future<BrowserPushSubscription?> browserPushSubscription(
  String vapidPublicKey,
) async {
  final worker = _serviceWorker;
  final crypto = _pushCrypto;
  if (worker == null || crypto == null) return null;
  final manager = (await worker.ready.toDart).pushManager;
  final existing = await manager.getSubscription().toDart;
  final sub =
      existing ??
      await manager
          .subscribe(
            {
                  'userVisibleOnly': true,
                  'applicationServerKey': crypto.b64uToBytes(vapidPublicKey),
                }.jsify()!
                as JSObject,
          )
          .toDart;
  String key(String name) =>
      crypto.bytesToB64u(JSUint8Array(sub.getKey(name)!));
  return (endpoint: sub.endpoint, p256dh: key('p256dh'), auth: key('auth'));
}

/// Encrypts [plaintext] for a subscription's keys (RFC 8291).
Future<Uint8List> encryptForPush(
  Uint8List plaintext,
  String p256dh,
  String auth,
) async {
  final crypto = _pushCrypto;
  if (crypto == null) throw StateError('push_crypto.js is not loaded');
  final out = await crypto.encrypt(plaintext.toJS, p256dh, auth).toDart;
  return out.toDart;
}
