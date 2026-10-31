import 'package:dottoday/domain/entities/enums.dart';
import 'package:dottoday/domain/scheduling/start_escalation.dart';
import 'package:dottoday/domain/wake_up/wake_up_day.dart';
import 'package:flutter_test/flutter_test.dart';

import '../fixtures.dart';

// One "still not started?" scheduler, two inputs (11 A0/B2, docs/15 W3):
// the Wake Up Check waits on "I'm up", Smallest step on a dot's start.

void main() {
  DateTime at(int h, int m) => DateTime.utc(2026, 11, 2, h, m);
  final up = WakeUpDay(date: '2026-11-02', stoppedAtUtc: at(7, 5));
  final run = occurrenceFixture().copyWith(
    startUtc: at(7, 30),
    durationMin: 30,
  );

  group('Wake Up Check (15 W3 AC)', () {
    test("I'm up + 10 min with no start: exactly one check", () {
      expect(escalationAt(WakeUpStart(up, firstDot: run)), at(7, 15));
      expect(
        escalationAt(WakeUpStart(up, firstDot: run), afterMin: 20),
        at(7, 25),
      );
    });

    test('a start at minute 4 calls it off', () {
      expect(
        escalationAt(
          WakeUpStart(up, firstDot: run.copyWith(actualStartUtc: at(7, 9))),
        ),
        isNull,
      );
      expect(
        escalationAt(WakeUpStart(up.copyWith(startedAtUtc: at(7, 9)))),
        isNull,
        reason: "the card's Start the day",
      );
      expect(
        escalationAt(
          WakeUpStart(
            up,
            firstDot: run.copyWith(status: OccurrenceStatus.done),
          ),
        ),
        isNull,
      );
    });

    test('two stops in a day: still one check, from the last', () {
      var day = const WakeUpDay(date: '2026-11-02');
      for (final stop in [at(7, 5), at(7, 30)]) {
        day = applyAlarmEvent(
          day,
          AlarmEvent('wakeup:2026-11-02', AlarmEventKind.stopped, stop),
        );
      }
      expect(escalationAt(WakeUpStart(day)), at(7, 40));
    });

    test('nothing stopped, nothing to check', () {
      expect(
        escalationAt(const WakeUpStart(WakeUpDay(date: '2026-11-02'))),
        isNull,
      );
    });
  });

  test('a dot: its start + N, the same rule (Smallest step)', () {
    expect(escalationAt(DotStart(run)), at(7, 40));
    expect(
      escalationAt(DotStart(run.copyWith(actualStartUtc: at(7, 31)))),
      isNull,
    );
  });
}
