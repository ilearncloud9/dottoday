// The browser's storage manager (E-G4-7 Q2, ED-188; handoff § G4-7 Q2):
// persisted() and persist(), and a localStorage note that the request was
// made. Anything missing, throwing or slow counts as "can't be asked".
// Hand-written js_interop.
import 'dart:async';
import 'dart:js_interop';
import 'dart:js_interop_unsafe';

@JS('navigator.storage')
external _StorageManager? get _storage;

@JS('localStorage')
external _LocalStorage? get _local;

extension type _StorageManager._(JSObject _) implements JSObject {
  external JSPromise<JSBoolean> persisted();
  external JSPromise<JSBoolean> persist();
}

extension type _LocalStorage._(JSObject _) implements JSObject {
  external String? getItem(String key);
  external void setItem(String key, String value);
}

/// A call that never answers counts as unsupported (handoff item 5).
const _wait = Duration(seconds: 5);

Future<bool?> _ask(String method) async {
  final storage = _storage;
  if (storage == null || !storage.has(method)) return null;
  try {
    final answer = method == 'persist'
        ? storage.persist()
        : storage.persisted();
    return (await answer.toDart.timeout(_wait)).toDart;
  } on Object {
    return null;
  }
}

Future<bool?> persisted() => _ask('persisted');

Future<bool?> persist() => _ask('persist');

String _key(String owner) => 'dottoday.storage.asked.$owner';

bool asked(String owner) {
  try {
    return _local?.getItem(_key(owner)) != null;
  } on Object {
    // No localStorage (a locked-down browser): treat as asked, never nag.
    return true;
  }
}

void markAsked(String owner) {
  try {
    _local?.setItem(_key(owner), '1');
  } on Object {
    return;
  }
}
