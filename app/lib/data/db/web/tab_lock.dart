import 'dart:async';
import 'dart:js_interop';
import 'dart:js_interop_unsafe';

final _held = <String, Future<bool>>{};

/// Claims [name] for this tab for the page's lifetime via the Web Locks
/// API; false if another tab of this origin holds it.
///
/// The web database lives in this page's memory and is flushed to
/// IndexedDB (M2.9); two tabs writing would overwrite each other, so only
/// one may open it. Browsers without Web Locks (pre-2022) are not guarded.
Future<bool> claimTabLock(String name) => _held[name] ??= _claim(name);

Future<bool> _claim(String name) {
  final navigator = globalContext['navigator']! as JSObject;
  final locks = navigator['locks'] as JSObject?;
  if (locks == null) return Future.value(true);
  final claimed = Completer<bool>();
  final options = JSObject()..['ifAvailable'] = true.toJS;
  locks.callMethod(
    'request'.toJS,
    'dottoday-db-$name'.toJS,
    options,
    ((JSAny? lock) {
      claimed.complete(lock != null);
      // Returning a promise that never settles holds the lock until the
      // page goes away.
      return lock == null ? null : Completer<void>().future.toJS;
    }).toJS,
  );
  return claimed.future;
}
