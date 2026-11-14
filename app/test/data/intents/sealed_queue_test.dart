import 'package:dottoday/domain/intents/dot_action.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/owner_app.dart';
import 'queue_owner_world.dart';

// CR-160 I1 final verification, the app's side of the sealed queue: what
// the native read hands Dart after opening (or failing to open) sealed
// words, and what a store without the key (the background isolate) reads.
// Text that could not be opened is never applied and never dropped;
// opened entries next to it apply as usual; an entry marked unreadable is
// never applied from any plaintext it still carries; entries with no
// owner stay quarantined whatever their words.

const _s1 = '01928c3e-0000-7000-8000-000000000ea1';
const _s2 = '01928c3e-0000-7000-8000-000000000ea2';
const _s3 = '01928c3e-0000-7000-8000-000000000ea3';

/// A share as stored at rest: its words sealed, as a store with no key
/// (the background isolate's) reads it.
Map<String, Object?> _sealedAtRest(String id, {String? owner}) => {
  'id': id,
  'at_ms': ownerAppNow.millisecondsSinceEpoch,
  'kind': 'add_task',
  'shared': true,
  'owner': ?owner,
  'sealed': {'v': 1, 'key': 'dottoday_queue_v1', 'iv': 'AAAA', 'ct': 'AAAA'},
};

/// The same share as the app's read returns it when the key is lost or the
/// words fail to open: kept, marked, no words.
Map<String, Object?> _unreadable(String id, {String? owner}) => {
  ..._sealedAtRest(id, owner: owner),
  'unreadable': true,
};

/// A share the app's read opened.
Map<String, Object?> _opened(String id, String text, {String? owner}) => {
  'id': id,
  'at_ms': ownerAppNow.millisecondsSinceEpoch,
  'kind': 'add_task',
  'shared': true,
  'owner': ?owner,
  'text': text,
};

void main() {
  useQueueWorld();

  test('after a restart, a mixed queue: opened shares apply, unopenable ones '
      'are kept and never applied, across drains and owners', () async {
    queue
      ..appendRaw(_unreadable(_s1, owner: ownerA))
      ..appendRaw(_opened(_s2, 'Dentist', owner: ownerA));
    await drain();
    expect(await ownersOf(_s2), {ownerA});
    expect(await ownersOf(_s1), isEmpty);
    expect(queue.ids, {_s1});
    await app.owners.signOut();
    await drain();
    await app.signIn(ownerA);
    await drain();
    expect(await ownersOf(_s1), isEmpty);
    expect(queue.ids, {_s1}, reason: 'never dropped');
  });

  test('marked unreadable but still carrying text: never applied from that '
      'text (no plaintext fallback), kept', () async {
    queue.appendRaw({..._unreadable(_s1, owner: ownerA), 'text': 'Dentist'});
    expect(
      decodeQueuedAction(queue.entries.single),
      isNull,
      reason: 'unreadable is final',
    );
    await drain();
    expect(await ownersOf(_s1), isEmpty);
    expect(queue.ids, {_s1});
  });

  test('sealed words as the background store reads them (no key): kept, '
      'never applied, never removed', () async {
    queue
      ..appendRaw(_sealedAtRest(_s1, owner: ownerA))
      ..appendRaw(_sealedAtRest(_s2, owner: ownerB));
    for (var i = 0; i < 3; i++) {
      await drain();
    }
    expect(await ownersOf(_s1), isEmpty);
    expect(queue.ids, {_s1, _s2});
  });

  test('no owner: quarantined whether its words opened or not', () async {
    queue
      ..appendRaw(_opened(_s1, 'Dentist'))
      ..appendRaw(_unreadable(_s2))
      ..appendRaw(_sealedAtRest(_s3));
    await drain();
    await app.owners.signOut();
    await drain();
    await app.signIn(ownerB);
    await drain();
    for (final id in [_s1, _s2, _s3]) {
      expect(await ownersOf(id), isEmpty, reason: id);
    }
    expect(queue.ids, {_s1, _s2, _s3});
  });
}
