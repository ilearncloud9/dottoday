import 'package:dottoday/domain/entities/alert.dart';
import 'package:dottoday/domain/entities/enums.dart';
import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:dottoday/domain/entities/settings.dart';
import 'package:dottoday/domain/notifications/notification_planner.dart';
import 'package:dottoday/domain/notifications/planned_notification.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest.dart' as tz_data;

import '../../support/fake_clock.dart';
import '../fixtures.dart';

// Low-energy mode (docs/09 M12.2, 11 D2): every nudge before the next
// Wake Up is off; alarm-loud dot starts still ring (A0); from Wake Up on,
// everything is planned as usual.

const _alerts = [
  Alert(kind: AlertKind.atStart),
  Alert(kind: AlertKind.before, offsetMin: 10),
];

Occurrence _task(String id, DateTime start) => occurrenceFixture().copyWith(
  id: id,
  startUtc: start,
  durationMin: 30,
  alerts: _alerts,
  tzId: 'UTC',
);

final _now = DateTime.utc(2026, 10, 21, 5);
final _wake = DateTime.utc(2026, 10, 22, 7);

List<PlannedNotification> _plan({DateTime? until, DateTime? now}) =>
    NotificationPlanner(clock: FakeClock(now ?? _now)).plan(
      occurrences: [
        _task('wed-1', DateTime.utc(2026, 10, 21, 7)),
        _task('wed-2', DateTime.utc(2026, 10, 21, 9)),
        _task('thu-1', DateTime.utc(2026, 10, 22, 7, 30)),
        _task('thu-2', DateTime.utc(2026, 10, 22, 9)),
      ],
      tzId: 'UTC',
      daily: Settings(windDownReminder: true, lowEnergyUntil: until),
    );

void main() {
  setUpAll(tz_data.initializeTimeZones);

  test('until Wake Up only the loud first dot rings', () {
    final before = [
      for (final n in _plan(until: _wake))
        if (n.fireAtUtc.isBefore(_wake)) n,
    ];
    expect(before.map((n) => (n.occurrenceId, n.loud)), [('wed-1', true)]);
  });

  test('from Wake Up everything is planned as usual', () {
    final on = _plan(until: _wake).where((n) => !n.fireAtUtc.isBefore(_wake));
    final off = _plan().where((n) => !n.fireAtUtc.isBefore(_wake));
    expect(on.map((n) => n.id), off.map((n) => n.id));
    expect(on.map((n) => n.occurrenceId), containsAll(['thu-1', 'thu-2']));
  });

  test('a passed low-energy end changes nothing', () {
    final ended = _plan(until: _wake, now: _wake.add(const Duration(hours: 1)));
    final plain = _plan(now: _wake.add(const Duration(hours: 1)));
    expect(ended.map((n) => n.id), plain.map((n) => n.id));
  });
}
