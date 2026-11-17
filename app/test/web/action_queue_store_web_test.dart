@TestOn('browser')
@Tags(['web'])
library;

import 'dart:async';
import 'dart:convert';
import 'dart:js_interop';

import 'package:dottoday/data/intents/web_action_queue_store.dart';
import 'package:dottoday/data/snapshot/web/snapshot_store_web.dart';
import 'package:dottoday/domain/intents/action_queue_store.dart';
import 'package:flutter_test/flutter_test.dart';

// The web's action queue (docs/09 M9.2d) in real Chrome: what web/sw.js
// appends at `__snapshot/actions.json` the page reads and trims.
void main() {
  test('reads the worker\'s entries and removes only the settled ones; '
      'unreadable ones stay (CR-160 I7)', () async {
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
    await queue.remove({'a'});
    expect(await queue.read(), [
      {'id': 'b'},
      'junk',
    ]);
  });

  test('publishes the owner where web/action_queue.js reads it', () async {
    const queue = WebActionQueueStore();
    await queue.publish(const QueueOwner('o1', guestSession: 's1'));
    expect(jsonDecode((await readStored(ownerPath))!), {
      'v': 1,
      'owner': 'o1',
      'guest_session': 's1',
    });
    await queue.publish(const QueueSwitching());
    expect(jsonDecode((await readStored(ownerPath))!), {
      'v': 1,
      'switching': true,
    });
    await queue.publish(const QueueRefusing());
    expect(jsonDecode((await readStored(ownerPath))!), {
      'v': 1,
      'refuse': true,
    });
  });

  // CR-160 I7: the tab's remove waits for the lock the worker appends
  // under (web/action_queue.js), so a read-then-write never overwrites.
  test('remove holds the queue lock the service worker takes', () async {
    await store(
      queuePath,
      jsonEncode([
        {'id': 'a'},
        {'id': 'b'},
      ]),
    );
    final release = Completer<void>();
    final held = Completer<void>();
    // Another context (the worker) holds the lock.
    unawaited(
      _locks
          .request(
            'dottoday-action-queue',
            ((JSAny? _) {
              held.complete();
              return release.future.toJS;
            }).toJS,
          )
          .toDart,
    );
    await held.future;
    var removed = false;
    final removing = const WebActionQueueStore()
        .remove({'a'})
        .then((_) => removed = true);
    await Future<void>.delayed(const Duration(milliseconds: 100));
    expect(removed, isFalse, reason: 'waits for the lock');
    // The worker appends while it holds the lock, then lets go.
    await store(
      queuePath,
      jsonEncode([
        {'id': 'a'},
        {'id': 'b'},
        {'id': 'c'},
      ]),
    );
    release.complete();
    await removing;
    expect(await const WebActionQueueStore().read(), [
      {'id': 'b'},
      {'id': 'c'},
    ]);
  });
}

@JS('navigator.locks')
external _LockManager get _locks;

extension type _LockManager._(JSObject _) implements JSObject {
  external JSPromise<JSAny?> request(String name, JSFunction callback);
}
