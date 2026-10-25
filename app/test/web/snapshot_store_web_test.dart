@TestOn('browser')
@Tags(['web'])
library;

import 'package:dottoday/data/snapshot/web/snapshot_store_web.dart';
import 'package:flutter_test/flutter_test.dart';

// The web's copy of the day snapshot (docs/09 M9.1) in real Chrome: what
// the page stores is what the service worker reads (same cache and URL).
void main() {
  test('stores the snapshot in Cache Storage and reads it back', () async {
    const json = '{"v":1,"blocks":[]}';
    await storeSnapshot(json);
    expect(await readStoredSnapshot(), json);
    const newer = '{"v":1,"blocks":[],"inbox_count":2}';
    await storeSnapshot(newer);
    expect(await readStoredSnapshot(), newer);
  });
}
