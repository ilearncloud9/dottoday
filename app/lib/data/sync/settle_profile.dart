import 'package:dottoday/data/db/app_database.dart';
import 'package:dottoday/data/db/owner_meta.dart';
import 'package:dottoday/data/sync/pull_guard.dart';
import 'package:dottoday/data/sync/sync_gateway.dart';
import 'package:drift/drift.dart';

/// An account's first sync on this device (docs/09 M6.4, CR-160
/// criterion 7): when the account already has settings on the server,
/// they stay. The profile pending here (a fresh device's defaults, or the
/// current guest's settings) is not pushed over them; the guest's stay
/// kept for an explicit choice (B1). A new account (no settings yet) takes
/// this device's profile, so there is nothing to choose. One transaction;
/// a run that fails later finds the outbox already settled.
Future<void> settleProfile(
  AppDatabase db,
  SyncGateway gateway,
  PullOwner owner,
) async {
  final userId = owner.userId;
  final server = (await gateway.fieldVersions('profiles', [userId]))[userId];
  final hasSettings = server != null && server.isNotEmpty;
  await db.transaction(() async {
    await checkPull(db, owner);
    if (!hasSettings) {
      await (db.delete(
        db.localMeta,
      )..where((m) => m.key.equals(guestSettingsKey(userId)))).go();
      return;
    }
    await (db.delete(db.changeLog)..where(
          (c) =>
              c.ownerId.equals(userId) &
              c.entity.equals('profiles') &
              c.entityId.equals(userId),
        ))
        .go();
  });
}
