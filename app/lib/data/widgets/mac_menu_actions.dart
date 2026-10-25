import 'package:dottoday/data/widgets/mac_status_item_sink.dart';
import 'package:dottoday/domain/intents/dot_action.dart';
import 'package:dottoday/domain/intents/dot_intents.dart';
import 'package:flutter/services.dart';

/// Done and +15 min from the Mac menu bar's What's next (docs/09 M9.6):
/// `macos/Runner/DayDotStatusItem.swift` sends `action` on
/// `dottoday/status_item`; the app runs the B6 intent in process (the Mac
/// has no queue: the menu bar lives and dies with the app).
void listenForMenuBarActions(
  DotIntents intents, {
  MethodChannel channel = MacStatusItemSink.statusItemChannel,
}) {
  channel.setMethodCallHandler((call) async {
    if (call.method != 'action') return null;
    final action = menuBarAction(call.arguments);
    if (action == null) return null;
    return (await intents.run(action)).name;
  });
}

/// The intent for the menu's arguments, or null when they are malformed.
DotAction? menuBarAction(Object? arguments) {
  if (arguments is! Map) return null;
  final id = arguments['id'];
  if (id is! String || id.isEmpty) return null;
  return switch (arguments['kind']) {
    'mark_done' => MarkDone(id),
    'add_fifteen' => switch (arguments['planned_end_ms']) {
      final num end => AddFifteen(
        id,
        plannedEndUtc: DateTime.fromMillisecondsSinceEpoch(
          end.toInt(),
          isUtc: true,
        ),
      ),
      _ => null,
    },
    _ => null,
  };
}
