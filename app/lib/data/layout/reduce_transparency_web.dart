// The browser's `(prefers-reduced-transparency: reduce)` (ED-248 C).
// Browsers that don't know the query never match it: false.
// Hand-written js_interop, as primary_pointer_web.dart.
import 'dart:async';
import 'dart:js_interop';

@JS('window.matchMedia')
external _MediaQueryList _matchMedia(String query);

extension type _MediaQueryList._(JSObject _) implements JSObject {
  external bool get matches;
  external void addEventListener(String type, JSFunction listener);
}

/// Whether the browser asks for less transparency now, and on each change.
Stream<bool>? browserReducedTransparency() {
  final query = _matchMedia('(prefers-reduced-transparency: reduce)');
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
