import 'dart:async';
import 'dart:convert';

import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/data/live_activity/live_activity_sink.dart';
import 'package:dottoday/data/live_activity/web_live_dot.dart';
import 'package:dottoday/data/notifications/notification_sync.dart';
import 'package:dottoday/data/repositories/drift_occurrence_repository.dart';
import 'package:dottoday/data/repositories/drift_series_repository.dart';
import 'package:dottoday/data/repositories/drift_settings_repository.dart';
import 'package:dottoday/data/snapshot/composite_snapshot_sink.dart';
import 'package:dottoday/data/snapshot/day_snapshot_writer.dart';
import 'package:dottoday/data/snapshot/snapshot_store_json.dart';
import 'package:dottoday/data/sync/shared_hlc.dart';
import 'package:dottoday/data/writes/after_write_effects.dart';
import 'package:dottoday/data/writes/drift_write_use_case.dart';
import 'package:dottoday/domain/intents/dot_action.dart';
import 'package:dottoday/domain/intents/dot_intents.dart';
import 'package:dottoday/domain/notifications/notification_planner.dart';
import 'package:dottoday/domain/recurrence/materialiser.dart';
import 'package:dottoday/domain/snapshot/day_snapshot.dart';
import 'package:dottoday/domain/writes/write_batch.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

import '../../domain/fixtures.dart';
import '../writes/write_harness.dart';

// The consistency gate (docs/09 M9.8, docs/11 A1): one change — Done, +15,
// a rename — and every surface outside the app shows the same dot within
// 1 s: the day snapshot, the widgets' and the menu bar's stored JSON (the
// native readers' rule replayed on it), the Live Activity / Android ongoing
// content state, and the web tab.

/// What one surface shows: the dot it is about, or null for none.
typedef Shown = ({String id, String title, int endMs})?;

/// The rule Swift (Snapshot.swift live/next), Kotlin (WidgetSnapshot.kt)
/// and the menu bar (DayDotStatusItem.swift) apply to the stored JSON.
Shown nativeReader(Map<String, Object?> json, DateTime now) {
  final ms = now.millisecondsSinceEpoch;
  final open = [
    for (final b in (json['blocks']! as List).cast<Map<String, Object?>>())
      if (b['done'] != true) b,
  ];
  final live = open.where(
    (b) => (b['start_ms']! as int) <= ms && ms < (b['end_ms']! as int),
  );
  final b = live.firstOrNull;
  return b == null
      ? null
      : (
          id: b['id']! as String,
          title: b['title']! as String,
          endMs: b['end_ms']! as int,
        );
}

void main() {
  final now = DateTime.utc(2026, 10, 21, 14);
  late WriteHarness h;
  late DotIntents intents;
  late AfterWriteEffects effects;
  late DriftWriteUseCase writes;
  late List<Map<String, Object?>?> liveCalls;
  late DaySnapshot? lastSnapshot;
  late Map<String, Object?>? lastStore;
  const channel = MethodChannel('test/live_dot');
  final task = occurrenceFixture().copyWith(
    startUtc: now.subtract(const Duration(minutes: 10)),
    durationMin: 30,
  );

  setUpAll(initializeDateFormatting);

  setUp(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    h = WriteHarness(now);
    liveCalls = [];
    lastSnapshot = null;
    lastStore = null;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
          liveCalls.add(
            call.arguments == null
                ? null
                : jsonDecode(call.arguments as String) as Map<String, Object?>,
          );
          return null;
        });
    final occurrences = DriftOccurrenceRepository(h.db);
    final sink = CompositeSnapshotSink([
      _Recording((s) async {
        lastSnapshot = s;
        lastStore = snapshotStoreJson(
          s,
          profile: profileFixture(),
          use24h: true,
        );
      }),
      LiveActivitySink(
        clock: h.clock,
        profile: () async => profileFixture(),
        channel: channel,
        timer: (_, _) => Timer(Duration.zero, () {})..cancel(),
      ),
    ]);
    // The harness's effects, with the real snapshot sinks.
    effects = AfterWriteEffects(
      notifications: NotificationSync(
        clock: h.clock,
        planner: NotificationPlanner(clock: h.clock),
        gateway: h.gateway,
        occurrences: occurrences,
        series: DriftSeriesRepository(h.db),
        settings: DriftSettingsRepository(h.db),
      ),
      snapshot: DaySnapshotWriter(
        clock: h.clock,
        occurrences: occurrences,
        profile: () async => profileFixture(),
        sink: sink,
      ),
      logger: h.logger,
    );
    writes = DriftWriteUseCase(
      db: h.db,
      clock: h.clock,
      materialiser: Materialiser(clock: h.clock),
      effects: effects,
      logger: h.logger,
      hlc: SharedHlc(h.db, h.clock),
    );
    intents = DotIntents(
      clock: h.clock,
      writes: writes,
      occurrences: occurrences,
      series: DriftSeriesRepository(h.db),
      profile: () async => profileFixture(),
      snapshot: () => throw UnimplementedError(),
      untitled: (_) => 'Untitled',
    );
    await writes.apply(
      WriteBatch(
        userId: userId,
        profile: profileFixture(),
        occurrences: [task],
      ),
    );
    await effects.idle;
  });
  tearDown(() async {
    await effects.idle;
    await h.dispose();
  });

  /// Every surface, after the change: what each one shows.
  Map<String, Shown> surfaces() {
    final snap = lastSnapshot!.currentAt(now);
    final live = liveCalls.last;
    final tab = webLiveDot(
      lastSnapshot,
      now,
      lookupAppLocalizations(const Locale('en')),
    );
    return {
      'snapshot': snap == null
          ? null
          : (
              id: snap.id,
              title: snap.title,
              endMs: snap.endUtc.millisecondsSinceEpoch,
            ),
      'widgets + menu bar': nativeReader(lastStore!, now),
      'live activity / ongoing': live == null || live['live'] != true
          ? null
          : (
              id: live['id']! as String,
              title: live['title']! as String,
              endMs: live['end_ms']! as int,
            ),
      'web tab': tab.title == null
          ? null
          : (
              id: snap!.id,
              title: tab.title!.split(' · ').last.replaceFirst('● ', ''),
              endMs: snap.endUtc.millisecondsSinceEpoch,
            ),
    };
  }

  Future<Map<String, Shown>> change(Future<void> Function() act) async {
    final watch = Stopwatch()..start();
    await act();
    await effects.idle;
    expect(watch.elapsed, lessThan(const Duration(seconds: 1)));
    return surfaces();
  }

  void allShow(Map<String, Shown> shown, Shown expected) {
    for (final MapEntry(key: surface, value: dot) in shown.entries) {
      expect(dot, expected, reason: surface);
    }
  }

  final end = task.endUtc!.millisecondsSinceEpoch;

  test('rename: every surface shows the new title', () async {
    final shown = await change(() async {
      await writes.apply(
        WriteBatch(
          userId: userId,
          occurrences: [task.copyWith(title: 'Renamed')],
        ),
      );
    });
    allShow(shown, (id: task.id, title: 'Renamed', endMs: end));
  });

  test('+15: every surface shows the new end', () async {
    final shown = await change(
      () => intents.run(AddFifteen(task.id, plannedEndUtc: task.endUtc!)),
    );
    allShow(shown, (id: task.id, title: task.title, endMs: end + 15 * 60000));
  });

  test('Done: no surface shows the dot any more', () async {
    final shown = await change(() => intents.run(MarkDone(task.id)));
    allShow(shown, null);
  });
}

final class _Recording implements DaySnapshotSink {
  _Recording(this.onWrite);

  final Future<void> Function(DaySnapshot) onWrite;

  @override
  Future<void> write(DaySnapshot snapshot) => onWrite(snapshot);
}
