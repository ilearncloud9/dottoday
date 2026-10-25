import 'package:dottoday/core/logging/logger.dart';
import 'package:dottoday/data/notifications/notification_platform.dart';
import 'package:dottoday/data/notifications/notification_responder.dart';
import 'package:dottoday/domain/entities/enums.dart';
import 'package:dottoday/domain/notifications/notification_payload.dart';
import 'package:dottoday/domain/notifications/planned_notification.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest.dart' as tz_data;

import '../../support/fake_clock.dart';
import '../../support/memory_log_sink.dart';
import '../../support/timeline_fakes.dart';

void main() {
  setUpAll(tz_data.initializeTimeZones);

  final now = DateTime.utc(2026, 10, 21, 15, 20);
  late FakeOccurrenceRepository repo;
  late FakeWriteUseCase writes;
  late List<String> opened;
  late NotificationResponder responder;

  setUp(() {
    repo = FakeOccurrenceRepository(demoDayRows(DateTime(2026, 10, 21)));
    writes = FakeWriteUseCase(FakeSettingsRepository(testProfile()), repo);
    opened = [];
    final clock = FakeClock(now);
    responder = NotificationResponder(
      clock: clock,
      writes: writes,
      occurrences: repo,
      profile: () async => testProfile(),
      open: opened.add,
      logger: Logger(MemoryLogSink(), clock),
    );
  });

  String gymId() => repo.rows.firstWhere((o) => o.title == 'Gym').id;

  NotificationTap tap(String occurrenceId, String? action) => NotificationTap(
    id: 9,
    actionId: action,
    payload: encodeNotificationPayload(
      PlannedNotification(
        id: 9,
        occurrenceId: occurrenceId,
        alertIndex: 0,
        fireAtUtc: now,
        kind: AlertKind.before,
      ),
    ),
  );

  test('Done ticks this occurrence only (R-09)', () async {
    await responder.handle(tap(gymId(), 'done'));
    final gym = repo.rows.firstWhere((o) => o.id == gymId());
    expect(gym.status, OccurrenceStatus.done);
    expect(gym.completedAtUtc, now);
    expect(gym.actualEndUtc, now, reason: 'Done from a notification ends it');
    expect(writes.applied.single.occurrences, hasLength(1));
    expect(opened, isEmpty);
  });

  test('Snooze sets a reminder 10 minutes on, nothing else moves', () async {
    final before = repo.rows.firstWhere((o) => o.id == gymId());
    await responder.handle(tap(gymId(), 'snooze'));
    final gym = repo.rows.firstWhere((o) => o.id == gymId());
    expect(gym.snoozedUntilUtc, now.add(const Duration(minutes: 10)));
    expect(gym.startUtc, before.startUtc);
    expect(gym.status, OccurrenceStatus.planned);
  });

  test('+15 (the web, M9.7) gives the task 15 more minutes', () async {
    final before = repo.rows.firstWhere((o) => o.id == gymId());
    await responder.handle(tap(gymId(), 'plus15'));
    final gym = repo.rows.firstWhere((o) => o.id == gymId());
    expect(gym.durationMin, before.durationMin + 15);
    expect(gym.startUtc, before.startUtc);
    expect(opened, isEmpty);
  });

  test('Open and a plain tap show the task', () async {
    await responder.handle(tap(gymId(), 'open'));
    await responder.handle(tap(gymId(), null));
    expect(opened, ['/task/${gymId()}', '/task/${gymId()}']);
    expect(writes.applied, isEmpty);
  });

  test('a payload that is not ours, or a gone task, opens Today', () async {
    await responder.handle(
      const NotificationTap(payload: 'x', actionId: 'done'),
    );
    final gym = repo.rows.firstWhere((o) => o.id == gymId());
    repo.put([gym.copyWith(deletedAt: now)]);
    await responder.handle(tap(gymId(), 'done'));
    expect(opened, ['/today', '/today']);
    expect(writes.applied, isEmpty);
  });

  test('the day-start summary opens Today, not its first task', () async {
    await responder.handle(
      NotificationTap(
        id: 10,
        payload: encodeNotificationPayload(
          PlannedNotification(
            id: 10,
            occurrenceId: gymId(),
            alertIndex: PlannedNotification.daySummaryIndex,
            fireAtUtc: now,
            kind: AlertKind.atStart,
            purpose: NotificationPurpose.daySummary,
            blocks: 4,
          ),
        ),
      ),
    );
    expect(opened, ['/today']);
    expect(writes.applied, isEmpty);
  });

  test('Start (Smallest step) opens Focus and writes nothing itself', () async {
    await responder.handle(tap(gymId(), 'start'));
    expect(opened, ['/focus/${gymId()}']);
    expect(writes.applied, isEmpty, reason: 'Focus records the start');
  });
}
