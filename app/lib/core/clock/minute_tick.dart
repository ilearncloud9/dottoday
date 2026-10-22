import 'dart:async';

import 'package:dottoday/core/clock/clock_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'minute_tick.g.dart';

/// "Now", emitted immediately and then on every minute boundary, so the
/// now-line moves once per minute (docs/03 §3.1) without a busy timer.
@Riverpod(keepAlive: true)
Stream<DateTime> minuteTick(Ref ref) {
  final clock = ref.watch(clockProvider);
  final controller = StreamController<DateTime>();
  Timer? timer;
  void tick() {
    final now = clock.nowUtc();
    controller.add(now);
    final untilNext = 60000 - now.millisecondsSinceEpoch % 60000;
    timer = Timer(Duration(milliseconds: untilNext), tick);
  }

  tick();
  ref.onDispose(() {
    timer?.cancel();
    unawaited(controller.close());
  });
  return controller.stream;
}
