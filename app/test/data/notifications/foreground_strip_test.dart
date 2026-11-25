import 'package:dottoday/data/notifications/foreground_strip.dart';
import 'package:dottoday/data/notifications/notification_platform.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/fake_clock.dart';

// The in-app strip in the apps (E-R2-20 "every platform", ED-468): while the
// app is on screen, each pending reminder shows in the strip at its time; in
// the background nothing is timed here (the OS shows it).

OsNotification _n(
  int id,
  DateTime at, {
  bool loud = false,
  bool silent = false,
  bool alarm = false,
}) => OsNotification(
  id: id,
  title: 'Task $id',
  body: 'Starts in 10 minutes',
  fireAtUtc: at,
  payload: '{}',
  channel: NotificationChannelKind.alerts,
  loud: loud,
  silent: silent,
  alarmClock: alarm,
);

void main() {
  final start = DateTime.utc(2026, 11, 25, 7, 50);

  test('which reminders the strip takes while open', () {
    expect(_n(1, start).stripWhileOpen, isTrue);
    expect(_n(2, start, loud: true).stripWhileOpen, isFalse);
    expect(_n(3, start, alarm: true).stripWhileOpen, isFalse);
    expect(_n(4, start, silent: true).stripWhileOpen, isFalse);
  });

  testWidgets('shows each at its time while open; none past or loud', (
    tester,
  ) async {
    final shown = <int>[];
    final strip = ForegroundStrip(
      pending: () async => [
        _n(1, start.add(const Duration(minutes: 1))),
        _n(2, start.add(const Duration(minutes: 2)), loud: true),
        _n(3, start.subtract(const Duration(minutes: 1))),
      ],
      show: (n) => shown.add(n.id),
      clock: FakeClock(start),
    )..didChangeAppLifecycleState(AppLifecycleState.resumed);
    await tester.pump();
    await tester.pump(const Duration(seconds: 59));
    expect(shown, isEmpty);
    await tester.pump(const Duration(seconds: 2));
    expect(shown, [1]);
    await tester.pump(const Duration(minutes: 5));
    expect(shown, [1], reason: 'loud and past ones stay the system’s');
    strip.dispose();
  });

  testWidgets('inactive still counts as open; leaving calls timers off', (
    tester,
  ) async {
    final shown = <int>[];
    final strip = ForegroundStrip(
      pending: () async => [_n(1, start.add(const Duration(minutes: 2)))],
      show: (n) => shown.add(n.id),
      clock: FakeClock(start),
    )..didChangeAppLifecycleState(AppLifecycleState.inactive);
    await tester.pump();
    strip.didChangeAppLifecycleState(AppLifecycleState.paused);
    await tester.pump(const Duration(minutes: 3));
    expect(shown, isEmpty, reason: 'in the background the OS shows it');
    strip.dispose();
  });

  testWidgets('a changed schedule times again', (tester) async {
    final shown = <int>[];
    var pending = [_n(1, start.add(const Duration(minutes: 1)))];
    final strip = ForegroundStrip(
      pending: () async => pending,
      show: (n) => shown.add(n.id),
      clock: FakeClock(start),
    )..didChangeAppLifecycleState(AppLifecycleState.resumed);
    await tester.pump();
    pending = [_n(2, start.add(const Duration(minutes: 1)))];
    final timed = StripTimedPlatform(_Quiet(), strip);
    await timed.cancel(1);
    await timed.schedule(pending.single);
    await tester.pump();
    await tester.pump(const Duration(minutes: 2));
    expect(shown, [2]);
    strip.dispose();
  });
}

final class _Quiet implements NotificationPlatform {
  @override
  Future<void> cancel(int id) async {}

  @override
  Future<void> clearAll() async {}

  @override
  Future<void> initialize(void Function(NotificationTap) onTap) async {}

  @override
  Future<NotificationTap?> launchTap() async => null;

  @override
  Future<Set<String>> mutedSoundIds() async => const {};

  @override
  Future<List<(int, String?)>> pending() async => const [];

  @override
  Future<void> schedule(OsNotification n) async {}
}
