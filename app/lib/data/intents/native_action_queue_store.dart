import 'package:dottoday/data/intents/action_queue_json.dart';
import 'package:dottoday/data/intents/home_widget_action_queue_store.dart';
import 'package:dottoday/domain/intents/action_queue_store.dart';
import 'package:flutter/services.dart';

/// The action queue on iOS and Android through `dottoday/intents` (docs/09
/// M9.2): the native side removes settled entries in one locked step, so
/// an action a Live Activity, widget or notification queues during a drain
/// is never overwritten (two `home_widget` calls — read, then write — left
/// that gap; found by integration_test/live_activity_test.dart). Where the
/// channel doesn't exist (the background refresh's engine) it falls back
/// to [HomeWidgetActionQueueStore].
final class NativeActionQueueStore implements ActionQueueStore {
  const NativeActionQueueStore({
    MethodChannel channel = const MethodChannel('dottoday/intents'),
    ActionQueueStore fallback = const HomeWidgetActionQueueStore(),
  }) : _channel = channel,
       _fallback = fallback;

  final MethodChannel _channel;
  final ActionQueueStore _fallback;

  @override
  Future<List<Object?>> read() async {
    try {
      return decodeQueueArray(await _channel.invokeMethod<String>('readQueue'));
    } on MissingPluginException {
      return _fallback.read();
    }
  }

  @override
  Future<void> remove(Set<String> ids, {bool unreadable = false}) async {
    if (ids.isEmpty && !unreadable) return;
    try {
      await _channel.invokeMethod<void>('removeQueued', {
        'ids': ids.toList(),
        'unreadable': unreadable,
      });
    } on MissingPluginException {
      await _fallback.remove(ids, unreadable: unreadable);
    }
  }
}
