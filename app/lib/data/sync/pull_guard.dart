/// What a sync pull must re-establish inside every transaction that writes
/// pulled data (CR-160 W1, W4): the account is still the one shown, in the
/// same owner session the pull began in, not sealed for deletion and not
/// being removed. One guard for the foreground engine and the background
/// isolate's: both run [SyncEngine] on their own connection, and SQLite
/// orders their transactions against the owner flips (serializable), so a
/// page is either committed before a flip or refused after it, cursor and
/// all.
library;

import 'package:dottoday/data/db/app_database.dart';
import 'package:dottoday/data/owners/deletion_seal.dart';
import 'package:dottoday/data/sync/account_owners.dart';
import 'package:drift/drift.dart';

/// Moves every time the shown owner actually changes (sign-in as another
/// owner, sign-out, the start of an account removal), in the same
/// transaction as the change. Durable, so the background isolate sees it
/// too: A → B → A is a new session even though A is shown again.
const ownerGenerationKey = 'owner_generation';

/// The owner session a pull belongs to.
typedef PullOwner = ({String userId, int generation});

/// Why a pull was refused (an enum, so logs can carry it: never content).
enum PullRefusal { ownerChanged, sealed, removalPending, foreignRow }

/// A pull for an owner no longer shown in the session it began in, being
/// deleted or removed, or a pulled row that isn't that owner's: refused,
/// and the transaction it was raised in (page, cursor, revision) rolls back.
final class PullRefusedException implements Exception {
  const PullRefusedException(this.reason);

  final PullRefusal reason;

  @override
  String toString() => 'PullRefusedException($reason)';
}

/// The owner generation now (0 before any change was recorded).
Future<int> ownerGeneration(AppDatabase db) async =>
    int.tryParse(await _get(db, ownerGenerationKey) ?? '') ?? 0;

/// Inside the caller's transaction: the shown owner changed.
Future<void> bumpOwnerGeneration(AppDatabase db) async {
  final next = await ownerGeneration(db) + 1;
  await db
      .into(db.localMeta)
      .insertOnConflictUpdate(
        LocalMetaCompanion.insert(key: ownerGenerationKey, value: '$next'),
      );
}

/// The session a pull for [userId] starts in, or throws
/// [PullRefusedException] when [userId] isn't the shown, live account.
Future<PullOwner> beginPull(AppDatabase db, String userId) =>
    db.transaction(() async {
      final generation = await ownerGeneration(db);
      final owner = (userId: userId, generation: generation);
      await checkPull(db, owner);
      return owner;
    });

/// [beginPull], or null when [userId] isn't the shown, live account.
Future<PullOwner?> ownerSessionOrNull(AppDatabase db, String userId) async {
  try {
    return await beginPull(db, userId);
  } on PullRefusedException {
    return null;
  }
}

/// Inside the caller's transaction, before it writes anything pulled:
/// throws [PullRefusedException] unless [owner] is still shown in the same
/// session, not sealed for deletion and not being removed.
Future<void> checkPull(AppDatabase db, PullOwner owner) async {
  try {
    await checkNotSealed(db, owner.userId);
  } on OwnerSealedException {
    throw const PullRefusedException(PullRefusal.sealed);
  }
  if (await isRemovalPending(db, owner.userId)) {
    throw const PullRefusedException(PullRefusal.removalPending);
  }
  if (await activeOwnerId(db) != owner.userId ||
      await ownerGeneration(db) != owner.generation) {
    throw const PullRefusedException(PullRefusal.ownerChanged);
  }
}

/// Inside the caller's transaction: throws [PullRefusedException] when the
/// pulled [remote] row of [entity] names another owner, or its id is
/// already another owner's row on this device. Never attributed to anyone.
Future<void> checkPulledRow(
  AppDatabase db,
  String entity,
  String userId,
  Map<String, Object?> remote,
) async {
  final id = remote['id'];
  final named = entity == 'profiles' ? id : remote['user_id'];
  if (id is! String || named != userId) {
    throw const PullRefusedException(PullRefusal.foreignRow);
  }
  final ownerColumn = entity == 'profiles' ? 'id' : 'user_id';
  final held = await db
      .customSelect(
        'SELECT $ownerColumn AS owner FROM $entity WHERE id = ?',
        variables: [Variable<String>(id)],
      )
      .getSingleOrNull();
  if (held != null && held.read<String>('owner') != userId) {
    throw const PullRefusedException(PullRefusal.foreignRow);
  }
}

Future<String?> _get(AppDatabase db, String key) async => (await (db.select(
  db.localMeta,
)..where((m) => m.key.equals(key))).getSingleOrNull())?.value;
