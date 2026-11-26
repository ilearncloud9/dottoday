import 'package:dottoday/data/intents/queue_owners.dart';
import 'package:dottoday/data/repositories/drift_occurrence_repository.dart';
import 'package:dottoday/data/repositories/drift_series_repository.dart';
import 'package:dottoday/data/widgets/mac_menu_actions.dart';
import 'package:dottoday/domain/entities/enums.dart';
import 'package:dottoday/domain/intents/dot_action.dart';
import 'package:dottoday/domain/intents/dot_intents.dart';
import 'package:dottoday/domain/writes/write_batch.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../domain/fixtures.dart';
import '../writes/write_harness.dart';

// Done and more time from the Mac menu bar (docs/09 M9.6) and the Now mini
// window (M20.9 part 7): the arguments become B6 intents and run through
// the write path in process.

final _now = DateTime.utc(2026, 10, 21, 14);
const _channel = MethodChannel('test/status_item');

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('menuBarAction', () {
    test('reads Done and +5 / +15 / +30', () {
      expect(
        menuBarAction({'kind': 'mark_done', 'id': 'x'}),
        isA<MarkDone>().having((a) => a.occurrenceId, 'id', 'x'),
      );
      for (final minutes in AddTime.choices) {
        final plus = menuBarAction({
          'kind': 'add_time',
          'id': 'x',
          'planned_end_ms': 1792584000000.0,
          'minutes': minutes,
        });
        expect(
          plus,
          isA<AddTime>()
              .having(
                (a) => a.plannedEndUtc,
                'end',
                DateTime.utc(2026, 10, 21, 12),
              )
              .having((a) => a.minutes, 'minutes', minutes),
        );
      }
    });

    test('refuses anything else', () {
      for (final junk in <Object?>[
        null,
        'x',
        {'kind': 'mark_done'},
        {'kind': 'delete', 'id': 'x'},
        {'kind': 'add_time', 'id': 'x', 'minutes': 15},
        {'kind': 'add_time', 'id': 'x', 'planned_end_ms': 1.0},
        {'kind': 'add_time', 'id': 'x', 'planned_end_ms': 1.0, 'minutes': 20},
        {'kind': 'add_fifteen', 'id': 'x', 'planned_end_ms': 1.0},
      ]) {
        expect(menuBarAction(junk), isNull, reason: '$junk');
      }
    });
  });

  test('Done and +30 reach the database', () async {
    final h = WriteHarness(_now);
    addTearDown(h.dispose);
    final occurrences = DriftOccurrenceRepository(h.db);
    final task = occurrenceFixture().copyWith(
      startUtc: _now.subtract(const Duration(minutes: 5)),
      durationMin: 30,
    );
    await h.writes.apply(
      WriteBatch(
        userId: userId,
        profile: profileFixture(),
        occurrences: [task],
      ),
    );
    listenForMenuBarActions(
      DotIntents(
        clock: h.clock,
        writes: h.writes,
        occurrences: occurrences,
        series: DriftSeriesRepository(h.db),
        profile: () async => profileFixture(),
        snapshot: () => throw UnimplementedError(),
        untitled: (_) => 'Untitled',
        ownerOf: (id) => taskOwnerOf(h.db, id),
      ),
      channel: _channel,
    );
    Future<Object?> send(Map<String, Object?> args) async {
      final reply = await TestDefaultBinaryMessengerBinding
          .instance
          .defaultBinaryMessenger
          .handlePlatformMessage(
            _channel.name,
            _channel.codec.encodeMethodCall(MethodCall('action', args)),
            (_) {},
          );
      return reply == null ? null : _channel.codec.decodeEnvelope(reply);
    }

    expect(
      await send({
        'kind': 'add_time',
        'id': task.id,
        'planned_end_ms': task.endUtc!.millisecondsSinceEpoch.toDouble(),
        'minutes': 30,
      }),
      'applied',
    );
    expect(await send({'kind': 'mark_done', 'id': task.id}), 'applied');
    final stored = (await occurrences.findById(userId, task.id))!;
    expect((stored.durationMin, stored.status), (60, OccurrenceStatus.done));
  });
}
