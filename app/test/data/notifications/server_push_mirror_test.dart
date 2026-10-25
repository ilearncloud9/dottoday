import 'dart:convert';
import 'dart:typed_data';

import 'package:dottoday/core/logging/logger.dart';
import 'package:dottoday/data/notifications/notification_platform.dart';
import 'package:dottoday/data/notifications/push/push_store.dart';
import 'package:dottoday/data/notifications/push/server_push_mirror.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/fake_clock.dart';
import '../../support/fake_notification_platform.dart';
import '../../support/memory_log_sink.dart';

final class _Store implements PushStore {
  final rows = <int, PushRow>{};
  var cleared = 0;
  var fail = false;

  void _check() {
    if (fail) throw StateError('offline');
  }

  @override
  Future<String> subscribe(String endpoint) async => 'sub';

  @override
  Future<void> put(String subscriptionId, List<PushRow> put) async {
    _check();
    for (final r in put) {
      rows[r.notificationId] = r;
    }
  }

  @override
  Future<void> remove(String subscriptionId, List<int> ids) async {
    _check();
    ids.forEach(rows.remove);
  }

  @override
  Future<void> clearPending(String subscriptionId) async {
    _check();
    cleared++;
    rows.clear();
  }
}

void main() {
  final when = DateTime.utc(2026, 10, 23, 9);
  late FakeNotificationPlatform inner;
  late _Store store;
  late MemoryLogSink logs;
  PushTarget? target;

  ServerPushMirror mirror() => ServerPushMirror(
    inner: inner,
    target: () async => target,
    store: store,
    // Reversible "encryption" so the test can read what would be pushed.
    encrypt: (plain, p256dh, auth) async =>
        Uint8List.fromList(plain.reversed.toList()),
    doneLabel: 'Done',
    plusLabel: '+15 min',
    logger: Logger(logs, FakeClock(when)),
  );

  OsNotification n(int id, {bool actions = true}) => OsNotification(
    id: id,
    title: 'Gym',
    body: 'Starts in 10 minutes',
    fireAtUtc: when,
    payload: '{"v":1,"o":"x"}',
    channel: NotificationChannelKind.alerts,
    withActions: actions,
  );

  Map<String, Object?> pushed(int id) =>
      jsonDecode(utf8.decode(store.rows[id]!.ciphertext.reversed.toList()))
          as Map<String, Object?>;

  setUp(() {
    inner = FakeNotificationPlatform();
    store = _Store();
    logs = MemoryLogSink();
    target = const PushTarget(subscriptionId: 'sub', p256dh: 'k', auth: 'a');
  });

  test('the tab and the server get the same reminder', () async {
    final m = mirror();
    await m.initialize((_) {});
    await m.schedule(n(7));
    expect(inner.pendingById.keys, [7]);
    expect(store.rows[7]!.plan, '{"v":1,"o":"x"}');
    expect(store.rows[7]!.fireAtUtc, when);
    expect(pushed(7), {
      'id': 7,
      'title': 'Gym',
      'body': 'Starts in 10 minutes',
      'payload': '{"v":1,"o":"x"}',
      'silent': false,
      'actions': [
        {'action': 'done', 'title': 'Done'},
        {'action': 'plus15', 'title': '+15 min'},
      ],
    });
    await m.cancel(7);
    expect(store.rows, isEmpty);
    expect(inner.pendingById, isEmpty);
  });

  test('a fresh tab clears what the server held, then re-plans', () async {
    store.rows[3] = PushRow(
      notificationId: 3,
      fireAtUtc: when,
      plan: 'old',
      ciphertext: Uint8List(1),
    );
    await mirror().initialize((_) {});
    expect(store.cleared, 1);
    expect(store.rows, isEmpty);
  });

  test('signed out or push refused: tab only', () async {
    target = null;
    final m = mirror();
    await m.initialize((_) {});
    await m.schedule(n(7));
    expect(inner.pendingById.keys, [7]);
    expect(store.rows, isEmpty);
    expect(store.cleared, 0);
  });

  test('a server failure is logged and the tab still reminds', () async {
    store.fail = true;
    final m = mirror();
    await m.initialize((_) {});
    await m.schedule(n(7));
    expect(inner.pendingById.keys, [7]);
    expect(
      logs.records.map((r) => r.event),
      everyElement('push.mirror_failed'),
    );
  });

  test('Bedtime has no actions', () async {
    await mirror().schedule(n(9, actions: false));
    expect(pushed(9)['actions'], isEmpty);
  });
}
