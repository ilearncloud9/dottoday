import 'package:dottoday/data/sync/server_columns.dart';
import 'package:flutter_test/flutter_test.dart';

// ADR-0012: a step's tick time syncs like the other instants — epoch ms on
// the device, timestamptz on the server.
void main() {
  test('subtasks.done_at may be pushed and crosses as an instant', () {
    expect(pushableColumns['subtasks'], contains('done_at'));
    final ms = DateTime.utc(2026, 10, 26, 9, 15).millisecondsSinceEpoch;
    final wire = toServerValue('done_at', ms);
    expect(wire, '2026-10-26T09:15:00.000Z');
    expect(toLocalValue('done_at', wire), ms);
    expect(toLocalRow({'done_at': null, 'done': true}), {
      'done_at': null,
      'done': true,
    });
  });

  test('a task sound may be pushed and crosses as it is (docs/12 §3)', () {
    expect(pushableColumns['series'], contains('sound_id'));
    expect(pushableColumns['occurrences'], contains('sound_id'));
    expect(toServerValue('sound_id', 'clear.lift'), 'clear.lift');
    expect(toLocalValue('sound_id', 'none'), 'none');
  });
}
