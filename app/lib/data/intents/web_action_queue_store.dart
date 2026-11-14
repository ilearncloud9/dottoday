import 'package:dottoday/data/intents/action_queue_json.dart';
import 'package:dottoday/data/snapshot/web/snapshot_store_stub.dart'
    if (dart.library.js_interop) 'package:dottoday/data/snapshot/web/snapshot_store_web.dart'
    as platform;
import 'package:dottoday/domain/intents/action_queue_store.dart';

/// The web's action queue (docs/09 M9.2): `web/sw.js` appends Done / +15
/// from a notification here when no tab is open; the next tab drains it.
/// Cache Storage, beside the day snapshot, with the owner the worker
/// stamps entries with (CR-160 I7).
final class WebActionQueueStore implements ActionQueueStore {
  const WebActionQueueStore();

  @override
  Future<List<Object?>> read() async =>
      decodeQueueArray(await platform.readStored(platform.queuePath));

  // Under the lock web/action_queue.js appends under, so an action the
  // worker queues meanwhile is never overwritten (CR-160 I7).
  @override
  Future<void> remove(Set<String> ids) async {
    if (ids.isEmpty) return;
    await platform.withQueueLock(() async {
      final raw = await platform.readStored(platform.queuePath);
      if (!isRewritable(raw)) return;
      await platform.store(platform.queuePath, withoutEntries(raw, ids));
    });
  }

  @override
  Future<void> publish(QueueMarker marker) => platform.withQueueLock(
    () => platform.store(platform.ownerPath, encodeQueueMarker(marker)),
  );
}
