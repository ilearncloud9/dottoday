// The browser's primary pointer (ED-261): `(pointer: coarse)` is a finger
// or a pen, `fine` a mouse or a trackpad. Only the primary pointer counts;
// `any-pointer` is not read. Hand-written js_interop.
import 'dart:async';
import 'dart:js_interop';

@JS('window.matchMedia')
external _MediaQueryList _matchMedia(String query);

extension type _MediaQueryList._(JSObject _) implements JSObject {
  external bool get matches;
  external void addEventListener(String type, JSFunction listener);
}

/// Whether the primary pointer is coarse now, and again whenever it
/// changes (a tablet's keyboard cover with a trackpad attached).
Stream<bool>? coarsePrimaryPointer() {
  final query = _matchMedia('(pointer: coarse)');
  late final StreamController<bool> changes;
  changes = StreamController<bool>(
    onListen: () {
      changes.add(query.matches);
      query.addEventListener(
        'change',
        ((JSObject _) => changes.add(query.matches)).toJS,
      );
    },
    onCancel: () => changes.close(),
  );
  return changes.stream;
}
