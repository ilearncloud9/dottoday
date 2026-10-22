import 'dart:async';
import 'dart:js_interop';
import 'dart:js_interop_unsafe';

final _held = <String, Future<bool>>{};
final _release = <String, Completer<void>>{};

@JS('BroadcastChannel')
extension type _Channel._(JSObject _) implements JSObject {
  external factory _Channel(String name);
  external void postMessage(JSAny message);
  external set onmessage(JSFunction f);
  external void close();
}

/// The message that asks the holding tab to let go ("Use it here").
const _letGo = 'let-go';

String _lockName(String name) => 'dottoday-db-$name';

JSObject? get _locks =>
    (globalContext['navigator']! as JSObject)['locks'] as JSObject?;

/// Claims [name] for this tab via the Web Locks API until [releaseTabLock]
/// or the page goes away; false if another tab of this origin holds it.
///
/// The web database lives in this page's memory and is flushed to
/// IndexedDB (M2.9); two tabs writing would overwrite each other, so only
/// one may open it. Browsers without Web Locks (pre-2022) are not guarded.
Future<bool> claimTabLock(String name) => _held[name] ??= _claim(name);

Future<bool> _claim(String name) {
  final locks = _locks;
  if (locks == null) return Future.value(true);
  final claimed = Completer<bool>();
  final options = JSObject()..['ifAvailable'] = true.toJS;
  locks.callMethod(
    'request'.toJS,
    _lockName(name).toJS,
    options,
    ((JSAny? lock) {
      claimed.complete(lock != null);
      if (lock == null) return null;
      // The returned promise holds the lock until it settles.
      final hold = _release[name] = Completer<void>();
      return hold.future.toJS;
    }).toJS,
  );
  return claimed.future;
}

/// Lets go of [name] (the database is closed first) so another tab can
/// open it (docs/09 M3f.9).
void releaseTabLock(String name) {
  _release.remove(name)?.complete();
  _held.remove(name)?.ignore();
}

/// Calls [onRequest] when another tab asks this one to let go of [name].
void onLetGoRequest(String name, Future<void> Function() onRequest) {
  _Channel(_lockName(name)).onmessage = ((JSObject event) {
    final data = event['data'];
    if (data.isA<JSString>() && (data! as JSString).toDart == _letGo) {
      unawaited(onRequest());
    }
  }).toJS;
}

/// Asks the tab holding [name] to let go and waits until it has; false
/// when it hasn't within [timeout] (that tab may be frozen). This tab's
/// earlier refusal is forgotten, so the next open claims afresh.
Future<bool> askToLetGo(
  String name, {
  Duration timeout = const Duration(seconds: 5),
}) async {
  final channel = _Channel(_lockName(name))..postMessage(_letGo.toJS);
  try {
    final end = DateTime.now().add(timeout);
    while (DateTime.now().isBefore(end)) {
      if (await _isFree(name)) {
        _held.remove(name)?.ignore();
        return true;
      }
      await Future<void>.delayed(const Duration(milliseconds: 200));
    }
    return false;
  } finally {
    channel.close();
  }
}

Future<bool> _isFree(String name) async {
  final locks = _locks;
  if (locks == null) return true;
  final state =
      await (locks.callMethod('query'.toJS)! as JSPromise<JSObject>).toDart;
  final held = (state['held']! as JSArray<JSObject>).toDart;
  return !held.any((l) => (l['name']! as JSString).toDart == _lockName(name));
}
