@TestOn('browser')
@Tags(['web'])
library;

import 'dart:js_interop';

import 'package:dottoday/data/live_activity/web_live_dot.dart';
import 'package:dottoday/data/pwa/tab_live_dot_web.dart';
import 'package:flutter_test/flutter_test.dart';

@JS('document.head.insertAdjacentHTML')
external void _insertHead(String position, String html);

@JS('document.querySelector')
external _Link? _query(String selector);

extension type _Link._(JSObject _) implements JSObject {
  external String get href;
}

// The tab's favicon in real Chrome (docs/09 M9.7): the ring while a dot is
// live, the app's icon again after; the badge call never throws.
void main() {
  test('sets and restores the favicon', () {
    _insertHead('beforeend', '<link rel="icon" href="favicon.png">');
    final ring = faviconRing(0.5, 0xFF3B6CF6);
    applyTabLiveDot(WebLiveDot(title: '● x', favicon: ring, badge: 2));
    expect(_query('link[rel="icon"]')!.href, ring);
    applyTabLiveDot(WebLiveDot.none);
    expect(_query('link[rel="icon"]')!.href, endsWith('favicon.png'));
  });
}
