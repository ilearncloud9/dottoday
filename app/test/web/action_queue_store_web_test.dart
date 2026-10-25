@TestOn('browser')
@Tags(['web'])
library;

import 'dart:convert';

import 'package:dottoday/data/intents/web_action_queue_store.dart';
import 'package:dottoday/data/snapshot/web/snapshot_store_web.dart';
import 'package:flutter_test/flutter_test.dart';

// The web's action queue (docs/09 M9.2d) in real Chrome: what web/sw.js
// appends at `__snapshot/actions.json` the page reads and trims.
void main() {
  test(
    'reads the worker\'s entries and removes only the settled ones',
    () async {
      await store(
        queuePath,
        jsonEncode([
          {'id': 'a'},
          {'id': 'b'},
          'junk',
        ]),
      );
      const queue = WebActionQueueStore();
      expect(await queue.read(), hasLength(3));
      await queue.remove({'a'}, unreadable: true);
      expect(await queue.read(), [
        {'id': 'b'},
      ]);
    },
  );
}
