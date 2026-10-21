import 'dart:math';

import 'package:dottoday/domain/sync/hlc.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/fake_clock.dart';

const _a = '00000000000000aa';
const _b = '00000000000000bb';
final _t0 = DateTime.utc(2026, 10, 21, 8);

void main() {
  group('Hlc wire format (ADR-0002)', () {
    test('fixed width and round-trips', () {
      final h = Hlc(1761033600000, 7, _a);
      expect(h.toString(), '1761033600000-0007-00000000000000aa');
      expect(Hlc.tryParse(h.toString()), h);
      expect(Hlc(5, 0, _a).toString(), '0000000000005-0000-$_a');
    });

    test('malformed strings are rejected like hlc_is_valid', () {
      for (final bad in [
        '',
        '1761033600000-7-$_a',
        '1761033600000-0007-00000000000000AA',
        '1761033600000-0007-00000000000000a',
        '176103360000-0007-$_a',
        ' 1761033600000-0007-$_a',
      ]) {
        expect(Hlc.tryParse(bad), isNull, reason: bad);
      }
    });

    test('constructor guards ranges and node', () {
      expect(() => Hlc(-1, 0, _a), throwsRangeError);
      expect(() => Hlc(0, 10000, _a), throwsRangeError);
      expect(() => Hlc(0, 0, 'XYZ'), throwsArgumentError);
    });

    test('string order equals (ms, counter, node) order', () {
      final rnd = Random(3);
      String node() =>
          List.generate(16, (_) => rnd.nextInt(16).toRadixString(16)).join();
      for (var i = 0; i < 2000; i++) {
        final x = Hlc(rnd.nextInt(3) + 1761033600000, rnd.nextInt(3), node());
        final y = Hlc(rnd.nextInt(3) + 1761033600000, rnd.nextInt(3), node());
        expect(x.compareTo(y).sign, x.toString().compareTo(y.toString()).sign);
      }
    });
  });

  group('HybridLogicalClock', () {
    test('now() follows the wall clock and resets the counter', () {
      final clock = FakeClock(_t0);
      final hlc = HybridLogicalClock(clock: clock, nodeId: _a);
      final first = hlc.now();
      expect((first.ms, first.counter), (_t0.millisecondsSinceEpoch, 0));
      expect(hlc.now().counter, 1);
      clock.advance(const Duration(milliseconds: 1));
      expect(hlc.now().counter, 0);
    });

    test('stays monotonic when the wall clock goes backwards', () {
      final clock = FakeClock(_t0);
      final hlc = HybridLogicalClock(clock: clock, nodeId: _a);
      final before = hlc.now();
      clock.advance(const Duration(hours: -1));
      final after = hlc.now();
      expect(after > before, isTrue);
      expect(after.ms, before.ms);
    });

    test('counter overflow borrows the next millisecond', () {
      final clock = FakeClock(_t0);
      final ms = _t0.millisecondsSinceEpoch;
      final hlc = HybridLogicalClock(
        clock: clock,
        nodeId: _a,
        last: Hlc(ms, Hlc.maxCounter, _a),
      );
      final next = hlc.now();
      expect((next.ms, next.counter), (ms + 1, 0));
    });

    test('receive() moves past a remote HLC from a faster device', () {
      final clock = FakeClock(_t0);
      final hlc = HybridLogicalClock(clock: clock, nodeId: _a);
      final remote = Hlc(_t0.millisecondsSinceEpoch + 2000, 3, _b);
      hlc.receive(remote);
      final local = hlc.now();
      expect(local > remote, isTrue);
      expect(local.node, _a);
    });

    test('receive() counter rules', () {
      final ms = _t0.millisecondsSinceEpoch;
      final clock = FakeClock(_t0);
      final same = HybridLogicalClock(
        clock: clock,
        nodeId: _a,
        last: Hlc(ms, 4, _a),
      );
      expect(same.receive(Hlc(ms, 9, _b)).counter, 10);
      final older = HybridLogicalClock(
        clock: clock,
        nodeId: _a,
        last: Hlc(ms, 4, _a),
      );
      expect(older.receive(Hlc(ms - 10, 9, _b)).counter, 5);
      clock.advance(const Duration(seconds: 1));
      expect(older.receive(Hlc(ms, 9, _b)).counter, 0);
    });

    test('a remote clock more than 5 min ahead does not drag ours', () {
      final clock = FakeClock(_t0);
      final hlc = HybridLogicalClock(clock: clock, nodeId: _a);
      final ahead = _t0.add(const Duration(minutes: 6)).millisecondsSinceEpoch;
      final merged = hlc.receive(Hlc(ahead, 0, _b));
      expect(merged.ms, _t0.millisecondsSinceEpoch);
      final near = _t0.add(const Duration(minutes: 4)).millisecondsSinceEpoch;
      expect(hlc.receive(Hlc(near, 0, _b)).ms, near);
    });

    test('every issued HLC is unique and increasing (property)', () {
      final rnd = Random(11);
      final clock = FakeClock(_t0);
      final hlc = HybridLogicalClock(clock: clock, nodeId: _a);
      var previous = hlc.last;
      for (var i = 0; i < 5000; i++) {
        clock.advance(Duration(milliseconds: rnd.nextInt(5) - 2));
        final next = rnd.nextInt(4) == 0
            ? hlc.receive(
                Hlc(
                  clock.nowUtc().millisecondsSinceEpoch + rnd.nextInt(50),
                  rnd.nextInt(20),
                  _b,
                ),
              )
            : hlc.now();
        expect(next > previous, isTrue);
        previous = next;
      }
    });

    test('rejects a malformed node id', () {
      expect(
        () => HybridLogicalClock(clock: FakeClock(_t0), nodeId: 'nope'),
        throwsArgumentError,
      );
    });
  });
}
