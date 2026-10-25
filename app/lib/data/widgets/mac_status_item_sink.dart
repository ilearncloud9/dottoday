import 'dart:convert';

import 'package:dottoday/data/snapshot/snapshot_store_json.dart';
import 'package:dottoday/domain/entities/settings.dart';
import 'package:dottoday/domain/snapshot/day_snapshot.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// "Next up" in the Mac menu bar (docs/02 F9, docs/07 macOS, M5.5): the
/// same display snapshot as the iOS/Android widgets, handed to the
/// `NSStatusItem` in `macos/Runner/AppDelegate.swift`, which lays it out and
/// moves on at each start and end by itself.
final class MacStatusItemSink implements DaySnapshotSink {
  MacStatusItemSink({
    required Future<Profile> Function() profile,
    MethodChannel channel = statusItemChannel,
  }) : _profile = profile,
       _channel = channel;

  static const statusItemChannel = MethodChannel('dottoday/status_item');

  final Future<Profile> Function() _profile;
  final MethodChannel _channel;

  static bool get supported =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.macOS;

  @override
  Future<void> write(DaySnapshot snapshot) async {
    final profile = await _profile();
    final json = snapshotStoreJson(
      snapshot,
      profile: profile,
      use24h:
          profile.settings.use24h ??
          PlatformDispatcher.instance.alwaysUse24HourFormat,
    );
    await _channel.invokeMethod<void>('update', jsonEncode(json));
  }
}
