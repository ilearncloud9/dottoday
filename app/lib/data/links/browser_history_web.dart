import 'dart:js_interop';

@JS('history.back')
external void _back();

/// Steps the browser one entry back, as its Back button does (ED-097:
/// closing a task you opened here is a Back step). Always true here.
bool browserBack() {
  _back();
  return true;
}
