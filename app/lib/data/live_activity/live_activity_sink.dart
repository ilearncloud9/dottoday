import 'dart:async';
import 'dart:convert';

import 'package:dottoday/core/clock/clock.dart';
import 'package:dottoday/data/live_activity/live_activity_content.dart';
import 'package:dottoday/domain/entities/settings.dart';
import 'package:dottoday/domain/live_activity/live_dot_plan.dart';
import 'package:dottoday/domain/snapshot/day_snapshot.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// The live dot outside the app (docs/11 A1): the iOS Live Activity (M9.3,
/// `dottoday/live_activity`, ios/Runner/AppDelegate.swift) and the Android
/// ongoing notification (M9.4, `dottoday/ongoing`, OngoingDot.kt) — one
/// lifecycle, one content. On every snapshot it works out the plan
/// ([liveDotPlan]) and hands the content to the native side, which shows,
/// updates or ends the one surface (`sync` with null = end).
/// While the app is open it re-plans on time — a dot coming within the
/// hour, starting, or passing its grace — from the last snapshot.
final class LiveActivitySink implements DaySnapshotSink {
  LiveActivitySink({
    required Clock clock,
    required Future<Profile> Function() profile,
    MethodChannel channel = liveActivityChannel,
    Timer Function(Duration, void Function()) timer = Timer.new,
  }) : _clock = clock,
       _profile = profile,
       _channel = channel,
       _timer = timer;

  static const liveActivityChannel = MethodChannel('dottoday/live_activity');
  static const ongoingChannel = MethodChannel('dottoday/ongoing');

  /// This platform's channel, or null where there is no such surface.
  static MethodChannel? get platformChannel {
    if (kIsWeb) return null;
    return switch (defaultTargetPlatform) {
      TargetPlatform.iOS => liveActivityChannel,
      TargetPlatform.android => ongoingChannel,
      _ => null,
    };
  }

  final Clock _clock;
  final Future<Profile> Function() _profile;
  final MethodChannel _channel;
  final Timer Function(Duration, void Function()) _timer;
  DaySnapshot? _last;
  Timer? _pending;

  static bool get supported => platformChannel != null;

  @override
  Future<void> write(DaySnapshot snapshot) async {
    _last = snapshot;
    await _sync();
  }

  Future<void> _sync() async {
    final snapshot = _last;
    if (snapshot == null) return;
    final now = _clock.nowUtc();
    final plan = liveDotPlan(snapshot, now);
    final profile = await _profile();
    final content = plan == null
        ? null
        : liveActivityContent(
            plan,
            profile: profile,
            use24h:
                profile.settings.use24h ??
                PlatformDispatcher.instance.alwaysUse24HourFormat,
          );
    try {
      await _channel.invokeMethod<void>(
        'sync',
        content == null ? null : jsonEncode(content),
      );
    } on MissingPluginException {
      // An engine without the surface (Android's background refresh): the
      // notification times out by itself; the next app start syncs it.
      return;
    }
    _pending?.cancel();
    final next = nextPlanChange(snapshot, now);
    if (next != null) {
      _pending = _timer(next.difference(now), () => unawaited(_sync()));
    }
  }
}
