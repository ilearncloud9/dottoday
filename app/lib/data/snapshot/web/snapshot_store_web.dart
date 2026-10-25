// The day snapshot in the browser (docs/09 M9.1, docs/11 B5). Hand-written
// js_interop. Cache Storage is the one store both the page and the service
// worker can read (a worker has no localStorage); `web/sw.js` reads the
// same cache and URL and keeps the cache on activate.
import 'dart:js_interop';

/// Shared with `web/sw.js`.
const snapshotCache = 'dottoday-day-snapshot';
const snapshotPath = '__snapshot/day.json';

/// The action queue the service worker appends to (M9.2).
const queuePath = '__snapshot/actions.json';

@JS('caches')
external _CacheStorage? get _caches;

extension type _CacheStorage._(JSObject _) implements JSObject {
  external JSPromise<_Cache> open(String name);
}

extension type _Cache._(JSObject _) implements JSObject {
  external JSPromise<JSAny?> put(String request, _Response response);
  external JSPromise<_Response?> match(String request);
}

@JS('Response')
extension type _Response._(JSObject _) implements JSObject {
  external factory _Response(String body, _ResponseInit init);
  external JSPromise<JSString> text();
}

extension type _ResponseInit._(JSObject _) implements JSObject {
  external factory _ResponseInit({JSObject headers});
}

String get _url => Uri.base.resolve(snapshotPath).toString();

/// Stores [json] for the service worker; nothing without Cache Storage
/// (an insecure origin has none, and no service worker either).
Future<void> storeSnapshot(String json) async {
  final caches = _caches;
  if (caches == null) return;
  final cache = await caches.open(snapshotCache).toDart;
  final headers = {'content-type': 'application/json'}.jsify()! as JSObject;
  await cache
      .put(_url, _Response(json, _ResponseInit(headers: headers)))
      .toDart;
}

/// What [storeSnapshot] last wrote, from Cache Storage.
Future<String?> readStoredSnapshot() async {
  final caches = _caches;
  if (caches == null) return null;
  final cache = await caches.open(snapshotCache).toDart;
  final hit = await cache.match(_url).toDart;
  return hit == null ? null : (await hit.text().toDart).toDart;
}
