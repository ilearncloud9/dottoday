import 'package:dottoday/data/notifications/notification_content.dart';
import 'package:dottoday/data/notifications/notification_platform.dart';
import 'package:dottoday/domain/entities/enums.dart';
import 'package:dottoday/domain/notifications/planned_notification.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:timezone/data/latest.dart' as tz_data;

import '../../domain/fixtures.dart';

// Loud dot-starts go to the alarm channel and carry the flag to Apple
// platforms (docs/09 M6.5.4–5).
void main() {
  setUpAll(() async {
    tz_data.initializeTimeZones();
    await initializeDateFormatting('en');
  });
  final task = occurrenceFixture().copyWith(
    startUtc: DateTime.utc(2026, 10, 21, 7),
  );

  OsNotification compose({required bool loud}) => composeNotification(
    PlannedNotification(
      id: 1,
      occurrenceId: task.id,
      alertIndex: 0,
      fireAtUtc: task.startUtc!,
      kind: AlertKind.atStart,
      loud: loud,
    ),
    task: task,
    profile: profileFixture(),
  )!;

  test('loud → alarm channel, loud flag, time-sensitive', () {
    final n = compose(loud: true);
    expect(n.channel, NotificationChannelKind.alarms);
    expect((n.loud, n.timeSensitive), (true, true));
  });

  test('the Wake Up alarm: alarm channel, alarm clock, the day it opens', () {
    final n = composeNotification(
      PlannedNotification(
        id: 1,
        occurrenceId: task.id,
        alertIndex: PlannedNotification.wakeUpIndex,
        fireAtUtc: DateTime.utc(2026, 10, 21, 6),
        kind: AlertKind.atStart,
        loud: true,
        purpose: NotificationPurpose.wakeUp,
      ),
      task: task,
      profile: profileFixture(),
    )!;
    expect(n.channel, NotificationChannelKind.alarms);
    expect((n.loud, n.alarmClock, n.timeSensitive), (true, true, true));
    expect(n.withActions, isFalse);
    expect(n.title, 'Wake Up');
    expect(n.body, startsWith('First: '));
    expect(n.sound?.id, 'dot_alarm');
  });

  test('the Wake Up alarm still rings when its first task is gone', () {
    final n = composeNotification(
      PlannedNotification(
        id: 1,
        occurrenceId: 'gone',
        alertIndex: PlannedNotification.wakeUpIndex,
        fireAtUtc: DateTime.utc(2026, 10, 21, 6),
        kind: AlertKind.atStart,
        loud: true,
        purpose: NotificationPurpose.wakeUp,
      ),
      task: null,
      profile: profileFixture(),
    )!;
    expect(n.body, 'Good morning.');
  });

  test('a normal dot-start stays on the alerts channel', () {
    final n = compose(loud: false);
    expect(n.channel, NotificationChannelKind.alerts);
    expect(n.loud, isFalse);
  });

  test('a task alert carries its sound; a loud one only a Start sound', () {
    OsNotification? withSound({
      required bool loud,
      NotificationPurpose? p,
      String? sound = 'ripple',
    }) => composeNotification(
      PlannedNotification(
        id: 1,
        occurrenceId: task.id,
        alertIndex: 0,
        fireAtUtc: task.startUtc!,
        kind: AlertKind.atStart,
        loud: loud,
        sound: sound,
        purpose: p ?? NotificationPurpose.task,
      ),
      task: task,
      profile: profileFixture(),
    );
    expect(withSound(loud: false)!.sound?.id, 'ripple');
    // docs/12 D2: loud plays the Start sound the planner chose.
    expect(
      withSound(loud: true, sound: 'start.swing')!.sound?.id,
      'start.swing',
    );
    expect(withSound(loud: true)!.sound?.id, 'dot_alarm', reason: 'not Start');
    expect(
      withSound(loud: false, p: NotificationPurpose.windDown)!.sound,
      isNull,
    );
    // Null is the OS sound; "none" shows without a sound.
    expect(withSound(loud: false, sound: null)!.sound, isNull);
    final off = withSound(loud: false, sound: 'none')!;
    expect((off.sound, off.soundOff), (null, true));
    expect(withSound(loud: false)!.soundOff, isFalse);
  });

  test('an unknown sound key plays the Dot tone, never nothing', () {
    final n = composeNotification(
      PlannedNotification(
        id: 1,
        occurrenceId: task.id,
        alertIndex: 0,
        fireAtUtc: task.startUtc!,
        kind: AlertKind.atStart,
        sound: 'from-a-newer-version',
      ),
      task: task,
      profile: profileFixture(),
    )!;
    expect(n.sound?.id, 'dot');
  });

  test('day-start summary: count and first time, summary channel, '
      'no actions (F6.2)', () {
    final n = composeNotification(
      PlannedNotification(
        id: 2,
        occurrenceId: task.id,
        alertIndex: PlannedNotification.daySummaryIndex,
        fireAtUtc: DateTime.utc(2026, 10, 21, 5),
        kind: AlertKind.atStart,
        purpose: NotificationPurpose.daySummary,
        blocks: 6,
      ),
      task: task,
      profile: profileFixture(),
    )!;
    expect(n.title, 'Your day');
    expect(n.body, matches(RegExp(r'^6 blocks, first at \S+')));
    expect(n.channel, NotificationChannelKind.summary);
    expect(n.withActions, isFalse);
    expect(n.timeSensitive, isFalse);
  });

  test('day-start summary whose first block is gone: not posted', () {
    final n = composeNotification(
      PlannedNotification(
        id: 2,
        occurrenceId: 'gone',
        alertIndex: PlannedNotification.daySummaryIndex,
        fireAtUtc: DateTime.utc(2026, 10, 21, 5),
        kind: AlertKind.atStart,
        purpose: NotificationPurpose.daySummary,
        blocks: 2,
      ),
      task: null,
      profile: profileFixture(),
    );
    expect(n, isNull);
  });

  // Smallest step (11 B2, docs/09 M10.6): the first step only, with Start.
  test('Smallest step: "Just <step> · 10 min?", the task below, Start', () {
    final planned = PlannedNotification(
      id: 3,
      occurrenceId: task.id,
      alertIndex: PlannedNotification.smallestStepIndex,
      fireAtUtc: task.startUtc!.add(const Duration(minutes: 10)),
      kind: AlertKind.atStart,
      purpose: NotificationPurpose.smallestStep,
    );
    final step = subtaskFixture().copyWith(
      title: 'Gather documents',
      durationMin: 10,
    );
    final n = composeNotification(
      planned,
      task: task,
      profile: profileFixture(),
      step: step,
    )!;
    expect(n.title, 'Just Gather documents · 10 min?');
    expect(n.body, task.title);
    expect((n.startAction, n.withActions), (true, false));
    expect(n.channel, NotificationChannelKind.alerts);
    final short = composeNotification(
      planned,
      task: task,
      profile: profileFixture(),
      step: step.copyWith(durationMin: null),
    )!;
    expect(short.title, 'Just Gather documents?');
    expect(
      composeNotification(planned, task: task, profile: profileFixture()),
      isNull,
      reason: 'no step left: nothing to post',
    );
  });

  group('the Wind Down reminder (docs/15 W6)', () {
    // profileFixture: New York; a Wind Down at 22:00 there (02:00Z).
    final windDown = PlannedNotification(
      id: 6,
      occurrenceId: 'run',
      alertIndex: PlannedNotification.windDownIndex,
      fireAtUtc: DateTime.utc(2026, 10, 22, 2),
      kind: AlertKind.atEnd,
      purpose: NotificationPurpose.windDown,
    );
    final run = occurrenceFixture().copyWith(
      id: 'run',
      title: 'Run',
      startUtc: DateTime.utc(2026, 10, 22, 10, 30),
    );

    test('without a sleep target: as before M17.5', () {
      final n = composeNotification(
        windDown,
        task: run,
        profile: profileFixture(),
      )!;
      expect(n.body, isNot(contains('Wind down now')));
    });

    test('with one: what the night protects, before the first dot', () {
      final profile = profileFixture().copyWith(
        settings: profileFixture().settings.copyWith(sleepTargetMin: 9 * 60),
      );
      // Next Wake Up 07:00 New York (11:00Z): 9 h of night.
      final n = composeNotification(windDown, task: run, profile: profile)!;
      expect(n.body, startsWith('Wind down now for 9 h before Run at'));
      final free = composeNotification(windDown, task: null, profile: profile)!;
      expect(free.body, startsWith('Wind down now for 9 h before'));
    });
  });
}
