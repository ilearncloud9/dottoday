import 'dart:convert';

import 'package:dottoday/data/snapshot/snapshot_store_json.dart';
import 'package:dottoday/data/snapshot/web/snapshot_store_stub.dart'
    if (dart.library.js_interop) 'package:dottoday/data/snapshot/web/snapshot_store_web.dart'
    as platform;
import 'package:dottoday/domain/entities/settings.dart';
import 'package:dottoday/domain/snapshot/day_snapshot.dart';
import 'package:flutter/foundation.dart';

/// The web's copy of the day snapshot (docs/09 M9.1): the service worker
/// reads it to act on a notification while no tab is open (M9.7).
///
/// Titles are blanked: browser storage outside the encrypted database is
/// plaintext (06 §4, ADR-0003), and the worker needs only ids and times —
/// a notification brings its own text.
final class WebSnapshotSink implements DaySnapshotSink {
  WebSnapshotSink({
    required Future<Profile> Function() profile,
    void Function(DaySnapshot)? onWrite,
  }) : _profile = profile,
       _onWrite = onWrite;

  final Future<Profile> Function() _profile;

  /// The full snapshot, titles and all, for the tab (M9.7) — in memory only.
  final void Function(DaySnapshot)? _onWrite;

  static bool get supported => kIsWeb;

  @override
  Future<void> write(DaySnapshot snapshot) async {
    _onWrite?.call(snapshot);
    final profile = await _profile();
    final json = snapshotStoreJson(
      snapshot,
      profile: profile,
      use24h:
          profile.settings.use24h ??
          PlatformDispatcher.instance.alwaysUse24HourFormat,
    );
    for (final block
        in (json['blocks']! as List).cast<Map<String, Object?>>()) {
      block['title'] = '';
    }
    await platform.storeSnapshot(jsonEncode(json));
  }
}
