import 'package:dottoday/domain/intents/action_queue_store.dart';

/// Where nothing outside the app queues actions: the Mac (its menu bar runs
/// in the app and calls the intents directly) and tests.
final class NoActionQueueStore implements ActionQueueStore {
  const NoActionQueueStore();

  @override
  Future<List<Object?>> read() async => const [];

  @override
  Future<void> remove(Set<String> ids, {bool unreadable = false}) async {}
}
