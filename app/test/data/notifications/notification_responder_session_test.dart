import 'dart:async';

import 'package:dottoday/core/failures/app_failure.dart';
import 'package:dottoday/core/failures/result.dart';
import 'package:dottoday/core/logging/logger.dart';
import 'package:dottoday/data/notifications/notification_platform.dart';
import 'package:dottoday/data/notifications/notification_responder.dart';
import 'package:dottoday/domain/entities/enums.dart';
import 'package:dottoday/domain/notifications/notification_payload.dart';
import 'package:dottoday/domain/notifications/planned_notification.dart';
import 'package:dottoday/domain/writes/write_batch.dart';
import 'package:dottoday/domain/writes/write_use_case.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest.dart' as tz_data;

import '../../support/fake_clock.dart';
import '../../support/memory_log_sink.dart';
import '../../support/timeline_fakes.dart';

// CR-160 §4 (owner 2026-11-09): a reminder action begun in one owner
// session that is refused after the owner changed never reports its
// refusal into the next session (another account, a new guest, or the
// same account shown again). Within its session it still does.

/// A write path that holds each save until [release], then answers
/// [result] without writing anything.
final class _Paused implements WriteUseCase {
  final applied = <WriteBatch>[];
  final _gate = Completer<void>();
  Result<void, AppFailure> result = const Err(StorageFailure());

  void release() => _gate.complete();

  @override
  Future<Result<void, AppFailure>> apply(WriteBatch batch) async {
    applied.add(batch);
    await _gate.future;
    return result;
  }
}

void main() {
  setUpAll(tz_data.initializeTimeZones);

  final now = DateTime.utc(2026, 10, 21, 15, 20);
  late FakeOccurrenceRepository repo;
  late _Paused writes;
  late List<String> opened;
  late List<(AppFailure, int)> refused;
  late int epoch;
  late bool deleting;
  late NotificationResponder responder;

  setUp(() {
    repo = FakeOccurrenceRepository(demoDayRows(DateTime(2026, 10, 21)));
    writes = _Paused();
    opened = [];
    refused = [];
    epoch = 0;
    deleting = true;
    final clock = FakeClock(now);
    responder = NotificationResponder(
      clock: clock,
      writes: writes,
      occurrences: repo,
      profile: () async => testProfile(),
      open: opened.add,
      logger: Logger(MemoryLogSink(), clock),
      deleting: () => deleting,
      ownerEpoch: () => epoch,
      refused: (f, e) => refused.add((f, e)),
    );
  });

  String gymId() => repo.rows.firstWhere((o) => o.title == 'Gym').id;
  NotificationTap tap(String action) => NotificationTap(
    id: 9,
    actionId: action,
    payload: encodeNotificationPayload(
      PlannedNotification(
        id: 9,
        occurrenceId: gymId(),
        alertIndex: 0,
        fireAtUtc: now,
        kind: AlertKind.before,
      ),
    ),
  );

  /// Starts [action], waits until its save is held, runs [meanwhile], then
  /// lets the save fail.
  Future<void> pausedAcross(String action, void Function() meanwhile) async {
    final handled = responder.handle(tap(action));
    await pumpEventQueue();
    expect(writes.applied, hasLength(1), reason: 'held at the save');
    meanwhile();
    writes.release();
    await handled;
  }

  for (final action in ['done', 'snooze', 'plus15']) {
    test('$action: refused within its session is reported, tagged with '
        'the session it began in', () async {
      await pausedAcross(action, () {});
      expect(refused, [(const StorageFailure(), 0)]);
      expect(opened, isEmpty, reason: 'D1 stays');
    });
  }

  test('begun under A, refused after the switch to B: nothing is reported '
      'and nothing is opened while the deletion runs', () async {
    await pausedAcross('done', () => epoch = 1);
    expect(refused, isEmpty);
    expect(opened, isEmpty);
  });

  test('begun under A, refused once a new guest session is shown (the '
      'deletion finished): nothing reported, nothing opened', () async {
    await pausedAcross('done', () {
      epoch = 1;
      deleting = false;
    });
    expect(refused, isEmpty);
    expect(opened, isEmpty);
  });

  test('A → B → A: the old tap is still from an ended session', () async {
    await pausedAcross('snooze', () => epoch = 2);
    expect(refused, isEmpty);
  });

  test('a save that went through reports nothing, in any session', () async {
    writes.result = const Ok(null);
    await pausedAcross('done', () {});
    expect(refused, isEmpty);
  });

  test('the epoch is taken when the tap arrives, before any lookup', () async {
    // The owner changes while the profile and task are still being read.
    final handled = responder.handle(tap('done'));
    epoch = 1;
    await pumpEventQueue();
    writes.release();
    await handled;
    expect(refused, isEmpty, reason: 'never tagged with the new session');
  });
}
