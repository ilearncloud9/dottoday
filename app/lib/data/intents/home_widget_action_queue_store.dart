import 'package:dottoday/data/intents/action_queue_json.dart';
import 'package:dottoday/data/widgets/home_widget_sink.dart';
import 'package:dottoday/domain/intents/action_queue_store.dart';
import 'package:home_widget/home_widget.dart';

/// The action queue in the store the widgets already share with the app
/// (docs/09 M9.2): the iOS App Group `UserDefaults` (written by the App
/// Intents in the app and the widget extension) and Android's
/// `home_widget` prefs (written by `DotActionReceiver`). Same key on both.
/// Used only where `dottoday/intents` isn't registered (Android's
/// background refresh engine): it reads, and leaves removal to the app.
final class HomeWidgetActionQueueStore implements ActionQueueStore {
  const HomeWidgetActionQueueStore();

  @override
  Future<List<Object?>> read() async {
    await HomeWidget.setAppGroupId(HomeWidgetSink.appGroupId);
    return decodeQueueArray(
      await HomeWidget.getWidgetData<String>(actionQueueKey),
    );
  }

  // Removes nothing: without the native lock a read-then-write here could
  // overwrite an action a surface appends in between (CR-160 I7). What
  // this engine applied stays queued and is removed by the app's next
  // drain, where replaying it changes nothing (M9.2 "idempotent replay").
  @override
  Future<void> remove(Set<String> ids) async {}

  // Only the app publishes the owner; a background job never changes it.
  @override
  Future<void> publish(QueueMarker marker) async {}
}
