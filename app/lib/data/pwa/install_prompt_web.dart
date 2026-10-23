// The browser side of "install after the 2nd visit" (web/install_prompt.js,
// docs/09 M5.7). Hand-written js_interop.
import 'dart:async';
import 'dart:js_interop';

@JS('dottodayInstall')
external _Install? get _install;

extension type _Install._(JSObject _) implements JSObject {
  external bool available();
  external JSPromise<JSBoolean> prompt();
  external void dismiss();
}

@JS('window.addEventListener')
external void _listen(String type, JSFunction listener);

/// One per page: the browser's "installable" event lands here.
final _changes = StreamController<void>.broadcast();
var _listening = false;

/// Whether to offer installing now, and again whenever that may change.
Stream<bool> installAvailability() async* {
  if (!_listening) {
    _listening = true;
    _listen('dottoday-installable', (() => _changes.add(null)).toJS);
  }
  yield _install?.available() ?? false;
  await for (final _ in _changes.stream) {
    yield _install?.available() ?? false;
  }
}

/// Shows the browser's install dialog; true when the user installed.
Future<bool> promptInstall() async =>
    (await _install?.prompt().toDart)?.toDart ?? false;

/// "Not now": never offered again in this browser.
void dismissInstall() => _install?.dismiss();
