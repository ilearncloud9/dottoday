import 'package:dottoday/data/widgets/mac_status_item_sink.dart';
import 'package:dottoday/domain/intents/dot_action.dart';
import 'package:dottoday/domain/intents/dot_intents.dart';
import 'package:flutter/services.dart';

/// Done and more time from the Mac's native surfaces (docs/09 M9.6): the
/// menu bar's +15 min (`macos/Runner/DayDotStatusItem.swift`) and the Now
/// mini window's +5 / +15 / +30 (`NowMiniWindow.swift`, M20.9 part 7) send
/// `action` on `dottoday/status_item`; the app runs the B6 intent in
/// process (the Mac has no queue: both live and die with the app).
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
    'add_time' => switch ((arguments['planned_end_ms'], arguments['minutes'])) {
      (final num end, final int minutes)
          when AddTime.choices.contains(minutes) =>
        AddTime(
          id,
          plannedEndUtc: DateTime.fromMillisecondsSinceEpoch(
            end.toInt(),
            isUtc: true,
          ),
          minutes: minutes,
        ),
      _ => null,
    },
    _ => null,
  };
}
