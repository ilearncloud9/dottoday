import 'dart:async';

import 'package:dottoday/data/sync/realtime_nudges.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/manual_timers.dart';

// The live feed is sync's only remote trigger (docs/04 §4 "Triggers"): every join
// must nudge (catch-up), and a broken feed must come back on its own.

/// One opened feed, driven by the test.
final class _Feed {
  _Feed(this.onChange, this.onStatus);
  final void Function() onChange;
  final void Function(FeedStatus) onStatus;
  var closed = false;
}

void main() {
  late List<_Feed> feeds;
  late ManualTimers timers;
  late RealtimeNudges nudges;
  late int nudged;
  late StreamSubscription<void> sub;

  setUp(() {
    feeds = [];
    timers = ManualTimers();
    nudged = 0;
    nudges = RealtimeNudges(
      ({required onChange, required onStatus}) {
        final feed = _Feed(onChange, onStatus);
        feeds.add(feed);
        return () async => feed.closed = true;
      },
      retryFirst: const Duration(seconds: 1),
      retryMax: const Duration(seconds: 4),
      timer: timers.call,
    );
    sub = nudges.stream().listen((_) => nudged++);
  });
  tearDown(() => sub.cancel());

  test('nudges on every change and on joining; cancel closes', () async {
    expect(feeds, hasLength(1));
    feeds.single
      ..onStatus(FeedStatus.subscribed)
      ..onChange()
      ..onChange();
    await pumpEventQueue();
    expect(nudged, 3);
    await sub.cancel();
    expect(feeds.single.closed, isTrue);
  });

  // Joining is reported before the server's change feed is live; a change
  // in between is never announced, so "live" nudges too (found against the
  // local stack, tool/sync/realtime_live_check_test.dart).
  test('the change feed going live nudges again', () async {
    feeds.single
      ..onStatus(FeedStatus.subscribed)
      ..onStatus(FeedStatus.live);
    await pumpEventQueue();
    expect(nudged, 2);
  });

  test('a rejoin after a drop nudges again (catch-up)', () async {
    feeds.single
      ..onStatus(FeedStatus.subscribed)
      ..onStatus(FeedStatus.timedOut) // the library rejoins this itself
      ..onStatus(FeedStatus.subscribed);
    await pumpEventQueue();
    expect(nudged, 2);
    expect(feeds, hasLength(1));
    expect(timers.pending, isEmpty);
  });

  for (final broken in [FeedStatus.closed, FeedStatus.error]) {
    test('a ${broken.name} feed is replaced and catches up', () async {
      feeds.single
        ..onStatus(FeedStatus.subscribed)
        ..onStatus(broken);
      await pumpEventQueue();
      expect(feeds.first.closed, isTrue);
      expect(feeds, hasLength(1), reason: 'waits before reopening');
      expect(timers.pending.single.wait, const Duration(seconds: 1));
      timers.fireAll();
      expect(feeds, hasLength(2));
      feeds.last.onStatus(FeedStatus.subscribed);
      await pumpEventQueue();
      expect(nudged, 2);
      await sub.cancel();
      expect(feeds.last.closed, isTrue);
    });
  }

  test('the old feed is ignored once replaced', () async {
    final old = feeds.single..onStatus(FeedStatus.closed);
    timers.fireAll();
    old
      ..onChange()
      ..onStatus(FeedStatus.closed);
    await pumpEventQueue();
    expect(nudged, 0);
    expect(feeds, hasLength(2));
    expect(timers.pending, isEmpty);
  });

  test('reopening backs off to the cap, and resets on a join', () {
    final waits = <Duration>[];
    for (var i = 0; i < 5; i++) {
      feeds.last.onStatus(FeedStatus.error);
      waits.add(timers.pending.single.wait);
      timers.fireAll();
    }
    expect(waits.map((w) => w.inSeconds), [1, 2, 4, 4, 4]);
    feeds.last
      ..onStatus(FeedStatus.subscribed)
      ..onStatus(FeedStatus.error);
    expect(timers.pending.single.wait, const Duration(seconds: 1));
  });

  test('cancelling stops a pending reopen', () async {
    feeds.single.onStatus(FeedStatus.error);
    await sub.cancel();
    expect(timers.pending, isEmpty);
    expect(feeds, hasLength(1));
  });
}
