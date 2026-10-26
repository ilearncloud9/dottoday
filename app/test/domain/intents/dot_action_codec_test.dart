import 'dart:convert';

import 'package:dottoday/domain/intents/dot_action.dart';
import 'package:flutter_test/flutter_test.dart';

final _at = DateTime.utc(2026, 10, 21, 12);
const _a = '01928c3e-0000-7000-8000-00000000a001';
const _o = '01928c3e-0000-7000-8000-00000000b001';

Map<String, Object?> _wire(DotAction action) =>
    jsonDecode(
          jsonEncode(
            encodeQueuedAction(
              QueuedAction(id: _a, createdAtUtc: _at, action: action),
            ),
          ),
        )
        as Map<String, Object?>;

void main() {
  test('every kind round-trips through JSON text', () {
    final end = _at.add(const Duration(minutes: 30));
    final cases = <DotAction, bool Function(DotAction)>{
      const AddTask('Gym 7am'): (a) => a is AddTask && a.text == 'Gym 7am',
      const AddTask('Read', note: 'https://ex.com', inbox: true): (a) =>
          a is AddTask && a.note == 'https://ex.com' && a.inbox,
      const MarkDone(_o): (a) => a is MarkDone && a.occurrenceId == _o,
      const StartFocus(_o): (a) => a is StartFocus && a.occurrenceId == _o,
      AddFifteen(_o, plannedEndUtc: end): (a) =>
          a is AddFifteen && a.occurrenceId == _o && a.plannedEndUtc == end,
    };
    for (final MapEntry(key: action, value: same) in cases.entries) {
      final decoded = decodeQueuedAction(_wire(action))!;
      expect(decoded.id, _a);
      expect(decoded.createdAtUtc, _at);
      expect(same(decoded.action), isTrue, reason: '$action');
    }
  });

  test('the kinds are the names Swift, Kotlin and sw.js write', () {
    expect(_wire(const MarkDone(_o))['kind'], 'mark_done');
    expect(_wire(const StartFocus(_o))['kind'], 'start_focus');
    expect(_wire(const AddTask('x'))['kind'], 'add_task');
    expect(_wire(AddFifteen(_o, plannedEndUtc: _at))['kind'], 'add_fifteen');
  });

  test('ids come back lowercase', () {
    final json = _wire(const MarkDone(_o))
      ..['id'] = _a.toUpperCase()
      ..['occurrence_id'] = _o.toUpperCase();
    final decoded = decodeQueuedAction(json)!;
    expect(decoded.id, _a);
    expect((decoded.action as MarkDone).occurrenceId, _o);
  });

  group('refuses malformed entries', () {
    Map<String, Object?> done() => _wire(const MarkDone(_o));
    final cases = <String, Map<String, Object?> Function()>{
      'unknown kind': () => done()..['kind'] = 'delete_all',
      'no id': () => done()..remove('id'),
      'id not a uuid': () => done()..['id'] = 'Buy milk',
      'occurrence not a uuid': () => done()..['occurrence_id'] = 'o1',
      'time as text': () => done()..['at_ms'] = 'now',
      'negative time': () => done()..['at_ms'] = -1,
      'no occurrence': () => done()..remove('occurrence_id'),
      'occurrence as number': () => done()..['occurrence_id'] = 7,
      'empty add text': () => _wire(const AddTask('x'))..['text'] = '  ',
      'add text too long': () =>
          _wire(const AddTask('x'))..['text'] = 'x' * 10001,
      '+15 without its end': () =>
          _wire(AddFifteen(_o, plannedEndUtc: _at))..remove('planned_end_ms'),
    };
    for (final MapEntry(key: name, value: json) in cases.entries) {
      test(name, () => expect(decodeQueuedAction(json()), isNull));
    }
    test('not a map', () {
      for (final junk in [null, 'x', 1, <Object?>[]]) {
        expect(decodeQueuedAction(junk), isNull);
      }
    });
  });
}
