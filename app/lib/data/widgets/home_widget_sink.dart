import 'dart:convert';

import 'package:dottoday/data/widgets/widget_display.dart';
import 'package:dottoday/domain/entities/settings.dart';
import 'package:dottoday/domain/widgets/widget_snapshot.dart';
import 'package:flutter/foundation.dart';
import 'package:home_widget/home_widget.dart';

/// Home-screen widgets on iOS and Android (docs/02 F9, docs/09 M5.4): the
/// display JSON goes to the shared container (iOS app group / Android
/// prefs) and every widget is asked to redraw. macOS shows "Next up" in
/// the menu bar instead (M5.5); the web has no widgets.
final class HomeWidgetSnapshotSink implements WidgetSnapshotSink {
  HomeWidgetSnapshotSink({required Future<Profile> Function() profile})
    : _profile = profile;

  final Future<Profile> Function() _profile;

  /// Shared with the WidgetKit extension (both entitlements files).
  static const appGroupId = 'group.app.dottoday.planner';

  /// The key the native widgets read.
  static const dataKey = 'snapshot';

  /// (iOS kind, Android receiver) per widget.
  static const widgets = [
    ('NextUpWidget', 'app.dottoday.planner.widgets.NextUpWidgetReceiver'),
    ('TodayWidget', 'app.dottoday.planner.widgets.TodayWidgetReceiver'),
    ('InboxWidget', 'app.dottoday.planner.widgets.InboxWidgetReceiver'),
  ];

  static bool get supported =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.iOS ||
          defaultTargetPlatform == TargetPlatform.android);

  @override
  Future<void> write(WidgetSnapshot snapshot) async {
    if (!supported) return;
    final profile = await _profile();
    final json = widgetDisplayJson(
      snapshot,
      profile: profile,
      use24h:
          profile.settings.use24h ??
          PlatformDispatcher.instance.alwaysUse24HourFormat,
    );
    await HomeWidget.setAppGroupId(appGroupId);
    await HomeWidget.saveWidgetData<String>(dataKey, jsonEncode(json));
    for (final (ios, android) in widgets) {
      await HomeWidget.updateWidget(
        iOSName: ios,
        qualifiedAndroidName: android,
      );
    }
    await _scheduleRedraws(snapshot);
  }

  /// Android redraws "Next up" and "Today" at each start and end so they
  /// move on without the app; iOS gets the same from its timeline entries.
  Future<void> _scheduleRedraws(WidgetSnapshot snapshot) async {
    if (defaultTargetPlatform != TargetPlatform.android) return;
    final times = redrawTimes(snapshot);
    for (final (_, android) in widgets.take(2)) {
      await HomeWidget.scheduleWidgetUpdates(
        times,
        qualifiedAndroidName: android,
      );
    }
  }

  /// Every block start and end after the snapshot, earliest first.
  @visibleForTesting
  static List<DateTime> redrawTimes(WidgetSnapshot snapshot) {
    final now = snapshot.generatedAtUtc;
    return {
      for (final b in snapshot.blocks) ...[
        b.startUtc,
        b.startUtc.add(Duration(minutes: b.durationMin)),
      ],
    }.where((t) => t.isAfter(now)).toList()..sort();
  }
}
