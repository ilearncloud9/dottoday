import 'dart:convert';

import 'package:dottoday/data/intents/home_widget_action_queue_store.dart';
import 'package:dottoday/data/intents/native_action_queue_store.dart';
import 'package:dottoday/domain/intents/action_queue_store.dart';
import 'package:dottoday/domain/intents/dot_action.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

// CR-160 I1, Q2 on a real Android device or emulator: queued words are
// sealed with the Android Keystore before they reach the shared
// preferences, opened only when the app reads the queue, migrated from an
// earlier version's plaintext in place, and never lost or re-attributed
// when a key is missing, wrong or the metadata was changed. Runs through
// the app's own channel (debug-build hooks for setup only).
//
//   flutter test integration_test/queue_cipher_test.dart -d <android>

const _channel = MethodChannel('dottoday/intents');
const _a = '01928c3e-0000-7000-8000-00000000000a';
const _b = '01928c3e-0000-7000-8000-00000000000b';

Future<String?> raw() => _channel.invokeMethod<String>('debugRawQueue');
Future<void> writeRaw(Object entries) =>
    _channel.invokeMethod('debugWriteRawQueue', {'raw': jsonEncode(entries)});
Future<bool> share(String text, {String? subject, String? alias}) async =>
    (await _channel.invokeMethod<bool>('debugShare', {
      'text': text,
      'subject': ?subject,
      'alias': ?alias,
    }))!;
Future<List<Map<String, Object?>>> opened() async => [
  for (final e
      in jsonDecode(await _channel.invokeMethod<String>('readQueue') ?? '[]')
          as List)
    e as Map<String, Object?>,
];
List<Map<String, Object?>> stored(String? r) => [
  for (final e in jsonDecode(r ?? '[]') as List) e as Map<String, Object?>,
];

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  const store = NativeActionQueueStore();

  setUp(() async {
    await writeRaw(const []);
    await store.publish(const QueueOwner(_a));
  });

  testWidgets('a share is sealed at rest, opened for the app, owner kept', (
    _,
  ) async {
    expect(await share('Secret plan', subject: 'Page title'), isTrue);
    final r = await raw();
    expect(r, isNot(contains('Secret plan')));
    expect(r, isNot(contains('Page title')));
    final e = stored(r).single;
    expect(e['sealed'], isA<Map<String, Object?>>());
    expect(e['owner'], _a);
    final app = (await opened()).single;
    expect(
      (app['text'], app['subject'], app['owner']),
      ('Secret plan', 'Page title', _a),
    );
    expect(app.containsKey('sealed'), isFalse);
    final action = decodeQueuedAction(app)!;
    expect(action.owner, _a);
    expect(action.action, isA<AddTask>());
  });

  testWidgets('every seal has its own nonce', (_) async {
    await share('Same words');
    await share('Same words');
    final seals = [
      for (final e in stored(await raw())) e['sealed']! as Map<String, Object?>,
    ];
    expect(seals[0]['iv'], isNot(seals[1]['iv']));
    expect(seals[0]['ct'], isNot(seals[1]['ct']));
  });

  testWidgets('an earlier version\'s plaintext is sealed in place on the '
      'first read, ids, times and owners unchanged; idempotent', (_) async {
    final legacy = [
      {
        'id': '01928c3e-0000-7000-8000-0000000009a1',
        'at_ms': 1,
        'kind': 'add_task',
        'shared': true,
        'text': 'Old share',
        'owner': _a,
      },
      {
        'id': '01928c3e-0000-7000-8000-0000000009a2',
        'at_ms': 2,
        'kind': 'add_task',
        'shared': true,
        'text': 'No owner',
      },
      {
        'id': '01928c3e-0000-7000-8000-0000000009a3',
        'at_ms': 3,
        'kind': 'mark_done',
        'occurrence_id': '01928c3e-0000-7000-8000-0000000009b1',
        'owner': _b,
      },
    ];
    await writeRaw(legacy);
    final app = await opened();
    final r = await raw();
    expect(r, isNot(contains('Old share')));
    expect(r, isNot(contains('No owner')));
    final kept = stored(r);
    expect(
      [for (final e in kept) (e['id'], e['at_ms'], e['owner'])],
      [for (final e in legacy) (e['id'], e['at_ms'], e['owner'])],
    );
    expect(kept[2].containsKey('sealed'), isFalse, reason: 'ids only');
    expect([for (final e in app) e['text']], ['Old share', 'No owner', null]);
    expect(app[1].containsKey('owner'), isFalse, reason: 'never attributed');
    await opened();
    expect(await raw(), r, reason: 'idempotent');
  });

  testWidgets('a changed owner stamp no longer opens: kept, unreadable, '
      'never applied', (_) async {
    await share('Secret plan');
    final e = stored(await raw()).single..['owner'] = _b;
    await writeRaw([e]);
    final app = (await opened()).single;
    expect(app['unreadable'], isTrue);
    expect(app.containsKey('text'), isFalse);
    expect(decodeQueuedAction(app), isNull, reason: 'never applied');
    expect(stored(await raw()), hasLength(1), reason: 'never erased');
  });

  testWidgets('a lost key keeps the entries unreadable; new shares use a '
      'new key', (_) async {
    await share('Before');
    await _channel.invokeMethod('debugDeleteKey');
    final app = await opened();
    expect(app.single['unreadable'], isTrue);
    expect(await share('After'), isTrue);
    final now = await opened();
    expect(now, hasLength(2));
    expect(now[0]['unreadable'], isTrue);
    expect(now[1]['text'], 'After');
  });

  testWidgets('rotation: entries under the old and new keys both open', (
    _,
  ) async {
    await share('Old key');
    await share('New key', alias: 'dottoday_queue_test_v2');
    final app = await opened();
    expect([for (final e in app) e['text']], ['Old key', 'New key']);
    await _channel.invokeMethod('debugDeleteKey', {
      'alias': 'dottoday_queue_test_v2',
    });
  });

  testWidgets('a full queue, or an account being deleted, refuses a share '
      'with nothing stored', (_) async {
    await writeRaw([
      for (var i = 0; i < 500; i++)
        {
          'id': '01928c3e-0000-7000-8000-${i.toString().padLeft(12, '0')}',
          'at_ms': i,
          'kind': 'mark_done',
          'occurrence_id': '01928c3e-0000-7000-8000-0000000009b1',
        },
    ]);
    final before = await raw();
    expect(await share('One too many'), isFalse);
    expect(await raw(), before);
    await writeRaw(const []);
    await store.publish(const QueueRefusing());
    expect(await share('While deleting'), isFalse);
    expect(stored(await raw()), isEmpty);
  });

  testWidgets('the background store (no channel) leaves sealed words alone: '
      'unreadable there, still queued for the app', (_) async {
    await share('Secret plan');
    final background = await const HomeWidgetActionQueueStore().read();
    expect(decodeQueuedAction(background.single), isNull);
    expect((await opened()).single['text'], 'Secret plan');
  });
}
