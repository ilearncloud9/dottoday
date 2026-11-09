import 'package:dottoday/core/logging/logger.dart';
import 'package:dottoday/data/intents/action_queue_drainer.dart';
import 'package:dottoday/data/intents/queue_owners.dart';
import 'package:dottoday/data/repositories/repository_providers.dart';
import 'package:dottoday/data/sync/account_owners.dart';
import 'package:dottoday/data/writes/write_providers.dart';
import 'package:dottoday/domain/intents/action_queue_store.dart';
import 'package:dottoday/domain/intents/dot_action.dart';
import 'package:dottoday/domain/intents/dot_intents.dart';
import 'package:dottoday/domain/profile/local_profile_service.dart';
import 'package:flutter_test/flutter_test.dart';
import '../../support/fake_clock.dart';
import '../../support/owner_app.dart';

import 'queue_owner_world.dart';

// CR-160 I7: an action a widget, Siri, the Live Activity, the service
// worker or the share extension queues keeps the owner it was queued under,
// across changes of owner, restarts, guest sessions and account deletion.
// It is applied only for that owner, only while shown, exactly once.

const _a = ownerA;
const _b = ownerB;
const _s1 = '01928c3e-0000-7000-8000-0000000003a1';
const _s2 = '01928c3e-0000-7000-8000-0000000003a2';
const _s3 = '01928c3e-0000-7000-8000-0000000003a3';
const _s4 = '01928c3e-0000-7000-8000-0000000003a4';

void main() {
  useQueueWorld();

  test('the app publishes the owner shown, and nobody during a switch', () {
    // A's sign-in: nobody while the owner changed, then A.
    expect(
      queue.published.map((m) => m is QueueOwner ? m.id : m.runtimeType),
      containsAllInOrder([QueueSwitching, _a]),
    );
    expect((queue.published.last as QueueOwner).guestSession, isNull);
  });

  test('a share queued for A, drained after A left and B signed in: never '
      "B's, kept, applied for A once A is back", () async {
    // Shared while A was shown; the drain at the switch read the queue a
    // moment before it landed.
    queue.onRead = () =>
        queue.append(_s1, const AddTask('Dentist', inbox: true));
    await app.owners.signOut();
    await app.signIn(_b);
    await drain();
    expect(await ownersOf(_s1), isEmpty);
    expect(queue.ids, {_s1});
    await app.owners.signOut();
    await app.signIn(_a);
    expect((await made(_a, _s1))?.title, 'Dentist');
    expect(await pushedBy(_s1), everyElement(_a));
    expect(queue.ids, isEmpty);
  });

  test('a share in the middle of the change of owner is kept and never '
      'applied to anyone', () async {
    queue.onPublish = (marker) {
      if (marker is QueueSwitching) queue.append(_s1, const AddTask('Dentist'));
    };
    await app.owners.signOut();
    queue.onPublish = null;
    await app.signIn(_b);
    await app.owners.signOut();
    await app.signIn(_a);
    await drain();
    expect(await ownersOf(_s1), isEmpty);
    expect(queue.ids, {_s1});
    expect(
      ownerAppLogs.records.map((r) => r.event),
      contains('intent.unattributed'),
    );
  });

  test('a share queued with the app closed lands with the owner it was '
      'stamped with, after a restart', () async {
    app.container.dispose();
    queue.append(_s1, const AddTask('Dentist', inbox: true));
    app = run();
    await app.shown();
    await app.owners.publishShownOwner();
    await drain();
    expect((await made(_a, _s1))?.title, 'Dentist');
    expect(queue.ids, isEmpty);
  });

  test('closed app, then the next person signs in first: the share waits '
      'for A', () async {
    app.container.dispose();
    queue.append(_s1, const AddTask('Dentist', inbox: true));
    app = run();
    await app.owners.signOut();
    // The switch's own drain applied it for A before A left.
    expect((await made(_a, _s1))?.title, 'Dentist');
    queue.append(_s2, const AddTask('Guest list'));
    await app.signIn(_b); // the guest's share: B is asked (G1), nothing moves
    expect(await ownersOf(_s2), {await app.shown()});
    expect(await made(_b, _s2), isNull);
  });

  test('a check made before a switch never writes after it: the write\'s '
      'own transaction refuses, the action waits for A', () async {
    await app.owners.signOut();
    queue.appendRaw({
      'id': _s1,
      'at_ms': ownerAppNow.millisecondsSinceEpoch,
      'kind': 'add_task',
      'text': 'Dentist',
      'owner': _a,
    });
    // A drain that still believes A is shown, with A's profile cached:
    // both checks before the write pass, the commit must not.
    final c = app.container;
    final stale = ActionQueueDrainer(
      store: queue,
      intents: DotIntents(
        clock: FakeClock(ownerAppNow),
        writes: c.read(writeUseCaseProvider),
        occurrences: c.read(occurrenceRepositoryProvider),
        series: c.read(seriesRepositoryProvider),
        profile: () async => freshAccountProfile(_a, 'UTC', 'en', ownerAppNow),
        snapshot: () => throw UnimplementedError(),
        untitled: (_) => 'Untitled',
        ownerOf: (id) => taskOwnerOf(db, id),
      ),
      logger: Logger(ownerAppLogs, FakeClock(ownerAppNow)),
      shownOwner: () async => _a,
    );
    await stale.drain();
    expect(await ownersOf(_s1), isEmpty);
    expect(queue.ids, {_s1});
    expect(
      ownerAppLogs.records.map((r) => r.event),
      contains('write.owner_not_shown'),
    );
    await app.signIn(_a);
    expect(await ownersOf(_s1), {_a});
    expect(queue.ids, isEmpty);
  });

  test('A, guest, B, A in quick turns: each share lands with its own '
      'owner, once', () async {
    queue.append(_s1, const AddTask('A1'));
    await app.owners.signOut();
    final guest = await app.shown();
    queue.append(_s2, const AddTask('G1'));
    await recordGuestChoice(db, _b, GuestChoice.keepSeparate);
    await app.signIn(_b);
    queue.append(_s3, const AddTask('B1'));
    await app.owners.signOut();
    await app.signIn(_a);
    queue.append(_s4, const AddTask('A2'));
    await drain();
    await drain(); // twice: still once
    expect(await ownersOf(_s1), {_a});
    expect(await ownersOf(_s2), {guest});
    expect(await ownersOf(_s3), {_b});
    expect(await ownersOf(_s4), {_a});
    for (final (id, owner) in [(_s1, _a), (_s2, guest), (_s3, _b), (_s4, _a)]) {
      expect(await pushedBy(id), everyElement(owner), reason: id);
    }
    expect(queue.ids, isEmpty);
  });

  test('mixed owners: an inactive owner ahead in the queue holds nothing '
      'up and keeps its place', () async {
    await app.owners.signOut();
    await app.signIn(_b);
    // B's queue: A's share (stamped A earlier) sits ahead of B's.
    queue
      ..appendRaw({
        'id': _s1,
        'at_ms': ownerAppNow.millisecondsSinceEpoch,
        'kind': 'add_task',
        'text': 'A first',
        'owner': _a,
      })
      ..append(_s2, const AddTask('B next'));
    await drain();
    expect(await ownersOf(_s1), isEmpty);
    expect(await ownersOf(_s2), {_b});
    expect(queue.ids, {_s1});
  });

  test("a guest share from an earlier guest session stays that session's "
      'work: never brought into the next account', () async {
    await app.owners.signOut();
    final guest = await app.shown();
    // Queued for the guest, but drained only after the guest session
    // ended (a sign-in and a sign-out since).
    queue.onRead = () => queue.append(_s1, const AddTask('Old guest share'));
    await app.signIn(_b);
    await app.owners.signOut();
    await drain();
    expect(await ownersOf(_s1), {guest});
    await recordGuestChoice(db, _a, GuestChoice.bringIn);
    expect(await app.signInAs(_a), isNot(OwnerChange.guestChoiceNeeded));
    expect(await ownersOf(_s1), {guest}, reason: 'never eligible');
  });

  test(
    "deleting an account removes its queued actions, nobody else's",
    () async {
      await app.owners.signOut();
      final guest = await app.shown();
      queue.append(_s2, const AddTask('Guest'));
      await recordGuestChoice(db, _b, GuestChoice.keepSeparate);
      await app.signIn(_b);
      queue.onRead = () => queue.append(_s1, const AddTask('B left this'));
      queue.appendRaw({'id': _s3, 'kind': 'add_task'}); // unreadable
      await app.owners.accountDeleted(_b);
      expect(await ownersOf(_s1), isEmpty);
      expect(queue.ids, isNot(contains(_s1)));
      expect(await ownersOf(_s2), {guest});
      expect(queue.ids, contains(_s3), reason: 'unreadable stays');
    },
  );
}
