import 'dart:convert';

import 'package:dottoday/domain/snapshot/day_snapshot.dart';
import 'package:dottoday/domain/snapshot/day_snapshot_codec.dart';
import 'package:flutter_test/flutter_test.dart';

final _now = DateTime.utc(2026, 10, 21, 12);

DaySnapshot _snapshot() => DaySnapshot(
  generatedAtUtc: _now,
  wakeUtc: DateTime.utc(2026, 10, 21, 7),
  bedUtc: DateTime.utc(2026, 10, 21, 22),
  inboxCount: 4,
  dayDone: 1,
  dayTotal: 3,
  dots: [
    SnapshotDot(
      id: 'live',
      title: 'Deep work: «roadmap» 🚀',
      startUtc: _now.subtract(const Duration(minutes: 10)),
      durationMin: 60,
      colorKey: 'indigo',
      iconKey: 'laptop',
      done: false,
      actualStartUtc: _now.subtract(const Duration(minutes: 8)),
    ),
    SnapshotDot(
      id: 'next',
      title: '',
      startUtc: _now.add(const Duration(hours: 2)),
      durationMin: 0,
      colorKey: 'coral',
      iconKey: 'dot',
      done: true,
      actualEndUtc: _now,
    ),
  ],
);

Map<String, Object?> _wire() =>
    jsonDecode(jsonEncode(encodeDaySnapshot(_snapshot())))
        as Map<String, Object?>;

void main() {
  test('round-trips through JSON text', () {
    expect(decodeDaySnapshot(_wire()), _snapshot());
  });

  test('writes the derived fields readers need', () {
    final json = _wire();
    expect(json['v'], 1);
    expect(json['current_id'], 'live');
    // The other dot is done, so nothing is next.
    expect(json['next_ids'], isEmpty);
    expect(json['progress'], closeTo(5 / 15, 1e-9));
    final first = (json['blocks']! as List).first as Map<String, Object?>;
    expect(first['end_ms'], (first['start_ms']! as int) + 60 * 60000);
    expect(first['actual_end_ms'], isNull);
  });

  test('ignores display fields a platform sink adds', () {
    final json = _wire()..['labels'] = {'now': 'Now'};
    ((json['blocks']! as List).first as Map<String, Object?>)['time'] = '9:00';
    expect(decodeDaySnapshot(json), _snapshot());
  });

  group('refuses hostile input', () {
    Map<String, Object?> block(Map<String, Object?> json) =>
        (json['blocks']! as List).first as Map<String, Object?>;

    final cases = <String, void Function(Map<String, Object?>)>{
      'another version': (j) => j['v'] = 2,
      'version as text': (j) => j['v'] = '1',
      'no generated_ms': (j) => j.remove('generated_ms'),
      'a double instant': (j) => j['wake_ms'] = 1.5e12,
      'year 1970': (j) => j['bed_ms'] = 0,
      'year 3000': (j) => j['generated_ms'] = 32503680000000,
      'negative inbox': (j) => j['inbox_count'] = -1,
      'more done than dots': (j) => j['day_done'] = 4,
      'no day total': (j) => j.remove('day_total'),
      'blocks not a list': (j) => j['blocks'] = {'a': 1},
      'too many blocks': (j) =>
          j['blocks'] = List.filled(DaySnapshot.maxDots + 1, block(j)),
      'a block not a map': (j) => (j['blocks']! as List)[0] = 'x',
      'empty id': (j) => block(j)['id'] = '',
      'long id': (j) => block(j)['id'] = 'x' * 65,
      'long title': (j) => block(j)['title'] = 'x' * 201,
      'title as number': (j) => block(j)['title'] = 7,
      'negative duration': (j) => block(j)['duration_min'] = -5,
      'duration over a day': (j) => block(j)['duration_min'] = 1441,
      'done as 1': (j) => block(j)['done'] = 1,
      'actual start as text': (j) => block(j)['actual_start_ms'] = 'soon',
      'no colour': (j) => block(j).remove('color_key'),
    };
    for (final MapEntry(key: name, value: spoil) in cases.entries) {
      test(name, () {
        final json = _wire();
        spoil(json);
        expect(decodeDaySnapshot(json), isNull);
      });
    }

    test('not a map at all', () {
      for (final junk in [null, 1, 'x', <Object?>[], true]) {
        expect(decodeDaySnapshot(junk), isNull);
      }
    });
  });
}
