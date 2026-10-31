import 'dart:async';

import 'package:flutter/services.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'system_events.g.dart';

/// What the operating system announces while the app runs, so the app acts
/// on the event instead of checking on a timer (docs/04 §4 "Triggers").
enum SystemEvent {
  /// The Mac woke from sleep: timers armed before may have fired late.
  wake,

  /// The clock, date or time zone changed (or, on iOS, the day turned
  /// over): what is due moves.
  clock,

  /// The device's calendars changed (another app, an account sync, or
  /// Dottoday's own write-back).
  calendar,
}

/// The OS's announcements, as a port so tests send their own.
abstract interface class SystemEvents {
  /// Every event from now on.
  Stream<SystemEvent> get events;

  /// Ends [events].
  Future<void> close();
}

/// [SystemEvents] over `dottoday/system_events`: iOS (ios/Runner/AppDelegate.swift), macOS
/// (macos/Runner/AppDelegate.swift) and Android
/// (android/.../SystemEvents.kt) call one method per [SystemEvent], by name.
/// The web has no such channel; its tab becoming visible is a resume.
final class ChannelSystemEvents implements SystemEvents {
  ChannelSystemEvents([
    MethodChannel channel = const MethodChannel('dottoday/system_events'),
  ]) {
    channel.setMethodCallHandler((call) async {
      final event = SystemEvent.values.asNameMap()[call.method];
      if (event != null) _out.add(event);
    });
  }

  final _out = StreamController<SystemEvent>.broadcast();

  @override
  Stream<SystemEvent> get events => _out.stream;

  @override
  Future<void> close() => _out.close();
}

@Riverpod(keepAlive: true)
SystemEvents systemEvents(Ref ref) {
  final events = ChannelSystemEvents();
  ref.onDispose(() => unawaited(events.close()));
  return events;
}
