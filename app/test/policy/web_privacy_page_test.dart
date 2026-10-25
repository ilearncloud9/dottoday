import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

// The privacy policy page (web/privacy.html, docs/09 M8.6) ships with the
// web build under the same CSP as the app (06 §8): no inline script or
// style. Play's account-deletion link points at its #delete section.
void main() {
  final html = File('web/privacy.html').readAsStringSync();

  test('no inline script or style', () {
    expect(html, isNot(contains('<script')));
    expect(html, isNot(contains('<style')));
    expect(html, isNot(matches(RegExp(r'\sstyle='))));
    expect(html, isNot(matches(RegExp(r'\son[a-z]+='))));
    expect(html, contains('href="privacy.css"'));
    expect(File('web/privacy.css').existsSync(), isTrue);
  });

  test('says what the store answers rest on', () {
    for (final anchor in ['id="delete"', 'id="children"', 'id="crashes"']) {
      expect(html, contains(anchor));
    }
    expect(html, contains('13 and over'));
    for (final processor in ['Supabase', 'Sentry', 'Resend']) {
      expect(html, contains(processor));
    }
  });
}
