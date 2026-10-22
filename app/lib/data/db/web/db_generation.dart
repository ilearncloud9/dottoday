import 'dart:js_interop';
import 'dart:js_interop_unsafe';

// "Start fresh" on the web (docs/09 M3f.9): IndexedDB databases can't be
// renamed, so a new one is opened under the next generation's name and the
// unreadable one stays where it is (never deleted).

const _key = 'dottoday-db-generation';

JSObject get _storage => globalContext['localStorage']! as JSObject;

/// The database name for this generation: `dottoday`, `dottoday-g1`, …
String webDatabaseName() {
  final g = _generation();
  return g == 0 ? 'dottoday' : 'dottoday-g$g';
}

/// Moves on to the next generation; returns the name left behind.
String nextWebDatabase() {
  final old = webDatabaseName();
  _storage.callMethod('setItem'.toJS, _key.toJS, '${_generation() + 1}'.toJS);
  return old;
}

int _generation() {
  final raw = _storage.callMethod('getItem'.toJS, _key.toJS);
  return raw.isA<JSString>() ? int.tryParse((raw! as JSString).toDart) ?? 0 : 0;
}
