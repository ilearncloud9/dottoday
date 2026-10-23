import 'package:dottoday/data/notifications/notification_platform.dart';
import 'package:dottoday/data/notifications/os_notification_gateway.dart';
import 'package:dottoday/domain/entities/alert.dart';
import 'package:dottoday/domain/entities/enums.dart';
import 'package:dottoday/domain/notifications/notification_planner.dart';
import 'package:dottoday/domain/notifications/planned_notification.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest.dart' as tz_data;

import '../../support/fake_clock.dart';
import '../../support/fake_notification_platform.dart';
import '../../support/timeline_fakes.dart';

void main() {
  setUpAll(tz_data.initializeTimeZones);

  final now = DateTime.utc(2026, 10, 21, 6);
  late FakeOccurrenceRepository repo;
  late FakeNotificationPlatform platform;
  late OsNotificationGateway gateway;
  late NotificationPlanner planner;

  setUp(() {
    repo = FakeOccurrenceRepository([
      for (final o in demoDayRows(DateTime(2026, 10, 21)))
        if (o.startUtc != null && o.status == OccurrenceStatus.planned)
          o.copyWith(
            alerts: const [
              Alert(kind: AlertKind.before, offsetMin: 10),
              Alert(kind: AlertKind.atStart),
            ],
          ),
    ]);
    platform = FakeNotificationPlatform();
    gateway = OsNotificationGateway(
      platform: () async => platform,
      occurrences: repo,
      profile: () async => testProfile(),
    );
    planner = NotificationPlanner(clock: FakeClock(now));
  });

  List<PlannedNotification> plan() => planner.plan(
    occurrences: repo.rows,
    tzId: 'Europe/Berlin',
    seriesAlerts: const {},
    quietHours: null,
    bedtimeFrom: null,
  );

  Future<void> resync() async =>
      gateway.apply(NotificationPlanner.diff(plan(), await gateway.pending()));

  test(
    'schedules each alert once; a second resync changes nothing (R-10)',
    () async {
      await resync();
      final first = platform.scheduled.length;
      expect(first, plan().length);
      expect(first, greaterThan(10));
      await resync();
      await resync();
      expect(platform.scheduled.length, first);
      expect(platform.cancelled, isEmpty);
      expect(platform.pendingById.length, first);
    },
  );

  test('posts the title with when, IDs only in the payload', () async {
    await resync();
    final gym = platform.scheduled.firstWhere(
      (n) => n.title == 'Gym' && n.body.startsWith('Starts in'),
    );
    expect(gym.body, 'Starts in 10 minutes');
    expect(gym.payload, isNot(contains('Gym')));
    expect(
      platform.scheduled.where((n) => n.title == 'Gym').map((n) => n.body),
      containsAll(['Starts in 10 minutes', 'Starting now']),
    );
  });

  test('a rename re-posts that task only', () async {
    await resync();
    final before = platform.scheduled.length;
    final gym = repo.rows.firstWhere((o) => o.title == 'Gym');
    repo.put([gym.copyWith(title: 'Climbing')]);
    await resync();
    final again = platform.scheduled.sublist(before);
    expect(again.map((n) => n.title).toSet(), {'Climbing'});
    expect(again, hasLength(2));
    expect(platform.cancelled, hasLength(2));
  });

  test('a done task loses its alerts; a moved one is re-timed', () async {
    await resync();
    final gym = repo.rows.firstWhere((o) => o.title == 'Gym');
    final read = repo.rows.firstWhere((o) => o.title == 'Read');
    repo.put([
      gym.copyWith(status: OccurrenceStatus.done),
      read.copyWith(startUtc: read.startUtc!.add(const Duration(hours: 1))),
    ]);
    await resync();
    final titles = platform.pendingById.values.map((n) => n.title);
    expect(titles, isNot(contains('Gym')));
    expect(titles.where((t) => t == 'Read'), hasLength(2));
    expect(plan().map((p) => p.id).toSet(), platform.pendingById.keys.toSet());
  });

  test('a foreign or corrupt pending notification is replaced', () async {
    await resync();
    final victim = platform.pendingById.values.first;
    platform.pendingById[victim.id] = OsNotification(
      id: victim.id,
      title: victim.title,
      body: victim.body,
      fireAtUtc: victim.fireAtUtc,
      payload: 'garbage',
      channel: victim.channel,
    );
    await resync();
    expect(platform.cancelled, [victim.id]);
    expect(platform.pendingById[victim.id]!.payload, victim.payload);
  });

  test('a task deleted between plan and apply is not posted', () async {
    final desired = plan();
    repo.put([for (final o in repo.rows) o.copyWith(deletedAt: now)]);
    await gateway.apply(NotificationPlanner.diff(desired, const {}));
    expect(platform.scheduled, isEmpty);
  });
}
