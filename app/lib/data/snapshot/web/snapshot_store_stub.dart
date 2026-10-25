// Only the web keeps the snapshot and the action queue in Cache Storage
// (docs/09 M9.1, M9.2).
const queuePath = '__snapshot/actions.json';

Future<void> storeSnapshot(String json) async {}

Future<String?> readStoredSnapshot() async => null;

Future<void> store(String path, String json) async {}

Future<String?> readStored(String path) async => null;
