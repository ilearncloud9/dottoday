import 'dart:convert';

import 'package:dottoday/data/sync/server_clock.dart';
import 'package:dottoday/data/sync/sync_engine.dart';
import 'package:dottoday/domain/sync/clock_skew.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest.dart' as tz_data;

import '../../domain/fixtures.dart';
import '../../support/fake_clock.dart';
import '../../support/fake_sync_server.dart';
import '../../support/sync_device.dart';

// A device clock more than 5 min off (docs/09 M6.5.7, 11 A0): pulls go on,
// a fast clock's pushes wait instead of "Sync paused", and resume once it
// is right.

const _account = '01928c3e-0000-7000-8000-0000000000ff';
final _t = DateTime.utc(2026, 10, 23, 9);

String _jwt(DateTime iat) {
  String part(Object json) =>
      base64Url.encode(utf8.encode(jsonEncode(json))).replaceAll('=', '');
  return '${part({'alg': 'HS256'})}.'
      '${part({'iat': iat.millisecondsSinceEpoch ~/ 1000})}.sig';
}

void main() {
  setUpAll(tz_data.initializeTimeZones);

  late FakeSyncServer server;
  late SyncDevice phone;
  late SyncDevice mac;
  Duration? offset;
  late SyncEngine engine;

  setUp(() async {
    server = FakeSyncServer(_account);
    phone = SyncDevice(server, _t, name: 'phone');
    mac = SyncDevice(server, _t, name: 'mac');
    await phone.start();
    await mac.start();
    offset = null;
    engine = SyncEngine(
      db: phone.h.db,
      gateway: server.forDevice(),
      hlc: phone.h.hlc,
      clock: phone.h.clock,
      clockOffset: () => offset,
    );
  });
  tearDown(() async {
    await phone.close();
    await mac.close();
  });

  final task = occurrenceFixture().copyWith(userId: _account, title: 'Run');

  test('+4 min: within the bound, everything as usual', () async {
    offset = const Duration(minutes: 4);
    await phone.write([task]);
    final run = await engine.run(_account);
    expect(run.skew, isNull);
    expect(run.pushed, greaterThan(0));
    expect(await phone.outboxSize(), 0);
  });

  test('+6 min: pulls arrive, pushes wait, nothing is refused', () async {
    await mac.write([task.copyWith(title: 'From the Mac')]);
    await mac.sync();
    offset = const Duration(minutes: 6);
    const mine = '01928c3e-0000-7000-8000-0000000000e1';
    await phone.write([task.copyWith(id: mine, title: 'Mine')]);

    final run = await engine.run(_account);

    expect(run.skew?.fast, isTrue);
    expect(run.skew?.minutes, 6);
    expect(run.pushed, 0);
    // Kept for later, not refused or dropped.
    expect(await phone.outboxSize(), greaterThan(0));
    expect(server.table('occurrences').containsKey(mine), isFalse);
    expect((await phone.occurrence(mine))!.title, 'Mine');
    expect((await phone.occurrence(task.id))!.title, 'From the Mac');

    // Clock corrected: the next round sends what waited.
    offset = Duration.zero;
    final next = await engine.run(_account);
    expect(next.skew, isNull);
    expect(next.pushed, greaterThan(0));
    expect(await phone.outboxSize(), 0);
    expect(server.table('occurrences'), hasLength(2));
  });

  test('−6 min: pushes go (the past is accepted), skew is reported', () async {
    offset = const Duration(minutes: -6);
    await phone.write([task]);
    final run = await engine.run(_account);
    expect(run.skew?.fast, isFalse);
    expect(run.skew?.minutes, 6);
    expect(run.pushed, greaterThan(0));
  });

  group('ServerClock', () {
    test('reads the offset from a fresh token\'s iat', () {
      final clock = FakeClock(_t);
      final server = ServerClock(clock)
        ..record(_jwt(_t.subtract(const Duration(minutes: 7))));
      expect(server.offset, const Duration(minutes: 7));
      expect(ClockSkew.of(server.offset)?.fast, isTrue);
    });

    test('an unreadable token leaves the offset unknown', () {
      final server = ServerClock(FakeClock(_t))
        ..record('not-a-jwt')
        ..record('a.%%%.c');
      expect(server.offset, isNull);
    });
  });

  test('ClockSkew rounds to minutes and ignores ≤ 5 min', () {
    expect(ClockSkew.of(const Duration(minutes: 5)), isNull);
    expect(ClockSkew.of(null), isNull);
    expect(ClockSkew.of(const Duration(minutes: 7, seconds: 40))!.minutes, 8);
  });
}
