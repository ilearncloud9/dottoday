import 'package:dottoday/core/failures/app_failure.dart';
import 'package:dottoday/domain/sync/conflict_resolver.dart';
import 'package:dottoday/domain/sync/hlc.dart';
import 'package:flutter_test/flutter_test.dart';

// docs/08 §2 `sync_engine_test` resolver cases: LWW per field, same field
// within 60 s creates a conflict (ADR-0002, R-08).

const _phone = '00000000000000aa';
const _laptop = '00000000000000bb';
const _base = 1761033600000;
const _r = ConflictResolver();

FieldChange _change(
  Object? value, {
  required int atMs,
  String node = _phone,
  String field = 'title',
}) => FieldChange(
  entity: EntityKind.occurrence,
  entityId: 'o1',
  field: field,
  value: value,
  hlc: Hlc(_base + atMs, 0, node),
);

void main() {
  test('LWW: the newer edit wins when more than 60 s apart', () {
    final mine = _change('Gym', atMs: 120000);
    final theirs = _change('Run', atMs: 0, node: _laptop);
    expect(_r.resolve(mine, theirs), isA<KeepLocal>());
    final newer = _change('Swim', atMs: 200000, node: _laptop);
    expect(_r.resolve(mine, newer), isA<TakeRemote>());
  });

  test('exactly 60 s apart is no longer simultaneous', () {
    final mine = _change('Gym', atMs: 60000);
    final theirs = _change('Run', atMs: 0, node: _laptop);
    expect(_r.resolve(mine, theirs), isA<KeepLocal>());
  });

  test('same field, different values within 60 s → conflict, server kept', () {
    final mine = _change('Gym', atMs: 30000);
    final theirs = _change('Run', atMs: 0, node: _laptop);
    final r = _r.resolve(mine, theirs);
    expect(r, isA<Conflict>());
    final conflict = r as Conflict;
    expect(conflict.mine.value, 'Gym');
    expect(conflict.applied.value, 'Run');
  });

  // The server may hold this device's own earlier write (M6.2): one
  // device's edits are in sequence, the later one wins, no conflict.
  test('two edits from one device within 60 s: the later wins', () {
    final first = _change('Run', atMs: 0);
    final second = _change('Gym', atMs: 20000);
    expect(_r.resolve(second, first), isA<KeepLocal>());
    expect(_r.resolve(first, second), isA<TakeRemote>());
  });

  test('same value is never a conflict', () {
    final mine = _change(['a', 1], atMs: 1000);
    final theirs = _change(['a', 1], atMs: 0, node: _laptop);
    expect(_r.resolve(mine, theirs), isA<TakeRemote>());
  });

  test('json values compare structurally', () {
    expect(
      jsonEquals(
        {
          'k': [1, 2],
        },
        {
          'k': [1, 2],
        },
      ),
      isTrue,
    );
    expect(
      jsonEquals(
        {
          'k': [1, 2],
        },
        {
          'k': [2, 1],
        },
      ),
      isFalse,
    );
    expect(jsonEquals({'a': 1}, {'b': 1}), isFalse);
    expect(jsonEquals([1], [1, 2]), isFalse);
    expect(jsonEquals({'a': null}, <String, Object?>{}), isFalse);
    expect(jsonEquals(null, null), isTrue);
  });

  test('resolveRow resolves only fields both sides changed', () {
    final local = {
      'title': _change('Gym', atMs: 90000),
      'notes': _change('bring water', atMs: 90000, field: 'notes'),
    };
    final remote = {
      'title': _change('Run', atMs: 0, node: _laptop),
      'duration_min': _change(
        45,
        atMs: 0,
        node: _laptop,
        field: 'duration_min',
      ),
    };
    final r = _r.resolveRow(local, remote);
    expect(r.keys, ['title']);
    expect(r['title'], isA<KeepLocal>());
  });

  test('changes of different fields are a programming error', () {
    expect(
      () => _r.resolve(
        _change('a', atMs: 0),
        _change('b', atMs: 0, field: 'notes'),
      ),
      throwsArgumentError,
    );
  });

  test('toString never includes the value (PII)', () {
    expect(
      _change('secret plan', atMs: 0).toString(),
      isNot(contains('secret')),
    );
  });
}
