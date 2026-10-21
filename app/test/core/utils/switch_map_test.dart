import 'dart:async';

import 'package:dottoday/core/utils/switch_map.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('a new outer event cancels the live inner stream', () async {
    final outer = StreamController<int>();
    addTearDown(outer.close);
    final inners = <int, StreamController<String>>{};
    final seen = <String>[];
    final sub = outer.stream
        .switchMap((n) => (inners[n] = StreamController<String>()).stream)
        .listen(seen.add);
    outer.add(1);
    await pumpEventQueue();
    inners[1]!.add('1a');
    outer.add(2);
    await pumpEventQueue();
    inners[1]!.add('1b'); // cancelled: never seen
    inners[2]!.add('2a');
    await pumpEventQueue();
    expect(seen, ['1a', '2a']);
    expect(inners[1]!.hasListener, isFalse);
    await sub.cancel();
    expect(inners[2]!.hasListener, isFalse);
  });

  test('closes after the outer and the last inner are done', () async {
    final done = Completer<void>();
    Stream.fromIterable(
      [1, 2],
    ).switchMap((n) => Stream.value('v$n')).listen(null, onDone: done.complete);
    await done.future.timeout(const Duration(seconds: 1));
  });
}
