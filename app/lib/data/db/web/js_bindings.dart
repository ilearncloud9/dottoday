// Minimal `dart:js_interop` bindings for IndexedDB and WebCrypto, enough
// for the key vault (key_vault.dart). Written by hand so the app doesn't
// take a direct dependency on `package:web` (CLAUDE.md §10).
import 'dart:async';
import 'dart:js_interop';

@JS('indexedDB')
external IdbFactory get indexedDB;

@JS('crypto')
external Crypto get crypto;

extension type IdbFactory._(JSObject _) implements JSObject {
  external IdbRequest open(String name, int version);
}

extension type IdbRequest._(JSObject _) implements JSObject {
  external JSAny? get result;
  external JSObject? get error;
  external set onsuccess(JSFunction f);
  external set onerror(JSFunction f);
  external set onupgradeneeded(JSFunction f);
}

extension type IdbDatabase._(JSObject _) implements JSObject {
  external IdbTransaction transaction(String store, String mode);
  external IdbObjectStore createObjectStore(String name);
  external void close();
}

extension type IdbTransaction._(JSObject _) implements JSObject {
  external IdbObjectStore objectStore(String name);
}

extension type IdbObjectStore._(JSObject _) implements JSObject {
  external IdbRequest get(String key);
  external IdbRequest add(JSAny value, String key);
}

extension type Crypto._(JSObject _) implements JSObject {
  external SubtleCrypto get subtle;
  external JSUint8Array getRandomValues(JSUint8Array array);
}

extension type SubtleCrypto._(JSObject _) implements JSObject {
  external JSPromise<JSObject> generateKey(
    JSObject algorithm,
    bool extractable,
    JSArray<JSString> usages,
  );
  external JSPromise<JSArrayBuffer> encrypt(
    JSObject algorithm,
    JSObject key,
    JSUint8Array data,
  );
  external JSPromise<JSArrayBuffer> decrypt(
    JSObject algorithm,
    JSObject key,
    JSArrayBuffer data,
  );
}

/// Completes with the request's result, or throws its error.
Future<JSAny?> idbResult(IdbRequest request) {
  final done = Completer<JSAny?>();
  request
    ..onsuccess = ((JSAny _) => done.complete(request.result)).toJS
    ..onerror = ((JSAny _) => done.completeError(
      StateError('IndexedDB request failed: ${request.error}'),
    )).toJS;
  return done.future;
}
