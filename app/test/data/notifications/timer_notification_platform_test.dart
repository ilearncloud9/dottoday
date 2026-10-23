import 'package:dottoday/data/notifications/notification_platform.dart';
import 'package:dottoday/data/notifications/timer_notification_platform.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/fake_clock.dart';

void main() {
  final start = DateTime.utc(2026, 10, 23, 9);

  OsNotification n(int id, int minutes, {bool silent = false}) =>
      OsNotification(
        id: id,
        title: 'Gym',
        body: 'Starts in 10 minutes',
        fireAtUtc: start.add(Duration(minutes: minutes)),
        payload: '{"v":1}',
        channel: NotificationChannelKind.alerts,
        silent: silent,
      );

  // testWidgets runs in fake time: pump moves the Timers on.
  testWidgets('posts each at its time, once; cancelled ones never', (
    tester,
  ) async {
    final clock = FakeClock(start);
    final shown = <int>[];
    final platform = TimerNotificationPlatform(
      clock: clock,
      show: (x) async {
        shown.add(x.id);
        return true;
      },
      onInApp: (_) => fail('permission was granted'),
    );
    await platform.schedule(n(1, 5));
    await platform.schedule(n(2, 10));
    await platform.schedule(n(2, 10));
    await platform.schedule(n(3, 15));
    await platform.cancel(3);
    await tester.pump(const Duration(minutes: 6));
    expect(shown, [1]);
    await tester.pump(const Duration(minutes: 20));
    expect(shown, [1, 2]);
    expect(await platform.pending(), isEmpty);
  });

  testWidgets('without permission, or in quiet hours, it goes in-app', (
    tester,
  ) async {
    final inApp = <int>[];
    final platform = TimerNotificationPlatform(
      clock: FakeClock(start),
      show: (_) async => false,
      onInApp: (x) => inApp.add(x.id),
    );
    await platform.schedule(n(1, 1));
    await platform.schedule(n(2, 2, silent: true));
    await tester.pump(const Duration(minutes: 3));
    expect(inApp, [1, 2]);
  });

  test('a time already past is dropped; pending lists the rest', () async {
    final platform = TimerNotificationPlatform(
      clock: FakeClock(start),
      show: (_) async => true,
      onInApp: (_) {},
    );
    await platform.schedule(n(1, -1));
    await platform.schedule(n(2, 30));
    expect(await platform.pending(), [(2, '{"v":1}')]);
    await platform.cancel(2);
  });

  test('taps from the service worker reach the handler', () async {
    final taps = Stream.value(const NotificationTap(id: 4, actionId: 'done'));
    final platform = TimerNotificationPlatform(
      clock: FakeClock(start),
      show: (_) async => true,
      onInApp: (_) {},
      taps: taps,
    );
    final got = <NotificationTap>[];
    await platform.initialize(got.add);
    await Future<void>.delayed(Duration.zero);
    expect(got.single.actionId, 'done');
    expect(await platform.launchTap(), isNull);
  });
}
