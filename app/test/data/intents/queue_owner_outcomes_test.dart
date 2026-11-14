import 'package:dottoday/core/logging/logger.dart';
import 'package:dottoday/data/intents/action_queue_drainer.dart';
import 'package:dottoday/data/intents/queue_owners.dart';
import 'package:dottoday/data/repositories/repository_providers.dart';
import 'package:dottoday/data/writes/write_providers.dart';
import 'package:dottoday/domain/entities/enums.dart';
import 'package:dottoday/domain/intents/dot_action.dart';
import 'package:dottoday/domain/intents/dot_intents.dart';
import 'package:dottoday/domain/profile/local_profile_service.dart';
import 'package:flutter_test/flutter_test.dart';
import '../../support/fake_clock.dart';
import '../../support/owner_app.dart';

import 'queue_owner_world.dart';

// CR-160 I7: what happens to each queued action once its owner is shown —
// applied once, refused and recorded as permanently invalid, kept when its
// content may be the only copy, kept when the database failed, quarantined
// with no owner — and that nothing is lost to a replay or a concurrent append.

const _a = ownerA;
const _b = ownerB;
const _s1 = '01928c3e-0000-7000-8000-0000000003a1';
const _s2 = '01928c3e-0000-7000-8000-0000000003a2';

void main() {
  useQueueWorld();

  test("an action naming another account's task: refused, recorded by ids "
      'and reason, then removed; no task changes', () async {
    await app.owners.signOut();
    await app.signIn(_b);
    queue.append(_s1, MarkDone(a1.id));
    final pushed = (await pushedBy(a1.id)).length;
    await drain();
    expect(
      (await repo.findById(_a, a1.id))!.status,
      isNot(OccurrenceStatus.done),
    );
    expect(await pushedBy(a1.id), hasLength(pushed), reason: 'no write');
    expect(queue.ids, isEmpty);
    final record = await (db.select(
      db.localMeta,
    )..where((m) => m.key.equals(queueOutcomeKey(_s1, _b)))).getSingle();
    expect(record.value, 'droppedForeign');
    // Removing B's account removes its record too.
    expect(queueOutcomeKey(_s1, _b), endsWith(':$_b'));
  });

  test('an Add task whose id another owner holds is kept, never applied '
      '(its text may be the only copy)', () async {
    queue.appendRaw({
      'id': a1.id,
      'at_ms': ownerAppNow.millisecondsSinceEpoch,
      'kind': 'add_task',
      'text': 'Collides',
      'owner': _b,
    });
    await app.owners.signOut();
    await app.signIn(_b);
    await drain();
    expect(await ownersOf(a1.id), {_a});
    expect(queue.ids, {a1.id});
  });

  test('a database failure keeps the entry pending, never terminal', () async {
    queue.append(_s1, MarkDone(a1.id));
    final failing = ActionQueueDrainer(
      store: queue,
      intents: DotIntents(
        clock: FakeClock(ownerAppNow),
        writes: app.container.read(writeUseCaseProvider),
        occurrences: app.container.read(occurrenceRepositoryProvider),
        series: app.container.read(seriesRepositoryProvider),
        profile: () async => freshAccountProfile(_a, 'UTC', 'en', ownerAppNow),
        snapshot: () => throw UnimplementedError(),
        untitled: (_) => 'Untitled',
        ownerOf: (_) => throw StateError('database closed'),
      ),
      logger: Logger(ownerAppLogs, FakeClock(ownerAppNow)),
      shownOwner: () async => _a,
    );
    // a1 is A's, so no owner lookup: drop it to force the lookup.
    queue.appendRaw({
      'id': _s2,
      'at_ms': ownerAppNow.millisecondsSinceEpoch,
      'kind': 'mark_done',
      'occurrence_id': '01928c3e-0000-7000-8000-0000000001ff',
      'owner': _a,
    });
    await expectLater(failing.drain(), throwsStateError);
    expect(queue.ids, containsAll([_s2]));
  });

  test('an entry from an older version (no owner) is kept, never applied, '
      'logged by id', () async {
    queue.appendRaw({
      'id': _s1,
      'at_ms': ownerAppNow.millisecondsSinceEpoch,
      'kind': 'add_task',
      'shared': true,
      'text': 'Dentist',
    });
    await drain();
    await app.owners.signOut();
    await drain();
    expect(await ownersOf(_s1), isEmpty);
    expect(queue.ids, {_s1});
  });

  test('delivered twice, and a crash before the queue was trimmed: '
      'applied once', () async {
    queue
      ..append(_s1, const AddTask('Dentist'))
      ..append(_s1, const AddTask('Dentist'));
    await drain();
    expect(await ownersOf(_s1), {_a});
    final changes = (await pushedBy(_s1)).length;
    // The app died between the write and the trim: the entry is back.
    queue.append(_s1, const AddTask('Dentist'));
    app.container.dispose();
    app = run();
    await drain();
    // The replay wrote nothing: no new change to push.
    expect(await pushedBy(_s1), hasLength(changes));
    expect(queue.ids, isEmpty);
  });

  test('appended while a drain runs: kept, applied by the next one', () async {
    queue
      ..append(_s1, const AddTask('first'))
      ..onRead = () => queue.append(_s2, const AddTask('meanwhile'));
    await drain();
    expect(queue.ids, {_s2});
    await drain();
    expect(await ownersOf(_s2), {_a});
    expect(queue.ids, isEmpty);
  });
}
