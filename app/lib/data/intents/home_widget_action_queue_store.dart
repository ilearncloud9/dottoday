import 'package:dottoday/data/intents/action_queue_json.dart';
import 'package:dottoday/data/widgets/home_widget_sink.dart';
import 'package:dottoday/domain/intents/action_queue_store.dart';
import 'package:home_widget/home_widget.dart';

/// The action queue in the store the widgets already share with the app
/// (docs/09 M9.2): the iOS App Group `UserDefaults` (written by the App
/// Intents in the app and the widget extension) and Android's
/// `home_widget` prefs (written by `DotActionReceiver`). Same key on both.
final class HomeWidgetActionQueueStore implements ActionQueueStore {
  const HomeWidgetActionQueueStore();

  @override
  Future<List<Object?>> read() async {
    await HomeWidget.setAppGroupId(HomeWidgetSink.appGroupId);
    return decodeQueueArray(
      await HomeWidget.getWidgetData<String>(actionQueueKey),
    );
  }

  // Re-reads right before writing, so an action a surface appended during
  // the drain survives; the gap is one platform call.
  @override
  Future<void> remove(Set<String> ids, {bool unreadable = false}) async {
    if (ids.isEmpty && !unreadable) return;
    await HomeWidget.setAppGroupId(HomeWidgetSink.appGroupId);
    final raw = await HomeWidget.getWidgetData<String>(actionQueueKey);
    await HomeWidget.saveWidgetData<String>(
      actionQueueKey,
      withoutEntries(raw, ids, unreadable: unreadable),
    );
  }
}
