import 'package:dottoday/data/notifications/notification_sync.dart';
import 'package:dottoday/data/repositories/drift_occurrence_repository.dart';
import 'package:dottoday/data/repositories/drift_series_repository.dart';
import 'package:dottoday/data/repositories/drift_settings_repository.dart';
import 'package:dottoday/data/repositories/drift_subtask_repository.dart';
import 'package:dottoday/domain/notifications/notification_planner.dart';
import 'package:dottoday/domain/notifications/planned_notification.dart';
import 'package:dottoday/domain/scheduling/task_progress.dart' as progress;
import 'package:dottoday/domain/writes/write_batch.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../domain/fixtures.dart';
import '../writes/write_harness.dart';

// Smallest step through the real database (docs/09 M10.6): a task with a
// step left gets its reminder; starting it (Focus) takes it away.

void main() {
  test('pending while a step is left and nobody started; gone after', () async {
    final now = DateTime.utc(2026, 10, 21, 8);
    final h = WriteHarness(now);
    addTearDown(h.dispose);
    final task = occurrenceFixture().copyWith(
      startUtc: now.add(const Duration(hours: 1)),
      durationMin: 60,
    );
    final step = subtaskFixture().copyWith(occurrenceId: task.id);
    await h.writes.apply(
      WriteBatch(
        userId: userId,
        profile: profileFixture(),
        occurrences: [task],
        subtasks: [step],
      ),
    );
    await h.effects.idle;
    final gateway = FakeGateway();
    final sync = NotificationSync(
      clock: h.clock,
      planner: NotificationPlanner(clock: h.clock),
      gateway: gateway,
      occurrences: DriftOccurrenceRepository(h.db),
      series: DriftSeriesRepository(h.db),
      settings: DriftSettingsRepository(h.db),
      subtasks: DriftSubtaskRepository(h.db),
    );
    bool pending() => gateway.pendingSet.values.any(
      (n) => n.purpose == NotificationPurpose.smallestStep,
    );
    await sync.resync(userId);
    expect(pending(), isTrue);

    await h.writes.apply(
      WriteBatch(
        userId: userId,
        occurrences: [progress.markStarted(task, now)],
      ),
    );
    await h.effects.idle;
    await sync.resync(userId);
    expect(pending(), isFalse);
  });
}
