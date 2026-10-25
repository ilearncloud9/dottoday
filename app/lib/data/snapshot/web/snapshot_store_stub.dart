// Only the web keeps the snapshot in Cache Storage (docs/09 M9.1).
Future<void> storeSnapshot(String json) async {}

Future<String?> readStoredSnapshot() async => null;
