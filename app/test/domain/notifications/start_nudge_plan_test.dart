import 'package:dottoday/domain/entities/enums.dart';
import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:dottoday/domain/entities/settings.dart';
import 'package:dottoday/domain/notifications/notification_planner.dart';
import 'package:dottoday/domain/notifications/planned_notification.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest.dart' as tz_data;

import '../../support/fake_clock.dart';
import '../fixtures.dart';

// The Start nudge (docs/15 §11, A0's dot-start input): off by default; on,
// one "Start <dot>?" at planned start + 10 min for a dot without steps,
// none for calendar events or the dot the Wake Up Check asks about.

final _now = DateTime.utc(2026, 10, 21, 8);
final _start = DateTime.utc(2026, 10, 21, 9);

Occurrence _dot(String id, {OccurrenceSource? source, DateTime? start}) =>
    occurrenceFixture().copyWith(
      id: id,
      startUtc: start ?? _start,
      durationMin: 60,
      tzId: 'UTC',
      source: source ?? OccurrenceSource.user,
    );

List<PlannedNotification> _nudges(
  Iterable<Occurrence> dots, {
  Settings settings = const Settings(startNudge: true),
  Set<String> withSteps = const {},
  bool ringsWakeUp = false,
  TimeWindow? quiet,
}) => [
  for (final n in NotificationPlanner(clock: FakeClock(_now)).plan(
    occurrences: dots,
    tzId: 'UTC',
    daily: settings,
    withSteps: withSteps,
    ringsWakeUp: ringsWakeUp,
    quietHours: quiet,
  ))
    if (n.purpose == NotificationPurpose.startNudge) n,
];

void main() {
  setUpAll(tz_data.initializeTimeZones);

  test('off by default: nothing rings differently', () {
    expect(_nudges([_dot('run')], settings: const Settings()), isEmpty);
  });

  test('on: one at start + 10 min, with Start', () {
    final n = _nudges([_dot('run')]).single;
    expect(n.fireAtUtc, _start.add(const Duration(minutes: 10)));
    expect(n.alertIndex, PlannedNotification.startNudgeIndex);
    expect(n.loud, isFalse);
  });

  test('a dot with steps gets Smallest step instead', () {
    expect(_nudges([_dot('run')], withSteps: {'run'}), isEmpty);
  });

  test('calendar events are not asked about', () {
    expect(
      _nudges([_dot('meeting', source: OccurrenceSource.calendar)]),
      isEmpty,
    );
  });

  // Tomorrow: today's Wake Up (07:00) is already past at 08:00.
  test("the Wake Up Check's dot is asked once, not twice", () {
    const settings = Settings(
      startNudge: true,
      wakeUpAlarm: true,
      wakeUpCheck: true,
    );
    final first = _dot('first', start: DateTime.utc(2026, 10, 22, 9));
    final later = _dot('later', start: DateTime.utc(2026, 10, 22, 12));
    final ids = _nudges(
      [first, later],
      settings: settings,
      ringsWakeUp: true,
    ).map((n) => n.occurrenceId);
    expect(ids, ['later']);
  });

  test('quiet hours make it silent', () {
    final n = _nudges([
      _dot('run'),
    ], quiet: const TimeWindow(start: '08:00', end: '11:00')).single;
    expect(n.silent, isTrue);
  });
}
