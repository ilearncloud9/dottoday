import 'package:dottoday/domain/entities/alert.dart';
import 'package:dottoday/domain/entities/enums.dart';
import 'package:dottoday/domain/notifications/planned_notification.dart';
import 'package:dottoday/domain/writes/write_batch.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest.dart' as tz_data;

import '../../domain/fixtures.dart';
import 'write_harness.dart';

final _now = DateTime.utc(2026, 10, 21, 6);

void main() {
  late WriteHarness h;

  setUpAll(tz_data.initializeTimeZones);

  setUp(() async {
    h = WriteHarness(_now);
    await h.writes.apply(WriteBatch(userId: userId, profile: profileFixture()));
    await h.effects.idle;
  });
  tearDown(() => h.dispose());

  group('series', () {
    test(
      'saving materialises occurrences + subtasks in the same write',
      () async {
        final s = seriesFixture();
        await h.writes.apply(WriteBatch(userId: userId, series: [s]));

        final occurrences = await h.db.select(h.db.occurrences).get();
        // Mon/Wed/Fri for ~90 days.
        expect(occurrences.length, inInclusiveRange(37, 40));
        expect(occurrences.every((o) => o.seriesId == s.id && o.dirty), isTrue);
        final subtasks = await h.db.select(h.db.subtasks).get();
        expect(subtasks, hasLength(occurrences.length));
        final row = await h.db.select(h.db.seriesTable).getSingle();
        expect(row.materialisedThroughUtc, isNotNull);
      },
    );

    test('re-saving is idempotent', () async {
      final s = seriesFixture();
      await h.writes.apply(WriteBatch(userId: userId, series: [s]));
      final count = (await h.db.select(h.db.occurrences).get()).length;
      await h.writes.apply(
        WriteBatch(
          userId: userId,
          series: [s.copyWith(title: 'Run')],
        ),
      );
      expect(await h.db.select(h.db.occurrences).get(), hasLength(count));
    });
  });

  group('after commit', () {
    test('schedules alerts once and writes the widget snapshot', () async {
      final o = occurrenceFixture().copyWith(
        startUtc: _now.add(const Duration(hours: 2)),
        alerts: const [Alert(kind: AlertKind.before, offsetMin: 10)],
      );
      await h.writes.apply(WriteBatch(userId: userId, occurrences: [o]));
      await h.effects.idle;
      expect(_taskAlerts(h).single.occurrenceId, o.id);
      expect(h.sink.written.last.dots.single.id, o.id);

      // Same desired set again: nothing re-scheduled (R-10).
      final applies = h.gateway.applied.length;
      await h.writes.apply(
        WriteBatch(
          userId: userId,
          occurrences: [o.copyWith(notes: 'x')],
        ),
      );
      await h.effects.idle;
      expect(h.gateway.applied, hasLength(applies));

      // Marked done: its alert is cancelled.
      await h.writes.apply(
        WriteBatch(
          userId: userId,
          occurrences: [o.copyWith(status: OccurrenceStatus.done)],
        ),
      );
      await h.effects.idle;
      expect(_taskAlerts(h), isEmpty);
    });

    test('a failing effect is logged and does not block the next', () async {
      h.gateway.failNext = true;
      final o = occurrenceFixture().copyWith(
        startUtc: _now.add(const Duration(hours: 2)),
        alerts: const [Alert(kind: AlertKind.atStart)],
      );
      final result = await h.writes.apply(
        WriteBatch(userId: userId, occurrences: [o]),
      );
      await h.effects.idle;
      expect(result.when(ok: (_) => true, err: (_) => false), isTrue);
      expect(
        h.logs.records.map((r) => r.event),
        contains('notifications.resync_failed'),
      );
      expect(h.sink.written.last.dots.single.id, o.id);

      // The next write repairs the OS set.
      await h.writes.apply(
        WriteBatch(
          userId: userId,
          occurrences: [o.copyWith(notes: 'n')],
        ),
      );
      await h.effects.idle;
      expect(_taskAlerts(h), hasLength(1));
    });
  });
}

/// Task alerts only: the Wind Down reminder (on by default, M3d.3) is
/// planned alongside them.
List<PlannedNotification> _taskAlerts(WriteHarness h) => [
  for (final n in h.gateway.pendingSet.values)
    if (n.purpose == NotificationPurpose.task) n,
];
