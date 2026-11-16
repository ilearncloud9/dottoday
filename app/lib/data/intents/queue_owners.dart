import 'package:dottoday/data/db/app_database.dart';
import 'package:dottoday/data/db/owned_local_meta.dart';
import 'package:dottoday/data/sync/guest_sessions.dart';
import 'package:dottoday/domain/intents/action_queue_store.dart';
import 'package:dottoday/domain/intents/dot_action.dart';
import 'package:dottoday/domain/intents/dot_intents.dart';
import 'package:drift/drift.dart';

// Who owns what in the action queue (CR-160 I7): the owner published to the
// surfaces, a task's owner whoever is shown, and a guest share's session.

/// The owner shown now, as the surfaces should stamp it; null when no
/// profile can be shown yet (entries then stay unattributed).
Future<QueueOwner?> shownQueueOwner(AppDatabase db) async {
  final id = await shownOwnerId(db);
  if (id == null) return null;
  return QueueOwner(id, guestSession: await guestSessionFor(db, id));
}

/// The owner of the task or repeat [id], whoever is shown; null if no
/// owner holds it.
Future<String?> taskOwnerOf(AppDatabase db, String id) async {
  final row = await db
      .customSelect(
        'SELECT user_id FROM occurrences WHERE id = ?1 '
        'UNION SELECT user_id FROM series WHERE id = ?1 LIMIT 1',
        variables: [Variable.withString(id)],
        readsFrom: {db.occurrences, db.seriesTable},
      )
      .getSingleOrNull();
  return row?.read<String>('user_id');
}

/// A guest share queued in an earlier guest session counts as that
/// session's work, never the current one's: it can't be brought into an
/// account by whoever uses the device now (policy §3). The write records
/// the current session only where none is recorded yet.
Future<void> keepGuestOrigin(AppDatabase db, QueuedAction queued) async {
  final session = queued.guestSession;
  if (session == null || queued.action is! AddTask) return;
  await db.batch(
    (b) => b.insertAll(db.guestRowSessions, [
      for (final entity in const ['occurrences', 'series'])
        GuestRowSessionsCompanion.insert(
          entity: entity,
          entityId: queued.id,
          session: session,
        ),
    ], mode: InsertMode.insertOrIgnore),
  );
}

/// Removes the queued entries stamped with [owner]: a deleted account's
/// (policy §4: removal takes everything it owns on the device). Other
/// owners' entries and unattributed ones stay.
Future<void> removeQueuedFor(ActionQueueStore store, String owner) async =>
    store.remove(await queuedIdsFor(store, owner));

/// The durable record of an entry dropped for its ownership (CR-160 I7):
/// the action id, its owner and the reason code, nothing of the task it
/// named. Keyed `queue_outcome:<action>:<owner>`, so removing the owner's
/// account removes it too (`finishAccountRemoval` takes every `%:<owner>`).
Future<void> recordQueueOutcome(
  AppDatabase db,
  QueuedAction queued,
  ActionOutcome outcome,
) => db
    .into(db.localMeta)
    .insertOnConflictUpdate(
      LocalMetaCompanion.insert(
        key: queueOutcomeKey(queued.id, queued.owner ?? ''),
        value: outcome.name,
      ),
    );

/// Key of [recordQueueOutcome]'s row.
String queueOutcomeKey(String action, String owner) =>
    'queue_outcome:$action:$owner';

/// Ids of the entries queued for [owner] now, as the queue holds them.
Future<Set<String>> queuedIdsFor(ActionQueueStore store, String owner) async =>
    {
      for (final raw in await store.read())
        if (decodeQueuedAction(raw) case final q? when q.owner == owner) q.id,
    };
