import 'package:dottoday/core/logging/logger.dart';
import 'package:dottoday/data/db/app_database.dart';
import 'package:dottoday/data/notifications/notification_sync.dart';
import 'package:dottoday/data/repositories/drift_occurrence_repository.dart';
import 'package:dottoday/data/repositories/drift_series_repository.dart';
import 'package:dottoday/data/repositories/drift_settings_repository.dart';
import 'package:dottoday/data/sync/shared_hlc.dart';
import 'package:dottoday/data/widgets/widget_snapshot_writer.dart';
import 'package:dottoday/data/writes/after_write_effects.dart';
import 'package:dottoday/data/writes/drift_write_use_case.dart';
import 'package:dottoday/domain/notifications/notification_gateway.dart';
import 'package:dottoday/domain/notifications/notification_planner.dart';
import 'package:dottoday/domain/notifications/planned_notification.dart';
import 'package:dottoday/domain/recurrence/materialiser.dart';
import 'package:dottoday/domain/widgets/widget_snapshot.dart';
import 'package:drift/native.dart';

import '../../support/fake_clock.dart';
import '../../support/memory_log_sink.dart';

/// Records what the OS would hold; [failNext] simulates a plugin error.
final class FakeGateway implements NotificationGateway {
  final pendingSet = <int, PlannedNotification>{};
  final applied = <NotificationDiff>[];
  bool failNext = false;

  @override
  Future<Map<int, PlannedNotification>> pending() async => {...pendingSet};

  @override
  Future<void> apply(NotificationDiff diff) async {
    if (failNext) {
      failNext = false;
      throw StateError('plugin down');
    }
    applied.add(diff);
    diff.cancel.forEach(pendingSet.remove);
    for (final n in diff.schedule) {
      pendingSet[n.id] = n;
    }
  }
}

final class FakeSink implements WidgetSnapshotSink {
  final written = <WidgetSnapshot>[];

  @override
  Future<void> write(WidgetSnapshot snapshot) async => written.add(snapshot);
}

/// A [DriftWriteUseCase] over an in-memory database with fakes around it.
final class WriteHarness {
  WriteHarness(DateTime now, {AppDatabase? db})
    : clock = FakeClock(now),
      db = db ?? AppDatabase(NativeDatabase.memory()) {
    logger = Logger(logs, clock);
    final occurrences = DriftOccurrenceRepository(this.db);
    effects = AfterWriteEffects(
      notifications: NotificationSync(
        clock: clock,
        planner: NotificationPlanner(clock: clock),
        gateway: gateway,
        occurrences: occurrences,
        series: DriftSeriesRepository(this.db),
        settings: DriftSettingsRepository(this.db),
      ),
      snapshot: WidgetSnapshotWriter(
        clock: clock,
        occurrences: occurrences,
        sink: sink,
      ),
      logger: logger,
    );
    hlc = SharedHlc(this.db, clock);
    writes = DriftWriteUseCase(
      db: this.db,
      clock: clock,
      materialiser: Materialiser(clock: clock),
      effects: effects,
      logger: logger,
      hlc: hlc,
    );
  }

  final FakeClock clock;
  final AppDatabase db;
  final logs = MemoryLogSink();
  late final Logger logger;
  final gateway = FakeGateway();
  final sink = FakeSink();
  late final AfterWriteEffects effects;
  late final DriftWriteUseCase writes;
  late final SharedHlc hlc;

  /// Lets queued after-commit effects finish before closing the database.
  Future<void> dispose() async {
    await effects.idle;
    await db.close();
  }

  Future<List<ChangeLogRow>> changeLog() => db.select(db.changeLog).get();
}
