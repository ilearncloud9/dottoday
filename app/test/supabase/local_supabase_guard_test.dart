import 'package:flutter_test/flutter_test.dart';

import 'local_supabase.dart';

// The client tests' URL guard (Q9, ED-352): untagged, so the unit job runs it
// without a stack. Only a local test stack passes; 54321 only on CI.
void main() {
  test('the test stack on 127.0.0.1 or localhost passes', () {
    expect(refuseUrl('http://127.0.0.1:55321', ci: false), isNull);
    expect(refuseUrl('http://localhost:55321', ci: false), isNull);
  });

  test('the shared stack port passes only on CI', () {
    expect(refuseUrl('http://127.0.0.1:54321', ci: false), isNotNull);
    expect(refuseUrl('http://127.0.0.1:54321', ci: true), isNull);
  });

  test('any other host or port is refused, CI or not', () {
    for (final ci in [false, true]) {
      expect(refuseUrl('https://abcd.supabase.co', ci: ci), isNotNull);
      expect(refuseUrl('http://10.0.0.5:55321', ci: ci), isNotNull);
      expect(refuseUrl('http://127.0.0.1:443', ci: ci), isNotNull);
      expect(refuseUrl('not a url', ci: ci), isNotNull);
    }
  });
}
