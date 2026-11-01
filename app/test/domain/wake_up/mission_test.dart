import 'package:dottoday/domain/entities/enums.dart';
import 'package:dottoday/domain/entities/settings.dart';
import 'package:dottoday/domain/notifications/alarm_capabilities.dart';
import 'package:dottoday/domain/wake_up/mission.dart';
import 'package:flutter_test/flutter_test.dart';

// docs/15 §8: which mornings ask for a mission, and which one.

MissionPlan? _plan(
  Settings s, {
  Weekday day = Weekday.mon,
  AlarmTier tier = AlarmTier.alarm,
  int dots = 3,
  bool Function(MissionKind)? can,
  bool flagged = false,
}) => missionFor(
  s,
  weekday: day,
  tier: tier,
  dots: dots,
  can: can ?? (_) => true,
  flagged: flagged,
);

void main() {
  group('modes', () {
    test('off by default, even on a flagged morning', () {
      expect(_plan(const Settings()), isNull);
      expect(_plan(const Settings(), flagged: true), isNull);
    });

    test('only after a snooze: Stand up, after a snooze', () {
      expect(
        _plan(const Settings(missionMode: MissionMode.afterSnooze)),
        const MissionPlan(MissionKind.standUp, afterSnooze: true),
      );
    });

    test('a flagged morning asks from the first ring', () {
      expect(
        _plan(
          const Settings(missionMode: MissionMode.afterSnooze),
          flagged: true,
        ),
        const MissionPlan(MissionKind.standUp, afterSnooze: false),
      );
    });

    test('only when I ask: flagged mornings only', () {
      const s = Settings(missionMode: MissionMode.whenAsked);
      expect(_plan(s), isNull);
      expect(
        _plan(s, flagged: true),
        const MissionPlan(MissionKind.standUp, afterSnooze: false),
      );
    });

    test('chosen days: weekdays by default, plus flags', () {
      const s = Settings(missionMode: MissionMode.chosenDays);
      expect(_plan(s, day: Weekday.fri), isNotNull);
      expect(_plan(s, day: Weekday.sat), isNull);
      expect(_plan(s, day: Weekday.sat, flagged: true), isNotNull);
    });

    test('every time', () {
      expect(
        _plan(const Settings(missionMode: MissionMode.always)),
        const MissionPlan(MissionKind.standUp, afterSnooze: false),
      );
    });

    test('needs the alarm tier', () {
      const s = Settings(missionMode: MissionMode.always);
      for (final tier in AlarmTier.values) {
        expect(_plan(s, tier: tier) != null, tier == AlarmTier.alarm);
      }
    });
  });

  group('which mission', () {
    const one = Settings(
      missionMode: MissionMode.always,
      missionKind: MissionKind.oneThing,
    );

    test('Pick today\'s one thing needs two dots', () {
      expect(_plan(one, dots: 2)?.kind, MissionKind.oneThing);
      expect(_plan(one, dots: 1), isNull, reason: 'a choice of one is fake');
      expect(_plan(one, dots: 0), isNull);
    });

    test('the backup runs when the mission can\'t', () {
      final s = one.copyWith(missionBackup: MissionKind.walk);
      expect(_plan(s, dots: 1)?.kind, MissionKind.walk);
      expect(
        _plan(s, dots: 1, can: (k) => k != MissionKind.walk),
        isNull,
        reason: 'no step counter: the alarm dismisses as usual',
      );
    });

    test('a missing sensor skips the mission', () {
      const s = Settings(
        missionMode: MissionMode.always,
        missionKind: MissionKind.light,
      );
      expect(_plan(s, can: (k) => k != MissionKind.light), isNull);
    });
  });

  group('the offer to turn missions off', () {
    final now = DateTime.utc(2026, 11, 8, 7);
    const on = Settings(missionMode: MissionMode.afterSnooze);
    List<DateTime> days(List<int> ago) => [
      for (final d in ago) now.subtract(Duration(days: d)),
    ];

    test('after 3 skips in 7 days', () {
      expect(
        missionOffOfferDue(on, skipsUtc: days([0, 2, 6]), nowUtc: now),
        isTrue,
      );
      expect(
        missionOffOfferDue(on, skipsUtc: days([0, 2, 8]), nowUtc: now),
        isFalse,
      );
    });

    test('once only, and not when switched off', () {
      final skips = days([0, 1, 2]);
      expect(
        missionOffOfferDue(
          on.copyWith(missionOffOfferAnswered: true),
          skipsUtc: skips,
          nowUtc: now,
        ),
        isFalse,
      );
      expect(
        missionOffOfferDue(
          on.copyWith(missionSkipOffer: false),
          skipsUtc: skips,
          nowUtc: now,
        ),
        isFalse,
      );
    });
  });

  test('on-screen missions are the three that only wake you', () {
    expect(MissionKind.values.where((k) => k.onScreen), [
      MissionKind.breathe,
      MissionKind.catchDot,
      MissionKind.oneThing,
    ]);
  });
}
