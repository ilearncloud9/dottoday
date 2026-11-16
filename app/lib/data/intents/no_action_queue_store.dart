import 'package:dottoday/domain/intents/action_queue_store.dart';

/// Where nothing outside the app queues actions (Linux, Windows, tests).
final class NoActionQueueStore implements ActionQueueStore {
  const NoActionQueueStore();

  @override
  Future<List<Object?>> read() async => const [];

  @override
  Future<void> remove(Set<String> ids) async {}

  @override
  Future<void> publish(QueueMarker marker) async {}
}
