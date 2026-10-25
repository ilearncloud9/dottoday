// The live dot on the browser tab (docs/09 M9.7): the favicon ring and the
// installed app's badge (Badging API, where the browser has it). The title
// goes through MaterialApp.onGenerateTitle. Hand-written js_interop.
import 'dart:js_interop';

import 'package:dottoday/data/live_activity/web_live_dot.dart';

/// The app's own icon (web/index.html), restored when no dot is live.
const _defaultIcon = 'favicon.png';

@JS('document.querySelector')
external _Link? _query(String selector);

@JS('navigator')
external _Navigator get _navigator;

extension type _Link._(JSObject _) implements JSObject {
  external set href(String value);
}

extension type _Navigator._(JSObject _) implements JSObject {
  external JSFunction? get setAppBadge;
  @JS('setAppBadge')
  external JSPromise<JSAny?> setBadge(int count);
  external JSPromise<JSAny?> clearAppBadge();
}

void applyTabLiveDot(WebLiveDot dot) {
  _query('link[rel="icon"]')?.href = dot.favicon ?? _defaultIcon;
  final navigator = _navigator;
  if (navigator.setAppBadge == null) return;
  // A rejected badge (not installed, no permission) changes nothing.
  if (dot.badge > 0) {
    navigator.setBadge(dot.badge).toDart.ignore();
  } else {
    navigator.clearAppBadge().toDart.ignore();
  }
}
