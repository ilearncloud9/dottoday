import 'package:dottoday/data/intents/action_queue_json.dart';
import 'package:dottoday/data/snapshot/web/snapshot_store_stub.dart'
    if (dart.library.js_interop) 'package:dottoday/data/snapshot/web/snapshot_store_web.dart'
    as platform;
import 'package:dottoday/domain/intents/action_queue_store.dart';

/// The web's action queue (docs/09 M9.2): `web/sw.js` appends Done / +15
/// from a notification here when no tab is open; the next tab drains it.
/// Cache Storage, beside the day snapshot.
final class WebActionQueueStore implements ActionQueueStore {
  const WebActionQueueStore();

  @override
  Future<List<Object?>> read() async =>
      decodeQueueArray(await platform.readStored(platform.queuePath));

  @override
  Future<void> remove(Set<String> ids, {bool unreadable = false}) async {
    if (ids.isEmpty && !unreadable) return;
    final raw = await platform.readStored(platform.queuePath);
    await platform.store(
      platform.queuePath,
      withoutEntries(raw, ids, unreadable: unreadable),
    );
  }
}
